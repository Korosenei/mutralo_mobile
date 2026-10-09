import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

/// Point d'entrée réseau unique de l'application.
/// Responsabilité unique : configurer Dio, attacher le token d'accès à
/// chaque requête, et rafraîchir automatiquement le token en cas de 401.
/// Aucune logique métier ici — uniquement du "plomberie réseau".
class ApiClient {
  // TODO: externaliser vers un fichier de config / --dart-define par environnement
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://resto.mutralo.org/api',
  );

  // defaultValue: 'https://resto.mutralo.org/api',
  // defaultValue: 'http://192.168.11.103:8000/api',

  final Dio dio;
  final ITokenStorage tokenStorage;

  // Évite les rafraîchissements de token concurrents (plusieurs requêtes
  // en 401 en même temps ne doivent déclencher qu'UN seul refresh).
  Future<String?>? _rafraichissementEnCours;

  ApiClient({required this.tokenStorage, Dio? dioClient})
      : dio = dioClient ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              contentType: 'application/json',
            )) {
    dio.interceptors.add(_authInterceptor());
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Les endpoints d'authentification n'ont pas besoin de token
        if (!_estEndpointPublic(options.path)) {
          final access = await tokenStorage.lireAccessToken();
          if (access != null) {
            options.headers['Authorization'] = 'Bearer $access';
          }
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        final requete = error.requestOptions;
        final estDeja401Retente = requete.extra['retente_apres_401'] == true;

        if (error.response?.statusCode == 401 &&
            !_estEndpointPublic(requete.path) &&
            !estDeja401Retente) {
          final nouveauToken = await _rafraichirToken();
          if (nouveauToken != null) {
            requete.extra['retente_apres_401'] = true;
            requete.headers['Authorization'] = 'Bearer $nouveauToken';
            try {
              final reponse = await dio.fetch(requete);
              return handler.resolve(reponse);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
          // Refresh impossible : on efface la session, l'AuthProvider
          // écoutera cet état via le prochain appel échoué (401 propagé).
          await tokenStorage.effacerTokens();
        }
        handler.next(error);
      },
    );
  }

  Future<String?> _rafraichirToken() {
    // Mutualise les refresh concurrents
    _rafraichissementEnCours ??= _executerRafraichissement();
    return _rafraichissementEnCours!
        .whenComplete(() => _rafraichissementEnCours = null);
  }

  Future<String?> _executerRafraichissement() async {
    final refresh = await tokenStorage.lireRefreshToken();
    if (refresh == null) return null;
    try {
      final reponse = await Dio(BaseOptions(baseUrl: baseUrl)).post(
        '/auth/token/refresh/',
        data: {'refresh': refresh},
      );
      final nouvelAccess = reponse.data['access'] as String;
      await tokenStorage.sauvegarderTokens(
          access: nouvelAccess, refresh: refresh);
      return nouvelAccess;
    } catch (_) {
      return null;
    }
  }

  bool _estEndpointPublic(String path) {
    const chemins = [
      '/accounts/login/',
      '/auth/token/refresh/',
      '/accounts/password/oubli/'
    ];
    return chemins.any((c) => path.contains(c));
  }
}
