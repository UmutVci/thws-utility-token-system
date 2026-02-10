import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../../../wallet/payment/payment_launcher.dart';
import '../../../../config/contracts.dart';
import '../../../../services/wallet_connect_singleton.dart';

class MensaPayCard extends StatefulWidget {
  const MensaPayCard({super.key});

  @override
  State<MensaPayCard> createState() => _MensaPayCardState();
}

class _MensaPayCardState extends State<MensaPayCard> {
  final _wcService = walletConnectService;
  String? _tokenBalance;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _wcService.addListener(_onWalletChanged);
    _wcService.init();
    _refreshTokenBalance();
  }

  @override
  void dispose() {
    _wcService.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    if (mounted) setState(() {});
    _refreshTokenBalance();
  }

  Future<ContractAbi> _loadAbi(String assetPath, String name) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final abiJson = jsonEncode(decoded['abi']);
    return ContractAbi.fromJson(abiJson, name);
  }

  Future<void> _refreshTokenBalance() async {
    if (!_wcService.isConnected || _wcService.connectedAddress == null) {
      if (mounted) setState(() => _tokenBalance = null);
      return;
    }
    if (_isRefreshing) return;

    _isRefreshing = true;
    final client = Web3Client(ContractsConfig.rpcUrl, Client());
    try {
      final tokenAbi = await _loadAbi('assets/abi/THWSToken.json', 'THWSToken');
      final tokenContract = DeployedContract(
        tokenAbi,
        EthereumAddress.fromHex(ContractsConfig.token),
      );
      final balanceFn = tokenContract.function('balanceOf');
      final result = await client.call(
        contract: tokenContract,
        function: balanceFn,
        params: [EthereumAddress.fromHex(_wcService.connectedAddress!)],
      ).timeout(const Duration(seconds: 12));

      if (result.isNotEmpty && result.first is BigInt) {
        final raw = result.first as BigInt;
        const decimals = 2;
        final divisor = BigInt.from(10).pow(decimals);
        final whole = raw ~/ divisor;
        final frac = (raw % divisor).toString().padLeft(decimals, '0');
        if (mounted) setState(() => _tokenBalance = '$whole.$frac');
      }
    } catch (_) {
      if (mounted) setState(() => _tokenBalance ??= '0.00');
    } finally {
      _isRefreshing = false;
      client.dispose();
    }
  }

  String _displayThws() {
    if (!_wcService.isConnected) return 'Wallet verbinden';
    if (_tokenBalance == null) return 'Lade...';
    return '${_tokenBalance!.replaceAll('.', ',')} THWS';
  }

  String _displayEuro() {
    if (!_wcService.isConnected || _tokenBalance == null) return '';
    final value = double.tryParse(_tokenBalance!);
    if (value == null) return '';
    return '≈ ${value.toStringAsFixed(2).replaceAll('.', ',')} €';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => openPayment(context),
        child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2F54EB),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Jetzt bezahlen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kamera öffnen',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _displayThws(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_displayEuro().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _displayEuro(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
