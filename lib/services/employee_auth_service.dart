import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/contracts.dart';

class EmployeeLoginResult {
  final bool authenticated;
  final String? displayName;

  const EmployeeLoginResult({
    required this.authenticated,
    this.displayName,
  });
}

class EmployeeAuthService {
  static const List<String> _candidateLoginPaths = [
    '/auth/login',
    '/api/auth/login',
  ];

  Future<EmployeeLoginResult> validateCredentials({
    required String username,
    required String password,
  }) async {
    for (final path in _candidateLoginPaths) {
      final uri = Uri.parse('${ContractsConfig.backendUrl}$path');
      try {
        final resp = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'username': username,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (resp.statusCode == 404) continue;
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          return const EmployeeLoginResult(authenticated: false);
        }
        if (resp.statusCode < 200 || resp.statusCode >= 300) continue;

        final body = _tryDecode(resp.body);
        if (body is Map<String, dynamic>) {
          final dynamic success = body['success'] ?? body['authenticated'];
          final displayName = _extractDisplayName(body);
          final hasToken = body['accessToken'] != null || body['token'] != null;
          if (success is bool) {
            return EmployeeLoginResult(
              authenticated: success,
              displayName: displayName,
            );
          }
          if (hasToken) {
            return EmployeeLoginResult(
              authenticated: true,
              displayName: displayName,
            );
          }
          return EmployeeLoginResult(
            authenticated: true,
            displayName: displayName,
          );
        }

        return const EmployeeLoginResult(authenticated: true);
      } catch (_) {
        // Nächsten bekannten Endpoint versuchen.
      }
    }

    throw Exception(
      'Mitarbeiter-Login derzeit nicht verfügbar. Backend-Login-Endpoint prüfen.',
    );
  }

  dynamic _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  String? _extractDisplayName(Map<String, dynamic> body) {
    final direct = body['displayName'] ??
        body['name'] ??
        body['fullName'] ??
        body['employeeName'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['displayName'] ??
          data['name'] ??
          data['fullName'] ??
          data['employeeName'];
      if (nested != null && nested.toString().trim().isNotEmpty) {
        return nested.toString().trim();
      }
    }
    return null;
  }
}
