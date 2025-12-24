import 'package:flutter/material.dart';
import '../../models/transaction_item.dart';
import '../../widgets/transaction_tile.dart';
import 'wallet_all_transactions_screen.dart';

class WalletTransactionsSection extends StatelessWidget {
  final List<TransactionItem> transactions;

  const WalletTransactionsSection({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Letzte Transaktionen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WalletAllTransactionsScreen(
                      transactions: transactions,
                    ),
                  ),
                );
              },
              child: const Text("Alle"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...transactions.map(
          (tx) => TransactionTile(tx: tx),
        ),
      ],
    );
  }
}
