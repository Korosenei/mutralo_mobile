import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/restaurant.dart';
import '../services/reservation_service.dart';

/// Gestion des réservations côté GESTIONNAIRE : consultation + confirmer/
/// terminer (le client ne peut jamais faire ces deux actions — cf. brief,
/// c'est normalement le scan QR qui déclenche "terminer").
class GestionnaireReservationProvider extends ChangeNotifier {
  final ReservationService _service;
  GestionnaireReservationProvider({required ReservationService service})
      : _service = service;

  List<Reservation> _reservations = [];
  bool _chargement = false;
  bool _actionEnCours = false;
  Failure? _erreur;

  List<Reservation> get reservations => _reservations;
  bool get chargement => _chargement;
  bool get actionEnCours => _actionEnCours;
  Failure? get erreur => _erreur;

  Future<void> charger({String? statut, DateTime? date}) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    final result =
        await _service.reservationsDeMonRestaurant(statut: statut, date: date);
    result.when(success: (r) => _reservations = r, failure: (f) => _erreur = f);

    _chargement = false;
    notifyListeners();
  }

  Future<bool> confirmer(Reservation reservation) async {
    _actionEnCours = true;
    notifyListeners();
    final result = await _service.confirmer(reservation);
    bool succes = false;
    result.when(
      success: (maj) {
        _reservations =
            _reservations.map((r) => r.id == maj.id ? maj : r).toList();
        succes = true;
      },
      failure: (f) => _erreur = f,
    );
    _actionEnCours = false;
    notifyListeners();
    return succes;
  }

  Future<void> refuser(Reservation reservation) async {
    final result = await _service
        .annuler(reservation); // ReservationService.annuler existant
    if (result is Success<void>) {
      await charger(); // ou mise à jour optimiste de la liste locale
    }
    // sinon : exposer l'erreur via un champ `erreur` comme pour charger()
  }

  Future<bool> terminer(Reservation reservation) async {
    _actionEnCours = true;
    notifyListeners();
    final result = await _service.terminer(reservation);
    bool succes = false;
    result.when(
      success: (maj) {
        _reservations =
            _reservations.map((r) => r.id == maj.id ? maj : r).toList();
        succes = true;
      },
      failure: (f) => _erreur = f,
    );
    _actionEnCours = false;
    notifyListeners();
    return succes;
  }
}
