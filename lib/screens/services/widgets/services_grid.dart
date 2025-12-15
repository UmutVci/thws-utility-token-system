import 'package:flutter/material.dart';
import 'service_card.dart';
import 'service_info_box.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

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
          children: const [
            ServiceCard(
              icon: Icons.local_cafe,
              iconBg: Color(0xFFFFEED6),
              title: 'Mensa & Cafeteria',
              subtitle: 'Bezahlung in allen Mensen',
            ),
            ServiceCard(
              icon: Icons.menu_book,
              iconBg: Color(0xFFEDE3FF),
              title: 'Bibliothek',
              subtitle: 'Ausleihen & Gebühren',
            ),
            ServiceCard(
              icon: Icons.home,
              iconBg: Color(0xFFE6F0FF),
              title: 'Wohnheim',
              subtitle: 'Waschmaschine & Services',
            ),
            ServiceCard(
              icon: Icons.confirmation_number,
              iconBg: Color(0xFFE8F9EC),
              title: 'Semesterticket',
              subtitle: 'Digitales Ticket WÜ-Region',
              badge: 'Neu',
            ),
            ServiceCard(
              icon: Icons.how_to_vote,
              iconBg: Color(0xFFE9ECFF),
              title: 'Abstimmungen',
              subtitle: 'Umfragen & Wahlen',
            ),
            ServiceCard(
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
