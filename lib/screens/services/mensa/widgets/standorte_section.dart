import 'package:flutter/material.dart';

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
                name: 'Mensa WÜ (Dummy)',
                distanceText: '—',
                address: 'Adresse folgt',
                hours: 'Öffnungszeiten folgt',
              ),
              _LocationItem(
                name: 'Cafeteria WÜ (Dummy)',
                distanceText: '—',
                address: 'Adresse folgt',
                hours: 'Öffnungszeiten folgt',
              ),
            ],
          ),

          const SizedBox(height: 16),

          _CityCard(
            cityTitle: 'Schweinfurt',
            items: const [
              _LocationItem(
                name: 'Mensa SHL (Dummy)',
                distanceText: '—',
                address: 'Adresse folgt',
                hours: 'Öffnungszeiten folgt',
              ),
              _LocationItem(
                name: 'Cafeteria SHL (Dummy)',
                distanceText: '—',
                address: 'Adresse folgt',
                hours: 'Öffnungszeiten folgt',
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
          ...items.map((e) => e),
        ],
      ),
    );
  }
}

class _LocationItem extends StatelessWidget {
  final String name;
  final String distanceText;
  final String address;
  final String hours;

  const _LocationItem({
    required this.name,
    required this.distanceText,
    required this.address,
    required this.hours,
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

              // Google Maps butonu için placeholder
              // Sonra sen buraya launchUrl ile link bağlarsın.
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.map_outlined),
                color: const Color(0xFF2F54EB),
                tooltip: 'Google Maps öffnen',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hours,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
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
