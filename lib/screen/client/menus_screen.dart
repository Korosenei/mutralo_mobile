import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agence.dart';
import '../../models/restaurant.dart';
import '../../providers/auth_provider.dart';
import '../../providers/agence_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/app_header.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/state_widgets.dart';

const _joursOuvres = ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI'];
const _nomsJours = {
  'LUNDI': 'Lundi',
  'MARDI': 'Mardi',
  'MERCREDI': 'Mercredi',
  'JEUDI': 'Jeudi',
  'VENDREDI': 'Vendredi',
};

class MenusScreen extends StatefulWidget {
  const MenusScreen({super.key});

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
  late String _jourSelectionne;

  @override
  void initState() {
    super.initState();
    _jourSelectionne = _joursOuvres[(DateTime.now().weekday - 1).clamp(0, 4)];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final agenceId = context.read<AuthProvider>().utilisateur?.agenceId;
      if (agenceId != null) {
        await context.read<RestaurantProvider>().chargerMenuParDefaut(agenceId);
      }
      await context.read<ReservationProvider>().chargerMesReservations();
    });
  }

  Future<void> _choisirAutreAgence() async {
    final agenceProvider = context.read<AgenceProvider>();
    if (agenceProvider.agences.isEmpty) await agenceProvider.charger();

    if (!mounted) return;
    final agenceId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          _FeuilleChoixAgence(agences: context.read<AgenceProvider>().agences),
    );
    if (agenceId != null && mounted) {
      context.read<RestaurantProvider>().consulterAgence(agenceId);
    }
  }

  /// Cherche le prochain jour ouvré (après celui actuellement sélectionné)
  /// pour lequel le client n'a ni consommé ni réservé — lui permet de
  /// réserver à l'avance même s'il est bloqué sur le jour courant.
  String? _prochainJourDisponible(
      RestaurantProvider provider, ReservationProvider reservationProvider) {
    final indexActuel = _joursOuvres.indexOf(_jourSelectionne);
    for (var i = indexActuel + 1; i < _joursOuvres.length; i++) {
      final jour = _joursOuvres[i];
      final date = provider.debutSemaine.add(Duration(days: i));
      final consomme = reservationProvider.dejaConsomme(date);
      final reserve = reservationProvider.dejaReserve(date);
      if (!consomme && !reserve) return jour;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final reservationProvider = context.watch<ReservationProvider>();
    final parJour = provider.menusParJour;
    final menusDuJour = parJour[_jourSelectionne] ?? [];

    // Date réelle correspondant à l'onglet sélectionné (pour vérifier
    // réservation/consommation sur CE jour précis, pas juste aujourd'hui).
    final indexJour = _joursOuvres.indexOf(_jourSelectionne);
    final dateOnglet = provider.debutSemaine.add(Duration(days: indexJour));

    final reservationActive = reservationProvider.reservationPour(dateOnglet);
    final dejaConsomme = reservationProvider.dejaConsomme(dateOnglet);
    final dejaReserve = reservationProvider.dejaReserve(dateOnglet);
    final jourBloque = dejaConsomme || dejaReserve;

    final prochainJour = jourBloque
        ? _prochainJourDisponible(provider, reservationProvider)
        : null;

    return Scaffold(
      appBar: AppHeader(
        titre: const Text('Menus de la semaine'),
        actionsSupplementaires: [
          IconButton(
            icon: const Icon(Icons.apartment_outlined),
            tooltip: 'Voir une autre agence',
            onPressed: _choisirAutreAgence,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            if (provider.agenceAfficheeId != null) {
              await provider.consulterAgence(provider.agenceAfficheeId!);
            }
            await reservationProvider.chargerMesReservations();
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
                    children: _joursOuvres.map((j) {
                      final selectionne = _jourSelectionne == j;
                      final nombre = parJour[j]?.length ?? 0;
                      final dateJ = provider.debutSemaine
                          .add(Duration(days: _joursOuvres.indexOf(j)));
                      final bloqueJ = reservationProvider.dejaConsomme(dateJ) ||
                          reservationProvider.dejaReserve(dateJ);
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(
                              '${_nomsJours[j]}${nombre > 0 ? ' ($nombre)' : ''}${bloqueJ ? ' ✓' : ''}'),
                          selected: selectionne,
                          onSelected: (_) =>
                              setState(() => _jourSelectionne = j),
                          selectedColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            color: selectionne
                                ? AppColors.primary
                                : (bloqueJ
                                    ? AppColors.textMuted.withOpacity(0.6)
                                    : AppColors.textMuted),
                            fontWeight:
                                selectionne ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, 110),
                  children: [
                    if (provider.consulteAutreAgence)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: BandeauInfo(
                          icone: Icons.info_outline,
                          message: "Vous consultez le menu d'une autre agence.",
                          couleurFond: AppColors.primaryLight,
                          couleurTexte: AppColors.primary,
                          action: TextButton(
                            onPressed: () => context
                                .read<RestaurantProvider>()
                                .revenirAMonAgence(),
                            child: const Text('Revenir à mon agence',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                    if (dejaConsomme)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: BandeauInfo(
                          icone: Icons.check_circle_outline,
                          message: _jourSelectionne ==
                                  _joursOuvres[
                                      (DateTime.now().weekday - 1).clamp(0, 4)]
                              ? "Vous avez déjà consommé votre repas aujourd'hui."
                              : "Repas déjà consommé pour ce jour.",
                          action: prochainJour != null
                              ? TextButton(
                                  onPressed: () => setState(
                                      () => _jourSelectionne = prochainJour),
                                  child: Text(
                                      'Réserver pour ${_nomsJours[prochainJour]}',
                                      style: const TextStyle(fontSize: 12)),
                                )
                              : null,
                        ),
                      )
                    else if (dejaReserve && reservationActive != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: BandeauInfo(
                          icone: Icons.event_available_outlined,
                          message:
                              "Vous avez déjà une réservation pour ce jour (${reservationActive.menuNom ?? ''}).",
                          action: prochainJour != null
                              ? TextButton(
                                  onPressed: () => setState(
                                      () => _jourSelectionne = prochainJour),
                                  child: Text(
                                      'Réserver pour ${_nomsJours[prochainJour]}',
                                      style: const TextStyle(fontSize: 12)),
                                )
                              : null,
                        ),
                      ),
                    if (provider.chargement)
                      const Padding(
                          padding: EdgeInsets.only(top: AppSpacing.xl),
                          child: ChargementWidget())
                    else if (provider.erreur != null)
                      ErreurWidget(
                          erreur: provider.erreur!,
                          onReessayer: () => provider.agenceAfficheeId != null
                              ? provider
                                  .consulterAgence(provider.agenceAfficheeId!)
                              : null)
                    else if (provider.aucunRestaurantProgramme)
                      const VideWidget(
                          icone: Icons.storefront_outlined,
                          message:
                              "Aucun restaurant programmé cette semaine pour cette agence.")
                    else if (menusDuJour.isEmpty)
                      VideWidget(
                          icone: Icons.restaurant_outlined,
                          message:
                              "Aucun plat disponible pour ${_nomsJours[_jourSelectionne]!.toLowerCase()}.")
                    else
                      ...menusDuJour.map((menu) => _CarteMenu(
                            menu: menu,
                            date: dateOnglet,
                            reservable: !jourBloque,
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

class _CarteMenu extends StatelessWidget {
  final Menu menu;
  final DateTime date;
  final bool reservable;
  const _CarteMenu(
      {required this.menu, required this.date, required this.reservable});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              image: menu.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(menu.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: menu.imageUrl == null
                ? const Icon(Icons.restaurant, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (menu.restaurantNom != null)
                  Text(menu.restaurantNom!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                Text(menu.nom,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                if (menu.description.isNotEmpty)
                  Text(menu.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (menu.noteMoyenne != null) ...[
                      EtoilesAffichage(note: menu.noteMoyenne!, taille: 12),
                      const SizedBox(width: 4),
                      Text('${menu.noteMoyenne!.toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                    ],
                    Text('${menu.prix} FCFA',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _BoutonReserver(menu: menu, date: date, reservable: reservable),
        ],
      ),
    );
  }
}

class _BoutonReserver extends StatelessWidget {
  final Menu menu;
  final DateTime date;
  final bool reservable;
  const _BoutonReserver(
      {required this.menu, required this.date, required this.reservable});

  Future<void> _reserver(BuildContext context) async {
    final succes = await context
        .read<ReservationProvider>()
        .reserver(menu: menu, date: date);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(succes
                ? 'Réservation effectuée.'
                : "Échec de la réservation.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!menu.estDisponible) {
      return const Text('Épuisé',
          style: TextStyle(
              fontSize: 11,
              color: AppColors.disabled,
              fontWeight: FontWeight.w700));
    }
    if (!reservable) {
      return const Icon(Icons.lock_outline,
          size: 20, color: AppColors.disabled);
    }
    return IconButton.filled(
      onPressed: () => _reserver(context),
      icon: const Icon(Icons.add, size: 18),
      style: IconButton.styleFrom(
          backgroundColor: AppColors.primary, minimumSize: const Size(36, 36)),
      tooltip: 'Réserver',
    );
  }
}

class _FeuilleChoixAgence extends StatelessWidget {
  final List<Agence> agences;
  const _FeuilleChoixAgence({required this.agences});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisir une agence',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.md),
            if (agences.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text('Aucune agence trouvée.'))
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: agences.length,
                  itemBuilder: (context, index) {
                    final a = agences[index];
                    return ListTile(
                      leading: const Icon(Icons.apartment_outlined,
                          color: AppColors.primary),
                      title: Text(a.nom),
                      subtitle: a.ville.isNotEmpty ? Text(a.ville) : null,
                      onTap: () => Navigator.of(context).pop(a.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
