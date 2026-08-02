import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/restaurant_models.dart';

class RestaurantsApi {
  static final Dio _dio = ApiClient.instance.dio;

  /// Menus du jour disponibles. Regroupe côté client par restaurant.
  /// NB: correspond à l'action `du_jour` de MenuViewSet — si le backend
  /// évolue pour scoper cette liste aux restaurants réellement programmés
  /// pour l'agence de l'utilisateur, aucune modification mobile ne sera
  /// nécessaire (même contrat de réponse).
  static Future<List<MenuJour>> getMenusDuJour() async {
    final resp = await _dio.get('/api/restaurants/menus/du_jour/');
    final data = _unwrap(resp.data);
    return data.map((e) => MenuJour.fromJson(e)).toList();
  }

  static Future<List<Reservation>> getMesReservations() async {
    final resp =
        await _dio.get('/api/restaurants/reservations/mes_reservations/');
    final data = _unwrap(resp.data);
    return data.map((e) => Reservation.fromJson(e)).toList();
  }

  static Future<Reservation> creerReservation({
    required int menuId,
    required String dateReservation, // format 'YYYY-MM-DD'
  }) async {
    final resp = await _dio.post(
      '/api/restaurants/reservations/',
      data: {'menu': menuId, 'date_reservation': dateReservation},
    );
    return Reservation.fromJson(resp.data);
  }

  static Future<void> annulerReservation(int id) async {
    await _dio.post('/api/restaurants/reservations/$id/annuler/');
  }

  static List<Map<String, dynamic>> _unwrap(dynamic data) {
    final raw =
        (data is Map && data['results'] != null) ? data['results'] : data;
    return (raw as List).cast<Map<String, dynamic>>();
  }
}

class ConsommationsClientApi {
  static final Dio _dio = ApiClient.instance.dio;

  /// Historique détaillé des consommations du client connecté (agence,
  /// restaurant, plat). Utilisé pour le détail d'un ticket CONSOMME.
  static Future<List<LogConsommation>> getMesLogsConsommation() async {
    final List<LogConsommation> tous = [];
    String? nextUrl = '/api/transactions/logs-consommation/';

    // On parcourt les pages pour être sûr de retrouver le log correspondant
    // à un ticket même s'il ne figure pas dans la première page.
    while (nextUrl != null) {
      final resp = await _dio.get(nextUrl);
      final data = resp.data;
      if (data is Map && data['results'] != null) {
        tous.addAll(
          (data['results'] as List).map((e) => LogConsommation.fromJson(e)),
        );
        nextUrl = data['next'];
      } else if (data is List) {
        tous.addAll(data.map((e) => LogConsommation.fromJson(e)));
        nextUrl = null;
      } else {
        nextUrl = null;
      }
    }
    return tous;
  }
}
