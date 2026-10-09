import '../core/utils/result.dart';
import '../models/log_consommation.dart';
import '../repositories/historique_repository.dart';

class HistoriqueService {
  final IHistoriqueRepository _repository;
  HistoriqueService({required IHistoriqueRepository repository}) : _repository = repository;

  Future<Result<List<LogConsommationClient>>> mesConsommations() async {
    final result = await _repository.mesConsommations();
    return result.when(
      success: (liste) {
        final triee = [...liste]..sort((a, b) => b.dateConsommation.compareTo(a.dateConsommation));
        return Result.success(triee);
      },
      failure: (f) => Result.failure(f),
    );
  }
}
