import '../core/utils/result.dart';
import '../models/agence.dart';
import '../repositories/agence_repository.dart';

class AgenceService {
  final IAgenceRepository _repository;
  AgenceService({required IAgenceRepository repository}) : _repository = repository;

  Future<Result<List<Agence>>> lister({String? recherche}) => _repository.lister(recherche: recherche);
}
