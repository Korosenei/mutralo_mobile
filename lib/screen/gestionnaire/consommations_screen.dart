import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/consommations_provider.dart';
import '../../providers/gestionnaire_espace_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/state_widgets.dart';
import '../shared/classement_screen.dart';

class ConsommationsScreen extends StatefulWidget {
  const ConsommationsScreen({super.key});

  @override
  State<ConsommationsScreen> createState() => _ConsommationsScreenState();
}

class _ConsommationsScreenState extends State<ConsommationsScreen> {
  final _rechercheCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ConsommationsProvider>().charger());
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsommationsProvider>();
    final estProgramme = context.watch<GestionnaireEspaceProvider>().estProgramme;

    return Scaffold(
      appBar: AppHeader(
        titre: const Text('Consommations'),
        actionsSupplementaires: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Classement',
            onPressed: () {
              final restaurantId = context.read<GestionnaireEspaceProvider>().restaurantId;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClassementScreen(restaurantId: restaurantId)));
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<ConsommationsProvider>().charger(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 110),
            children: [
              if (!estProgramme)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: BandeauInfo(
                    icone: Icons.info_outline,
                    message: "Restaurant non programmé aujourd'hui — vous consultez uniquement votre historique.",
                  ),
                ),
              TextField(
                controller: _rechercheCtrl,
                decoration: const InputDecoration(hintText: 'Rechercher un client, un matricule…', prefixIcon: Icon(Icons.search)),
                onSubmitted: (v) => context.read<ConsommationsProvider>().charger(recherche: v),
              ),
              const SizedBox(height: AppSpacing.md),
              if (provider.stats != null) _statsRow(provider.stats!),
              const SizedBox(height: AppSpacing.lg),
              if (provider.chargement)
                const ChargementWidget()
              else if (provider.erreur != null)
                ErreurWidget(erreur: provider.erreur!, onReessayer: () => context.read<ConsommationsProvider>().charger())
              else if (provider.resultats.isEmpty)
                const VideWidget(icone: Icons.receipt_long_outlined, message: 'Aucune consommation trouvée.')
              else
                ...provider.resultats.map((c) => _LigneConsommation(consommation: c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsRow(StatsConsommations stats) {
    return Row(
      children: [
        Expanded(child: _StatMini(label: "Aujourd'hui", value: stats.aujourdhui)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatMini(label: '7 jours', value: stats.cetteSemaine)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatMini(label: 'Ce mois', value: stats.ceMois)),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final int value;
  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _LigneConsommation extends StatelessWidget {
  final ConsommationHistorique consommation;
  const _LigneConsommation({required this.consommation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(consommation.client, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text('${consommation.matricule} · ${consommation.agence}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text(consommation.menu, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${consommation.dateConsommation.day.toString().padLeft(2, '0')}/${consommation.dateConsommation.month.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
