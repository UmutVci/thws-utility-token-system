import 'package:flutter/material.dart';

class WalletStatsRow extends StatelessWidget {
  const WalletStatsRow({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  final double totalIncome;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Einzahlungen',
            value: '${_formatAmount(totalIncome)} THWS',
            sub: 'Gesamt',
            up: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Ausgaben',
            value: '${_formatAmount(totalExpense)} THWS',
            sub: 'Gesamt',
            up: true,
          ),
        ),
      ],
    );
  }

  static String _formatAmount(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final bool up;

  const _StatCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.up,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor:
                    up ? Colors.orange.shade100 : Colors.green.shade100,
                child: Icon(
                  up ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: up ? Colors.orange : Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
