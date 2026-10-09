import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/evaluation.dart';
import '../../providers/evaluation_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/state_widgets.dart';

/// Classement des menus et des restaurants sur une période, basé sur les
/// évaluations des plats consommés (jamais de note de service — cf. brief).
class ClassementScreen extends StatefulWidget {
  /// Si fourni, restreint le classement des menus à ce restaurant (utile
  /// pour le gestionnaire qui veut voir le classement de SES plats).
  final int? restaurantId;

  const ClassementScreen({super.key, this.restaurantId});

  @override
  State<ClassementScreen> createState() => _ClassementScreenState();
}

class _ClassementScreenState extends State<ClassementScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _Periode _periode = _Periode.mois;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _charger() {
    final provider = context.read<EvaluationProvider>();
    final (debut, fin) = _periode.bornes();
    provider.chargerClassementMenus(dateDebut: debut, dateFin: fin, restaurantId: widget.restaurantId);
    provider.chargerClassementRestaurants(dateDebut: debut, dateFin: fin);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EvaluationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Plats'), Tab(text: 'Restaurants')],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _SelecteurPeriode(
                periode: _periode,
                onChanged: (p) {
                  setState(() => _periode = p);
                  _charger();
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _listeMenus(provider),
                  _listeRestaurants(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listeMenus(EvaluationProvider provider) {
    if (provider.chargement) return const ChargementWidget();
    if (provider.classementMenus.isEmpty) {
      return const VideWidget(icone: Icons.restaurant_outlined, message: 'Aucun plat évalué sur cette période.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: provider.classementMenus.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _CarteClassement(rang: index + 1, entree: provider.classementMenus[index]),
    );
  }

  Widget _listeRestaurants(EvaluationProvider provider) {
    if (provider.chargement) return const ChargementWidget();
    if (provider.classementRestaurants.isEmpty) {
      return const VideWidget(icone: Icons.storefront_outlined, message: 'Aucun restaurant évalué sur cette période.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: provider.classementRestaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => _CarteClassement(rang: index + 1, entree: provider.classementRestaurants[index]),
    );
  }
}

enum _Periode { semaine, mois, tout }

extension on _Periode {
  String get libelle => switch (this) {
        _Periode.semaine => '7 jours',
        _Periode.mois => 'Ce mois',
        _Periode.tout => 'Tout',
      };

  (DateTime?, DateTime?) bornes() {
    final maintenant = DateTime.now();
    switch (this) {
      case _Periode.semaine:
        return (maintenant.subtract(const Duration(days: 7)), maintenant);
      case _Periode.mois:
        return (DateTime(maintenant.year, maintenant.month, 1), maintenant);
      case _Periode.tout:
        return (null, null);
    }
  }
}

class _SelecteurPeriode extends StatelessWidget {
  final _Periode periode;
  final ValueChanged<_Periode> onChanged;
  const _SelecteurPeriode({required this.periode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _Periode.values.map((p) {
        final selectionne = p == periode;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ChoiceChip(
            label: Text(p.libelle),
            selected: selectionne,
            onSelected: (_) => onChanged(p),
            selectedColor: AppColors.primaryLight,
            labelStyle: TextStyle(color: selectionne ? AppColors.primary : AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
    );
  }
}

class _CarteClassement extends StatelessWidget {
  final int rang;
  final ClassementEntree entree;
  const _CarteClassement({required this.rang, required this.entree});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Medaille(rang: rang),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entree.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    EtoilesAffichage(note: entree.noteMoyenne, taille: 14),
                    const SizedBox(width: 6),
                    Text(entree.noteMoyenne.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 6),
                    Text('(${entree.nombreEvaluations} avis)', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Medaille extends StatelessWidget {
  final int rang;
  const _Medaille({required this.rang});

  @override
  Widget build(BuildContext context) {
    Color couleur;
    switch (rang) {
      case 1:
        couleur = const Color(0xFFFFD700);
        break;
      case 2:
        couleur = const Color(0xFFC0C0C0);
        break;
      case 3:
        couleur = const Color(0xFFCD7F32);
        break;
      default:
        couleur = AppColors.disabled;
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: couleur.withOpacity(0.18), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('$rang', style: TextStyle(fontWeight: FontWeight.w800, color: couleur == AppColors.disabled ? AppColors.textMuted : couleur)),
    );
  }
}
