import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/restaurants_api.dart';
import '../../models/ticket.dart';
import '../../models/restaurant_models.dart';
import '../../theme/colors.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  LogConsommation? _log;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final logs = await ConsommationsClientApi.getMesLogsConsommation();
      final match = logs.where((l) => l.ticketId == widget.ticket.id);
      if (mounted) {
        setState(() {
          _log = match.isNotEmpty ? match.first : null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _log = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateHeure(String iso) {
    try {
      return DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _formatDateCourte(String iso) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;

    return Scaffold(
      appBar: AppBar(title: Text('Ticket ${t.numeroTicket}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.numeroTicket,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.statut == 'CONSOMME'
                              ? AppColors.textMuted
                              : AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          t.statutLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(label: 'Prix payé', value: '${t.prixPaye} FCFA'),
                  _DetailRow(
                      label: 'Subvention',
                      value: '${t.montantSubventionne} FCFA'),
                  _DetailRow(
                    label: 'Validité',
                    value:
                        '${_formatDateCourte(t.valideDe)} → ${_formatDateCourte(t.valideJusqua)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Détail de la consommation',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (t.statut != 'CONSOMME')
              const _InfoBanner(text: "Ce ticket n'a pas encore été consommé.")
            else if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_log == null)
              const _InfoBanner(
                text:
                    "Détail non disponible pour ce ticket (peut arriver pour d'anciennes consommations).",
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailIconRow(
                      icon: Icons.storefront,
                      label: 'Restaurant',
                      value: _log!.restaurantNom.isEmpty
                          ? '—'
                          : _log!.restaurantNom,
                    ),
                    _DetailIconRow(
                      icon: Icons.location_on_outlined,
                      label: 'Agence',
                      value: _log!.agenceNom.isEmpty ? '—' : _log!.agenceNom,
                    ),
                    _DetailIconRow(
                      icon: Icons.restaurant_menu,
                      label: 'Plat consommé',
                      value: _log!.menuNom ?? '—',
                    ),
                    _DetailIconRow(
                      icon: Icons.access_time,
                      label: 'Date et heure',
                      value: _formatDateHeure(_log!.dateConsommation),
                      isLast: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0E4),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 13, color: AppColors.text)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailIconRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailIconRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
