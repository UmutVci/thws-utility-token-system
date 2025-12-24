import 'package:flutter/material.dart';

import 'widgets/wohnheim_header.dart';
import 'widgets/wohnheim_standorte_section.dart';

class WohnheimPage extends StatelessWidget {
  final VoidCallback onBack;

  const WohnheimPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WohnheimHeader(onBack: onBack),
        const SizedBox(height: 20),
        const WohnheimStandorteSection(),
        const SizedBox(height: 24),
      ],
    );
  }
}
