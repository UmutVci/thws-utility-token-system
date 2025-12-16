import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const SecurityPrivacyScreen({super.key, this.onBack});

  static const String _pwUrl =
      'https://itsc.thws.de/fuer-studierende/kennwort-aendern/';

  // ✅ Preview (kurz)
  static const String _privacyPreviewText = '''
• Wir verarbeiten nur Daten, die für die Nutzung der App notwendig sind (z.B. Anzeige deiner Studiendaten, Wallet-Funktionen, QR-Identifikation).
• Support-Kontakt: Telefon/Mail wird geöffnet. Inhalte werden erst gesendet, wenn du das selbst bestätigst.
• Externe Links werden im Browser geöffnet (Datenschutz gilt nach Richtlinie der jeweiligen Website).
''';

  // ✅ Volltext (hier kannst du später den echten Text einfügen oder aus Assets laden)
  static const String _privacyFullText = '''
Datenschutzerklärung

1. Verantwortlicher
Technische Hochschule Würzburg-Schweinfurt (THWS)
[Adresse / Kontakt / Datenschutzbeauftragter]

2. Zweck der Verarbeitung
Wir verarbeiten personenbezogene Daten ausschließlich, soweit dies für die Nutzung der App erforderlich ist (z.B. Anzeige von Studiendaten, QR-Identifikation, Wallet-Funktionen).

3. Verarbeitete Datenkategorien
- Identitäts-/Studiendaten (z.B. Name, Matrikelnummer, Studiengang) zur Darstellung innerhalb der App
- App-interne technische Daten (z.B. Fehlerdiagnose), sofern vorgesehen/aktiviert

4. Support & Kontakt
Wenn du Hotline oder E-Mail nutzt, öffnen wir die jeweilige App (Telefon/Mail). Inhalte werden erst gesendet, wenn du dies selbst bestätigst.

5. Externe Links
Links (z.B. ITSC/HSST/Studierendenwerk) werden im Browser geöffnet. Für den Datenschutz gelten die Richtlinien der jeweiligen Website.

6. Speicherung von Zugangsdaten
Sensible Zugangsdaten (z.B. THWS-Passwort) werden nicht in der App gespeichert.

7. Blockchain-Hinweis
Blockchain kann genutzt werden, um Informationen manipulationssicher zu verifizieren (z.B. Referenzen/Hashes). Es werden keine Klartext-Passwörter auf der Blockchain gespeichert. Transaktionen/Einträge können dauerhaft sein. Daher sollten personenbezogene Daten minimiert und – wenn möglich – off-chain gespeichert werden.

8. Rechte der betroffenen Personen
Du hast nach Maßgabe der gesetzlichen Vorschriften Rechte auf Auskunft, Berichtigung, Löschung, Einschränkung der Verarbeitung, Widerspruch und Datenübertragbarkeit.

9. Stand
[Datum]
''';

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
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
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

              // ✅ Datenschutz: ohne "(Kurzfassung)" + Preview + Mehr lesen
              _SectionCard(
                title: 'Datenschutzerklärung',
                child: _PrivacyPreview(
                  previewText: _privacyPreviewText,
                  onMore: () => _showPrivacyPolicy(context),
                ),
              ),

              const SizedBox(height: 12),

              const _SectionCard(
                title: 'Blockchain-Hinweis',
                child: _BlockchainText(),
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

  // ✅ BottomSheet mit Volltext öffnen
  static void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Datenschutzerklärung',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      child: const Text(
                        _privacyFullText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

// ✅ Preview + Mehr lesen
class _PrivacyPreview extends StatelessWidget {
  final String previewText;
  final VoidCallback onMore;

  const _PrivacyPreview({
    required this.previewText,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          previewText.trim(),
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onMore,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined, size: 18, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  'Mehr lesen',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
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
