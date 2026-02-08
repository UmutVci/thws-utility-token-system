import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmployeePriceInput extends StatelessWidget {
  final TextEditingController controller;

  const EmployeePriceInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price (THWS)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]{0,2}')),
          ],
          decoration: InputDecoration(
            suffixText: 'THWS',
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
