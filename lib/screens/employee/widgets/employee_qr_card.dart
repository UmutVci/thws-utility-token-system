import 'package:flutter/material.dart';
import 'employee_price_input.dart';
import 'employee_primary_button.dart';

class EmployeeQrCard extends StatelessWidget {
  const EmployeeQrCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: const [
          SizedBox(height: 12),
          CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFE9EEFF),
            child: Icon(Icons.qr_code_2, size: 36, color: Color(0xFF3E581E)),
          ),
          SizedBox(height: 20),
          Text(
            'Enter Payment Amount',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'The QR code will be generated\nwith this price',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 24),
          EmployeePriceInput(),
          Spacer(),
          EmployeePrimaryButton(),
        ],
      ),
    );
  }
}
