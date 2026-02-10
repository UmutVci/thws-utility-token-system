import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/contracts.dart';
import '../models/transaction_item.dart';
import 'user_session_service.dart';

final TransactionHistoryService transactionHistoryService =
    TransactionHistoryService();

class TransactionHistoryService extends ChangeNotifier {
  static const String _storageKeyPrefix = 'wallet_transactions_v2';
  static const String _pendingPushStorageKeyPrefix =
      'wallet_transactions_pending_push_v2';
  static const String _apiPath = '/api/students/transactions';

  final List<TransactionItem> _transactions = [];
  final List<Map<String, dynamic>> _pendingPushItems = [];
  final _sessionService = UserSessionService();
  bool _initialized = false;
  bool _isFlushingPending = false;
  String? _activeScope;

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  Future<void> init() async {
    await _ensureScopeLoaded();
    if (_initialized) return;
    _initialized = true;
    await _flushPendingPushes();
  }

  Future<void> reloadForCurrentUser() async {
    await _ensureScopeLoaded(forceReload: true);
    await _flushPendingPushes();
  }

  Future<void> _ensureScopeLoaded({bool forceReload = false}) async {
    final scope = await _resolveScope();
    if (!forceReload && _activeScope == scope) return;

    _activeScope = scope;
    final prefs = await SharedPreferences.getInstance();
    final storageKey = _storageKeyFor(scope);
    final pendingKey = _pendingStorageKeyFor(scope);

    var rawItems = prefs.getStringList(storageKey) ?? const [];
    var rawPendingItems = prefs.getStringList(pendingKey) ?? const [];

    _transactions
      ..clear()
      ..addAll(
        rawItems
            .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
            .map(TransactionItem.fromJson),
      );
    _pendingPushItems
      ..clear()
      ..addAll(
        rawPendingItems
            .map((raw) => jsonDecode(raw))
            .whereType<Map<String, dynamic>>(),
      );

    _sortNewestFirst();
    notifyListeners();
  }

  Future<String> _resolveScope() async {
    final knummer = (await _sessionService.getKnummer())?.trim().toLowerCase();
    if (knummer == null || knummer.isEmpty) return 'anonymous';
    return knummer;
  }

  String _storageKeyFor(String scope) => '$_storageKeyPrefix::$scope';

  String _pendingStorageKeyFor(String scope) =>
      '$_pendingPushStorageKeyPrefix::$scope';

  String _effectiveScope() => _activeScope ?? 'anonymous';

  Future<void> _ensureReadyForOperation() async {
    if (!_initialized) {
      await init();
      return;
    }
    await _ensureScopeLoaded();
  }

  Future<void> addTransaction(
    TransactionItem item, {
    String? knummer,
  }) async {
    await _ensureReadyForOperation();
    _transactions.insert(0, item);
    _sortNewestFirst();
    await _persist();
    notifyListeners();

    final effectiveKnummer =
        (knummer ?? await _sessionService.getKnummer())?.trim();
    if (effectiveKnummer != null && effectiveKnummer.isNotEmpty) {
      final pushed = await _pushTransactionToBackend(
        knummer: effectiveKnummer,
        item: item,
      );
      if (!pushed) {
        await _enqueuePendingPush(
          knummer: effectiveKnummer,
          item: item,
        );
      }
    }
  }

  Future<void> clear() async {
    await _ensureReadyForOperation();
    _transactions.clear();
    _pendingPushItems.clear();
    await _persist();
    notifyListeners();
  }

  void _sortNewestFirst() {
    _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final scope = _effectiveScope();
    final encoded = _transactions.map((t) => jsonEncode(t.toJson())).toList();
    final encodedPending = _pendingPushItems.map(jsonEncode).toList();
    await prefs.setStringList(_storageKeyFor(scope), encoded);
    await prefs.setStringList(_pendingStorageKeyFor(scope), encodedPending);
  }

  Future<void> syncFromBackend({
    String? knummer,
  }) async {
    await _ensureReadyForOperation();
    final effectiveKnummer =
        (knummer ?? await _sessionService.getKnummer())?.trim();
    if (effectiveKnummer == null || effectiveKnummer.isEmpty) return;

    try {
      final uri = Uri.parse(
        '${ContractsConfig.backendUrl}$_apiPath?knummer=$effectiveKnummer',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      if (resp.statusCode < 200 || resp.statusCode >= 300) return;

      final body = jsonDecode(resp.body);
      final List<dynamic> rawItems;
      if (body is List) {
        rawItems = body;
      } else if (body is Map<String, dynamic> && body['items'] is List) {
        rawItems = body['items'] as List<dynamic>;
      } else {
        return;
      }

      final remoteItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map(TransactionItem.fromJson)
          .toList();

      final merged = _mergeKeepLocal(
        localItems: _transactions,
        remoteItems: remoteItems,
      );

      _transactions
        ..clear()
        ..addAll(merged);
      _sortNewestFirst();
      await _persist();
      notifyListeners();
      await _flushPendingPushes();
    } catch (_) {
      // Backend optional: bei Fehler lokal weiterarbeiten.
    }
  }

  List<TransactionItem> _mergeKeepLocal({
    required List<TransactionItem> localItems,
    required List<TransactionItem> remoteItems,
  }) {
    final mergedByKey = <String, TransactionItem>{};
    for (final item in remoteItems) {
      mergedByKey[_dedupeKey(item)] = item;
    }
    for (final item in localItems) {
      mergedByKey.putIfAbsent(_dedupeKey(item), () => item);
    }
    return mergedByKey.values.toList();
  }

  String _dedupeKey(TransactionItem item) {
    final hash = item.txHash?.trim();
    if (hash != null && hash.isNotEmpty) {
      return 'hash:${hash.toLowerCase()}';
    }
    return [
      item.title.trim().toLowerCase(),
      item.subtitle.trim().toLowerCase(),
      item.amount.toStringAsFixed(2),
      item.isExpense ? 'out' : 'in',
      item.createdAt.toIso8601String(),
    ].join('|');
  }

  Future<void> _enqueuePendingPush({
    required String knummer,
    required TransactionItem item,
  }) async {
    _pendingPushItems.add({
      'knummer': knummer,
      'item': item.toJson(),
    });
    await _persist();
  }

  Future<void> _flushPendingPushes() async {
    if (_isFlushingPending || _pendingPushItems.isEmpty) return;
    _isFlushingPending = true;

    try {
      final snapshot = List<Map<String, dynamic>>.from(_pendingPushItems);
      final remaining = <Map<String, dynamic>>[];

      for (final pending in snapshot) {
        final knummer = (pending['knummer'] ?? '').toString().trim();
        final itemJson = pending['item'];
        if (knummer.isEmpty || itemJson is! Map<String, dynamic>) {
          continue;
        }

        final item = TransactionItem.fromJson(itemJson);
        final pushed = await _pushTransactionToBackend(
          knummer: knummer,
          item: item,
        );
        if (!pushed) {
          remaining.add(pending);
        }
      }

      _pendingPushItems
        ..clear()
        ..addAll(remaining);
      await _persist();
    } finally {
      _isFlushingPending = false;
    }
  }

  Future<bool> _pushTransactionToBackend({
    required String knummer,
    required TransactionItem item,
  }) async {
    try {
      final uri = Uri.parse('${ContractsConfig.backendUrl}$_apiPath');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'knummer': knummer,
              ...item.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 12));
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (_) {
      // Backend optional: lokal gespeichert kalsın.
      return false;
    }
  }
}
