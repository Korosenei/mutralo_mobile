import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/scanner_models.dart';

class ScannerApi {
  static final Dio _dio = ApiClient.instance.dio;

  static Future<ScannerVerifierResponse> verifierQRCode(String code) async {
    final resp = await _dio.get(
      '/api/restaurants/scanner/verifier/',
      queryParameters: {'code': code},
    );
    return ScannerVerifierResponse.fromJson(resp.data);
  }

  static Future<ScannerValiderResponse> validerQRCode(
    String code, {
    int? menuId,
  }) async {
    final resp = await _dio.post(
      '/api/restaurants/scanner/valider/',
      data: {'code': code, if (menuId != null) 'menu_id': menuId},
    );
    return ScannerValiderResponse.fromJson(resp.data);
  }

  static Future<ConsommationsResponse> getConsommations({
    String? search,
    String? dateDebut,
    String? dateFin,
  }) async {
    final resp = await _dio.get(
      '/api/restaurants/consommations/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin != null) 'date_fin': dateFin,
      },
    );
    return ConsommationsResponse.fromJson(resp.data);
  }
}
