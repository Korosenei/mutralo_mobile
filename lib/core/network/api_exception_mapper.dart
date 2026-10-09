import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../utils/result.dart';

/// Traduit une DioException (ou toute autre exception) en Failure normalisée.
/// C'est la SEULE classe qui doit connaître la forme des erreurs DRF
/// ({'detail': ...}, {'non_field_errors': [...]}, {'champ': [...]}).
/// Si le format des erreurs backend change, on ne modifie qu'ici.
class ApiExceptionMapper {
  const ApiExceptionMapper._();

  static Failure depuis(Object erreur) {
    if (erreur is DioException) return _depuisDio(erreur);
    return Failure.inconnue(erreur.toString());
  }

  static Failure _depuisDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return Failure.reseau();
      default:
        break;
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 401) {
      return Failure.authentification(_extraireMessage(data) ??
          'Session expirée, veuillez vous reconnecter.');
    }

    if (status == 403) {
      return Failure.authentification(_extraireMessage(data) ??
          "Vous n'avez pas la permission d'effectuer cette action.");
    }

    if (status == 404) {
      // Une 404 signifie presque toujours une route mal configurée côté
      // client (mauvaise URL) plutôt qu'une vraie absence de ressource
      // métier — mais dans les deux cas, JAMAIS le message brut de Dio
      // (RequestOptions.validateStatus...) devant l'utilisateur.
      return Failure.inconnue(_extraireMessage(data) ??
          "Cette fonctionnalité est momentanément indisponible. Veuillez réessayer plus tard.");
    }

    if (status == 400 || status == 422) {
      final message =
          _extraireMessage(data) ?? 'Certaines informations sont invalides.';
      final champs = (data is Map<String, dynamic>) ? data : null;
      return Failure.validation(message, champs: champs);
    }

    if (status != null && status >= 500) {
      return Failure.serveur();
    }

    // Tout le reste : statut HTTP non explicitement géré ci-dessus (405,
    //409, 429...) ou absence totale de réponse (certificat invalide,
    // requête annulée, erreur DNS...). On NE renvoie JAMAIS e.message ici
    // — pour les erreurs de statut, Dio le génère automatiquement en
    // anglais avec des détails d'implémentation internes qui n'ont rien à
    // faire devant un utilisateur. Le détail technique part uniquement
    // dans les logs, pour le développeur.
    developer.log(
      'Erreur HTTP non explicitement gérée par ApiExceptionMapper',
      name: 'ApiExceptionMapper',
      error: 'status=$status type=${e.type} message=${e.message}',
    );
    return Failure.inconnue(_extraireMessage(data) ??
        'Une erreur est survenue. Veuillez réessayer plus tard.');
  }

  static String? _extraireMessage(dynamic data) {
    if (data is! Map) return null;
    if (data['detail'] != null) return data['detail'].toString();
    if (data['error'] != null) return data['error'].toString();
    if (data['non_field_errors'] is List &&
        (data['non_field_errors'] as List).isNotEmpty) {
      return data['non_field_errors'][0].toString();
    }
    // Première erreur de champ trouvée, en dernier recours
    for (final valeur in data.values) {
      if (valeur is List && valeur.isNotEmpty) return valeur.first.toString();
      if (valeur is String) return valeur;
    }
    return null;
  }
}
