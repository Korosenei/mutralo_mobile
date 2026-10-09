import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/utilisateur.dart';
import '../repositories/scanner_repository.dart';
import '../services/scanner_service.dart';

class ScannerProvider extends ChangeNotifier {
  final ScannerService _service;
  ScannerProvider({required ScannerService service}) : _service = service;

  bool _peutScanner = false;
  bool _verificationAutorisationEnCours = true;
  ResultatVerificationQR? _resultatVerification;
  bool _enCours = false;
  Failure? _erreur;

  bool get peutScanner => _peutScanner;
  bool get verificationAutorisationEnCours => _verificationAutorisationEnCours;
  ResultatVerificationQR? get resultatVerification => _resultatVerification;
  bool get enCours => _enCours;
  Failure? get erreur => _erreur;

  /// À appeler à l'entrée de l'écran scanner — détermine si le
  /// gestionnaire est autorisé à scanner (restaurant programmé aujourd'hui).
  Future<void> verifierAutorisation(Utilisateur utilisateur) async {
    _verificationAutorisationEnCours = true;
    notifyListeners();

    final result = await _service.peutScanner(utilisateur);
    result.when(
      success: (autorise) => _peutScanner = autorise,
      failure: (f) {
        _peutScanner = false;
        _erreur = f;
      },
    );

    _verificationAutorisationEnCours = false;
    notifyListeners();
  }

  Future<bool> verifierCode(String code) async {
    _enCours = true;
    _erreur = null;
    _resultatVerification = null;
    notifyListeners();

    final result = await _service.verifier(code);
    bool succes = false;
    result.when(
      success: (r) {
        _resultatVerification = r;
        succes = r.valide;
        if (!r.valide) _erreur = Failure.validation(r.erreur ?? 'QR code invalide.');
      },
      failure: (f) => _erreur = f,
    );

    _enCours = false;
    notifyListeners();
    return succes;
  }

  Future<bool> validerCode(String code, {int? menuId}) async {
    _enCours = true;
    _erreur = null;
    notifyListeners();

    final result = await _service.valider(code, menuId: menuId);
    bool succes = false;
    result.when(
      success: (_) => succes = true,
      failure: (f) => _erreur = f,
    );

    _enCours = false;
    notifyListeners();
    return succes;
  }

  void reinitialiser() {
    _resultatVerification = null;
    _erreur = null;
    notifyListeners();
  }
}
