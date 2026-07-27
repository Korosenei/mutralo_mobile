import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/utilisateur.dart';

class AuthApi {
  static final Dio _dio = ApiClient.instance.dio;

  static Future<Utilisateur> login(String email, String motDePasse) async {
    final resp = await _dio.post(
      '/api/accounts/login/',
      data: {'email': email, 'mot_de_passe': motDePasse},
    );
    await TokenStorage.setTokens(resp.data['access'], resp.data['refresh']);
    return Utilisateur.fromJson(resp.data['utilisateur']);
  }

  static Future<void> logout() async {
    try {
      final refresh = await TokenStorage.getRefresh();
      if (refresh != null) {
        await _dio.post('/api/accounts/logout/', data: {'refresh': refresh});
      }
    } catch (_) {
      // On nettoie localement même si l'appel réseau échoue.
    } finally {
      await TokenStorage.clear();
    }
  }

  static Future<Utilisateur> getMe() async {
    final resp = await _dio.get('/api/accounts/me/');
    return Utilisateur.fromJson(resp.data);
  }
}
