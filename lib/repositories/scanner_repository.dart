import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/utils/result.dart';
import '../models/restaurant.dart';

class ResultatVerificationQR {
  final bool valide;
  final String? erreur;
  final String? client;
  final String? matricule;
  final String? agence;
  final String? ticketNumero;
  final int? ticketsRestants;
  final String? photoUrl;
  final List<Map<String, dynamic>> platsDuJour;
  final Map<String, dynamic>? reservation;

  const ResultatVerificationQR({
    required this.valide,
    this.erreur,
    this.client,
    this.matricule,
    this.agence,
    this.ticketNumero,
    this.ticketsRestants,
    this.photoUrl,
    this.platsDuJour = const [],
    this.reservation,
  });

  factory ResultatVerificationQR.fromJson(Map<String, dynamic> json) {
    return ResultatVerificationQR(
      valide: json['valide'] as bool? ?? false,
      erreur: json['error'] as String?,
      client: json['client'] as String?,
      matricule: json['matricule'] as String?,
      agence: json['agence'] as String?,
      ticketNumero: json['ticket_numero'] as String?,
      ticketsRestants: json['tickets_restants'] as int?,
      photoUrl: json['photo_url'] as String?,
      platsDuJour:
          (json['plats_du_jour'] as List? ?? []).cast<Map<String, dynamic>>(),
      reservation: json['reservation'] as Map<String, dynamic>?,
    );
  }
}

abstract interface class IScannerRepository {
  /// Vérifie le QR code SANS consommer le ticket (aperçu client + plats du jour).
  Future<Result<ResultatVerificationQR>> verifier(String code);

  /// Valide définitivement : associe le plat choisi (obligatoire s'il y a
  /// des plats disponibles et pas de réservation déjà faite) et consomme le
  /// ticket — reflète la règle métier de scanner_valider côté backend.
  Future<Result<Map<String, dynamic>>> valider(String code, {int? menuId});

  /// GET /restaurants/consommations/ — accessible même si le restaurant du
  /// gestionnaire N'EST PAS programmé aujourd'hui (permission
  /// EstGestionnaireAvecRestaurant, distincte de EstGestionnaireDeRestaurantProgramme
  /// utilisée pour le scanner). C'est ce qui permet au gestionnaire "non
  /// programmé" de continuer à consulter son historique.
  Future<Result<(StatsConsommations, List<ConsommationHistorique>)>>
      consommations({
    DateTime? dateDebut,
    DateTime? dateFin,
    int? agenceId,
    String? recherche,
  });
}

class ScannerRepositoryImpl implements IScannerRepository {
  final ApiClient _apiClient;
  ScannerRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Result<ResultatVerificationQR>> verifier(String code) async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/scanner/verifier/',
          queryParameters: {'code': code});
      return Result.success(ResultatVerificationQR.fromJson(
          reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> valider(String code,
      {int? menuId}) async {
    try {
      final reponse =
          await _apiClient.dio.post('/restaurants/scanner/valider/', data: {
        'code': code,
        if (menuId != null) 'menu_id': menuId,
      });
      return Result.success(reponse.data as Map<String, dynamic>);
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<(StatsConsommations, List<ConsommationHistorique>)>>
      consommations({
    DateTime? dateDebut,
    DateTime? dateFin,
    int? agenceId,
    String? recherche,
  }) async {
    try {
      final reponse = await _apiClient.dio
          .get('/restaurants/consommations/', queryParameters: {
        if (dateDebut != null) 'date_debut': _fmt(dateDebut),
        if (dateFin != null) 'date_fin': _fmt(dateFin),
        if (agenceId != null) 'agence': agenceId,
        if (recherche != null && recherche.isNotEmpty) 'search': recherche,
      });
      final data = reponse.data as Map<String, dynamic>;
      final stats =
          StatsConsommations.fromJson(data['stats'] as Map<String, dynamic>);
      final resultats = (data['resultats'] as List)
          .map(
              (e) => ConsommationHistorique.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success((stats, resultats));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
