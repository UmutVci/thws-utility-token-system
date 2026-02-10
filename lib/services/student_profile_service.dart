import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/contracts.dart';
import '../models/student_profile.dart';

class StudentProfileService {
  static const String _apiPath = '/api/students/profile';
  static const String _walletApiPath = '/api/students/wallet';

  Future<StudentProfile> fetchStudentProfile({
    required String? knummer,
  }) async {
    if (knummer == null || knummer.isEmpty) {
      return StudentProfile.fallback();
    }

    final uri = Uri.parse(
      '${ContractsConfig.backendUrl}$_apiPath?knummer=$knummer',
    );

    final resp = await http.get(uri).timeout(const Duration(seconds: 12));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
          'Profil konnte nicht geladen werden (${resp.statusCode}).');
    }

    final body = jsonDecode(resp.body);
    if (body is Map<String, dynamic>) {
      if (body['item'] is Map<String, dynamic>) {
        return StudentProfile.fromJson(body['item'] as Map<String, dynamic>);
      }
      if (body['data'] is Map<String, dynamic>) {
        return StudentProfile.fromJson(body['data'] as Map<String, dynamic>);
      }
      return StudentProfile.fromJson(body);
    }

    throw Exception('Ungültiges Profil-Response vom Backend.');
  }

  Future<void> bindWallet({
    required String knummer,
    required String walletAddress,
  }) async {
    if (knummer.trim().isEmpty || walletAddress.trim().isEmpty) return;

    final uri = Uri.parse('${ContractsConfig.backendUrl}$_walletApiPath');
    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'knummer': knummer.trim(),
            'walletAddress': walletAddress.trim(),
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Wallet-Bind fehlgeschlagen (${resp.statusCode}).');
    }
  }
}
