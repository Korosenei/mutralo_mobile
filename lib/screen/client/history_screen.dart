import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/log_consommation.dart';
import '../../providers/evaluation_provider.dart';
import '../../providers/historique_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/evaluation_sheet.dart';
import '../../widgets/state_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoriqueProvider>().charger();
      context.read<EvaluationProvider>().chargerMesEvaluations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoriqueProvider>();

    return Scaffold(
      appBar: const AppHeader(titre: Text('Historique')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<HistoriqueProvider>().charger(),
          child: provider.chargement && provider.consommations.isEmpty
              ? const ChargementWidget()
              : provider.consommations.isEmpty
                  ? const VideWidget(icone: Icons.history, message: "Vous n'avez encore consommé aucun ticket.")
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 110),
                      itemCount: provider.consommations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) => _CarteConsommation(consommation: provider.consommations[index]),
                    ),
        ),
      ),
    );
  }
}

class _CarteConsommation extends StatelessWidget {
  final LogConsommationClient consommation;
  const _CarteConsommation({required this.consommation});

  @override
  Widget build(BuildContext context) {
    final dejaEvalue = context.watch<EvaluationProvider>().dejaEvalue(consommation.id);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.sm)),
            alignment: Alignment.center,
            child: const Icon(Icons.restaurant, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(consommation.menuNom ?? 'Plat consommé', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(consommation.restaurantNom, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text(
                  '${consommation.dateConsommation.day.toString().padLeft(2, '0')}/${consommation.dateConsommation.month.toString().padLeft(2, '0')}/${consommation.dateConsommation.year}',
                  style: const TextStyle(fontSize: 11, color: AppColors.disabled),
                ),
              ],
            ),
          ),
          dejaEvalue
              ? const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(Icons.star_rounded, color: AppColors.warning, size: 22),
                )
              : TextButton.icon(
                  onPressed: () => ouvrirFeuilleEvaluation(context, consommation),
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Noter', style: TextStyle(fontSize: 12)),
                ),
        ],
      ),
    );
  }
}
