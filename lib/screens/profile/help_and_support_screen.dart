import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const HelpSupportScreen({super.key, this.onBack});

  static const String _hotlineLabel = '+49 0931 135 65 84';
  static const String _hotlineTel = 'tel:+499311356584';

  static const String _mailLabel = 'info@thws-token.com';
  static const String _mailTo =
      'mailto:info@thws-token.com?subject=Support%20Anfrage&body=Hallo%20THWS%20Token%20Team,%0A%0A';

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
                    'Hilfe & Support',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      title: 'Hotline',
                      subtitle: _hotlineLabel,
                      icon: Icons.call_outlined,
                      onTap: () => _open(_hotlineTel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      title: 'E-Mail',
                      subtitle: _mailLabel,
                      icon: Icons.mail_outline,
                      onTap: () => _open(_mailTo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _LinkCard(
                title: 'THWS – HSST (Hochschulservice Studium)',
                subtitle:
                    'Organisation, Services und Anlaufstellen rund ums Studium.',
                url:
                    'https://www.thws.de/hochschule/organisation/hochschulservices/hochschulservice-studium/',
                leading: const _LogoCircle(assetPath: 'assets/icons/thws.png'),
              ),

              _LinkCard(
                title: 'Studierendenwerk Würzburg – Offene Beratung',
                subtitle:
                    'Sozialberatung, Unterstützung & Beratung für Studierende.',
                url: 'https://www.swerk-wue.de/beratung/offenes-beratungsangebot',
                leading: const _LogoCircle(assetPath: 'assets/icons/swerk.png'),
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String url;
  final Widget leading;

  const _LinkCard({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => HelpSupportScreen._open(url),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.open_in_new, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  final String assetPath;

  const _LogoCircle({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
