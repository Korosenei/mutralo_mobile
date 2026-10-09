import '../core/utils/result.dart';
import '../models/evaluation.dart';
import '../repositories/evaluation_repository.dart';

class EvaluationService {
  final IEvaluationRepository _repository;
  EvaluationService({required IEvaluationRepository repository}) : _repository = repository;

  /// Note UNIQUEMENT le plat consommé (pas de note de service — décision
  /// produit du brief). [consommationId] est l'identifiant du
  /// LogConsommation, seule entité qui garantit que le client a
  /// effectivement consommé ce plat précis ce jour-là (contrainte OneToOne
  /// côté backend : une seule évaluation par consommation).
  Future<Result<Evaluation>> noterPlatConsomme({
    required int consommationId,
    required int note,
    String commentaire = '',
  }) {
    if (note < 1 || note > 5) {
      return Future.value(Result.failure(Failure.validation('La note doit être comprise entre 1 et 5.')));
    }
    return _repository.evaluer(consommationId: consommationId, note: note, commentaire: commentaire.trim());
  }

  Future<Result<List<Evaluation>>> mesEvaluations() => _repository.mesEvaluations();
  Future<Result<List<Evaluation>>> evaluationsDeMonRestaurant() => _repository.evaluationsDeMonRestaurant();

  Future<Result<List<ClassementEntree>>> classementMenus({
    DateTime? dateDebut,
    DateTime? dateFin,
    int? restaurantId,
    int minAvis = 1,
  }) =>
      _repository.classementMenus(
        dateDebut: dateDebut,
        dateFin: dateFin,
        restaurantId: restaurantId,
        minAvis: minAvis,
      );

  Future<Result<List<ClassementEntree>>> classementRestaurants({
    DateTime? dateDebut,
    DateTime? dateFin,
    int minAvis = 1,
  }) =>
      _repository.classementRestaurants(dateDebut: dateDebut, dateFin: dateFin, minAvis: minAvis);
}
