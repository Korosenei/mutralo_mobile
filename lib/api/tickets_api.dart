import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/ticket.dart';

class TicketsApi {
  static final Dio _dio = ApiClient.instance.dio;

  static Future<List<Ticket>> getMesTickets() async {
    final resp = await _dio.get('/api/tickets/tickets/mes_tickets/');
    return (resp.data as List).map((e) => Ticket.fromJson(e)).toList();
  }

  static Future<List<Ticket>> getTousMesTickets() async {
    final resp = await _dio.get('/api/tickets/tickets/');
    final data = resp.data is Map && resp.data['results'] != null
        ? resp.data['results']
        : resp.data;
    return (data as List).map((e) => Ticket.fromJson(e)).toList();
  }

  static Future<CodeQR?> getCodeQRActif() async {
    try {
      final resp = await _dio.get('/api/tickets/codes-qr/actif/');
      return CodeQR.fromJson(resp.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<CodeQR> genererCodeQR() async {
    final resp = await _dio.post('/api/tickets/codes-qr/');
    return CodeQR.fromJson(resp.data);
  }

  static Future<void> invaliderCodeQR(int id) async {
    await _dio.post('/api/tickets/codes-qr/$id/invalider/');
  }

  static Future<(int, List<Notif>)> getNotificationsNonLues() async {
    final resp = await _dio.get('/api/notifications/notifications/non_lues/');
    final notifs = (resp.data['notifications'] as List)
        .map((e) => Notif.fromJson(e))
        .toList();
    return (resp.data['count'] as int, notifs);
  }

  static Future<void> marquerNotificationLue(int id) async {
    await _dio.post('/api/notifications/notifications/$id/marquer_lu/');
  }

  static Future<void> marquerToutesLues() async {
    await _dio.post('/api/notifications/notifications/marquer_tout_lu/');
  }
}
