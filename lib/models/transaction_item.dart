class TransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;

 const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
  });
}
