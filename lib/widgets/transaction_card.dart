import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/colors.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const TransactionCard({super.key, required this.transaction});

  static const _statutColors = {
    'TERMINEE': AppColors.success,
    'REMBOURSEE': AppColors.danger,
    'EN_ATTENTE': AppColors.textMuted,
    'ANNULEE': AppColors.danger,
  };

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _statutColors[transaction.statut] ?? AppColors.textMuted;

    return Container(
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
                  transaction.numeroTransaction,
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
                  transaction.statutLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${transaction.typeLabel} · ${transaction.nombreTickets} ticket${transaction.nombreTickets > 1 ? 's' : ''} · ${transaction.modePaiementLabel}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(transaction.dateTransaction),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              Text('${transaction.montantPaye} FCFA payés',
                  style: const TextStyle(fontSize: 13)),
              Text(
                '+ ${transaction.montantSubventionne} FCFA subventionnés',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
