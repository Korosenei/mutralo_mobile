import 'package:flutter/material.dart';
import '../../widgets/floating_nav_bar.dart';
import 'home_dashboard_screen.dart';
import 'tickets_screen.dart';
import 'qr_code_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  static const int _centerIndex = 2; // Accueil au centre

  int _index = _centerIndex;

  void _goTo(int index) => setState(() => _index = index);

  late final List<Widget> _screens = [
    const TicketsScreen(),
    const QRCodeScreen(),
    HomeDashboardScreen(onNavigate: _goTo),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  static const _leftItems = [
    NavItem(
      icon: Icons.confirmation_number_outlined,
      selectedIcon: Icons.confirmation_number,
      label: 'Tickets',
    ),
    NavItem(
      icon: Icons.qr_code_2_outlined,
      selectedIcon: Icons.qr_code_2,
      label: 'QR Code',
    ),
  ];

  static const _centerItem = NavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Accueil',
  );

  static const _rightItems = [
    NavItem(icon: Icons.history, label: 'Historique'),
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
