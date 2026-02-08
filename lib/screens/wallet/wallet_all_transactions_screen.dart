import 'package:flutter/material.dart';

import '../../layout/app_bottom_nav.dart';
import '../../layout/main_layout.dart';
import '../../models/transaction_item.dart';
import '../../widgets/transaction_tile.dart';

class WalletAllTransactionsScreen extends StatelessWidget {
  final List<TransactionItem> transactions;

  const WalletAllTransactionsScreen({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTransactions = [...transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          'Alle Transaktionen',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SafeArea(
        child: sortedTransactions.isEmpty
            ? const Center(
                child: Text(
                  'Noch keine Transaktionen vorhanden.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: sortedTransactions.length,
                itemBuilder: (context, index) => TransactionTile(
                  tx: sortedTransactions[index],
                ),
              ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
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
    );
  }
}
