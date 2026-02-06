import 'package:flutter/material.dart';
import 'add_money/modals/add_money_modal.dart';
import 'payment/payment_qr_screen.dart';

class WalletBalanceCard extends StatefulWidget {
  const WalletBalanceCard({
    super.key,
    required this.isConnected,
    this.balanceText,
    this.onRefresh,
  });

  final bool isConnected;
  final String? balanceText;
  final Future<void> Function()? onRefresh;

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard> {
  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final String displayBalance;
    if (!widget.isConnected) {
      displayBalance = '—';
    } else if (widget.balanceText != null) {
      displayBalance = '${widget.balanceText} THWS';
    } else {
      displayBalance = 'Lade...';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2F5BEA),
            Color(0xFF2747C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                'THWS Coin Guthaben',
                style: TextStyle(color: Colors.white70),
              ),
              Row(
                children: [
                  if (widget.onRefresh != null && widget.isConnected)
                    IconButton(
                      onPressed: widget.onRefresh,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: Icon(
                      _isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Balance
         Text(
            _isBalanceVisible ? displayBalance : '•••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (_isBalanceVisible && widget.isConnected && widget.balanceText != null) ...[
            const SizedBox(height: 4),
            const Text(
              'On-chain THWS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.add,
                  label: 'Aufladen',
                  filled: false,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      builder: (_) => const AddMoneyModal(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.qr_code,
                  label: 'Zahlen',
                  filled: true,
                  onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentQrScreen(),
        ),
      );
    },
                ),
              ),
            ],
          ),
        ],
      ),
      );
    
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? Colors.blue : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.blue : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
