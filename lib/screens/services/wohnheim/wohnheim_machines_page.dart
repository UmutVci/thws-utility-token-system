import 'package:flutter/material.dart';

import '../../wallet/payment/payment_qr_screen.dart';
import '../../../layout/app_bottom_nav.dart';
import '../../../layout/main_layout.dart';
import 'widgets/wohnheim_standorte_section.dart';

class WohnheimMachinesPage extends StatelessWidget {
  final String title;
  final String address;
  final List<MachineGroup> groups;

  const WohnheimMachinesPage({
    super.key,
    required this.title,
    required this.address,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Waschmaschinen',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context);
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainLayout(initialIndex: index),
            ),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...groups.map(
            (group) => _MachineGroupCard(group: group),
          ),
        ],
      ),
    );
  }
}

class _MachineGroupCard extends StatelessWidget {
  final MachineGroup group;

  const _MachineGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final washers = group.machines.where((m) => m.type == 'Waschmaschine').toList();
    final dryers = group.machines.where((m) => m.type == 'Trockner').toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (washers.isNotEmpty) ...[
              const Text(
                'Waschmaschinen',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: washers.map((m) => _MachineTile(machine: m)).toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (dryers.isNotEmpty) ...[
              const Text(
                'Trockner',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: dryers.map((m) => _MachineTile(machine: m)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MachineTile extends StatelessWidget {
  final MachineInfo machine;

  const _MachineTile({required this.machine});

  @override
  Widget build(BuildContext context) {
    final color = machine.available ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bg = machine.available ? const Color(0xFFEFFDF4) : const Color(0xFFFFF2F2);

    return InkWell(
      onTap: machine.available
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentQrScreen()),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        constraints: const BoxConstraints(minHeight: 110),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_laundry_service, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    machine.type,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              machine.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              machine.available ? 'Verfügbar (zum Bezahlen tippen)' : 'Besetzt',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
