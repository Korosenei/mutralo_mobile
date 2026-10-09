import 'package:flutter/material.dart';
import '../core/utils/result.dart';
import '../theme/colors.dart';

class ChargementWidget extends StatelessWidget {
  const ChargementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}

class ErreurWidget extends StatelessWidget {
  final Failure erreur;
  final VoidCallback? onReessayer;

  const ErreurWidget({super.key, required this.erreur, this.onReessayer});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icone(), color: AppColors.danger, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text(
              erreur.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            if (onReessayer != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: onReessayer, child: const Text('Réessayer')),
            ],
          ],
        ),
      ),
    );
  }

  IconData _icone() {
    switch (erreur.type) {
      case FailureType.reseau:
        return Icons.wifi_off_rounded;
      case FailureType.authentification:
        return Icons.lock_outline;
      default:
        return Icons.error_outline;
    }
  }
}

class VideWidget extends StatelessWidget {
  final String message;
  final IconData icone;
  final Widget? action;

  const VideWidget({super.key, required this.message, this.icone = Icons.inbox_outlined, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: AppColors.disabled, size: 44),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
            if (action != null) ...[const SizedBox(height: AppSpacing.md), action!],
          ],
        ),
      ),
    );
  }
}

/// Bandeau d'information non bloquant — utilisé notamment pour signaler
/// "restaurant non programmé aujourd'hui" côté gestionnaire, ou "vous
/// consultez une autre agence" côté client.
class BandeauInfo extends StatelessWidget {
  final IconData icone;
  final String message;
  final Widget? action;
  final Color couleurFond;
  final Color couleurTexte;

  const BandeauInfo({
    super.key,
    required this.icone,
    required this.message,
    this.action,
    this.couleurFond = AppColors.warningLight,
    this.couleurTexte = AppColors.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: couleurFond, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Row(
        children: [
          Icon(icone, color: couleurTexte, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: TextStyle(color: couleurTexte, fontSize: 13, fontWeight: FontWeight.w600))),
          if (action != null) action!,
        ],
      ),
    );
  }
}
