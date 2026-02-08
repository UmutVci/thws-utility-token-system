import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_item.dart';

final TransactionHistoryService transactionHistoryService =
    TransactionHistoryService();

class TransactionHistoryService extends ChangeNotifier {
  static const String _storageKey = 'wallet_transactions_v1';

  final List<TransactionItem> _transactions = [];
  bool _initialized = false;

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_storageKey) ?? const [];

    _transactions
      ..clear()
      ..addAll(
        rawItems
            .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
            .map(TransactionItem.fromJson),
      );

    _sortNewestFirst();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionItem item) async {
    _transactions.insert(0, item);
    _sortNewestFirst();
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _transactions.clear();
    await _persist();
    notifyListeners();
  }

  void _sortNewestFirst() {
    _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _transactions.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}
