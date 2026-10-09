import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/utils/result.dart';
import '../models/evaluation.dart';

abstract interface class IEvaluationRepository {
  /// POST /restaurants/evaluations/evaluer/  { consommation, note, commentaire }
  /// Note UNIQUEMENT le plat (EvaluationPlat.consommation est OneToOne —
  /// le backend refuse une 2e évaluation sur la même consommation).
  Future<Result<Evaluation>> evaluer({
    required int consommationId,
    required int note,
    String commentaire = '',
  });

  /// GET /restaurants/evaluations/ — le backend route automatiquement vers
  /// les évaluations du client connecté (EvaluationSelector.du_client).
  Future<Result<List<Evaluation>>> mesEvaluations();

  /// GET /restaurants/evaluations/ — pour un gestionnaire connecté, route
  /// automatiquement vers les évaluations de SON restaurant
  /// (EvaluationSelector.du_restaurant), accessible même si non programmé.
  Future<Result<List<Evaluation>>> evaluationsDeMonRestaurant();

  /// GET /restaurants/evaluations/classement_restaurants/
  Future<Result<List<ClassementEntree>>> classementRestaurants({
    DateTime? dateDebut,
    DateTime? dateFin,
    int minAvis = 1,
  });

  /// GET /restaurants/evaluations/classement_menus/?restaurant=
  Future<Result<List<ClassementEntree>>> classementMenus({
    int? restaurantId,
    DateTime? dateDebut,
    DateTime? dateFin,
    int minAvis = 1,
  });
}

class EvaluationRepositoryImpl implements IEvaluationRepository {
  final ApiClient _apiClient;
  EvaluationRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Result<Evaluation>> evaluer({
    required int consommationId,
    required int note,
    String commentaire = '',
  }) async {
    try {
      final reponse = await _apiClient.dio.post('/restaurants/evaluations/evaluer/', data: {
        'consommation': consommationId,
        'note': note,
        'commentaire': commentaire,
      });
      return Result.success(Evaluation.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<Evaluation>>> mesEvaluations() async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/evaluations/');
      return Result.success(_liste(reponse.data).map((e) => Evaluation.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<Evaluation>>> evaluationsDeMonRestaurant() async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/evaluations/');
      return Result.success(_liste(reponse.data).map((e) => Evaluation.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<ClassementEntree>>> classementRestaurants({
    DateTime? dateDebut,
    DateTime? dateFin,
    int minAvis = 1,
  }) async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/evaluations/classement_restaurants/', queryParameters: {
        if (dateDebut != null) 'date_debut': _fmt(dateDebut),
        if (dateFin != null) 'date_fin': _fmt(dateFin),
        'min': minAvis,
      });
      return Result.success(_liste(reponse.data).map((e) => ClassementEntree.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<ClassementEntree>>> classementMenus({
    int? restaurantId,
    DateTime? dateDebut,
    DateTime? dateFin,
    int minAvis = 1,
  }) async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/evaluations/classement_menus/', queryParameters: {
        if (restaurantId != null) 'restaurant': restaurantId,
        if (dateDebut != null) 'date_debut': _fmt(dateDebut),
        if (dateFin != null) 'date_fin': _fmt(dateFin),
        'min': minAvis,
      });
      return Result.success(_liste(reponse.data).map((e) => ClassementEntree.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  List<Map<String, dynamic>> _liste(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['results'] is List) return (data['results'] as List).cast<Map<String, dynamic>>();
    return [];
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
