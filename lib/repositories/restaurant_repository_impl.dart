import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/utils/result.dart';
import '../models/restaurant.dart';
import 'restaurant_repository.dart';

class RestaurantRepositoryImpl implements IRestaurantRepository {
  final ApiClient _apiClient;
  RestaurantRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Result<List<Restaurant>>> restaurants(
      {String? ville, String? statut}) async {
    try {
      final reponse = await _apiClient.dio
          .get('/restaurants/restaurants/', queryParameters: {
        if (ville != null) 'ville': ville,
        if (statut != null) 'statut': statut,
      });
      return Result.success(
          _liste(reponse).map((e) => Restaurant.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<Restaurant>> restaurant(int id) async {
    try {
      final reponse = await _apiClient.dio.get('/restaurants/restaurants/$id/');
      return Result.success(
          Restaurant.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<Menu>>> menusDuJourRestaurant(int restaurantId) async {
    try {
      final reponse = await _apiClient.dio
          .get('/restaurants/restaurants/$restaurantId/menus_du_jour/');
      return Result.success(
          _liste(reponse).map((e) => Menu.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<Menu>>> menusRestaurant(int restaurantId,
      {DateTime? dateDebut, DateTime? dateFin}) async {
    try {
      final reponse =
          await _apiClient.dio.get('/restaurants/menus/', queryParameters: {
        'restaurant': restaurantId,
        if (dateDebut != null) 'date_debut': _fmt(dateDebut),
        if (dateFin != null) 'date_fin': _fmt(dateFin),
      });
      return Result.success(
          _liste(reponse).map((e) => Menu.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<Menu>> creerMenu(Map<String, dynamic> donnees,
      {String? imagePath}) async {
    try {
      final data = await _construireCorpsMenu(donnees, imagePath);
      final reponse =
          await _apiClient.dio.post('/restaurants/menus/', data: data);
      return Result.success(
          Menu.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<Menu>> modifierMenu(int menuId, Map<String, dynamic> donnees,
      {String? imagePath}) async {
    try {
      final data = await _construireCorpsMenu(donnees, imagePath);
      final reponse =
          await _apiClient.dio.patch('/restaurants/menus/$menuId/', data: data);
      return Result.success(
          Menu.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  /// Construit soit un simple Map (JSON, comme avant) soit un FormData
  /// multipart quand une image locale doit être envoyée — l'API Menu
  /// (MenuSerializer) expose un ImageField 'image' qui exige un envoi
  /// multipart/form-data, jamais du JSON, dès qu'un fichier est fourni.
  Future<dynamic> _construireCorpsMenu(
      Map<String, dynamic> donnees, String? imagePath) async {
    if (imagePath == null) return donnees;
    final nomFichier = imagePath.split(Platform.pathSeparator).last;
    return FormData.fromMap({
      ...donnees.map((cle, valeur) => MapEntry(cle, valeur?.toString())),
      'image': await MultipartFile.fromFile(imagePath, filename: nomFichier),
    });
  }

  @override
  Future<Result<void>> supprimerMenu(int menuId) async {
    try {
      await _apiClient.dio.delete('/restaurants/menus/$menuId/');
      return Result.success(null);
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<PlanningRestaurant>>> planningsAgence(int agenceId) async {
    try {
      final reponse =
          await _apiClient.dio.get('/restaurants/plannings/', queryParameters: {
        'agence': agenceId,
      });
      return Result.success(
          _liste(reponse).map((e) => PlanningRestaurant.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<List<PlanningRestaurant>>> planningsRestaurant(
      int restaurantId) async {
    try {
      final reponse =
          await _apiClient.dio.get('/restaurants/plannings/', queryParameters: {
        'restaurant': restaurantId,
      });
      return Result.success(
          _liste(reponse).map((e) => PlanningRestaurant.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<PlanningRestaurant>> creerPlanning(
      Map<String, dynamic> donnees) async {
    try {
      final reponse =
          await _apiClient.dio.post('/restaurants/plannings/', data: donnees);
      return Result.success(
          PlanningRestaurant.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  List<Map<String, dynamic>> _liste(Response reponse) {
    final data = reponse.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['results'] is List)
      return (data['results'] as List).cast<Map<String, dynamic>>();
    return [];
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
