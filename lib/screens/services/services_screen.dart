import 'package:flutter/material.dart';
import 'services_header.dart';
import 'widgets/services_grid.dart';
import 'mensa/mensa_cafeteria_page.dart';

enum ServicesView {
  grid,
  mensa,
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  ServicesView _view = ServicesView.grid;

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_view) {
      case ServicesView.grid:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ServicesHeader(),
            const SizedBox(height: 24),
            ServicesGrid(
              onMensaTap: () {
                setState(() {
                  _view = ServicesView.mensa;
                });
              },
            ),
          ],
        );
        break;

      case ServicesView.mensa:
        content = LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: MensaCafeteriaPage(
                onBack: () {
                  setState(() {
                    _view = ServicesView.grid;
                  });
                },
              ),
            );
          },
        );
        break;
    }

    final EdgeInsets contentPadding =
        _view == ServicesView.mensa ? EdgeInsets.zero : const EdgeInsets.all(20);

    return SafeArea(
      child: SingleChildScrollView(
        padding: contentPadding,
        child: content,
      ),
    );
  }
}
