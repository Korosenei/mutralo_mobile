import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/restaurant.dart';
import '../services/scanner_service.dart';

/// Historique + statistiques de consommation d'un restaurant — accessible
/// au gestionnaire QUE le restaurant soit programmé aujourd'hui ou non
/// (contrairement au scan, cf. brief : "il peut toujours voir ...
/// l'historique et ses consommations").
class ConsommationsProvider extends ChangeNotifier {
  final ScannerService _service;
  ConsommationsProvider({required ScannerService service}) : _service = service;

  StatsConsommations? _stats;
  List<ConsommationHistorique> _resultats = [];
  bool _chargement = false;
  Failure? _erreur;

  StatsConsommations? get stats => _stats;
  List<ConsommationHistorique> get resultats => _resultats;
  bool get chargement => _chargement;
  Failure? get erreur => _erreur;

  Future<void> charger({DateTime? dateDebut, DateTime? dateFin, int? agenceId, String? recherche}) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    final result = await _service.consommations(
      dateDebut: dateDebut,
      dateFin: dateFin,
      agenceId: agenceId,
      recherche: recherche,
    );
    result.when(
      success: (donnees) {
        _stats = donnees.$1;
        _resultats = donnees.$2;
      },
      failure: (f) => _erreur = f,
    );

    _chargement = false;
    notifyListeners();
  }
}
