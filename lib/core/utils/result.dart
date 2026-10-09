/// Type "Result" générique : encapsule soit une réussite (Success<T>) soit
/// un échec (Failure). Objectif : sortir la gestion d'erreurs des try/catch
/// dispersés dans chaque écran, et donner un contrat explicite à toutes les
/// méthodes de Repository/Service.
///
/// Utilisation :
/// ```dart
/// final result = await ticketRepository.getMesTickets();
/// result.when(
///   success: (tickets) => ...,
///   failure: (failure) => ...,
/// );
/// ```
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = ResultFailure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is ResultFailure<T>) return failure(self.failure);
    throw StateError('Result non exhaustif');
  }

  /// Retourne la donnée si succès, sinon `null` (pratique pour l'UI quand
  /// on ne veut pas gérer explicitement l'erreur à cet endroit).
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}

/// Représentation normalisée d'une erreur, indépendante de Dio/HTTP.
/// Les Repositories ont la responsabilité de transformer toute exception
/// technique (DioException, TimeoutException, FormatException...) en Failure.
class Failure {
  final String message;
  final FailureType type;
  final Map<String, dynamic>? champErreurs; // erreurs de validation par champ (DRF-style)

  const Failure({
    required this.message,
    this.type = FailureType.inconnue,
    this.champErreurs,
  });

  factory Failure.reseau([String? message]) =>
      Failure(message: message ?? 'Erreur réseau. Vérifiez votre connexion.', type: FailureType.reseau);

  factory Failure.authentification([String? message]) =>
      Failure(message: message ?? 'Session expirée, veuillez vous reconnecter.', type: FailureType.authentification);

  factory Failure.validation(String message, {Map<String, dynamic>? champs}) =>
      Failure(message: message, type: FailureType.validation, champErreurs: champs);

  factory Failure.serveur([String? message]) =>
      Failure(message: message ?? 'Erreur serveur. Veuillez réessayer plus tard.', type: FailureType.serveur);

  factory Failure.inconnue([String? message]) =>
      Failure(message: message ?? 'Une erreur inattendue est survenue.', type: FailureType.inconnue);

  @override
  String toString() => 'Failure($type): $message';
}

enum FailureType { reseau, authentification, validation, serveur, inconnue }
