import '../models/notification.dart';
import '../repositories/notification_repository.dart';

class NotificationService {
  final INotificationRepository _repository;
  NotificationService({required INotificationRepository repository})
      : _repository = repository;

  Future<List<AppNotification>> lister() => _repository.lister();
  Future<void> marquerCommeLue(String id) => _repository.marquerCommeLue(id);
  Future<void> marquerToutesCommeLues() => _repository.marquerToutesCommeLues();
  Future<int> nombreNonLues() => _repository.nombreNonLues();
  Future<void> supprimer(String id) => _repository.supprimer(id);
}
