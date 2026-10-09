import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraction du stockage des tokens JWT.
/// Permet de changer d'implémentation (secure storage, mock en test, etc.)
/// sans jamais toucher à ApiClient ou AuthRepository (Dependency Inversion).
abstract interface class ITokenStorage {
  Future<void> sauvegarderTokens({required String access, required String refresh});
  Future<String?> lireAccessToken();
  Future<String?> lireRefreshToken();
  Future<void> effacerTokens();
}

class SecureTokenStorage implements ITokenStorage {
  static const _cleAccess = 'mutralo_access_token';
  static const _cleRefresh = 'mutralo_refresh_token';

  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> sauvegarderTokens({required String access, required String refresh}) async {
    await _storage.write(key: _cleAccess, value: access);
    await _storage.write(key: _cleRefresh, value: refresh);
  }

  @override
  Future<String?> lireAccessToken() => _storage.read(key: _cleAccess);

  @override
  Future<String?> lireRefreshToken() => _storage.read(key: _cleRefresh);

  @override
  Future<void> effacerTokens() async {
    await _storage.delete(key: _cleAccess);
    await _storage.delete(key: _cleRefresh);
  }
}
