import '../core/network/api_client.dart';
import '../models/notification.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final ApiClient _apiClient;
  NotificationRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<AppNotification>> lister() async {
    try {
      final reponse = await _apiClient.dio.get('/notifications/notifications/');
      final data = reponse.data;
      final liste = data is List ? data : (data['results'] as List? ?? []);
      return liste
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> marquerCommeLue(String id) async {
    try {
      await _apiClient.dio.post('/notifications/notifications/$id/marquer_lu/');
    } catch (_) {
      // Silencieux : un échec de marquage ne doit pas interrompre l'UI.
    }
  }

  @override
  Future<void> marquerToutesCommeLues() async {
    try {
      await _apiClient.dio
          .post('/notifications/notifications/marquer_toutes_lues/');
    } catch (_) {}
  }

  @override
  Future<int> nombreNonLues() async {
    try {
      final reponse =
          await _apiClient.dio.get('/notifications/notifications/non_lues/');
      return (reponse.data as Map<String, dynamic>)['count'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> supprimer(String id) async {
    try {
      await _apiClient.dio
          .delete('/notifications/notifications/$id/supprimer/');
    } catch (_) {}
  }
}
