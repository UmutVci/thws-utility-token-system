import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'wallet_header.dart';
import 'wallet_balance_card.dart';
import 'wallet_stats_row.dart';
import 'wallet_transactions_section.dart';
import '../../models/transaction_item.dart';
import '../../services/wallet_connect_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // TODO: Replace with your WalletConnect Cloud projectId.
  final WalletConnectService _wcService =
      WalletConnectService(projectId: '8bcdb71c4952a4b75a62c7f38ba5eb55');

  @override
  void initState() {
    super.initState();
    _wcService.addListener(_onServiceChanged);
    _wcService.init();
  }

  @override
  void dispose() {
    _wcService.removeListener(_onServiceChanged);
    _wcService.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _connectWallet() async {
    try {
      await _wcService.connect();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı başarısız: $e')),
      );
    }
  }

  Future<void> _disconnectWallet() async {
    await _wcService.disconnect();
  }

  List<TransactionItem> _mockTransactions() {
    return const [
      TransactionItem(
        title: "Mensa SHL",
        subtitle: "Heute, 12:15",
        amount: -4.50,
        isExpense: true,
      ),
      TransactionItem(
        title: "Bibliothek Gebühr",
        subtitle: "Gestern, 16:30",
        amount: -2.00,
        isExpense: true,
      ),
      TransactionItem(
        title: "Aufladung",
        subtitle: "Gestern, 09:10",
        amount: 20.00,
        isExpense: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _mockTransactions();

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
            ),
            const SizedBox(height: 16),
            const WalletBalanceCard(),
            const SizedBox(height: 20),
            const WalletStatsRow(),
            const SizedBox(height: 24),
            WalletTransactionsSection(
              transactions: transactions,
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
  });

  final bool isConnecting;
  final bool isConnected;
  final String? address;
  final Uri? pairingUri;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
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
                isConnected ? 'Cüzdan bağlı' : 'Cüzdana bağlan',
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
                child: const Text('Disconnect'),
              ),
            ),
          ] else ...[
            const Text(
              'WalletConnect ile bağlanmak için butona tıkla. QR kodu cüzdandan tara veya destekleyen cüzdanı aç.',
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
                  'Cüzdana Bağlan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (pairingUri != null) ...[
              const SizedBox(height: 12),
              Center(
                child: QrImageView(
                  data: pairingUri.toString(),
                  size: 140,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => launchUrl(
                  pairingUri!,
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Cüzdanı aç'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
