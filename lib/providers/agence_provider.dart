import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/agence.dart';
import '../services/agence_service.dart';

class AgenceProvider extends ChangeNotifier {
  final AgenceService _service;
  AgenceProvider({required AgenceService service}) : _service = service;

  List<Agence> _agences = [];
  bool _chargement = false;
  Failure? _erreur;

  List<Agence> get agences => _agences;
  bool get chargement => _chargement;
  Failure? get erreur => _erreur;

  Future<void> charger({String? recherche}) async {
    _chargement = true;
    notifyListeners();
    final result = await _service.lister(recherche: recherche);
    result.when(success: (a) => _agences = a, failure: (f) => _erreur = f);
    _chargement = false;
    notifyListeners();
  }
}
