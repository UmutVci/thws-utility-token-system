import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StandorteSection extends StatelessWidget {
  const StandorteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Standorte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          _CityCard(
            cityTitle: 'Würzburg',
            items: const [
              _LocationItem(
                name: 'Mensa Josef-Schneider-Straße Würzburg',
                distanceText: ' ',
                address: 'Josef-Schneider-Straße 9, 97080 Würzburg',
              ),
              _LocationItem(
                name: 'Mensa Röntgenring Würzburg',
                distanceText: ' ',
                address: 'Röntgenring 12, 97070 Würzburg',
              ),
              _LocationItem(
                name: 'Mensa am Studentenhaus Würzburg',
                distanceText: ' ',
                address: 'Am Studentenhaus, 97072 Würzburg',
              ),
              _LocationItem(
                name: 'Mensateria Campus Hubland Nord Würzburg',
                distanceText: ' ',
                address: 'Magdalene-Schoch-Straße, 97074 Würzburg',
              ),
              _LocationItem(
                name: 'Mensa Campus Hubland Süd Würzburg',
                distanceText: ' ',
                address: 'Am Hubland, 97074 Würzburg',
              ),
            ],
          ),

          const SizedBox(height: 16),

          _CityCard(
            cityTitle: 'Schweinfurt',
            items: const [
              _LocationItem(
                name: 'Mensa THWS Campus Schweinfurt',
                distanceText: ' ',
                address: 'Fritz-Drescher-Straße 1, 97421 Schweinfurt',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  final String cityTitle;
  final List<_LocationItem> items;

  const _CityCard({
    required this.cityTitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E6F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cityTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }
}

class _LocationItem extends StatelessWidget {
  final String name;
  final String distanceText;
  final String address;

  const _LocationItem({
    required this.name,
    required this.distanceText,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                distanceText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => openGoogleMaps(address),
                icon: const Icon(Icons.map_outlined),
                color: const Color(0xFF2F54EB),
                tooltip: 'Google Maps öffnen',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFEDEFF6)),
        ],
      ),
    );
  }
}

/// Google Maps helper (TEK YER)
Future<void> openGoogleMaps(String address) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
  );

  final launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!launched) {
    debugPrint('Google Maps açılamadı: $uri');
  }
}
