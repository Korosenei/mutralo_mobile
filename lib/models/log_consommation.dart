/// Miroir de transactions.models.LogConsommation, exposé côté client via
/// GET /api/transactions/logs-consommation/ (LogConsommationViewSet,
/// ReadOnly — filtré automatiquement par le backend selon le rôle).
///
/// C'est l'identifiant [id] de cette classe qui sert de `consommation` lors
/// de la notation d'un plat (EvaluationPlat.consommation est un OneToOne
/// dessus) — jamais le numéro de ticket.
class LogConsommationClient {
  final int id;
  final String ticketNumero;
  final int restaurantId;
  final String restaurantNom;
  final int? menuId;
  final String? menuNom;
  final DateTime dateConsommation;

  const LogConsommationClient({
    required this.id,
    required this.ticketNumero,
    required this.restaurantId,
    required this.restaurantNom,
    required this.dateConsommation,
    this.menuId,
    this.menuNom,
  });

  factory LogConsommationClient.fromJson(Map<String, dynamic> json) {
    return LogConsommationClient(
      id: json['id'] as int,
      ticketNumero: json['ticket_numero'] as String? ?? json['ticket']?.toString() ?? '',
      restaurantId: json['restaurant'] as int,
      restaurantNom: json['restaurant_nom'] as String? ?? '',
      menuId: json['menu_consomme'] as int?,
      menuNom: json['menu_consomme_nom'] as String?,
      dateConsommation: DateTime.parse(json['date_consommation'] as String),
    );
  }
}
