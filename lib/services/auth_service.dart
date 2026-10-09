import '../core/utils/result.dart';
import '../models/utilisateur.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  final IAuthRepository _repository;
  AuthService({required IAuthRepository repository}) : _repository = repository;

  Future<Result<Utilisateur>> login(String email, String motDePasse) {
    final emailValide = email.trim();
    if (emailValide.isEmpty || motDePasse.isEmpty) {
      return Future.value(Result.failure(
        Failure.validation(
            'Veuillez renseigner votre email et votre mot de passe.'),
      ));
    }
    return _repository.login(email: emailValide, motDePasse: motDePasse);
  }

  Future<Result<void>> logout() => _repository.logout();

  Future<Result<Utilisateur>> utilisateurConnecte() => _repository.moi();

  Future<bool> estConnecte() => _repository.estConnecte();

  Future<Result<void>> changerMotDePasse({
    required String ancien,
    required String nouveau,
    required String confirmation,
  }) {
    if (nouveau.length < 4) {
      return Future.value(Result.failure(
        Failure.validation('Le nouveau mot de passe est trop court.'),
      ));
    }
    if (nouveau != confirmation) {
      return Future.value(Result.failure(
        Failure.validation('Les deux mots de passe ne correspondent pas.'),
      ));
    }
    return _repository.changerMotDePasse(
      ancien: ancien,
      nouveau: nouveau,
      confirmation: confirmation,
    );
  }

  Future<Result<void>> demanderReinitialisationMotDePasse(String email) {
    final valide = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
    if (!valide) {
      return Future.value(
          Result.failure(Failure.validation('Adresse email invalide.')));
    }
    return _repository.demanderReinitialisationMotDePasse(email: email.trim());
  }
}
