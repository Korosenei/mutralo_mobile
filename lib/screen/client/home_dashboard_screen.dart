import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/log_consommation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/historique_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import 'reservations_screen.dart';

// Écrans désactivés temporairement côté navbar/actions rapides mais dont
// les fichiers restent intacts pour réactivation future.
// import 'history_screen.dart';
// import '../shared/classement_screen.dart';

/// TABLEAU DE BORD CLIENT — VERSION RÉDUITE (phase actuelle du projet)
/// Cartes conservées : Disponibles, Consommés (total), Valeur disponible.
/// Actions rapides conservées : Mon QR code, Menu du jour, Mes réservations.
/// "Dernières consommations" utilise l'historique (LogConsommation), seule
/// source qui porte le plat réellement consommé — un Ticket ne le sait pas.
class HomeDashboardScreen extends StatefulWidget {
  /// [onNavigate] cible les index de la navbar réduite : 0 = QR Code,
  /// 2 = Menus (voir client_home.dart).
  final ValueChanged<int> onNavigate;
  const HomeDashboardScreen({super.key, required this.onNavigate});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().charger();
      context.read<HistoriqueProvider>().charger();
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
    final ticketProvider = context.watch<TicketProvider>();
    final historiqueProvider = context.watch<HistoriqueProvider>();

    final disponibles = ticketProvider.disponibles;
    final consommes =
        ticketProvider.historique.where((t) => t.estConsomme).toList();
    final valeurDisponible = disponibles.fold<double>(
        0, (sum, t) => sum + (double.tryParse(t.prixPaye) ?? 0));

    // Déjà trié du plus récent au plus ancien par HistoriqueService — on
    // ne prend que les 3 premiers pour l'aperçu du tableau de bord.
    final dernieresConsommations =
        historiqueProvider.consommations.take(3).toList();

    return Scaffold(
      appBar: AppHeader(
          titre: Text('${_salutation()}, ${utilisateur?.prenom ?? ''} 👋')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<TicketProvider>().charger(),
              context.read<HistoriqueProvider>().charger(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 110),
            children: [
              if (utilisateur?.agenceNom != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(utilisateur!.agenceNom!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              // ── Cartes stats ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                      child: _StatCard(
                          label: 'Disponibles',
                          value: '${disponibles.length}',
                          icon: Icons.confirmation_number,
                          color: AppColors.primary)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: _StatCard(
                          label: 'Consommés',
                          value: '${consommes.length}',
                          icon: Icons.check_circle,
                          color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatCard(
                label: 'Valeur disponible',
                value: '${valeurDisponible.toStringAsFixed(0)} FCFA',
                icon: Icons.account_balance_wallet,
                color: AppColors.warning,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              // ── Actions rapides ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.qr_code_2,
                          label: 'Mon QR code',
                          onTap: () => widget.onNavigate(0))),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: _QuickAction(
                          icon: Icons.restaurant_menu,
                          label: 'Menu du jour',
                          onTap: () => widget.onNavigate(2))),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _QuickAction(
                icon: Icons.event_note_outlined,
                label: 'Mes réservations',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ReservationsScreen())),
                pleineLargeur: true,
              ),

              // ── Actions rapides désactivées temporairement ──────────
              // Expanded(
              //   child: _QuickAction(
              //     icon: Icons.history,
              //     label: 'Historique de consommation',
              //     onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
              //   ),
              // ),
              // _QuickAction(
              //   icon: Icons.emoji_events_outlined,
              //   label: 'Classement des plats & restaurants',
              //   onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClassementScreen())),
              //   pleineLargeur: true,
              // ),

              const SizedBox(height: AppSpacing.lg),
              const Text('Dernières consommations',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              if (dernieresConsommations.isEmpty &&
                  !historiqueProvider.chargement)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Text('Aucune consommation récente.',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 13)),
                )
              else
                ...dernieresConsommations
                    .map((c) => _LigneConsommation(consommation: c)),
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
  final bool fullWidth;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
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

/// Ligne "Dernières consommations" — précise à la fois le restaurant ET le
/// plat consommé (portés par LogConsommation, jamais par le Ticket seul).
class _LigneConsommation extends StatelessWidget {
  final LogConsommationClient consommation;
  const _LigneConsommation({required this.consommation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(consommation.menuNom ?? 'Plat consommé',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(consommation.restaurantNom,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${consommation.dateConsommation.day.toString().padLeft(2, '0')}/${consommation.dateConsommation.month.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
