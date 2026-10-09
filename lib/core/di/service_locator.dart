import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../storage/token_storage.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/auth_repository_impl.dart';
import '../../repositories/ticket_repository.dart';
import '../../repositories/ticket_repository_impl.dart';
import '../../repositories/restaurant_repository.dart';
import '../../repositories/restaurant_repository_impl.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/scanner_repository.dart';
import '../../repositories/evaluation_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/notification_repository_impl.dart';
import '../../repositories/historique_repository.dart';
import '../../repositories/agence_repository.dart';

import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../services/restaurant_service.dart';
import '../../services/reservation_service.dart';
import '../../services/scanner_service.dart';
import '../../services/evaluation_service.dart';
import '../../services/notification_service.dart';
import '../../services/historique_service.dart';
import '../../services/agence_service.dart';

/// Conteneur d'injection de dépendances (get_it).
///
/// C'est le SEUL fichier de tout le projet qui a le droit de connaître à la
/// fois une interface (ex: IAuthRepository) ET son implémentation concrète
/// (ex: AuthRepositoryImpl). Tout le reste de l'app (Services, Providers,
/// UI) ne manipule que des abstractions — c'est ce qui rend l'app testable
/// (on peut enregistrer des mocks ici pour les tests) et respecte
/// l'inversion de dépendance (principe D de SOLID).
final GetIt locator = GetIt.instance;

Future<void> configurerServiceLocator() async {
  // ── Core ────────────────────────────────────────────────────────────
  locator.registerLazySingleton<ITokenStorage>(() => SecureTokenStorage());
  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenStorage: locator<ITokenStorage>()),
  );

  // ── Repositories (interface -> implémentation) ─────────────────────
  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(apiClient: locator(), tokenStorage: locator()),
  );
  locator.registerLazySingleton<ITicketRepository>(
    () => TicketRepositoryImpl(apiClient: locator()),
  );
  locator.registerLazySingleton<IRestaurantRepository>(
    () => RestaurantRepositoryImpl(apiClient: locator()),
  );
  locator.registerLazySingleton<IReservationRepository>(
    () => ReservationRepositoryImpl(apiClient: locator()),
  );
  locator.registerLazySingleton<IScannerRepository>(
    () => ScannerRepositoryImpl(apiClient: locator()),
  );
  locator.registerLazySingleton<IEvaluationRepository>(
    () => EvaluationRepositoryImpl(apiClient: locator()),
  );
  // Backend notifs prêt (apps.notifs) — branché sur l'API réelle.
  // NotificationRepositoryLocal (mock) reste disponible dans le même
  // fichier pour des tests hors-ligne ; il suffirait de le substituer ici
  // pour y revenir, sans rien changer ailleurs dans l'app (Open/Closed).
  locator.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(apiClient: locator()),
  );
  locator.registerLazySingleton<IHistoriqueRepository>(
    () => HistoriqueRepositoryImpl(apiClient: locator()),
  );
  locator.registerLazySingleton<IAgenceRepository>(
    () => AgenceRepositoryImpl(apiClient: locator()),
  );

  // ── Services (règles métier) ─────────────────────────────────────────
  locator.registerLazySingleton(() => AuthService(repository: locator()));
  locator.registerLazySingleton(() => TicketService(repository: locator()));
  locator.registerLazySingleton(() => RestaurantService(repository: locator()));
  locator
      .registerLazySingleton(() => ReservationService(repository: locator()));
  locator.registerLazySingleton(
    () => ScannerService(
        scannerRepository: locator(), restaurantService: locator()),
  );
  locator.registerLazySingleton(() => EvaluationService(repository: locator()));
  locator
      .registerLazySingleton(() => NotificationService(repository: locator()));
  locator.registerLazySingleton(() => HistoriqueService(repository: locator()));
  locator.registerLazySingleton(() => AgenceService(repository: locator()));
}
