import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/restaurants_api.dart';
import '../../models/restaurant_models.dart';
import '../../theme/colors.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _loading = true;

  static const _statutColors = {
    'EN_ATTENTE': AppColors.warning,
    'CONFIRME': AppColors.primary,
    'TERMINE': AppColors.textMuted,
    'ANNULE': AppColors.danger,
  };

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final data = await RestaurantsApi.getMesReservations();
      if (mounted) setState(() => _reservations = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _annuler(Reservation r) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text('Annuler la réservation pour "${r.menuNom}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Retour')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Annuler la réservation', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    try {
      await RestaurantsApi.annulerReservation(r.id);
      _charger();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'annuler cette réservation.")),
        );
      }
    }
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes réservations')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _charger,
              child: _reservations.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xl),
                          child: Center(
                            child: Text('Aucune réservation.', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final r = _reservations[index];
                        final peutAnnuler = r.statut == 'EN_ATTENTE' || r.statut == 'CONFIRME';
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.menuNom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${r.restaurantNom} · ${_formatDate(r.dateReservation)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (_statutColors[r.statut] ?? AppColors.textMuted),
                                        borderRadius: BorderRadius.circular(AppRadius.pill),
                                      ),
                                      child: Text(
                                        r.statutLabel,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (peutAnnuler)
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.danger),
                                  onPressed: () => _annuler(r),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
