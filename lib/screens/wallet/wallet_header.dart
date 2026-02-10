import 'package:flutter/material.dart';

import '../../services/user_session_service.dart';

class WalletHeader extends StatefulWidget {
  const WalletHeader({super.key});

  @override
  State<WalletHeader> createState() => _WalletHeaderState();
}

class _WalletHeaderState extends State<WalletHeader> {
  final _sessionService = UserSessionService();
  String _displayName = 'Studierende/r';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final savedName = await _sessionService.getDisplayName();
    final knummer = await _sessionService.getKnummer();
    final fallback = knummer == null ? null : 'Studierende/r $knummer';
    final next = (savedName ?? fallback ?? '').trim();
    if (!mounted || next.isEmpty) return;
    setState(() => _displayName = next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guten Tag,',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _displayName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
