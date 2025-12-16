import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const SecurityPrivacyScreen({super.key, this.onBack});

  static const String _pwUrl =
      'https://itsc.thws.de/fuer-studierende/kennwort-aendern/';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F5F9),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Sicherheit & Datenschutz',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _SectionCard(
                title: 'Konto & Zugriff',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Passwort zurücksetzen / ändern',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Dein THWS-Account-Passwort wird über das offizielle ITSC-Portal verwaltet.',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    _PrimaryButton(
                      label: 'Zum ITSC Passwort-Portal',
                      icon: Icons.open_in_new,
                      onTap: () => _open(_pwUrl),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'Datenschutzerklärung (Kurzfassung)',
                child: const _PrivacyText(),
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'Blockchain-Hinweis',
                child: const _BlockchainText(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _open(String raw) async {
    final uri = Uri.parse(raw);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyText extends StatelessWidget {
  const _PrivacyText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Wir verarbeiten nur Daten, die für die Nutzung der App notwendig sind (z.B. Anzeige deiner Studiendaten, Wallet-Funktionen, QR-Identifikation).',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Support-Kontakt: Wenn du Hotline oder E-Mail nutzt, werden die jeweiligen Apps (Telefon/Mail) geöffnet. Inhalte werden erst gesendet, wenn du das selbst bestätigst.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Externe Links (z.B. ITSC/HSST/Studierendenwerk) werden im Browser geöffnet. Für deren Datenschutz gelten die jeweiligen Webseiten-Richtlinien.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Du kannst jederzeit die App schließen oder dich abmelden. Sensible Zugangsdaten (z.B. THWS-Passwort) werden nicht in der App gespeichert.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _BlockchainText extends StatelessWidget {
  const _BlockchainText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Blockchain wird verwendet, um bestimmte Informationen manipulationssicher zu verifizieren (z.B. Ausweis-/Wallet-Referenzen).',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Wichtiger Grundsatz: Es werden keine Klartext-Passwörter auf der Blockchain gespeichert.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Je nach Implementierung können Hashes/IDs gespeichert werden. Das dient der Integritätsprüfung (‚stimmt das so?‘), nicht dem Auslesen persönlicher Daten.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• Hinweis: Transaktionen/Einträge können dauerhaft sein. Deshalb sollten personenbezogene Daten minimiert und – wenn möglich – off-chain gespeichert werden.',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
        ),
      ],
    );
  }
}
