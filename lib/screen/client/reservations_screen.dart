import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/reservation_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/state_widgets.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ReservationProvider>().chargerMesReservations());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes réservations')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<ReservationProvider>().chargerMesReservations(),
          child: provider.chargement && provider.mesReservations.isEmpty
              ? const ChargementWidget()
              : provider.mesReservations.isEmpty
                  ? const VideWidget(
                      icone: Icons.event_note_outlined,
                      message: "Vous n'avez aucune réservation.")
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: provider.mesReservations.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) => _CarteReservation(
                          reservation: provider.mesReservations[index]),
                    ),
        ),
      ),
    );
  }
}

class _CarteReservation extends StatelessWidget {
  final Reservation reservation;
  const _CarteReservation({required this.reservation});

  Color _couleurStatut() {
    switch (reservation.statut) {
      case 'CONFIRME':
        return AppColors.primary;
      case 'TERMINE':
        return AppColors.textMuted;
      case 'ANNULE':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  String _libelleStatut() {
    switch (reservation.statut) {
      case 'CONFIRME':
        return 'Confirmée';
      case 'TERMINE':
        return 'Terminée';
      case 'ANNULE':
        return 'Annulée';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurStatut();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reservation.menuNom ?? 'Plat',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(reservation.restaurantNom ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  '${reservation.dateReservation.day.toString().padLeft(2, '0')}/${reservation.dateReservation.month.toString().padLeft(2, '0')}/${reservation.dateReservation.year}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: couleur.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Text(_libelleStatut(),
                    style: TextStyle(
                        color: couleur,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              if (reservation.estAnnulable)
                TextButton(
                  onPressed: () =>
                      context.read<ReservationProvider>().annuler(reservation),
                  child: const Text('Annuler',
                      style: TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
