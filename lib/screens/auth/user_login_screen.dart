import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/student_auth_service.dart';
import '../../services/student_profile_service.dart';
import '../../services/transaction_history_service.dart';
import '../../services/user_session_service.dart';
import '../../services/wallet_connect_singleton.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _knummerController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _sessionService = UserSessionService();
  final _authService = StudentAuthService();
  final _profileService = StudentProfileService();
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _knummerController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openForgotPassword() async {
    final uri = Uri.parse(
      'https://studierendenportal.thws.de/password-reset',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _login(BuildContext context) async {
    if (_isLoggingIn) return;
    final knummer = _knummerController.text.trim();
    final password = _passwordController.text;
    if (knummer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte K-Nummer eingeben.')),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Passwort eingeben.')),
      );
      return;
    }

    setState(() => _isLoggingIn = true);
    try {
      final result = await _authService.validateCredentials(
        knummer: knummer,
        password: password,
      );
      if (!result.authenticated) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('K-Nummer oder Passwort ist falsch.')),
        );
        return;
      }

      final previousKnummer = (await _sessionService.getKnummer())?.trim();
      if (previousKnummer != null &&
          previousKnummer.isNotEmpty &&
          previousKnummer.toLowerCase() != knummer.toLowerCase()) {
        await walletConnectService.disconnect();
      }

      await _sessionService.clear();
      await _sessionService.saveKnummer(knummer);
      await transactionHistoryService.reloadForCurrentUser();
      final displayName = await _resolveDisplayName(
        knummer: knummer,
        authDisplayName: result.displayName,
      );
      await _sessionService.saveDisplayName(displayName);
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainLayout(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  Future<String> _resolveDisplayName({
    required String knummer,
    required String? authDisplayName,
  }) async {
    final fromAuth = authDisplayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty && fromAuth != knummer) {
      return fromAuth.split(RegExp(r'\s+')).first;
    }

    try {
      final profile =
          await _profileService.fetchStudentProfile(knummer: knummer);
      final name = profile.name.trim();
      if (name.isNotEmpty && name.toLowerCase() != 'unbekannt') {
        return name.split(RegExp(r'\s+')).first;
      }
    } catch (_) {
      // Profil optional: bei Fehler Fallback nutzen.
    }

    return knummer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Titel
              const Text(
                'Studierenden-Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F5BEA),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Melde dich mit deiner K-Nummer an',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 48),

              // K-Nummer
              TextField(
                controller: _knummerController,
                decoration: InputDecoration(
                  labelText: 'K-Nummer',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Passwort
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Passwort vergessen
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _openForgotPassword,
                  child: const Text(
                    'Passwort vergessen?',
                    style: TextStyle(
                      color: Color(0xFF2F5BEA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Anmeldebutton
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5BEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoggingIn ? null : () => _login(context),
                  child: _isLoggingIn
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Anmelden',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
