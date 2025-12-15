import 'package:flutter/material.dart';

class EmployeePrimaryButton extends StatelessWidget {
  const EmployeePrimaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E581E), Color(0xFF567B2A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          'Generate QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
