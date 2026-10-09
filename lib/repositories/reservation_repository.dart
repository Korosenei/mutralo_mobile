import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/utils/result.dart';
import '../models/restaurant.dart';

abstract interface class IReservationRepository {
  Future<Result<List<Reservation>>> mesReservations();
  Future<Result<Reservation>> creer({required int menuId, required DateTime date, int quantite = 1});
  Future<Result<void>> annuler(int reservationId);

  /// Réservations du restaurant du gestionnaire connecté — le backend
  /// (ReservationViewSet.get_queryset) route automatiquement vers le bon
  /// jeu de données selon le rôle, donc c'est le MÊME endpoint liste.
  Future<Result<List<Reservation>>> reservationsDeMonRestaurant({String? statut, DateTime? date});
  Future<Result<Reservation>> confirmer(int reservationId);
  Future<Result<Reservation>> terminer(int reservationId);
}

class ReservationRepositoryImpl implements IReservationRepository {
  final ApiClient _apiClient;
  ReservationRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Result<List<Reservation>>> mesReservations() async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/reservations/mes_reservations/');
      final data = reponse.data;
      final liste = data is List ? data : (data['results'] as List? ?? []);
      return Result.success(liste.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<Reservation>> creer({required int menuId, required DateTime date, int quantite = 1}) async {
    try {
      final reponse = await _apiClient.dio.post('/restaurants/reservations/', data: {
        'menu': menuId,
        'date_reservation': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'quantite': quantite,
      });
      return Result.success(Reservation.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<void>> annuler(int reservationId) async {
    try {
      await _apiClient.dio.post('/restaurants/reservations/$reservationId/annuler/');
      return Result.success(null);
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<Reservation>>> reservationsDeMonRestaurant({String? statut, DateTime? date}) async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/reservations/', queryParameters: {
        if (statut != null) 'statut': statut,
        if (date != null) 'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      });
      final data = reponse.data;
      final liste = data is List ? data : (data['results'] as List? ?? []);
      return Result.success(liste.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<Reservation>> confirmer(int reservationId) async {
    try {
      final reponse = await _apiClient.dio.post('/restaurants/reservations/$reservationId/confirmer/');
      return Result.success(Reservation.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<Reservation>> terminer(int reservationId) async {
    try {
      final reponse = await _apiClient.dio.post('/restaurants/reservations/$reservationId/terminer/');
      return Result.success(Reservation.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }
}
