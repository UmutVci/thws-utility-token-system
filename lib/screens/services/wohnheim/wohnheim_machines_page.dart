import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../../config/contracts.dart';
import '../../../layout/app_bottom_nav.dart';
import '../../../layout/main_layout.dart';
import '../../../models/transaction_item.dart';
import '../../../services/transaction_history_service.dart';
import '../../../services/wallet_connect_singleton.dart';
import 'widgets/wohnheim_standorte_section.dart';

class WohnheimMachinesPage extends StatefulWidget {
  final String title;
  final String address;
  final List<MachineGroup> groups;

  const WohnheimMachinesPage({
    super.key,
    required this.title,
    required this.address,
    required this.groups,
  });

  @override
  State<WohnheimMachinesPage> createState() => _WohnheimMachinesPageState();
}

class _WohnheimMachinesPageState extends State<WohnheimMachinesPage> {
  static const int _priceMinor = 150; // 1,50 THWS mit 2 Nachkommastellen
  static final BigInt _maxUint256 = BigInt.parse(
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
    radix: 16,
  );

  final _wcService = walletConnectService;
  final _historyService = transactionHistoryService;

  final Map<String, int> _lockedUntilByLabel = {};
  final Set<String> _pendingMachines = {};
  late final Future<ContractAbi> _tokenAbiFuture;
  late final Future<ContractAbi> _pmAbiFuture;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tokenAbiFuture = _loadAbi('assets/abi/THWSToken.json', 'THWSToken');
    _pmAbiFuture = _loadAbi('assets/abi/PaymentManager.json', 'PaymentManager');
    _wcService.init();
    _wcService.resyncActiveSession();
    _historyService.init();

    _refreshLocks();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshLocks();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Uint8List _bytes32(String value) {
    final bytes = utf8.encode(value);
    final out = Uint8List(32);
    final len = bytes.length > 32 ? 32 : bytes.length;
    out.setRange(0, len, bytes.take(len));
    return out;
  }

  int _machineIdForMachine(MachineInfo machine) {
    final match = RegExp(r'(\d+)').firstMatch(machine.label);
    final number = match == null ? 1 : (int.tryParse(match.group(1)!) ?? 1);

    // Waschmaschinen und Trockner dürfen auf der Chain nicht dieselbe ID teilen.
    if (machine.type == 'Trockner') {
      return 100 + number;
    }
    return number;
  }

  String _dormCodeForTitle(String title) {
    final normalized = title
        .toUpperCase()
        .replaceAll('Ä', 'AE')
        .replaceAll('Ö', 'OE')
        .replaceAll('Ü', 'UE')
        .replaceAll('ß', 'SS')
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (normalized.isEmpty) return 'DORM';
    return normalized.length <= 12 ? normalized : normalized.substring(0, 12);
  }

  String _subtitleForTransaction(String? txHash, DateTime at) {
    final dd = at.day.toString().padLeft(2, '0');
    final mm = at.month.toString().padLeft(2, '0');
    final hh = at.hour.toString().padLeft(2, '0');
    final mi = at.minute.toString().padLeft(2, '0');
    final hashPart = (txHash != null && txHash.length >= 10)
        ? ' • ${txHash.substring(0, 10)}...'
        : '';
    return '$dd.$mm $hh:$mi$hashPart';
  }

