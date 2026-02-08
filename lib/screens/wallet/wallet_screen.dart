import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../../config/contracts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'wallet_header.dart';
import 'wallet_balance_card.dart';
import 'wallet_stats_row.dart';
import 'wallet_transactions_section.dart';
import '../../services/transaction_history_service.dart';
import '../../services/wallet_connect_singleton.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final AppLifecycleListener _lifecycleListener;
  String? _tokenBalance;
  bool _isLoadingBalance = false;
  bool _refreshScheduled = false;
  final _wcService = walletConnectService;
  final _historyService = transactionHistoryService;

  @override
  void initState() {
    super.initState();
    _wcService.addListener(_onServiceChanged);
    _historyService.addListener(_onServiceChanged);
    _wcService.init();
    _historyService.init();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          _wcService.resyncActiveSession();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _wcService.removeListener(_onServiceChanged);
    _historyService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
    if (_wcService.isConnected) {
      _scheduleRefresh();
    }
  }

  void _scheduleRefresh() {
    if (_refreshScheduled) return;
    _refreshScheduled = true;
    Future.delayed(const Duration(milliseconds: 300), () async {
      _refreshScheduled = false;
      await _refreshTokenBalance();
    });
  }

  Future<ContractAbi> _loadAbi(String assetPath, String name) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final abiJson = jsonEncode(decoded['abi']);
    return ContractAbi.fromJson(abiJson, name);
  }

  Future<void> _refreshTokenBalance() async {
    if (!_wcService.isConnected) return;
    final address = _wcService.connectedAddress;
    if (address == null) return;

    setState(() => _isLoadingBalance = true);

    try {
      final client = Web3Client(ContractsConfig.rpcUrl, Client());
      final tokenAbi = await _loadAbi('assets/abi/THWSToken.json', 'THWSToken');
      final token = DeployedContract(
        tokenAbi,
        EthereumAddress.fromHex(ContractsConfig.token),
      );
      final balanceFn = token.function('balanceOf');
      final result = await client.call(
        contract: token,
        function: balanceFn,
        params: [EthereumAddress.fromHex(address)],
      ).timeout(const Duration(seconds: 12));

      if (result.isNotEmpty && result.first is BigInt) {
        final raw = result.first as BigInt;
        const decimals = 2;
        final divisor = BigInt.from(10).pow(decimals);
        final whole = raw ~/ divisor;
        final frac = (raw % divisor).toString().padLeft(decimals, '0');
        _tokenBalance = '$whole.$frac';
      }
    } catch (_) {
      // Prevent indefinite "Lade..." state if first load fails.
      _tokenBalance ??= '0.00';
    } finally {
      if (mounted) setState(() => _isLoadingBalance = false);
    }
  }

  Future<void> _connectWallet() async {
    try {
      if (_wcService.isConnected && _wcService.connectedAddress != null) {
        await _wcService.ensureSepoliaChain();
        await _refreshTokenBalance();
        return;
      }

      final uri = await _wcService.connect();
      await _wcService.ensureSepoliaChain();
      await _refreshTokenBalance();
      final target = _wcService.metamaskDeepLink ?? uri;

      if (target == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pairing-URI konnte nicht erstellt werden.')),
        );
        return;
      }

      final launched = await launchUrl(
        target,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MetaMask konnte nicht geöffnet werden.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindung fehlgeschlagen: $e')),
      );
    }
  }

  Future<void> _disconnectWallet() async {
    await _wcService.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = [..._historyService.transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentTransactions =
        allTransactions.length > 3 ? allTransactions.take(3).toList() : allTransactions;
    final totalIncome = allTransactions
        .where((tx) => !tx.isExpense)
        .fold<double>(0, (sum, tx) => sum + tx.amount.abs());
    final totalExpense = allTransactions
        .where((tx) => tx.isExpense)
        .fold<double>(0, (sum, tx) => sum + tx.amount.abs());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WalletHeader(),
            const SizedBox(height: 20),
            _WalletConnectCard(
              isConnecting: _wcService.isConnecting,
              isConnected: _wcService.isConnected,
              address: _wcService.connectedAddress,
              pairingUri: _wcService.pairingUri,
              onConnect: _connectWallet,
              onDisconnect: _disconnectWallet,
              onResync: _wcService.resyncActiveSession,
              debugStatus:
                  'connecting=${_wcService.isConnecting} connected=${_wcService.isConnected} addr=${_wcService.connectedAddress ?? "-"}',
            ),
            const SizedBox(height: 16),
            WalletBalanceCard(
              isConnected: _wcService.isConnected,
              balanceText: _tokenBalance,
              onRefresh: () async {
                await _wcService.ensureSepoliaChain();
                await _refreshTokenBalance();
              },
            ),
            if (_isLoadingBalance)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            const SizedBox(height: 20),
            WalletStatsRow(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
            ),
            const SizedBox(height: 24),
            WalletTransactionsSection(
              transactions: recentTransactions,
              allTransactions: allTransactions,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletConnectCard extends StatelessWidget {
  const _WalletConnectCard({
    required this.isConnecting,
    required this.isConnected,
    required this.address,
    required this.pairingUri,
    required this.onConnect,
    required this.onDisconnect,
    required this.onResync,
    required this.debugStatus,
  });

  final bool isConnecting;
  final bool isConnected;
  final String? address;
  final Uri? pairingUri;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onResync;
  final String debugStatus;

  @override
  Widget build(BuildContext context) {
    final metaMaskDeepLink = pairingUri == null
        ? null
        : Uri.parse(
            'metamask://wc?uri=${Uri.encodeComponent(pairingUri.toString())}');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: Color(0xFF2F5BEA)),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'MetaMask verbunden' : 'Nur MetaMask Verbindung',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isConnecting) const CircularProgressIndicator(strokeWidth: 2),
            ],
          ),
          const SizedBox(height: 12),
          if (isConnected && address != null) ...[
            Text(
              address!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: onDisconnect,
                child: const Text('Trennen'),
              ),
            ),
          ] else ...[
            const Text(
              'Diese DApp verbindet sich ausschließlich mit MetaMask. Sobald du auf die Schaltfläche unten klickst, wird MetaMask geöffnet und du wirst um Bestätigung gebeten.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5BEA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isConnecting ? null : onConnect,
                child: const Text(
                  'Mit MetaMask verbinden',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (metaMaskDeepLink != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => launchUrl(
                  metaMaskDeepLink,
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('MetaMask öffnen'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onResync,
                child: const Text('Bestätigt, Status aktualisieren'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              debugStatus,
              style: const TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
