import 'package:flutter/material.dart';
import 'package:thws_token_frontend/screens/employee/employee_home_screen.dart';
import '../auth/user_login_screen.dart';
import '../auth/employee_login_screen.dart';
import '../../layout/main_layout.dart';


class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
              const Text(
                'Willkommen',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bitte wähle deinen Zugang',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              _RoleCard(
                icon: Icons.school,
                title: 'Student / User',
                subtitle: 'Zahlungen & Services nutzen',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (_) => const UserLoginScreen(),
                      //builder: (_) => const MainLayout(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _RoleCard(
                icon: Icons.badge,
                title: 'Employee',
                subtitle: 'Verwaltung & Kontrolle',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (_) => const EmployeeLoginScreen(),
                    //builder: (_) => const EmployeeHomeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE9EEFF),
              child: Icon(icon, color: const Color(0xFF2F5BEA)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
