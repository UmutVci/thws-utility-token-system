class TransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final DateTime createdAt;
  final String? txHash;

  const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.createdAt,
    this.txHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'isExpense': isExpense,
      'createdAt': createdAt.toIso8601String(),
      'txHash': txHash,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      title: (json['title'] ?? '') as String,
      subtitle: (json['subtitle'] ?? '') as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      isExpense: (json['isExpense'] ?? true) as bool,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      txHash: json['txHash'] as String?,
    );
  }
}
