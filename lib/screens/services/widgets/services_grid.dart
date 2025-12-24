import 'package:flutter/material.dart';
import 'service_card.dart';
import 'service_info_box.dart';

class ServicesGrid extends StatelessWidget {
  final VoidCallback onMensaTap;

  const ServicesGrid({
    super.key,
    required this.onMensaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            ServiceCard(
              icon: Icons.local_cafe,
              iconBg: const Color(0xFFFFEED6),
              title: 'Mensa & Cafeteria',
              subtitle: 'Bezahlung in allen Mensen',
              onTap: onMensaTap, // 🔑 sadece callback
            ),
            const ServiceCard(
              icon: Icons.menu_book,
              iconBg: Color(0xFFEDE3FF),
              title: 'Bibliothek',
              subtitle: 'Ausleihen & Gebühren',
            ),
            const ServiceCard(
              icon: Icons.home,
              iconBg: Color(0xFFE6F0FF),
              title: 'Wohnheim',
              subtitle: 'Waschmaschine & Services',
            ),
            const ServiceCard(
              icon: Icons.confirmation_number,
              iconBg: Color(0xFFE8F9EC),
              title: 'Semesterticket',
              subtitle: 'Digitales Ticket WÜ-Region',
              badge: 'Neu',
            ),
            const ServiceCard(
              icon: Icons.how_to_vote,
              iconBg: Color(0xFFE9ECFF),
              title: 'Abstimmungen',
              subtitle: 'Umfragen & Wahlen',
            ),
            const ServiceCard(
              icon: Icons.card_giftcard,
              iconBg: Color(0xFFFFE6F1),
              title: 'Partner-Angebote',
              subtitle: 'Rabatte & Aktionen',
              badge: '15% Rabatt',
            ),
          ],
        ),
        const SizedBox(height: 20),
        const ServiceInfoBox(),
      ],
    );
  }
}
