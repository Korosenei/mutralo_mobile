import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gestionnaire_espace_provider.dart';
import '../../widgets/floating_nav_bar.dart';
import 'home_dashboard_screen.dart';
import 'menus_management_screen.dart';
import 'scanner_screen.dart';

// Écrans désactivés temporairement en tant qu'onglets de navbar — imports
// conservés pour réactivation future. Toujours accessibles en poussant la
// route depuis le tableau de bord (voir home_dashboard_screen.dart).
// import 'consommations_screen.dart';
// import 'agences_screen.dart';
// import 'reservations_screen.dart';

/// NAVBAR GESTIONNAIRE — VERSION RÉDUITE (phase actuelle du projet)
/// Accueil est désormais centré (même logique que côté client). Scanner
/// est à gauche, Menus à droite. Consommations, Agences et Réservations
/// restent accessibles via les actions rapides du tableau de bord en
/// attendant leur éventuelle réactivation en tant qu'onglets.
class GestionnaireHome extends StatefulWidget {
  const GestionnaireHome({super.key});

  @override
  State<GestionnaireHome> createState() => _GestionnaireHomeState();
}

class _GestionnaireHomeState extends State<GestionnaireHome> {
  static const int _centerIndex =
      1; // Accueil au centre (0=Scanner, 1=Accueil, 2=Menus)

  int _index = _centerIndex;

  void _goTo(int index) => setState(() => _index = index);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final utilisateur = context.read<AuthProvider>().utilisateur;
      if (utilisateur != null)
        context.read<GestionnaireEspaceProvider>().initialiser(utilisateur);
    });
  }

  late final List<Widget> _screens = [
    const ScannerScreen(),
    GestionnaireHomeDashboardScreen(onNavigate: _goTo),
    const MenusManagementScreen(),
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
  //   const ConsommationsScreen(),
  //   const MenusManagementScreen(),
  //   const ScannerScreen(),
  //   const ReservationsGestionnaireScreen(),
  //   const AgencesScreen(),
  // ];
  //
  // static const _leftItems = [
  //   NavItem(icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: 'Consommations'),
  //   NavItem(icon: Icons.restaurant_menu_outlined, selectedIcon: Icons.restaurant_menu, label: 'Menus'),
  // ];
  //
  // static const _rightItems = [
  //   NavItem(icon: Icons.event_note_outlined, selectedIcon: Icons.event_note, label: 'Réservations'),
  //   NavItem(icon: Icons.apartment_outlined, selectedIcon: Icons.apartment, label: 'Agences'),
  // ];

  @override
  Widget build(BuildContext context) {
    final estProgramme =
        context.watch<GestionnaireEspaceProvider>().estProgramme;

    // Scanner n'est plus l'item central (verrouillable via centerVerrouille)
    // — on reflète donc l'état "non programmé" directement sur son icône,
    // dans le même esprit que le cadenas central utilisé auparavant.
    final leftItems = [
      NavItem(
        icon:
            estProgramme ? Icons.qr_code_scanner_outlined : Icons.lock_outline,
        selectedIcon: estProgramme ? Icons.qr_code_scanner : Icons.lock_outline,
        label: 'Scanner',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: FloatingNavBar(
        leftItems: leftItems,
        centerItem: _centerItem,
        rightItems: _rightItems,
        currentIndex: _index,
        onTap: _goTo,
      ),
    );
  }
}
