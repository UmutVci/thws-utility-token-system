import 'package:flutter/material.dart';

import '../wohnheim_machines_page.dart';

class MachineInfo {
  final String label;
  final String type; // Waschmaschine oder Trockner
  final bool available;

  const MachineInfo({
    required this.label,
    required this.type,
    required this.available,
  });
}

class MachineGroup {
  final String title;
  final List<MachineInfo> machines;

  const MachineGroup({
    required this.title,
    required this.machines,
  });
}

class WohnheimStandorteSection extends StatelessWidget {
  const WohnheimStandorteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Standorte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _CityCard(
            cityTitle: 'Würzburg',
            items: [
              _WohnheimItem(
                name: 'Am Galgenberg',
                address: 'Am Galgenberg 52, 97074 Würzburg',
                groups: [
                  MachineGroup(
                    title: 'Waschraum',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: true),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: false),
                    ],
                  ),
                ],
              ),
              _WohnheimItem(
                name: 'Leo-Weismantel-Straße',
                address: 'Leo-Weismantel-Straße 1, 97074 Würzburg',
                groups: [
                  MachineGroup(
                    title: 'Haus A',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: true),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: false),
                    ],
                  ),
                  MachineGroup(
                    title: 'Haus C',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: false),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: true),
                    ],
                  ),
                ],
              ),
              _WohnheimItem(
                name: 'Landsteinerstraße',
                address: 'Landsteinerstraße 3, 97074 Würzburg',
                groups: [
                  MachineGroup(
                    title: 'Waschraum',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: false),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: true),
                    ],
                  ),
                ],
              ),
              _WohnheimItem(
                name: 'Josef-Martin-Weg',
                address: 'Josef-Martin-Weg, 97074 Würzburg',
                groups: [
                  MachineGroup(
                    title: 'Waschraum',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: true),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: false),
                    ],
                  ),
                ],
              ),
              _WohnheimItem(
                name: 'Peter-Schneider-Straße',
                address: 'Peter-Schneider-Straße, Würzburg',
                groups: [
                  MachineGroup(
                    title: 'Waschraum',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: true),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: false),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CityCard(
            cityTitle: 'Schweinfurt',
            items: [
              _WohnheimItem(
                name: 'Florian-Geyer-Strasse Wohnheim',
                address: 'Florian-Geyer-Strasse 7-9, 97421 Schweinfurt',
                groups: [
                  MachineGroup(
                    title: 'Waschraum',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: false),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: true),
                    ],
                  ),
                ],
              ),
              _WohnheimItem(
                name: 'Marie-Curie-Platz Wohnheim',
                address: 'Marie-Curie-Platz 2, 97424 Schweinfurt',
                groups: [
                  MachineGroup(
                    title: 'Waschraum',
                    machines: [
                      const MachineInfo(label: 'Waschmaschine 1', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 2', type: 'Waschmaschine', available: true),
                      const MachineInfo(label: 'Waschmaschine 3', type: 'Waschmaschine', available: false),
                      const MachineInfo(label: 'Trockner 1', type: 'Trockner', available: true),
                      const MachineInfo(label: 'Trockner 2', type: 'Trockner', available: false),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  final String cityTitle;
  final List<_WohnheimItem> items;

  const _CityCard({
    required this.cityTitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E6F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cityTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE8EDF5)),
          const SizedBox(height: 10),
          ...items.map((e) => e),
        ],
      ),
    );
  }
}

class _WohnheimItem extends StatelessWidget {
  final String name;
  final String address;
  final List<MachineGroup> groups;

  const _WohnheimItem({
    required this.name,
    required this.address,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
              TextButton.icon(
                onPressed: () => _openMachines(context),
                icon: const Icon(Icons.local_laundry_service, color: Color(0xFF2563EB)),
                label: const Text(
                  'Waschmaschinen anzeigen',
                  style: TextStyle(color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFEDEFF6)),
        ],
      ),
    );
  }

  void _openMachines(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WohnheimMachinesPage(
          title: name,
          address: address,
          groups: groups,
        ),
      ),
    );
  }
}
