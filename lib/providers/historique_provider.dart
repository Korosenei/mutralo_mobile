import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/log_consommation.dart';
import '../services/historique_service.dart';

class HistoriqueProvider extends ChangeNotifier {
  final HistoriqueService _service;
  HistoriqueProvider({required HistoriqueService service}) : _service = service;

  List<LogConsommationClient> _consommations = [];
  bool _chargement = false;
  Failure? _erreur;

  List<LogConsommationClient> get consommations => _consommations;
  bool get chargement => _chargement;
  Failure? get erreur => _erreur;

  Future<void> charger() async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    final result = await _service.mesConsommations();
    result.when(success: (l) => _consommations = l, failure: (f) => _erreur = f);

    _chargement = false;
    notifyListeners();
  }
}
