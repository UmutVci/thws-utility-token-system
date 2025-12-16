import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class UserLoginScreen extends StatelessWidget {
  const UserLoginScreen({super.key});

  void _openForgotPassword() async {
  final uri = Uri.parse(
    'https://studierendenportal.thws.de/password-reset',
  );

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
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

              // Başlık
              const Text(
                'Student Login',
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

              // Login Button
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
                  onPressed: () {
                    // ŞİMDİLİK DİREKT GEÇİŞ
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainLayout(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
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
