import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consommations_provider.dart';
import '../../providers/gestionnaire_espace_provider.dart';
import '../../providers/gestionnaire_reservation_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/state_widgets.dart';
import 'agences_screen.dart';
import 'consommations_screen.dart';
import 'reservations_screen.dart';

/// TABLEAU DE BORD GESTIONNAIRE — écran d'accueil par défaut à la connexion.
/// Quelques stats clés (consommations + réservations en attente) et des
/// actions rapides vers les sections principales, y compris celles qui ne
/// sont plus des onglets de navbar pour l'instant (Consommations, Agences,
/// Réservations) mais qui restent accessibles d'ici via Navigator.push.
class GestionnaireHomeDashboardScreen extends StatefulWidget {
  /// [onNavigate] cible les index de la navbar réduite définie dans
  /// gestionnaire_home.dart : 0 = Scanner, 1 = Accueil (ici), 2 = Menus.
  /// Réservations, Consommations et Agences n'ont PAS d'index de navbar
  /// (ce ne sont pas des onglets) — elles s'ouvrent via Navigator.push.
  final ValueChanged<int> onNavigate;
  const GestionnaireHomeDashboardScreen({super.key, required this.onNavigate});

  @override
  State<GestionnaireHomeDashboardScreen> createState() =>
      _GestionnaireHomeDashboardScreenState();
}

class _GestionnaireHomeDashboardScreenState
    extends State<GestionnaireHomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsommationsProvider>().charger();
      context
          .read<GestionnaireReservationProvider>()
          .charger(statut: 'EN_ATTENTE');
      final utilisateur = context.read<AuthProvider>().utilisateur;
      if (utilisateur != null) {
        context.read<GestionnaireEspaceProvider>().initialiser(utilisateur);
      }
    });
  }

  String _salutation() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final espace = context.watch<GestionnaireEspaceProvider>();
    final consoStats = context.watch<ConsommationsProvider>().stats;
    final reservationsEnAttente =
        context.watch<GestionnaireReservationProvider>().reservations.length;

    return Scaffold(
      appBar: AppHeader(
          titre: Text('${_salutation()}, ${utilisateur?.prenom ?? ''} 👋')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ConsommationsProvider>().charger();
            context
                .read<GestionnaireReservationProvider>()
                .charger(statut: 'EN_ATTENTE');
            if (utilisateur != null) {
              await context
                  .read<GestionnaireEspaceProvider>()
                  .rafraichir(utilisateur);
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 110),
            children: [
              if (utilisateur?.restaurantGereNom != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(utilisateur!.restaurantGereNom!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              if (!espace.chargement && !espace.estProgramme)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: BandeauInfo(
                    icone: Icons.info_outline,
                    message:
                        "Restaurant non programmé aujourd'hui — le scanner est désactivé.",
                  ),
                ),
              // ── Cartes stats (2x2) ──────────────────────────────────
              Row(
                children: [
                  Expanded(
                      child: _StatCard(
                          label: "Aujourd'hui",
                          value: '${consoStats?.aujourdhui ?? 0}',
                          icon: Icons.today_outlined,
                          color: AppColors.primary)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: _StatCard(
                          label: 'Cette semaine',
                          value: '${consoStats?.cetteSemaine ?? 0}',
                          icon: Icons.calendar_view_week_outlined,
                          color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                      child: _StatCard(
                          label: 'Ce mois',
                          value: '${consoStats?.ceMois ?? 0}',
                          icon: Icons.calendar_month_outlined,
                          color: AppColors.warning)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: _StatCard(
                          label: 'Réservations en attente',
                          value: '$reservationsEnAttente',
                          icon: Icons.event_note_outlined,
                          color: AppColors.primaryDark)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Actions rapides ─────────────────────────────────────
              // Index de navbar réels (voir gestionnaire_home.dart) :
              // 0 = Scanner, 1 = Accueil, 2 = Menus.
              Row(
                children: [
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.qr_code_scanner,
                          label: 'Scanner',
                          onTap: () => widget.onNavigate(0))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.restaurant_menu,
                          label: 'Mes menus',
                          onTap: () => widget.onNavigate(
                              2))), // ← corrigé (était 1, pointait vers Accueil)
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.event_note_outlined,
                          label: 'Réservations',
                          // ← corrigé : ce n'est pas un onglet de navbar,
                          // onNavigate(3) n'existait pas et faisait planter
                          // l'IndexedStack. On pousse la route à la place,
                          // comme pour Consommations et Agences.
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ReservationsGestionnaireScreen())))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.bar_chart_outlined,
                      label: 'Consommations',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ConsommationsScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _QuickAction(
                icon: Icons.apartment_outlined,
                label: 'Mes agences',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AgencesScreen())),
                pleineLargeur: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool pleineLargeur;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.pleineLargeur = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: pleineLargeur ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md)),
        child: pleineLargeur
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              )
            : Column(
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(height: 4),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
