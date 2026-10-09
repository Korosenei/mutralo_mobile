import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/utils/result.dart';
import '../models/log_consommation.dart';

abstract interface class IHistoriqueRepository {
  /// GET /api/transactions/logs-consommation/ — le backend filtre
  /// automatiquement sur le client connecté (LogConsommationViewSet).
  Future<Result<List<LogConsommationClient>>> mesConsommations();
}

class HistoriqueRepositoryImpl implements IHistoriqueRepository {
  final ApiClient _apiClient;
  HistoriqueRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Result<List<LogConsommationClient>>> mesConsommations() async {
    try {
      final reponse = await _apiClient.dio.get('/transactions/logs-consommation/');
      final data = reponse.data;
      final liste = data is List ? data : (data['results'] as List? ?? []);
      return Result.success(
        liste.map((e) => LogConsommationClient.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }
}
