import '../core/utils/result.dart';
import '../models/restaurant.dart';

abstract interface class IRestaurantRepository {
  Future<Result<List<Restaurant>>> restaurants({String? ville, String? statut});
  Future<Result<Restaurant>> restaurant(int id);

  /// GET /restaurants/restaurants/{id}/menus_du_jour/ — plats du jour d'UN
  /// restaurant. Pour "le menu de mon agence", on résout d'abord le
  /// restaurant programmé via [planningsAgence], puis on appelle ceci.
  Future<Result<List<Menu>>> menusDuJourRestaurant(int restaurantId);

  /// GET /restaurants/menus/?restaurant=&date= — menus de la semaine d'un
  /// restaurant (utilisé par le gestionnaire pour gérer ses plats).
  Future<Result<List<Menu>>> menusRestaurant(int restaurantId,
      {DateTime? dateDebut, DateTime? dateFin});

  /// [imagePath] : chemin local d'une image à uploader (multipart) —
  /// optionnel, laisser le plat sans nouvelle photo si non fourni.
  Future<Result<Menu>> creerMenu(Map<String, dynamic> donnees,
      {String? imagePath});
  Future<Result<Menu>> modifierMenu(int menuId, Map<String, dynamic> donnees,
      {String? imagePath});
  Future<Result<void>> supprimerMenu(int menuId);

  /// GET /restaurants/plannings/?agence=&actif=1
  Future<Result<List<PlanningRestaurant>>> planningsAgence(int agenceId);

  /// GET /restaurants/plannings/?restaurant=
  Future<Result<List<PlanningRestaurant>>> planningsRestaurant(
      int restaurantId);

  Future<Result<PlanningRestaurant>> creerPlanning(
      Map<String, dynamic> donnees);
}
