import 'package:flutter/material.dart';

import '../../services/user_session_service.dart';
import 'widgets/employee_header.dart';
import 'widgets/employee_qr_card.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final _sessionService = UserSessionService();
  String _displayName = 'Mitarbeitende/r';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final savedName = await _sessionService.getDisplayName();
    final fallbackUsername = await _sessionService.getEmployeeUsername();
    final next = (savedName ?? fallbackUsername ?? '').trim();
    if (!mounted || next.isEmpty) return;
    setState(() => _displayName = next);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF7BB03C),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      EmployeeHeader(displayName: _displayName),
                      const EmployeeQrCard(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
