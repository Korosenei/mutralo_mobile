import 'package:flutter/material.dart';
import '../../widgets/floating_nav_bar.dart';
import '../client/notifications_screen.dart';
import '../client/profile_screen.dart';
import 'scanner_screen.dart';
import 'consommations_screen.dart';

class GestionnaireHome extends StatefulWidget {
  const GestionnaireHome({super.key});

  @override
  State<GestionnaireHome> createState() => _GestionnaireHomeState();
}

class _GestionnaireHomeState extends State<GestionnaireHome> {
  static const int _centerIndex = 1; // Scanner au centre

  int _index = _centerIndex;

  void _goTo(int index) => setState(() => _index = index);

  final _screens = const [
    ConsommationsScreen(),
    ScannerScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  static const _leftItems = [
    NavItem(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Consommations',
    ),
  ];

  static const _centerItem = NavItem(
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner,
    label: 'Scanner',
  );

  static const _rightItems = [
    NavItem(
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      label: 'Notifications',
    ),
    NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: FloatingNavBar(
        leftItems: _leftItems,
        centerItem: _centerItem,
        rightItems: _rightItems,
        currentIndex: _index,
        onTap: _goTo,
      ),
    );
  }
}
