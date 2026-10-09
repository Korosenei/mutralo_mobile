import '../core/utils/result.dart';
import '../models/restaurant.dart';
import '../models/utilisateur.dart';
import '../repositories/scanner_repository.dart';
import 'restaurant_service.dart';

class ScannerService {
  final IScannerRepository _scannerRepository;
  final RestaurantService _restaurantService;

  ScannerService({
    required IScannerRepository scannerRepository,
    required RestaurantService restaurantService,
  })  : _scannerRepository = scannerRepository,
        _restaurantService = restaurantService;

  /// Le gestionnaire ne peut scanner QUE si son restaurant a un planning
  /// actif aujourd'hui (règle métier centrale demandée dans le brief).
  /// Retourne false également si l'utilisateur ne gère aucun restaurant.
  Future<Result<bool>> peutScanner(Utilisateur utilisateur) async {
    if (!utilisateur.estGestionnaireRestaurant || utilisateur.restaurantGereId == null) {
      return Result.success(false);
    }
    return _restaurantService.estProgrammeAujourdhui(utilisateur.restaurantGereId!);
  }

  Future<Result<ResultatVerificationQR>> verifier(String code) => _scannerRepository.verifier(code);

  /// Valide le QR code. Applique la règle : si des plats du jour existent
  /// et qu'aucune réservation n'est déjà associée, [menuId] est obligatoire
  /// — sinon le backend renverra une erreur de validation explicite qui
  /// remonte telle quelle à l'UI (source de vérité côté serveur, on ne
  /// duplique pas la règle ici pour éviter une désynchronisation).
  Future<Result<Map<String, dynamic>>> valider(String code, {int? menuId}) =>
      _scannerRepository.valider(code, menuId: menuId);

  /// Accessible même si le restaurant n'est pas programmé aujourd'hui —
  /// le gestionnaire "non programmé" garde accès à son historique complet.
  Future<Result<(StatsConsommations, List<ConsommationHistorique>)>> consommations({
    DateTime? dateDebut,
    DateTime? dateFin,
    int? agenceId,
    String? recherche,
  }) =>
      _scannerRepository.consommations(
        dateDebut: dateDebut,
        dateFin: dateFin,
        agenceId: agenceId,
        recherche: recherche,
      );
}
