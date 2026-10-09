import 'package:flutter/material.dart';
import '../../widgets/floating_nav_bar.dart';
import 'home_dashboard_screen.dart';
import 'qr_code_screen.dart';
import 'menus_screen.dart';

// Écrans désactivés temporairement (voir plus bas) — imports conservés
// pour réactivation future sans avoir à les re-écrire.
// import 'tickets_screen.dart';
// import 'history_screen.dart';

/// NAVBAR CLIENT — VERSION RÉDUITE (phase actuelle du projet)
/// Seuls QR Code, Accueil et Menus sont exposés en onglets principaux.
/// Tickets et Historique restent accessibles via les actions rapides du
/// tableau de bord (voir home_dashboard_screen.dart) en attendant leur
/// réactivation en tant qu'onglets de navbar.
class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  static const int _centerIndex = 1; // Accueil au centre

  int _index = _centerIndex;

  void _goTo(int index) => setState(() => _index = index);

  late final List<Widget> _screens = [
    const QRCodeScreen(),
    HomeDashboardScreen(onNavigate: _goTo),
    const MenusScreen(),
  ];

  static const _leftItems = [
    NavItem(
        icon: Icons.qr_code_2_outlined,
        selectedIcon: Icons.qr_code_2,
        label: 'QR Code'),
  ];

  static const _centerItem = NavItem(
      icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Accueil');

  static const _rightItems = [
    NavItem(
        icon: Icons.restaurant_menu_outlined,
        selectedIcon: Icons.restaurant_menu,
        label: 'Menus'),
  ];

  // ── Version complète (5 onglets) — à restaurer plus tard ────────────
  // late final List<Widget> _screens = [
  //   const TicketsScreen(),
  //   const QRCodeScreen(),
  //   HomeDashboardScreen(onNavigate: _goTo),
  //   const MenusScreen(),
  //   const HistoryScreen(),
  // ];
  //
  // static const _leftItems = [
  //   NavItem(icon: Icons.confirmation_number_outlined, selectedIcon: Icons.confirmation_number, label: 'Tickets'),
  //   NavItem(icon: Icons.qr_code_2_outlined, selectedIcon: Icons.qr_code_2, label: 'QR Code'),
  // ];
  //
  // static const _rightItems = [
  //   NavItem(icon: Icons.restaurant_menu_outlined, selectedIcon: Icons.restaurant_menu, label: 'Menus'),
  //   NavItem(icon: Icons.history, label: 'Historique'),
  // ];

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
