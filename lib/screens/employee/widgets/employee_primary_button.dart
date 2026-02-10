import 'package:flutter/material.dart';

class EmployeePrimaryButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;

  const EmployeePrimaryButton({super.key, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final gradientColors = enabled
        ? const [Color(0xFF3E581E), Color(0xFF567B2A)]
        : const [Color(0xFF9FB786), Color(0xFF9FB786)];

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'QR-Code erzeugen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
