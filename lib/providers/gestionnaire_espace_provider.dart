import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/agence.dart';
import '../models/restaurant.dart';
import '../models/utilisateur.dart';
import '../services/restaurant_service.dart';

/// Regroupe l'état propre au restaurant du gestionnaire connecté :
/// - est-il programmé aujourd'hui (conditionne l'accès au Scanner et à la
///   création de menus) ?
/// - dans quelles agences intervient-il (planning actif ou non) ?
/// - quels sont ses menus de la semaine (CRUD) ?
///
/// Ces trois informations partagent la même source (le restaurant géré du
/// gestionnaire) et sont systématiquement consommées ensemble par l'écran
/// "Espace gestionnaire" — les regrouper évite trois providers qui se
/// resynchronisent en permanence sur la même clé (restaurantId).
class GestionnaireEspaceProvider extends ChangeNotifier {
  final RestaurantService _service;
  GestionnaireEspaceProvider({required RestaurantService service})
      : _service = service;

  int? _restaurantId;
  bool _estProgramme = false;
  List<Agence> _agencesServies = [];
  List<Menu> _menusDeLaSemaine = [];
  bool _chargement = true;
  bool _actionEnCours = false;
  Failure? _erreur;

  bool get estProgramme => _estProgramme;
  List<Agence> get agencesServies => _agencesServies;
  List<Menu> get menusDeLaSemaine => _menusDeLaSemaine;
  bool get chargement => _chargement;
  bool get actionEnCours => _actionEnCours;
  Failure? get erreur => _erreur;
  bool get aUnRestaurant => _restaurantId != null;
  int? get restaurantId => _restaurantId;

  Future<void> initialiser(Utilisateur utilisateur) async {
    _restaurantId = utilisateur.restaurantGereId;
    if (_restaurantId == null) {
      _chargement = false;
      notifyListeners();
      return;
    }

    _chargement = true;
    _erreur = null;
    notifyListeners();

    final (debut, fin) = _semaineCourante();

    final resultats = await Future.wait([
      _service.estProgrammeAujourdhui(_restaurantId!),
      _service.agencesServies(_restaurantId!),
      _service.menusDeLaSemaine(_restaurantId!, dateDebut: debut, dateFin: fin),
    ]);

    (resultats[0] as Result<bool>)
        .when(success: (v) => _estProgramme = v, failure: (f) => _erreur = f);
    (resultats[1] as Result<List<Agence>>).when(
        success: (v) => _agencesServies = v, failure: (f) => _erreur ??= f);
    (resultats[2] as Result<List<Menu>>).when(
        success: (v) => _menusDeLaSemaine = v, failure: (f) => _erreur ??= f);

    _chargement = false;
    notifyListeners();
  }

  /// Lundi → dimanche de la semaine courante.
  (DateTime, DateTime) _semaineCourante() {
    final aujourdhui = DateTime.now();
    final jour = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    final lundi = jour.subtract(Duration(days: jour.weekday - 1));
    final dimanche = lundi.add(const Duration(days: 6));
    return (lundi, dimanche);
  }

  Future<void> rafraichir(Utilisateur utilisateur) => initialiser(utilisateur);

  Future<bool> creerMenu(Map<String, dynamic> donnees,
      {String? imagePath}) async {
    if (_restaurantId == null) return false;
    _actionEnCours = true;
    notifyListeners();

    final result = await _service.creerMenu(
        {...donnees, 'restaurant': _restaurantId},
        imagePath: imagePath);
    bool succes = false;
    result.when(
      success: (m) {
        _menusDeLaSemaine = [m, ..._menusDeLaSemaine];
        succes = true;
      },
      failure: (f) => _erreur = f,
    );

    _actionEnCours = false;
    notifyListeners();
    return succes;
  }

  Future<bool> modifierMenu(int menuId, Map<String, dynamic> donnees,
      {String? imagePath}) async {
    _actionEnCours = true;
    notifyListeners();

    final result =
        await _service.modifierMenu(menuId, donnees, imagePath: imagePath);
    bool succes = false;
    result.when(
      success: (m) {
        _menusDeLaSemaine =
            _menusDeLaSemaine.map((e) => e.id == m.id ? m : e).toList();
        succes = true;
      },
      failure: (f) => _erreur = f,
    );

    _actionEnCours = false;
    notifyListeners();
    return succes;
  }

  Future<bool> supprimerMenu(int menuId) async {
    _actionEnCours = true;
    notifyListeners();

    final result = await _service.supprimerMenu(menuId);
    bool succes = false;
    result.when(
      success: (_) {
        _menusDeLaSemaine =
            _menusDeLaSemaine.where((e) => e.id != menuId).toList();
        succes = true;
      },
      failure: (f) => _erreur = f,
    );

    _actionEnCours = false;
    notifyListeners();
    return succes;
  }
}
