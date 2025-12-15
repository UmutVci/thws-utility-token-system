import 'package:flutter/material.dart';

import 'wallet_header.dart';
import 'wallet_balance_card.dart';
import 'wallet_stats_row.dart';
import 'wallet_transactions_section.dart';
import '../../models/transaction_item.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
