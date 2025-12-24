import 'package:flutter/material.dart';

class MensaHeader extends StatelessWidget {
  final VoidCallback onBack;

  const MensaHeader({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170, // 🔑 mock’a yakın, kısa
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2F54EB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),  // 🔑 daha az radius
          bottomRight: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            ),
            const SizedBox(height: 14),
            const Text(
              'Mensa & Cafeteria',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22, // 🔑 mock’a daha yakın
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bezahlen Sie bequem mit THWS Coins in allen\nMensen und Cafeterias',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
