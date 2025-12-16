import 'package:flutter/material.dart';
import 'modals/payment_result_modal.dart';


class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key});

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  bool _scanned = false;

  void _simulateScan({required bool success}) async {
    if (_scanned) return;
    setState(() => _scanned = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    showModalBottomSheet(
  context: context,
  isDismissible: false,
  enableDrag: false,
  backgroundColor: Colors.transparent,
  builder: (_) => PaymentResultModal(
    success: success,
    onClose: () {
      Navigator.pop(context); // modal
      Navigator.pop(context); // qr screen
    },
  ),
);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'QR scannen',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Kamera placeholder
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
            ),
          ),

          // Alt bilgi
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: const [
                Text(
                  'Halte den QR-Code in den Rahmen',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // DEBUG BUTONLAR (sonra silinecek)
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => _simulateScan(success: true),
                    child: const Text('Simulate Success'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _simulateScan(success: false),
                    child: const Text('Simulate Error'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