  Future<ContractAbi> _loadAbi(String assetPath, String name) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final abiJson = jsonEncode(decoded['abi']);
    return ContractAbi.fromJson(abiJson, name);
  }

  Future<bool> _openMetaMask() async {
    final primary = Uri.parse('metamask://');
    final fallback = Uri.parse('https://metamask.app.link/');

    final openedPrimary = await launchUrl(
      primary,
      mode: LaunchMode.externalApplication,
    );
    if (openedPrimary) return true;

    return launchUrl(
      fallback,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _refreshLocks() async {
    if (!_wcService.isConnected || _wcService.connectedAddress == null) {
      return;
    }

    try {
      final pmAbi = await _pmAbiFuture;
      final pmContract = DeployedContract(
        pmAbi,
        EthereumAddress.fromHex(ContractsConfig.paymentManager),
      );
      final lockFn = pmContract.function('getMachineLockedUntil');

      final client = Web3Client(ContractsConfig.rpcUrl, http.Client());
      try {
        final dormCode = _dormCodeForTitle(widget.title);
        final next = <String, int>{};
        for (final group in widget.groups) {
          for (final machine in group.machines) {
            final machineId = _machineIdForMachine(machine);
            final result = await client.call(
              contract: pmContract,
              function: lockFn,
              params: [
                _bytes32(dormCode),
                BigInt.from(machineId),
              ],
            );
            if (result.isNotEmpty && result.first is BigInt) {
              next[machine.label] = (result.first as BigInt).toInt();
            }
          }
        }

        if (!mounted) return;
        setState(() {
          _lockedUntilByLabel
            ..clear()
            ..addAll(next);
        });
      } finally {
        client.dispose();
      }
    } catch (_) {
      // Letzten bekannten Schlosszustand bei RPC-Fehler beibehalten.
    }
  }

  Future<void> _payLaundry(MachineInfo machine) async {
    if (!_wcService.isConnected || _wcService.connectedAddress == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte zuerst Wallet verbinden.')),
      );
      return;
    }

    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final lockedUntil = _lockedUntilByLabel[machine.label] ?? 0;
    if (lockedUntil > nowSec) {
      if (!mounted) return;
      final dt = DateTime.fromMillisecondsSinceEpoch(lockedUntil * 1000);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Maschine ist belegt bis ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}')),
      );
      return;
    }

    final label = machine.label;
    setState(() => _pendingMachines.add(label));

    try {
      // MetaMask'ı olabildiğince erken öne getir, kullanıcı beklemesin.
      await _openMetaMask();
      await _wcService.ensureSepoliaChain();

      final tokenAbi = await _tokenAbiFuture;
      final pmAbi = await _pmAbiFuture;

      final tokenContract = DeployedContract(
        tokenAbi,
        EthereumAddress.fromHex(ContractsConfig.token),
      );
      final pmContract = DeployedContract(
        pmAbi,
        EthereumAddress.fromHex(ContractsConfig.paymentManager),
      );

      final dormCode = _dormCodeForTitle(widget.title);
      final machineId = _machineIdForMachine(machine);

      final approveFn = tokenContract.function('approve');
      final allowanceFn = tokenContract.function('allowance');
      final approveData = bytesToHex(
        approveFn.encodeCall([
          EthereumAddress.fromHex(ContractsConfig.paymentManager),
          _maxUint256,
        ]),
        include0x: true,
      );

      final payLaundryFn = pmContract.function('payLaundry');
      final payData = bytesToHex(
        payLaundryFn.encodeCall([
          _bytes32(dormCode),
          BigInt.from(machineId),
        ]),
        include0x: true,
      );

      final allowanceClient = Web3Client(ContractsConfig.rpcUrl, http.Client());
      final allowanceResult = await allowanceClient.call(
        contract: tokenContract,
        function: allowanceFn,
        params: [
          EthereumAddress.fromHex(_wcService.connectedAddress!),
          EthereumAddress.fromHex(ContractsConfig.paymentManager),
        ],
      );
      allowanceClient.dispose();
      final allowance = allowanceResult.isNotEmpty && allowanceResult.first is BigInt
          ? allowanceResult.first as BigInt
          : BigInt.zero;

      if (allowance < BigInt.from(_priceMinor)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warte auf Freigabe in MetaMask...')),
        );
        await _openMetaMask();
        final approveFuture = _wcService
            .sendTransaction(
              to: ContractsConfig.token,
              data: approveData,
            )
            .timeout(const Duration(seconds: 90));
        await approveFuture;
      }

      await _openMetaMask();
      final payFuture = _wcService
          .sendTransaction(
            to: ContractsConfig.paymentManager,
            data: payData,
          )
          .timeout(const Duration(seconds: 90));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Warte auf Zahlungsbestätigung in MetaMask...')),
      );
      final txHash = await payFuture;
      if (txHash == null || txHash.isEmpty) {
        throw Exception('Keine Transaktions-Hash von MetaMask erhalten.');
      }
      await _wcService.waitForTransactionSuccess(txHash);

      final now = DateTime.now();
      await _historyService.addTransaction(
        TransactionItem(
          title: 'Laundry Zahlung',
          subtitle: _subtitleForTransaction(txHash, now),
          amount: _priceMinor / 100,
          isExpense: true,
          createdAt: now,
          txHash: txHash,
        ),
      );

      await _refreshLocks();
      await _wcService.refreshBalance();
      await _wcService.resyncActiveSession();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Zahlung gesendet. Maschine ist jetzt gesperrt.')),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Zeitüberschreitung. Bitte MetaMask öffnen und Anfrage prüfen.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zahlung fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingMachines.remove(label));
      }
    }
  }

  bool _isMachineAvailable(MachineInfo machine) {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final lockedUntil = _lockedUntilByLabel[machine.label] ?? 0;
    return machine.available && lockedUntil <= nowSec;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Waschmaschinen',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context);
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainLayout(initialIndex: index),
            ),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Preis: 1,50 THWS pro Waschgang',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...widget.groups.map(
            (group) => _MachineGroupCard(
              group: group,
              isAvailable: _isMachineAvailable,
              isPending: (m) => _pendingMachines.contains(m.label),
              onPayTap: _payLaundry,
            ),
          ),
        ],
      ),
    );
  }
}

class _MachineGroupCard extends StatelessWidget {
  final MachineGroup group;
  final bool Function(MachineInfo machine) isAvailable;
  final bool Function(MachineInfo machine) isPending;
  final Future<void> Function(MachineInfo machine) onPayTap;

  const _MachineGroupCard({
    required this.group,
    required this.isAvailable,
    required this.isPending,
    required this.onPayTap,
  });

  @override
  Widget build(BuildContext context) {
    final washers =
        group.machines.where((m) => m.type == 'Waschmaschine').toList();
    final dryers = group.machines.where((m) => m.type == 'Trockner').toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (washers.isNotEmpty) ...[
              const Text(
                'Waschmaschinen',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: washers
                    .map(
                      (m) => _MachineTile(
                        machine: m,
                        available: isAvailable(m),
                        pending: isPending(m),
                        onTap: () => onPayTap(m),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (dryers.isNotEmpty) ...[
              const Text(
                'Trockner',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: dryers
                    .map(
                      (m) => _MachineTile(
                        machine: m,
                        available: isAvailable(m),
                        pending: isPending(m),
                        onTap: () => onPayTap(m),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MachineTile extends StatelessWidget {
  final MachineInfo machine;
  final bool available;
  final bool pending;
  final VoidCallback onTap;

  const _MachineTile({
    required this.machine,
    required this.available,
    required this.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = available ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bg = available ? const Color(0xFFEFFDF4) : const Color(0xFFFFF2F2);

    return InkWell(
      onTap: (available && !pending) ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        constraints: const BoxConstraints(minHeight: 110),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_laundry_service, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    machine.type,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              machine.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (pending)
              const Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Wird bezahlt...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ],
              )
            else
              Text(
                available ? 'Verfügbar (zum Bezahlen tippen)' : 'Besetzt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
