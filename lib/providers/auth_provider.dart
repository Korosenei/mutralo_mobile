import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/utilisateur.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({required AuthService authService})
      : _authService = authService {
    _initialiser();
  }

  AuthStatus _status = AuthStatus.loading;
  Utilisateur? _utilisateur;
  Failure? _derniereErreur;
  bool _enCours = false;

  AuthStatus get status => _status;
  Utilisateur? get utilisateur => _utilisateur;
  Failure? get derniereErreur => _derniereErreur;
  bool get enCours => _enCours;

  Future<void> _initialiser() async {
    final connecte = await _authService.estConnecte();
    if (!connecte) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    final result = await _authService.utilisateurConnecte();
    result.when(
      success: (u) {
        _utilisateur = u;
        _status = AuthStatus.authenticated;
      },
      failure: (_) => _status = AuthStatus.unauthenticated,
    );
    notifyListeners();
  }

  Future<bool> login(String email, String motDePasse) async {
    _enCours = true;
    _derniereErreur = null;
    notifyListeners();

    final result = await _authService.login(email, motDePasse);
    bool succes = false;
    result.when(
      success: (u) {
        _utilisateur = u;
        _status = AuthStatus.authenticated;
        succes = true;
      },
      failure: (f) => _derniereErreur = f,
    );

    _enCours = false;
    notifyListeners();
    return succes;
  }

  Future<void> logout() async {
    await _authService.logout();
    _utilisateur = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> demanderReinitialisationMotDePasse(String email) async {
    _enCours = true;
    _derniereErreur = null;
    notifyListeners();

    final result = await _authService.demanderReinitialisationMotDePasse(email);
    final succes = result.isSuccess;
    if (!succes) _derniereErreur = (result as ResultFailure).failure;

    _enCours = false;
    notifyListeners();
    return succes;
  }

  Future<bool> changerMotDePasse({
  required String ancienMotDePasse,
  required String nouveauMotDePasse,
  required String confirmationMotDePasse,
}) async {
  _enCours = true;
  _derniereErreur = null;
  notifyListeners();

  // Validations locales rapides (le backend revalide de son côté).
  if (ancienMotDePasse.isEmpty ||
      nouveauMotDePasse.isEmpty ||
      confirmationMotDePasse.isEmpty) {
    _derniereErreur = Failure.validation('Veuillez remplir tous les champs.');
    _enCours = false;
    notifyListeners();
    return false;
  }

  if (nouveauMotDePasse != confirmationMotDePasse) {
    _derniereErreur =
        Failure.validation('Les deux mots de passe ne correspondent pas.');
    _enCours = false;
    notifyListeners();
    return false;
  }

  final result = await _authService.changerMotDePasse(
    ancien: ancienMotDePasse,
    nouveau: nouveauMotDePasse,
    confirmation: confirmationMotDePasse,   // ← LE CHAMP MANQUANT
  );

  bool succes = false;
  result.when(
    success: (_) => succes = true,
    failure: (f) => _derniereErreur = f,
  );

  _enCours = false;
  notifyListeners();
  return succes;
}

  void effacerErreur() {
    _derniereErreur = null;
    notifyListeners();
  }
}
