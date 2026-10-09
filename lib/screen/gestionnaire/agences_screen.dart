import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../models/agence.dart';
import '../../models/evaluation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gestionnaire_espace_provider.dart';
import '../../services/evaluation_service.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/state_widgets.dart';
import 'consommations_screen.dart';

/// Le gestionnaire voit toujours les agences dans lesquelles il intervient
/// (planning actif ou non — cf. brief) ainsi que les avis clients reçus,
/// que son restaurant soit programmé aujourd'hui ou non.
class AgencesScreen extends StatefulWidget {
  const AgencesScreen({super.key});

  @override
  State<AgencesScreen> createState() => _AgencesScreenState();
}

class _AgencesScreenState extends State<AgencesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final utilisateur = context.read<AuthProvider>().utilisateur;
      if (utilisateur != null) context.read<GestionnaireEspaceProvider>().initialiser(utilisateur);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GestionnaireEspaceProvider>();

    return Scaffold(
      appBar: const AppHeader(titre: Text('Mes agences')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final utilisateur = context.read<AuthProvider>().utilisateur;
            if (utilisateur != null) await context.read<GestionnaireEspaceProvider>().rafraichir(utilisateur);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 110),
            children: [
              if (!provider.estProgramme && !provider.chargement)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: BandeauInfo(
                    icone: Icons.info_outline,
                    message: "Restaurant non programmé aujourd'hui — voici l'historique de vos agences.",
                  ),
                ),
              Row(
                children: [
                  const Text('Avis clients', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AvisClientsScreen())),
                    child: const Text('Voir tout', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Agences desservies', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: AppSpacing.sm),
              if (provider.chargement)
                const ChargementWidget()
              else if (provider.agencesServies.isEmpty)
                const VideWidget(icone: Icons.apartment_outlined, message: "Aucune agence enregistrée pour votre restaurant.")
              else
                ...provider.agencesServies.map((a) => _CarteAgence(agence: a)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarteAgence extends StatelessWidget {
  final Agence agence;
  const _CarteAgence({required this.agence});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConsommationsScreen())),
        child: Row(
          children: [
            const Icon(Icons.apartment_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(agence.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
            const Icon(Icons.chevron_right, color: AppColors.disabled),
          ],
        ),
      ),
    );
  }
}

/// Avis (note + commentaire) reçus par le restaurant du gestionnaire —
/// accessible même si le restaurant n'est pas programmé aujourd'hui
/// (EvaluationSelector.du_restaurant côté backend n'exige pas de planning
/// actif, contrairement au scan).
class AvisClientsScreen extends StatefulWidget {
  const AvisClientsScreen({super.key});

  @override
  State<AvisClientsScreen> createState() => _AvisClientsScreenState();
}

class _AvisClientsScreenState extends State<AvisClientsScreen> {
  late Future<List<Evaluation>> _futureAvis;

  @override
  void initState() {
    super.initState();
    _futureAvis = locator<EvaluationService>().evaluationsDeMonRestaurant().then(
          (result) => result.dataOrNull ?? [],
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avis clients')),
      body: SafeArea(
        child: FutureBuilder<List<Evaluation>>(
          future: _futureAvis,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const ChargementWidget();
            final avis = snapshot.data ?? [];
            if (avis.isEmpty) {
              return const VideWidget(icone: Icons.star_outline_rounded, message: "Aucun avis reçu pour le moment.");
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: avis.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _CarteAvis(evaluation: avis[index]),
            );
          },
        ),
      ),
    );
  }
}

class _CarteAvis extends StatelessWidget {
  final Evaluation evaluation;
  const _CarteAvis({required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(evaluation.menuNom ?? 'Plat', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
              EtoilesAffichage(note: evaluation.note.toDouble(), taille: 14),
            ],
          ),
          if (evaluation.clientNom != null)
            Text(evaluation.clientNom!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          if (evaluation.commentaire.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(evaluation.commentaire, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
