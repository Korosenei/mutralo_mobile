import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/gestionnaire_reservation_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/state_widgets.dart';

/// Le gestionnaire ne voit que les réservations du jour J et des jours à
/// venir (pas d'historique passé), et seulement les statuts EN_ATTENTE /
/// CONFIRME. Il peut confirmer ou refuser une réservation en attente —
/// jamais la "terminer" manuellement : une réservation passe à TERMINE
/// uniquement via le scan QR au moment où le plat est réellement
/// consommé (ScannerService.valider côté backend).
///
/// Navigation par jour (aujourd'hui + jours à venir ayant des réservations)
/// pour que le gestionnaire puisse traiter les réservations des jours
/// suivants sans qu'elles soient noyées dans une liste unique.
class ReservationsGestionnaireScreen extends StatefulWidget {
  const ReservationsGestionnaireScreen({super.key});

  @override
  State<ReservationsGestionnaireScreen> createState() =>
      _ReservationsGestionnaireScreenState();
}

class _ReservationsGestionnaireScreenState
    extends State<ReservationsGestionnaireScreen> {
  String _filtreStatut = 'EN_ATTENTE';
  DateTime? _jourSelectionne; // null = pas encore initialisé

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<GestionnaireReservationProvider>().charger());
  }

  DateTime _jourSeul(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _estAujourdhuiOuFutur(DateTime date) {
    final ref = _jourSeul(DateTime.now());
    return !_jourSeul(date).isBefore(ref);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GestionnaireReservationProvider>();
    final aujourdhui = _jourSeul(DateTime.now());

    // Réservations pertinentes : jour J et jours à venir, statuts actionnables.
    final reservationsVisibles = provider.reservations
        .where((r) =>
            (r.statut == 'EN_ATTENTE' || r.statut == 'CONFIRME') &&
            _estAujourdhuiOuFutur(r.dateReservation))
        .toList()
      ..sort((a, b) => a.dateReservation.compareTo(b.dateReservation));

    // Jours distincts présents (toujours inclure aujourd'hui même sans réservation,
    // pour que l'onglet reste visible).
    final joursDisponibles = <DateTime>{aujourdhui};
    for (final r in reservationsVisibles) {
      joursDisponibles.add(_jourSeul(r.dateReservation));
    }
    final jours = joursDisponibles.toList()..sort();

    _jourSelectionne ??= aujourdhui;
    if (!jours.contains(_jourSelectionne)) {
      _jourSelectionne = aujourdhui;
    }

    final reservationsDuJour = reservationsVisibles
        .where((r) => _jourSeul(r.dateReservation) == _jourSelectionne)
        .toList();
    final reservations =
        reservationsDuJour.where((r) => r.statut == _filtreStatut).toList();

    final nbEnAttente =
        reservationsDuJour.where((r) => r.statut == 'EN_ATTENTE').length;
    final nbConfirmees =
        reservationsDuJour.where((r) => r.statut == 'CONFIRME').length;

    return Scaffold(
      appBar: const AppHeader(titre: Text('Réservations')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<GestionnaireReservationProvider>().charger(),
          child: Column(
            children: [
              // ── Onglets de jour ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: jours.map((j) {
                      final selectionne = _jourSelectionne == j;
                      final estAujourdhui = j == aujourdhui;
                      final nb = reservationsVisibles
                          .where((r) => _jourSeul(r.dateReservation) == j)
                          .length;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(
                            '${estAujourdhui ? "Aujourd'hui" : '${j.day.toString().padLeft(2, '0')}/${j.month.toString().padLeft(2, '0')}'}${nb > 0 ? ' ($nb)' : ''}',
                          ),
                          selected: selectionne,
                          onSelected: (_) =>
                              setState(() => _jourSelectionne = j),
                          selectedColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            color: selectionne
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight:
                                selectionne ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // ── Onglets de statut (pour le jour sélectionné) ────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ChipStatut(
                        label:
                            'En attente${nbEnAttente > 0 ? ' ($nbEnAttente)' : ''}',
                        selectionne: _filtreStatut == 'EN_ATTENTE',
                        onTap: () =>
                            setState(() => _filtreStatut = 'EN_ATTENTE'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ChipStatut(
                        label:
                            'Confirmées${nbConfirmees > 0 ? ' ($nbConfirmees)' : ''}',
                        selectionne: _filtreStatut == 'CONFIRME',
                        onTap: () => setState(() => _filtreStatut = 'CONFIRME'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: provider.chargement && provider.reservations.isEmpty
                    ? const ChargementWidget()
                    : reservations.isEmpty
                        ? VideWidget(
                            icone: Icons.event_note_outlined,
                            message: _filtreStatut == 'EN_ATTENTE'
                                ? 'Aucune réservation en attente pour ce jour.'
                                : 'Aucune réservation confirmée pour ce jour.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg, 0, AppSpacing.lg, 110),
                            itemCount: reservations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) =>
                                _CarteReservationGestion(
                                    reservation: reservations[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipStatut extends StatelessWidget {
  final String label;
  final bool selectionne;
  final VoidCallback onTap;
  const _ChipStatut(
      {required this.label, required this.selectionne, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selectionne,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
          color: selectionne ? AppColors.primary : AppColors.textMuted,
          fontWeight: FontWeight.w600),
    );
  }
}

class _CarteReservationGestion extends StatelessWidget {
  final Reservation reservation;
  const _CarteReservationGestion({required this.reservation});

  Future<void> _refuser(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser cette réservation ?'),
        content: Text(
            'La réservation de "${reservation.clientNom ?? 'ce client'}" pour "${reservation.menuNom ?? ''}" sera annulée.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Retour')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Refuser',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirme == true && context.mounted) {
      await context
          .read<GestionnaireReservationProvider>()
          .refuser(reservation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reservation.clientNom ?? 'Client',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(reservation.menuNom ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (reservation.statut == 'EN_ATTENTE')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _refuser(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child:
                        const Text('Refuser', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<GestionnaireReservationProvider>()
                        .confirmer(reservation),
                    child:
                        const Text('Confirmer', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Confirmée — sera clôturée au scan du QR code',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
