import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/tickets_api.dart';
import '../../models/ticket.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/ticket_card.dart';
import 'notifications_screen.dart';
import 'menus_screen.dart';
import 'reservations_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  const HomeDashboardScreen({super.key, required this.onNavigate});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<Ticket> _disponibles = [];
  List<Ticket> _tous = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final results = await Future.wait([
        TicketsApi.getMesTickets(),
        TicketsApi.getTousMesTickets(),
      ]);
      if (mounted) {
        setState(() {
          _disponibles = results[0];
          _tous = results[1];
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    final consommes = _tous.where((t) => t.statut == 'CONSOMME').toList();
    final valeurDisponible = _disponibles.fold<double>(
      0,
      (sum, t) => sum + (double.tryParse(t.prixPaye) ?? 0),
    );
    final derniers = consommes.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _charger,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 110),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_salutation()}, ${utilisateur?.prenom ?? ''} 👋',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        if (utilisateur?.agenceNom != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              utilisateur!.agenceNom!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _NotificationBell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Disponibles',
                      value: '${_disponibles.length}',
                      icon: Icons.confirmation_number,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'Consommés',
                      value: '${consommes.length}',
                      icon: Icons.check_circle,
                      color: AppColors.textMuted,
                    ),
                  ),
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
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.qr_code_2,
                      label: 'Mon QR code',
                      onTap: () => widget.onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Mes tickets',
                      onTap: () => widget.onNavigate(0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.restaurant_menu,
                      label: 'Menus du jour',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MenusScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.event_note_outlined,
                      label: 'Mes réservations',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReservationsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dernières consommations',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigate(3),
                    child: const Text('Voir tout', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              if (derniers.isEmpty && !_loading)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Aucune consommation récente.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                )
              else
                ...derniers.map((t) => TicketCard(ticket: t)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.notifications_outlined, color: AppColors.text, size: 22),
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
