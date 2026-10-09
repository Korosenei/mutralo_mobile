import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_consommation.dart';
import '../providers/evaluation_provider.dart';
import '../theme/colors.dart';
import 'rating_stars.dart';

/// Ouvre la feuille de notation pour une consommation donnée. Retourne
/// `true` si l'évaluation a été envoyée avec succès.
Future<bool?> ouvrirFeuilleEvaluation(BuildContext context, LogConsommationClient consommation) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EvaluationSheet(consommation: consommation),
  );
}

class _EvaluationSheet extends StatefulWidget {
  final LogConsommationClient consommation;
  const _EvaluationSheet({required this.consommation});

  @override
  State<_EvaluationSheet> createState() => _EvaluationSheetState();
}

class _EvaluationSheetState extends State<_EvaluationSheet> {
  int _note = 0;
  final _commentaireCtrl = TextEditingController();

  @override
  void dispose() {
    _commentaireCtrl.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    if (_note == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez choisir une note.')));
      return;
    }
    final succes = await context.read<EvaluationProvider>().noter(
          consommationId: widget.consommation.id,
          note: _note,
          commentaire: _commentaireCtrl.text,
        );
    if (mounted) Navigator.of(context).pop(succes);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EvaluationProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Noter ce plat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              widget.consommation.menuNom ?? 'Plat consommé',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.consommation.restaurantNom,
              style: const TextStyle(color: AppColors.disabled, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            EtoilesSaisie(note: _note, onChanged: (n) => setState(() => _note = n)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _commentaireCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Un commentaire sur ce plat (optionnel)',
              ),
            ),
            if (provider.erreur != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(provider.erreur!.message, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: provider.envoiEnCours ? null : _envoyer,
              child: provider.envoiEnCours
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Envoyer mon avis'),
            ),
          ],
        ),
      ),
    );
  }
}
