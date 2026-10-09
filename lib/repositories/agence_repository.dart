import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/utils/result.dart';
import '../models/agence.dart';

abstract interface class IAgenceRepository {
  /// GET /api/accounts/agencies/ — lecture ouverte à tout utilisateur
  /// connecté (EstAdminOuLectureSeule), écriture réservée admin.
  Future<Result<List<Agence>>> lister({String? recherche});
}

class AgenceRepositoryImpl implements IAgenceRepository {
  final ApiClient _apiClient;
  AgenceRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Result<List<Agence>>> lister({String? recherche}) async {
    try {
      final reponse = await _apiClient.dio.get('/accounts/agencies/', queryParameters: {
        if (recherche != null && recherche.isNotEmpty) 'search': recherche,
      });
      final data = reponse.data;
      final liste = data is List ? data : (data['results'] as List? ?? []);
      return Result.success(liste.map((e) => Agence.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }
}
