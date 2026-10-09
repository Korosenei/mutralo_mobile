import '../core/utils/result.dart';
import '../models/utilisateur.dart';

abstract interface class IAuthRepository {
  Future<Result<Utilisateur>> login({required String email, required String motDePasse});
  Future<Result<void>> logout();
  Future<Result<Utilisateur>> moi();
  Future<Result<void>> changerMotDePasse({required String ancien, required String nouveau, required String confirmation});
  Future<Result<void>> demanderReinitialisationMotDePasse({required String email});
  Future<bool> estConnecte();
}
