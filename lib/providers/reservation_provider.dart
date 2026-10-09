import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/restaurant.dart';
import '../services/reservation_service.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationService _service;
  ReservationProvider({required ReservationService service})
      : _service = service;

  List<Reservation> _mesReservations = [];
  bool _chargement = false;
  Failure? _erreur;

  List<Reservation> get mesReservations => _mesReservations;
  bool get chargement => _chargement;
  Failure? get erreur => _erreur;

  Future<void> chargerMesReservations() async {
    _chargement = true;
    notifyListeners();
    final result = await _service.mesReservations();
    result.when(
      success: (liste) => _mesReservations = liste,
      failure: (f) => _erreur = f,
    );
    _chargement = false;
    notifyListeners();
  }

  bool _memeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Réservation active (non annulée) du client pour une date donnée,
  /// tous menus confondus — reflète Reservation.active_du_jour côté backend.
  Reservation? reservationPour(DateTime date) {
    for (final r in _mesReservations) {
      if (_memeJour(r.dateReservation, date) && r.statut != 'ANNULE') {
        return r;
      }
    }
    return null;
  }

  bool dejaConsomme(DateTime date) =>
      reservationPour(date)?.statut == 'TERMINE';
  bool dejaReserve(DateTime date) {
    final r = reservationPour(date);
    return r != null && r.statut != 'TERMINE';
  }

  Future<bool> reserver({required Menu menu, required DateTime date}) async {
    final result = await _service.reserver(menu: menu, date: date);
    final succes = result is Success<Reservation>;
    if (succes) await chargerMesReservations();
    return succes;
  }

  Future<bool> annuler(Reservation reservation) async {
    final result = await _service.annuler(reservation);
    final succes = result is! ResultFailure<void>;
    if (succes) await chargerMesReservations();
    return succes;
  }
}
