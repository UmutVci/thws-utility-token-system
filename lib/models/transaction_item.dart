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
    final amount = _parseAmount(json['amount']);
    return TransactionItem(
      title: (json['title'] ?? '') as String,
      subtitle: (json['subtitle'] ?? '') as String,
      amount: amount.abs(),
      isExpense: _parseIsExpense(json, amount),
      createdAt: _parseCreatedAt(json['createdAt']),
      txHash: json['txHash']?.toString(),
    );
  }

  static double _parseAmount(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim()) ?? 0;
    return 0;
  }

  static DateTime _parseCreatedAt(dynamic raw) {
    if (raw is String) {
      final parsed = DateTime.tryParse(raw.trim());
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static bool _parseIsExpense(Map<String, dynamic> json, double parsedAmount) {
    final raw = json['isExpense'];
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }

    final direction = json['direction']?.toString().trim().toLowerCase();
    if (direction != null && direction.isNotEmpty) {
      if (direction == 'out' || direction == 'debit') return true;
      if (direction == 'in' || direction == 'credit') return false;
    }

    final type = json['type']?.toString().trim().toLowerCase();
    if (type != null && type.isNotEmpty) {
      if (type.contains('spend') || type.contains('expense')) return true;
      if (type.contains('top_up') ||
          type.contains('topup') ||
          type.contains('deposit')) {
        return false;
      }
    }

    if (parsedAmount < 0) return true;

    final title = json['title']?.toString().trim().toLowerCase() ?? '';
    if (title.contains('einzahlung') || title.contains('deposit')) {
      return false;
    }
    if (title.contains('ausgabe') || title.contains('spend')) {
      return true;
    }

    return false;
  }
}
