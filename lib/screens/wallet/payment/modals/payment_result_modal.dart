import 'package:flutter/material.dart';

class PaymentResultModal extends StatefulWidget {
  final bool success;
  final VoidCallback onClose;

  const PaymentResultModal({
    super.key,
    required this.success,
    required this.onClose,
  });

  @override
  State<PaymentResultModal> createState() => _PaymentResultModalState();
}

class _PaymentResultModalState extends State<PaymentResultModal> {
  @override
  void initState() {
    super.initState();

    // 5 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.success ? Colors.green : Colors.red;
    final icon = widget.success ? Icons.check_circle : Icons.error;
    final title =
        widget.success ? 'Zahlung erfolgreich' : 'Zahlung fehlgeschlagen';
    final description = widget.success
        ? 'Der Betrag wurde erfolgreich bezahlt.'
        : 'Bitte versuche es erneut.';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 72),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onClose,
              child: const Text('Zurück'),
            ),
          ),
        ],
      ),
    );
  }
}
