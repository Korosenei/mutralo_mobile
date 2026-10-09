import '../core/utils/result.dart';
import '../models/agence.dart';
import '../models/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class RestaurantService {
  final IRestaurantRepository _repository;
  RestaurantService({required IRestaurantRepository repository})
      : _repository = repository;

  Future<Result<List<Restaurant>>> restaurants({String? ville}) =>
      _repository.restaurants(ville: ville);
  Future<Result<Restaurant>> restaurant(int id) => _repository.restaurant(id);

  /// Restaurant + menus du jour programmés pour une agence. Résout d'abord
  /// le planning actif de l'agence, puis récupère le restaurant et ses
  /// plats du jour. Retourne (null, []) si aucun restaurant n'est
  /// programmé aujourd'hui pour cette agence.
  Future<Result<({Restaurant? restaurant, List<Menu> menus})>>
      menusDuJourPourAgence(int agenceId) async {
    final planningsResult = await _repository.planningsAgence(agenceId);

    if (planningsResult is ResultFailure<List<PlanningRestaurant>>) {
      return Result.failure(planningsResult.failure);
    }

    final plannings =
        (planningsResult as Success<List<PlanningRestaurant>>).data;
    final actuel = plannings.where((p) => p.estActuel).toList();
    if (actuel.isEmpty) {
      return Result.success((restaurant: null, menus: <Menu>[]));
    }

    final restaurantId = actuel.first.restaurantId;
    final restaurantResult = await _repository.restaurant(restaurantId);
    final menusResult = await _repository.menusDuJourRestaurant(restaurantId);

    final restaurant = restaurantResult.dataOrNull;
    final menus = menusResult.dataOrNull ?? <Menu>[];

    return Result.success((restaurant: restaurant, menus: menus));
  }

  /// disponible programmé cette semaine.
  Future<Result<List<Menu>>> menusSemainePourAgence(
    int agenceId, {
    required DateTime debutSemaine,
    required DateTime finSemaine,
  }) async {
    final planningsResult = await _repository.planningsAgence(agenceId);
    if (planningsResult is ResultFailure<List<PlanningRestaurant>>) {
      return Result.failure(planningsResult.failure);
    }
    final plannings =
        (planningsResult as Success<List<PlanningRestaurant>>).data;

    // Tous les restaurants ayant un planning actif chevauchant la semaine
    // ouvrée (normalement un seul à la fois, mais peut changer en cours de
    // semaine — cf. PlanningService.creer côté backend).
    final restaurantIds = plannings
        .where((p) =>
            p.estActif &&
            !p.dateFin.isBefore(debutSemaine) &&
            !p.dateDebut.isAfter(finSemaine))
        .map((p) => p.restaurantId)
        .toSet();

    if (restaurantIds.isEmpty) return Result.success(<Menu>[]);

    final tousLesMenus = <Menu>[];
    for (final rid in restaurantIds) {
      final menusResult = await _repository.menusRestaurant(
        rid,
        dateDebut: debutSemaine,
        dateFin: finSemaine,
      );
      if (menusResult is Success<List<Menu>>) {
        tousLesMenus.addAll(menusResult.data.where((m) => m.estDisponible));
      }
    }
    tousLesMenus.sort(
        (a, b) => (a.date ?? debutSemaine).compareTo(b.date ?? debutSemaine));
    return Result.success(tousLesMenus);
  }

  Future<Result<List<Menu>>> menusDeLaSemaine(int restaurantId,
          {DateTime? dateDebut, DateTime? dateFin}) =>
      _repository.menusRestaurant(restaurantId,
          dateDebut: dateDebut, dateFin: dateFin);

  Future<Result<Menu>> creerMenu(Map<String, dynamic> donnees,
          {String? imagePath}) =>
      _repository.creerMenu(donnees, imagePath: imagePath);
  Future<Result<Menu>> modifierMenu(int menuId, Map<String, dynamic> donnees,
          {String? imagePath}) =>
      _repository.modifierMenu(menuId, donnees, imagePath: imagePath);
  Future<Result<void>> supprimerMenu(int menuId) =>
      _repository.supprimerMenu(menuId);

  Future<Result<List<PlanningRestaurant>>> planningsRestaurant(
          int restaurantId) =>
      _repository.planningsRestaurant(restaurantId);

  Future<Result<PlanningRestaurant>> creerPlanning(
          Map<String, dynamic> donnees) =>
      _repository.creerPlanning(donnees);

  /// Vrai si le restaurant a un planning actif AUJOURD'HUI — détermine si
  /// le gestionnaire peut scanner des QR codes (voir ScannerService).
  Future<Result<bool>> estProgrammeAujourdhui(int restaurantId) async {
    final result = await _repository.planningsRestaurant(restaurantId);
    return result.when(
      success: (plannings) => Result.success(plannings.any((p) => p.estActuel)),
      failure: (f) => Result.failure(f),
    );
  }

  /// Agences dans lesquelles le restaurant intervient (planning actif ou
  /// non) — dérivé côté client à partir de l'historique complet des
  /// plannings, puisque le backend n'expose pas d'endpoint dédié.
  /// Utilisé pour le gestionnaire "non programmé" (cf. brief).
  Future<Result<List<Agence>>> agencesServies(int restaurantId) async {
    final result = await _repository.planningsRestaurant(restaurantId);
    return result.when(
      success: (plannings) {
        final vues = <int>{};
        final agences = <Agence>[];
        for (final p in plannings) {
          if (vues.add(p.agenceId)) {
            agences.add(Agence(
                id: p.agenceId,
                nom: p.agenceNom ?? 'Agence #${p.agenceId}',
                code: '',
                ville: ''));
          }
        }
        return Result.success(agences);
      },
      failure: (f) => Result.failure(f),
    );
  }
}
