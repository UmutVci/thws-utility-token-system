import 'package:flutter/material.dart';
import 'payment_qr_screen.dart';

void openPayment(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PaymentQrScreen(),
    ),
  );
}
