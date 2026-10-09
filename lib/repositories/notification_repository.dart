import '../models/notification.dart';

abstract interface class INotificationRepository {
  Future<List<AppNotification>> lister();
  Future<void> marquerCommeLue(String id);
  Future<void> marquerToutesCommeLues();
  Future<int> nombreNonLues();
  Future<void> supprimer(String id);
}
