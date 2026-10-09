import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/evaluation.dart';
import '../services/evaluation_service.dart';

class EvaluationProvider extends ChangeNotifier {
  final EvaluationService _service;
  EvaluationProvider({required EvaluationService service}) : _service = service;

  List<Evaluation> _mesEvaluations = [];
  List<ClassementEntree> _classementMenus = [];
  List<ClassementEntree> _classementRestaurants = [];
  bool _chargement = false;
  bool _envoiEnCours = false;
  Failure? _erreur;

  List<Evaluation> get mesEvaluations => _mesEvaluations;
  List<ClassementEntree> get classementMenus => _classementMenus;
  List<ClassementEntree> get classementRestaurants => _classementRestaurants;
  bool get chargement => _chargement;
  bool get envoiEnCours => _envoiEnCours;
  Failure? get erreur => _erreur;

  /// Vrai si le plat lié à cette consommation a déjà été noté (évite
  /// d'afficher deux fois le bouton "Évaluer" pour la même consommation —
  /// contrainte OneToOne côté backend).
  bool dejaEvalue(int consommationId) =>
      _mesEvaluations.any((e) => e.consommationId == consommationId);

  Future<bool> noter({required int consommationId, required int note, String commentaire = ''}) async {
    _envoiEnCours = true;
    _erreur = null;
    notifyListeners();

    final result = await _service.noterPlatConsomme(
      consommationId: consommationId,
      note: note,
      commentaire: commentaire,
    );
    bool succes = false;
    result.when(
      success: (evaluation) {
        _mesEvaluations = [evaluation, ..._mesEvaluations];
        succes = true;
      },
      failure: (f) => _erreur = f,
    );

    _envoiEnCours = false;
    notifyListeners();
    return succes;
  }

  Future<void> chargerMesEvaluations() async {
    final result = await _service.mesEvaluations();
    result.when(success: (l) => _mesEvaluations = l, failure: (f) => _erreur = f);
    notifyListeners();
  }

  Future<void> chargerClassementMenus({DateTime? dateDebut, DateTime? dateFin, int? restaurantId}) async {
    _chargement = true;
    notifyListeners();
    final result = await _service.classementMenus(dateDebut: dateDebut, dateFin: dateFin, restaurantId: restaurantId);
    result.when(success: (l) => _classementMenus = l, failure: (f) => _erreur = f);
    _chargement = false;
    notifyListeners();
  }

  Future<void> chargerClassementRestaurants({DateTime? dateDebut, DateTime? dateFin}) async {
    _chargement = true;
    notifyListeners();
    final result = await _service.classementRestaurants(dateDebut: dateDebut, dateFin: dateFin);
    result.when(success: (l) => _classementRestaurants = l, failure: (f) => _erreur = f);
    _chargement = false;
    notifyListeners();
  }
}
