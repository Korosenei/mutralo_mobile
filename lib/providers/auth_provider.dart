import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/utilisateur.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  Utilisateur? _utilisateur;
  AuthStatus _status = AuthStatus.loading;

  Utilisateur? get utilisateur => _utilisateur;
  AuthStatus get status => _status;

  AuthProvider() {
    _restaurerSession();
  }

  Future<void> _restaurerSession() async {
    final access = await TokenStorage.getAccess();
    if (access == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _utilisateur = await AuthApi.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await TokenStorage.clear();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String motDePasse) async {
    final user = await AuthApi.login(email, motDePasse);
    _utilisateur = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthApi.logout();
    _utilisateur = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshMe() async {
    try {
      _utilisateur = await AuthApi.getMe();
      notifyListeners();
    } catch (_) {
      await logout();
    }
  }
}
