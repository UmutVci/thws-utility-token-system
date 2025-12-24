import 'package:flutter/material.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/services/services_screen.dart';
import '../screens/profile/profile_screen.dart';

import 'app_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex = widget.initialIndex;

 final List<Widget> _pages = const [
  WalletScreen(),
  ServicesScreen(),
  ProfilePage(),
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
