import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'help_and_support_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool autoLoadEnabled = false;

  // ✅ NEU: Umschalten zwischen Profil und Hilfe&Support,
  // ohne Navigator.push -> BottomNav bleibt sichtbar
  bool _showHelpSupport = false;

  final Map<String, String> studentData = {
    'name': 'Max Mustermann',
    'id': '1234567',
    'course': 'Informatik (B.Sc.)',
    'semester': '5. Semester',
    'validUntil': '30.09.2025',
    'email': 'max.mustermann@study.thws.de',
    'phone': '+49 151 12345678',
    'campus': 'Schweinfurt',
  };

  late final String cardId;

  @override
  void initState() {
    super.initState();
    cardId =
        'THWS-ID:${studentData['id']}:${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    if (_showHelpSupport) {
      return HelpSupportScreen(
        onBack: () => setState(() => _showHelpSupport = false),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _studentCard(),
            const SizedBox(height: 14),
            _qrCard(),
            const SizedBox(height: 14),
            _infoCard(),
            const SizedBox(height: 12),
            _menuList(),
            const SizedBox(height: 12),
            _appInfoCard(),
            const SizedBox(height: 12),
            _logoutButton(),
            const SizedBox(height: 18),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _qrWidget() {
    return QrImageView(
      data: cardId,
      version: QrVersions.auto,
      size: 180,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(8),
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    );
  }

  // -----------------------
  // Digitale Ausweiskarte
  // -----------------------
  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -80,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -70,
            bottom: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Technische Hochschule',
                            style: TextStyle(
                                color: Color(0xFFBFDBFE), fontSize: 12)),
                        SizedBox(height: 4),
                        Text(
                          'Würzburg-Schweinfurt',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.credit_card_outlined, color: Color(0xFFBFDBFE)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(studentData['name']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(studentData['course']!,
                            style: const TextStyle(
                                color: Color(0xFFBFDBFE), fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(studentData['semester']!,
                            style: const TextStyle(
                                color: Color(0xFFBFDBFE), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Matrikelnummer',
                          style: TextStyle(
                              color: Color(0xFFBFDBFE), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        studentData['id']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Gültig bis',
                          style: TextStyle(
                              color: Color(0xFFBFDBFE), fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(studentData['validUntil']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------
  // QR Karte
  // -----------------------
  Widget _qrCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, size: 10, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('Verifiziert',
                    style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _qrWidget(),
          ),
          const SizedBox(height: 10),
          const Text('Scannen für Identifikation',
              style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
          const SizedBox(height: 4),
          const Text('Blockchain-verifizierte Identität',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // -----------------------
  // Informationen
  // -----------------------
  Widget _infoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Informationen',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          _infoRow(Icons.school_outlined, 'Studiengang', studentData['course']!),
          _infoRow(Icons.calendar_today_outlined, 'Semester',
              studentData['semester']!),
          _infoRow(Icons.location_on_outlined, 'Campus', studentData['campus']!),
          _infoRow(Icons.mail_outline, 'E-Mail', studentData['email']!),
          _infoRow(Icons.phone_outlined, 'Telefon', studentData['phone']!),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: const Color(0xFF2563EB)),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w600)),
    );
  }
  // -----------------------
  // Menü
  // -----------------------
  Widget _menuList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _menuItem(Icons.settings_outlined, 'Einstellungen', onTap: () {}),
          _divider(),
          _menuItem(Icons.notifications_none_outlined, 'Benachrichtigungen',
              badge: '3', onTap: () {}),
          _divider(),
          _menuItem(Icons.shield_outlined, 'Sicherheit & Datenschutz',
              onTap: () {}),
          _divider(),
          _menuItem(Icons.credit_card_outlined, 'Zahlungsmethoden', onTap: () {}),
          _divider(),
          _menuItem(
            Icons.help_outline,
            'Hilfe & Support',
            onTap: () => setState(() => _showHelpSupport = true),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));

  Widget _menuItem(IconData icon, String label,
      {String? badge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600)),
            ),
            if (badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
            ],
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // -----------------------
  // App Info
  // -----------------------
  Widget _appInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('App-Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _kvRow('Version', '1.0.0'),
          const SizedBox(height: 10),
          _kvRow('Blockchain Network', 'THWS Chain'),
          const SizedBox(height: 10),
          _kvRow('Contract Version', '2.1.0'),
        ],
      ),
    );
  }

  Widget _kvRow(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        Text(v,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  // -----------------------
  // Logout
  // -----------------------
  Widget _logoutButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
      label: const Text('Abmelden',
          style: TextStyle(
              color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFFFEE2E2),
        side: const BorderSide(color: Color(0xFFFCA5A5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  // -----------------------
  // Footer
  // -----------------------
  Widget _footer() {
    return const Column(
      children: [
        Text(
          '© 2025 THWS - Technische Hochschule Würzburg-Schweinfurt',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        SizedBox(height: 6),
        Text(
          'Powered by Blockchain Technology',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
