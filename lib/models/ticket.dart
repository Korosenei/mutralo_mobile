class Ticket {
  static const disponible = 'DISPONIBLE';
  static const consomme = 'CONSOMME';
  static const annule = 'ANNULE';

  final int id;
  final String numeroTicket;
  final String statut;
  final String prixPaye;
  final DateTime? dateConsommation;
  final int? restaurantConsommateurId;
  final String? restaurantConsommateurNom;
  final int transactionId;
  final DateTime dateCreation;

  const Ticket({
    required this.id,
    required this.numeroTicket,
    required this.statut,
    required this.prixPaye,
    required this.transactionId,
    required this.dateCreation,
    this.dateConsommation,
    this.restaurantConsommateurId,
    this.restaurantConsommateurNom,
  });

  bool get estDisponible => statut == disponible;
  bool get estConsomme => statut == consomme;

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      numeroTicket: json['numero_ticket'] as String,
      statut: json['statut'] as String,
      prixPaye: json['prix_paye'].toString(),
      transactionId: json['transaction'] as int,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateConsommation: json['date_consommation'] != null
          ? DateTime.parse(json['date_consommation'] as String)
          : null,
      restaurantConsommateurId: json['restaurant_consommateur'] as int?,
      restaurantConsommateurNom: json['restaurant_consommateur_nom'] as String?,
    );
  }
}

class CodeQR {
  final int id;
  final String code;
  final String? imageQrUrl;
  final DateTime expireLe;
  final bool estValide;
  final bool estUtilise;

  const CodeQR({
    required this.id,
    required this.code,
    required this.expireLe,
    required this.estValide,
    required this.estUtilise,
    this.imageQrUrl,
  });

  bool get estExpire => DateTime.now().isAfter(expireLe);

  factory CodeQR.fromJson(Map<String, dynamic> json) {
    return CodeQR(
      id: json['id'] as int,
      code: json['code'] as String,
      imageQrUrl: json['image_qr'] as String?,
      expireLe: DateTime.parse(json['expire_le'] as String),
      estValide: json['est_valide'] as bool? ?? false,
      estUtilise: json['est_utilise'] as bool? ?? false,
    );
  }
}
