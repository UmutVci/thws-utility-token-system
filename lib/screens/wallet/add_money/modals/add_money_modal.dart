import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../config/contracts.dart';
import '../../../../models/transaction_item.dart';
import '../../../../services/transaction_history_service.dart';
import '../../../../services/wallet_connect_singleton.dart';

/// ================= ENUM =================
/// ⚠️ Das Enum muss auf Dateiebene definiert sein
enum PaymentMethod {
  sepa,
  card,
  paypal,
}

/// ================= MODAL =================

class AddMoneyModal extends StatefulWidget {
  const AddMoneyModal({
    super.key,
    this.currentBalanceText,
  });

  final String? currentBalanceText;

  @override
  State<AddMoneyModal> createState() => _AddMoneyModalState();
}

class _AddMoneyModalState extends State<AddMoneyModal> {
  int selectedAmount = 10;
  PaymentMethod selectedPayment = PaymentMethod.sepa;
  bool _isMinting = false;
  final _wcService = walletConnectService;
  final _historyService = transactionHistoryService;

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

  Future<void> _mintSelectedAmount(BuildContext context) async {
    if (_isMinting) return;
    if (!_wcService.isConnected || _wcService.connectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte zuerst Wallet verbinden.')),
      );
      return;
    }

    setState(() => _isMinting = true);
    final client = Web3Client(ContractsConfig.rpcUrl, http.Client());
    try {
      await _wcService.ensureSepoliaChain();

      final tokenAbi = await _loadAbi('assets/abi/THWSToken.json', 'THWSToken');
      final tokenContract = DeployedContract(
        tokenAbi,
        EthereumAddress.fromHex(ContractsConfig.token),
      );
      final ownerFn = tokenContract.function('owner');
      final decimalsFn = tokenContract.function('decimals');
      final mintFn = tokenContract.function('mint');

      final ownerRes = await client.call(
        contract: tokenContract,
        function: ownerFn,
        params: const [],
      );
      final owner = ownerRes.isNotEmpty && ownerRes.first is EthereumAddress
          ? (ownerRes.first as EthereumAddress).hex.toLowerCase()
          : '';
      final caller = _wcService.connectedAddress!.toLowerCase();
      if (owner != caller) {
        throw Exception('Mint ist nur mit dem Owner-Wallet erlaubt.');
      }

      final decimalsRes = await client.call(
        contract: tokenContract,
        function: decimalsFn,
        params: const [],
      );
      final decimals = decimalsRes.isNotEmpty && decimalsRes.first is int
          ? decimalsRes.first as int
          : 2;

      final mintAmount =
          BigInt.from(selectedAmount) * BigInt.from(10).pow(decimals);
      final mintData = bytesToHex(
        mintFn.encodeCall([
          EthereumAddress.fromHex(_wcService.connectedAddress!),
          mintAmount,
        ]),
        include0x: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('$selectedAmount THWS werden in MetaMask bestätigt...')),
      );

      final mintFuture = _wcService
          .sendTransaction(
            to: ContractsConfig.token,
            data: mintData,
          )
          .timeout(const Duration(seconds: 90));
      await _openMetaMask();
      final txHash = await mintFuture;
      if (txHash == null || txHash.isEmpty) {
        throw Exception('Keine Transaktions-Hash von MetaMask erhalten.');
      }
      await _wcService.waitForTransactionSuccess(txHash);

      final now = DateTime.now();
      await _historyService.addTransaction(
        TransactionItem(
          title: 'Einzahlung',
          subtitle: 'Aufladung per Mint',
          amount: selectedAmount.toDouble(),
          isExpense: false,
          createdAt: now,
          txHash: txHash,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$selectedAmount THWS erfolgreich gemintet.')),
      );
      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mint fehlgeschlagen: $e')),
      );
    } finally {
      client.dispose();
      if (mounted) setState(() => _isMinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===== SCROLLABLE CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    const SizedBox(height: 20),
                    _balanceCard(),
                    const SizedBox(height: 24),
                    _amountGrid(),
                    const SizedBox(height: 24),
                    _paymentMethods(),
                  ],
                ),
              ),
            ),

            // ===== FIXED BOTTOM ACTIONS =====
            _bottomActions(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Guthaben aufladen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  // ================= BALANCE CARD =================

  Widget _balanceCard() {
    final balanceValue = _parseBalance(widget.currentBalanceText);
    final balanceLabel = balanceValue == null
        ? '— THWS'
        : '${balanceValue.toStringAsFixed(2)} THWS';
    final euroLabel = balanceValue == null
        ? '≈ — €'
        : '≈ ${balanceValue.toStringAsFixed(2)} €';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktuelles Guthaben',
            style: TextStyle(
              color: Color(0xFF2F5BEA),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            balanceLabel,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(euroLabel, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  double? _parseBalance(String? raw) {
    if (raw == null) return null;
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  // ================= AMOUNT GRID =================

  Widget _amountGrid() {
    final amounts = [5, 10, 20, 50];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Betrag wählen',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: amounts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, index) {
            final amount = amounts[index];
            final selected = selectedAmount == amount;

            return GestureDetector(
              onTap: () => setState(() => selectedAmount = amount),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFE9EEFF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2F5BEA)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$amount €',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '= $amount THWS',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= PAYMENT METHODS =================

  Widget _paymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zahlungsmethode',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _paymentTile(
          value: PaymentMethod.sepa,
          icon: Icons.account_balance,
          title: 'SEPA Lastschrift',
          subtitle: 'Sofortige Gutschrift',
        ),
        _paymentTile(
          value: PaymentMethod.card,
          icon: Icons.credit_card,
          title: 'Kredit-/Debitkarte',
          subtitle: 'Visa, Mastercard',
        ),
        _paymentTile(
          value: PaymentMethod.paypal,
          icon: Icons.paypal,
          title: 'PayPal',
          subtitle: 'Schnell & sicher',
        ),
      ],
    );
  }

  Widget _paymentTile({
    required PaymentMethod value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = selectedPayment == value;

    return GestureDetector(
      onTap: () => setState(() => selectedPayment = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF2F5BEA) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF2F5BEA) : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: const Color(0xFF2F5BEA),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM ACTIONS =================

  Widget _bottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Abbrechen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isMinting ? null : () => _mintSelectedAmount(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5BEA),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_isMinting ? 'Mint läuft...' : 'Aufladen'),
            ),
          ),
        ],
      ),
    );
  }
}
