import 'package:flutter/material.dart';
import 'services_header.dart';
import 'widgets/services_grid.dart';


class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ServicesHeader(),
            SizedBox(height: 24),
            ServicesGrid(),
          ],
        ),
      ),
    );
  }
}
