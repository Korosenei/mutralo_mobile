import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// const String kBaseUrl = "http://127.0.0.1:8000/";
// const String kBaseUrl = "https://expectingly-yellowish-winter.ngrok-free.dev";
const String kBaseUrl = "http://192.168.11.105:8000/";

class TokenStorage {
  static const _accessKey = "mutralo_access_token";
  static const _refreshKey = "mutralo_refresh_token";
  static const _storage = FlutterSecureStorage();

  static Future<String?> getAccess() => _storage.read(key: _accessKey);
  static Future<String?> getRefresh() => _storage.read(key: _refreshKey);

  static Future<void> setTokens(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

/// Exception levée quand le refresh token est lui-même invalide/expiré :
/// l'app doit alors renvoyer l'utilisateur vers l'écran de connexion.
class SessionExpiredException implements Exception {}

class ApiClient {
  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;
  bool _isRefreshing = false;
  final List<void Function()> _pendingQueue = [];

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'ngrok-skip-browser-warning': 'true'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccess();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          final isUnauthorized = error.response?.statusCode == 401;
          final alreadyRetried = error.requestOptions.extra['retried'] == true;

          if (isUnauthorized && !alreadyRetried) {
            error.requestOptions.extra['retried'] = true;

            if (_isRefreshing) {
              // Une autre requête est déjà en train de rafraîchir le token :
              // on met celle-ci en attente puis on la rejoue.
              final completer = Completer<void>();
              _pendingQueue.add(() => completer.complete());
              await completer.future;
              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }

            _isRefreshing = true;
            try {
              final refresh = await TokenStorage.getRefresh();
              if (refresh == null) throw SessionExpiredException();

              final refreshDio = Dio(BaseOptions(baseUrl: kBaseUrl));
              final resp = await refreshDio.post(
                '/api/auth/token/refresh/',
                data: {'refresh': refresh},
              );
              final newAccess = resp.data['access'] as String;
              await TokenStorage.setTokens(newAccess, refresh);

              for (final cb in _pendingQueue) {
                cb();
              }
              _pendingQueue.clear();

              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              await TokenStorage.clear();
              _pendingQueue.clear();
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: SessionExpiredException(),
                ),
              );
            } finally {
              _isRefreshing = false;
            }
          }

          handler.next(error);
        },
      ),
    );
  }
}
