import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/utils/result.dart';
import '../models/ticket.dart';
import 'ticket_repository.dart';

class TicketRepositoryImpl implements ITicketRepository {
  final ApiClient _apiClient;
  TicketRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Result<List<Ticket>>> mesTicketsDisponibles() async {
    try {
      final reponse = await _apiClient.dio.get('/tickets/tickets/mes_tickets/');
      final liste = _extraireListe(reponse);
      return Result.success(liste.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<Ticket>>> tousMesTickets() async {
    try {
      final reponse = await _apiClient.dio.get('/tickets/tickets/');
      final liste = _extraireListe(reponse);
      return Result.success(liste.map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<CodeQR?>> codeQRActif() async {
    try {
      final reponse = await _apiClient.dio.get('/tickets/codes-qr/actif/');
      return Result.success(CodeQR.fromJson(reponse.data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return Result.success(null);
      return Result.failure(ApiExceptionMapper.depuis(e));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<CodeQR>> genererCodeQR() async {
    try {
      final reponse = await _apiClient.dio.post('/tickets/codes-qr/');
      return Result.success(CodeQR.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<void>> invaliderCodeQR(int id) async {
    try {
      await _apiClient.dio.post('/tickets/codes-qr/$id/invalider/');
      return Result.success(null);
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  // DRF pagine par défaut ({ "results": [...] }) mais certaines @action
  // renvoient une liste brute — on gère les deux formats à un seul endroit.
  List<dynamic> _extraireListe(Response reponse) {
    final data = reponse.data;
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'] as List;
    return [];
  }
}
