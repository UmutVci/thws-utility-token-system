import 'package:flutter/material.dart';
import 'widgets/employee_header.dart';
import 'widgets/employee_qr_card.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7BB03C),
      body: SafeArea(
        child: Column(
          children: const [
            EmployeeHeader(),
            Expanded(
              child: EmployeeQrCard(),
            ),
          ],
        ),
      ),
    );
  }
}
