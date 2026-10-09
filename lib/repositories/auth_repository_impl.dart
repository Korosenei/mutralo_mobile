import '../core/network/api_client.dart';
import '../core/network/api_exception_mapper.dart';
import '../core/storage/token_storage.dart';
import '../core/utils/result.dart';
import '../models/utilisateur.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient _apiClient;
  final ITokenStorage _tokenStorage;

  AuthRepositoryImpl(
      {required ApiClient apiClient, required ITokenStorage tokenStorage})
      : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<Result<Utilisateur>> login(
      {required String email, required String motDePasse}) async {
    try {
      final reponse = await _apiClient.dio.post('/accounts/login/', data: {
        'email': email,
        'mot_de_passe': motDePasse,
      });
      final data = reponse.data as Map<String, dynamic>;
      await _tokenStorage.sauvegarderTokens(
        access: data['access'] as String,
        refresh: data['refresh'] as String,
      );
      return Result.success(
          Utilisateur.fromJson(data['utilisateur'] as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refresh = await _tokenStorage.lireRefreshToken();
      if (refresh != null) {
        await _apiClient.dio
            .post('/accounts/logout/', data: {'refresh': refresh});
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    } finally {
      // On efface la session locale même si l'appel serveur échoue : on ne
      // bloque jamais un utilisateur qui veut se déconnecter.
      await _tokenStorage.effacerTokens();
    }
  }

  @override
  Future<Result<Utilisateur>> moi() async {
    try {
      final reponse = await _apiClient.dio.get('/accounts/me/');
      return Result.success(
          Utilisateur.fromJson(reponse.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<void>> changerMotDePasse({
    required String ancien,
    required String nouveau,
    required String confirmation,
  }) async {
    try {
      await _apiClient.dio.post('/accounts/me/change-password/', data: {
        'ancien_mot_de_passe': ancien,
        'nouveau_mot_de_passe': nouveau,
        'nouveau_mot_de_passe2': confirmation,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<Result<void>> demanderReinitialisationMotDePasse(
      {required String email}) async {
    // TODO(backend): endpoint à créer — POST /api/accounts/password/oubli/
    // { "email": "..." } -> envoie un email/SMS de réinitialisation.
    // Le repository est déjà prêt côté mobile pour brancher dessus sans
    // toucher au reste de l'app (Provider/UI) une fois le backend livré.
    try {
      await _apiClient.dio
          .post('/accounts/password/oubli/', data: {'email': email});
      return Result.success(null);
    } catch (e) {
      return Result.failure(ApiExceptionMapper.depuis(e));
    }
  }

  @override
  Future<bool> estConnecte() async {
    final access = await _tokenStorage.lireAccessToken();
    return access != null;
  }
}
