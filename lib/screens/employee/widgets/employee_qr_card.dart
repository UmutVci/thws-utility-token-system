import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'employee_price_input.dart';
import 'employee_primary_button.dart';

class EmployeeQrCard extends StatefulWidget {
  const EmployeeQrCard({super.key});

  @override
  State<EmployeeQrCard> createState() => _EmployeeQrCardState();
}

class _EmployeeQrCardState extends State<EmployeeQrCard> {
  final TextEditingController _priceController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _generateQr(BuildContext context) {
    final raw = _priceController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);

    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Bitte einen Betrag größer 0 eingeben.';
      });
      return;
    }

    final amountMinor = (amount * 100).round(); // 2 decimals
    final orderId = DateTime.now().millisecondsSinceEpoch;

    // QR-Payload kompatibel zum Parser in payment_qr_screen halten.
    final payload = jsonEncode({
      'service': 'MENSA',
      'amount': amountMinor,
      'orderId': orderId,
    });

    setState(() {
      _error = null;
    });

    _showQrSheet(context, payload);
  }

  void _showQrSheet(BuildContext rootContext, String data) {
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'QR-Code für Zahlung',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: QrImageView(
                              data: data,
                              size: 220,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Studierende scannen diesen QR-Code und bestätigen die Zahlung in MetaMask.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFE9EEFF),
            child: Icon(Icons.qr_code_2, size: 36, color: Color(0xFF3E581E)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Zahlungsbetrag eingeben',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Der QR-Code wird mit diesem THWS-Betrag erzeugt',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          EmployeePriceInput(controller: _priceController),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          EmployeePrimaryButton(
            onTap: () => _generateQr(context),
          ),
        ],
      ),
    );
  }
}
