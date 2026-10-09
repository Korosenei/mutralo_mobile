import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gestionnaire_espace_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/state_widgets.dart';
import 'menu_form_sheet.dart';

const _joursSemaine = ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI'];
const _nomsJoursAffichage = {
  'LUNDI': 'Lundi',
  'MARDI': 'Mardi',
  'MERCREDI': 'Mercredi',
  'JEUDI': 'Jeudi',
  'VENDREDI': 'Vendredi',
};

/// Le gestionnaire ne peut CRÉER des menus que si son restaurant est
/// programmé aujourd'hui (cf. brief). En lecture seule, il garde accès à
/// la liste de ses menus existants même hors planning.
///
/// Les plats sont désormais regroupés par jour (onglets), avec le jour
/// actuel sélectionné par défaut — plus d'affichage "en vrac".
class MenusManagementScreen extends StatefulWidget {
  const MenusManagementScreen({super.key});

  @override
  State<MenusManagementScreen> createState() => _MenusManagementScreenState();
}

class _MenusManagementScreenState extends State<MenusManagementScreen> {
  late String _jourSelectionne;

  @override
  void initState() {
    super.initState();
    // Jour ouvré courant par défaut (samedi/dimanche -> lundi, via clamp).
    _jourSelectionne = _joursSemaine[(DateTime.now().weekday - 1).clamp(0, 4)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final utilisateur = context.read<AuthProvider>().utilisateur;
      if (utilisateur != null) {
        context.read<GestionnaireEspaceProvider>().initialiser(utilisateur);
      }
    });
  }

  Future<void> _ouvrirFormulaire({Menu? menu}) async {
    final restaurantId =
        context.read<GestionnaireEspaceProvider>().restaurantId;
    if (restaurantId == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuFormSheet(menu: menu),
    );
  }

  Map<String, List<Menu>> _regrouperParJour(List<Menu> menus) {
    final Map<String, List<Menu>> groupes = {
      for (final j in _joursSemaine) j: []
    };
    for (final m in menus) {
      (groupes[m.jourSemaine] ??= []).add(m);
    }
    // Tri par date croissante à l'intérieur de chaque jour, pour que les
    // plats de la semaine prochaine apparaissent après ceux de la semaine
    // en cours dans le même onglet.
    for (final liste in groupes.values) {
      liste.sort((a, b) {
        if (a.date == null || b.date == null) return 0;
        return a.date!.compareTo(b.date!);
      });
    }
    return groupes;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GestionnaireEspaceProvider>();
    final parJour = _regrouperParJour(provider.menusDeLaSemaine);
    final menusDuJour = parJour[_jourSelectionne] ?? [];

    return Scaffold(
      appBar: AppHeader(
        titre: const Text('Mes menus'),
        actionsSupplementaires: [
          if (provider.estProgramme)
            IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Ajouter un plat',
                onPressed: () => _ouvrirFormulaire()),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final utilisateur = context.read<AuthProvider>().utilisateur;
            if (utilisateur != null) {
              await context
                  .read<GestionnaireEspaceProvider>()
                  .rafraichir(utilisateur);
            }
          },
          child: Column(
            children: [
              // ── Onglets de jour ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _joursSemaine.map((j) {
                      final selectionne = _jourSelectionne == j;
                      final nombre = parJour[j]?.length ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(
                              '${_nomsJoursAffichage[j]}${nombre > 0 ? ' ($nombre)' : ''}'),
                          selected: selectionne,
                          onSelected: (_) =>
                              setState(() => _jourSelectionne = j),
                          selectedColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            color: selectionne
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight:
                                selectionne ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // ── Liste du jour sélectionné ────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, 110),
                  children: [
                    if (!provider.estProgramme && !provider.chargement)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: BandeauInfo(
                          icone: Icons.lock_outline,
                          message:
                              "Restaurant non programmé aujourd'hui : création de plats désactivée. Vous pouvez consulter vos menus existants.",
                        ),
                      ),
                    if (provider.chargement)
                      const ChargementWidget()
                    else if (menusDuJour.isEmpty)
                      VideWidget(
                          icone: Icons.restaurant_menu_outlined,
                          message:
                              "Aucun plat pour ${_nomsJoursAffichage[_jourSelectionne]!.toLowerCase()}.")
                    else
                      ...menusDuJour.map((m) => _CarteMenuGestion(
                            menu: m,
                            modifiable: provider.estProgramme,
                            onEdit: () => _ouvrirFormulaire(menu: m),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarteMenuGestion extends StatelessWidget {
  final Menu menu;
  final bool modifiable;
  final VoidCallback onEdit;
  const _CarteMenuGestion(
      {required this.menu, required this.modifiable, required this.onEdit});

  Future<void> _confirmerSuppression(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce plat ?'),
        content: Text('"${menu.nom}" sera définitivement supprimé.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirme == true && context.mounted) {
      await context.read<GestionnaireEspaceProvider>().supprimerMenu(menu.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.sm)),
            alignment: Alignment.center,
            child: (menu.imageUrl != null && menu.imageUrl!.isNotEmpty)
                ? Image.network(
                    menu.imageUrl!,
                    fit: BoxFit.cover,
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.restaurant, color: AppColors.primary),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  )
                : const Icon(Icons.restaurant, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.nom,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  menu.date != null
                      ? '${menu.date!.day.toString().padLeft(2, '0')}/${menu.date!.month.toString().padLeft(2, '0')} · ${menu.prix} FCFA'
                      : '${menu.jourSemaine} · ${menu.prix} FCFA',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                if (menu.quantiteDisponible != null)
                  Text(
                      'Reste : ${menu.quantiteRestante}/${menu.quantiteDisponible}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (modifiable) ...[
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.danger),
                onPressed: () => _confirmerSuppression(context)),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: menu.estDisponible
                      ? AppColors.primaryLight
                      : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text(
                menu.estDisponible ? 'Disponible' : 'Épuisé',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: menu.estDisponible
                        ? AppColors.primary
                        : AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }
}
