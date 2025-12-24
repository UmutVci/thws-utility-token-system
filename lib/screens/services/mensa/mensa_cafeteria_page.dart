import 'package:flutter/material.dart';
import 'widgets/mensa_header.dart';
import 'widgets/mensa_pay_card.dart';
import 'widgets/standorte_section.dart';

class MensaCafeteriaPage extends StatelessWidget {
  final VoidCallback onBack;

  const MensaCafeteriaPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MensaHeader(onBack: onBack),

        const SizedBox(height: 16),

        const MensaPayCard(),

        const SizedBox(height: 24),

        const StandorteSection(),

        const SizedBox(height: 24),
      ],
    );
  }
}
