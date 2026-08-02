import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../theme/colors.dart';
import '../screens/client/ticket_detail_screen.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  const TicketCard({super.key, required this.ticket});

  static const _statutColors = {
    'DISPONIBLE': AppColors.success,
    'CONSOMME': AppColors.textMuted,
    'EXPIRE': AppColors.danger,
    'ANNULE': AppColors.danger,
  };

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _statutColors[ticket.statut] ?? AppColors.textMuted;
    final estConsomme = ticket.statut == 'CONSOMME';

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: estConsomme
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => TicketDetailScreen(ticket: ticket)),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.numeroTicket,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    ticket.statutLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (estConsomme) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textMuted),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Valide du ${_formatDate(ticket.valideDe)} au ${_formatDate(ticket.valideJusqua)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                Text('${ticket.prixPaye} FCFA payés',
                    style: const TextStyle(fontSize: 13)),
                Text(
                  '+ ${ticket.montantSubventionne} FCFA subventionnés',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
