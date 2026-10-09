import '../core/utils/result.dart';
import '../models/restaurant.dart';
import '../repositories/reservation_repository.dart';

class ReservationService {
  final IReservationRepository _repository;
  ReservationService({required IReservationRepository repository}) : _repository = repository;

  Future<Result<List<Reservation>>> mesReservations() => _repository.mesReservations();

  Future<Result<Reservation>> reserver({required Menu menu, required DateTime date, int quantite = 1}) {
    if (!menu.estDisponible) {
      return Future.value(Result.failure(Failure.validation('Ce plat n\'est plus disponible.')));
    }
    if (date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      return Future.value(Result.failure(Failure.validation('La date de réservation doit être dans le futur.')));
    }
    return _repository.creer(menuId: menu.id, date: date, quantite: quantite);
  }

  Future<Result<void>> annuler(Reservation reservation) {
    if (reservation.statut == 'TERMINE') {
      return Future.value(Result.failure(Failure.validation("Impossible d'annuler une réservation terminée.")));
    }
    return _repository.annuler(reservation.id);
  }

  // ── Côté gestionnaire ────────────────────────────────────────────────

  Future<Result<List<Reservation>>> reservationsDeMonRestaurant({String? statut, DateTime? date}) =>
      _repository.reservationsDeMonRestaurant(statut: statut, date: date);

  Future<Result<Reservation>> confirmer(Reservation reservation) {
    if (reservation.statut != 'EN_ATTENTE') {
      return Future.value(Result.failure(Failure.validation('Seule une réservation en attente peut être confirmée.')));
    }
    return _repository.confirmer(reservation.id);
  }

  Future<Result<Reservation>> terminer(Reservation reservation) => _repository.terminer(reservation.id);
}
