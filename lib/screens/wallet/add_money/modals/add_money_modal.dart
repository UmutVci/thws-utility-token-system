import 'package:flutter/material.dart';

/// ================= ENUM =================
/// ⚠️ Enum MUTLAKA dosya seviyesinde olmalı
enum PaymentMethod {
  sepa,
  card,
  paypal,
}

/// ================= MODAL =================

class AddMoneyModal extends StatefulWidget {
  const AddMoneyModal({super.key});

  @override
  State<AddMoneyModal> createState() => _AddMoneyModalState();
}

class _AddMoneyModalState extends State<AddMoneyModal> {
  int selectedAmount = 10;
  PaymentMethod selectedPayment = PaymentMethod.sepa;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===== SCROLLABLE CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    const SizedBox(height: 20),
                    _balanceCard(),
                    const SizedBox(height: 24),
                    _amountGrid(),
                    const SizedBox(height: 24),
                    _paymentMethods(),
                  ],
                ),
              ),
            ),

            // ===== FIXED BOTTOM ACTIONS =====
            _bottomActions(context),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Guthaben aufladen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  // ================= BALANCE CARD =================

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Aktuelles Guthaben',
            style: TextStyle(
              color: Color(0xFF2F5BEA),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '47.85 THWS',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('≈ 47.85 €', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // ================= AMOUNT GRID =================

  Widget _amountGrid() {
    final amounts = [5, 10, 20, 50];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Betrag wählen',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: amounts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (_, index) {
            final amount = amounts[index];
            final selected = selectedAmount == amount;

            return GestureDetector(
              onTap: () => setState(() => selectedAmount = amount),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFE9EEFF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2F5BEA)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$amount €',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '= $amount THWS',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= PAYMENT METHODS =================

  Widget _paymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zahlungsmethode',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        _paymentTile(
          value: PaymentMethod.sepa,
          icon: Icons.account_balance,
          title: 'SEPA Lastschrift',
          subtitle: 'Sofortige Gutschrift',
        ),

        _paymentTile(
          value: PaymentMethod.card,
          icon: Icons.credit_card,
          title: 'Kredit-/Debitkarte',
          subtitle: 'Visa, Mastercard',
        ),

        _paymentTile(
          value: PaymentMethod.paypal,
          icon: Icons.paypal,
          title: 'PayPal',
          subtitle: 'Schnell & sicher',
        ),
      ],
    );
  }

  Widget _paymentTile({
    required PaymentMethod value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = selectedPayment == value;

    return GestureDetector(
      onTap: () => setState(() => selectedPayment = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF2F5BEA)
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF2F5BEA)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: const Color(0xFF2F5BEA),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM ACTIONS =================

  Widget _bottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Abbrechen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // ⏭️ Buradan sonra ödeme akışına geçeceğiz
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5BEA),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Aufladen'),
            ),
          ),
        ],
      ),
    );
  }
}
