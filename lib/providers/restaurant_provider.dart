import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';

const _joursOuvres = ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI'];

/// Gère l'affichage des menus côté CLIENT : agence par défaut (celle de
/// l'utilisateur connecté), avec possibilité de consulter une autre agence.
/// Affiche désormais toute la semaine ouvrée (lundi-vendredi) au lieu du
/// seul jour courant après 8h — le client peut réserver à l'avance.
class RestaurantProvider extends ChangeNotifier {
  final RestaurantService _service;
  RestaurantProvider({required RestaurantService service}) : _service = service;

  int? _agenceParDefautId;
  int? _agenceAfficheeId;
  List<Menu> _menusSemaine = [];
  bool _chargement = false;
  Failure? _erreur;
  late DateTime _debutSemaine;
  late DateTime _finSemaine;

  RestaurantProvider._init() : _service = throw UnimplementedError();

  bool get chargement => _chargement;
  Failure? get erreur => _erreur;
  int? get agenceAfficheeId => _agenceAfficheeId;
  DateTime get debutSemaine => _debutSemaine;
  DateTime get finSemaine => _finSemaine;

  bool get aucunRestaurantProgramme => !_chargement && _menusSemaine.isEmpty;

  bool get consulteAutreAgence =>
      _agenceAfficheeId != null && _agenceAfficheeId != _agenceParDefautId;

  /// Menus groupés par jour ouvré (LUNDI..VENDREDI), triés par date.
  Map<String, List<Menu>> get menusParJour {
    final groupes = <String, List<Menu>>{for (final j in _joursOuvres) j: []};
    for (final m in _menusSemaine) {
      if (m.jourSemaine.isNotEmpty && groupes.containsKey(m.jourSemaine)) {
        groupes[m.jourSemaine]!.add(m);
      }
    }
    return groupes;
  }

  DateTime _lundiDe(DateTime d) {
    final jour = DateTime(d.year, d.month, d.day);
    return jour.subtract(Duration(days: jour.weekday - 1));
  }

  Future<void> chargerMenuParDefaut(int agenceClientId) async {
    _agenceParDefautId = agenceClientId;
    await _charger(agenceClientId);
  }

  Future<void> consulterAgence(int agenceId) => _charger(agenceId);

  Future<void> revenirAMonAgence() async {
    if (_agenceParDefautId != null) await _charger(_agenceParDefautId!);
  }

  Future<void> _charger(int agenceId) async {
    _chargement = true;
    _erreur = null;
    _agenceAfficheeId = agenceId;
    final aujourdhui = DateTime.now();
    _debutSemaine = _lundiDe(aujourdhui);
    _finSemaine = _debutSemaine.add(const Duration(days: 4)); // vendredi
    notifyListeners();

    final result = await _service.menusSemainePourAgence(
      agenceId,
      debutSemaine: _debutSemaine,
      finSemaine: _finSemaine,
    );
    result.when(
      success: (menus) => _menusSemaine = menus,
      failure: (f) => _erreur = f,
    );

    _chargement = false;
    notifyListeners();
  }
}