import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/contracts.dart';

class StudentLoginResult {
  final bool authenticated;
  final String? displayName;

  const StudentLoginResult({
    required this.authenticated,
    this.displayName,
  });
}

class StudentAuthService {
  static const List<String> _candidateLoginPaths = [
    '/auth/login',
    '/api/auth/login',
  ];

  Future<StudentLoginResult> validateCredentials({
    required String knummer,
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
                'username': knummer,
                'knummer': knummer,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (resp.statusCode == 404) {
          continue;
        }
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          return const StudentLoginResult(authenticated: false);
        }
        if (resp.statusCode < 200 || resp.statusCode >= 300) {
          continue;
        }

        final body = _tryDecode(resp.body);
        if (body is Map<String, dynamic>) {
          final dynamic success = body['success'] ?? body['authenticated'];
          final displayName = _extractDisplayName(body);
          final hasToken = body['accessToken'] != null || body['token'] != null;
          if (success is bool) {
            return StudentLoginResult(
              authenticated: success,
              displayName: displayName,
            );
          }
          if (hasToken) {
            return StudentLoginResult(
              authenticated: true,
              displayName: displayName,
            );
          }
          return StudentLoginResult(
            authenticated: true,
            displayName: displayName,
          );
        }
        return const StudentLoginResult(authenticated: true);
      } catch (_) {
        // Nächsten bekannten Endpoint versuchen.
      }
    }

    throw Exception(
      'Login-Validierung derzeit nicht verfügbar. Backend-Login-Endpoint prüfen.',
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
        body['studentName'];
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString().trim();
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['displayName'] ??
          data['name'] ??
          data['fullName'] ??
          data['studentName'];
      if (nested != null && nested.toString().trim().isNotEmpty) {
        return nested.toString().trim();
      }
    }
    return null;
  }
}
