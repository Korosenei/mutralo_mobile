class Ticket {
  final int id;
  final String numeroTicket;
  final String statut;
  final String valideDe;
  final String valideJusqua;
  final String prixPaye;
  final String montantSubventionne;
  final String? dateConsommation;
  final String? restaurantNom;
  final String? validePartNom;
  final String? transactionNumero;
  final bool estValide;
  final bool estExpire;

  Ticket({
    required this.id,
    required this.numeroTicket,
    required this.statut,
    required this.valideDe,
    required this.valideJusqua,
    required this.prixPaye,
    required this.montantSubventionne,
    this.dateConsommation,
    this.restaurantNom,
    this.validePartNom,
    this.transactionNumero,
    this.estValide = false,
    this.estExpire = false,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      numeroTicket: json['numero_ticket'],
      statut: json['statut'],
      valideDe: json['valide_de'],
      valideJusqua: json['valide_jusqua'],
      prixPaye: json['prix_paye'].toString(),
      montantSubventionne: json['montant_subventionne'].toString(),
      dateConsommation: json['date_consommation'],
      restaurantNom: json['restaurant_nom'],
      validePartNom: json['valide_par_nom'],
      transactionNumero: json['transaction_numero'],
      estValide: json['est_valide'] ?? false,
      estExpire: json['est_expire'] ?? false,
    );
  }

  static const statutLabels = {
    'DISPONIBLE': 'Disponible',
    'CONSOMME': 'Consommé',
    'EXPIRE': 'Expiré',
    'ANNULE': 'Annulé',
  };

  String get statutLabel => statutLabels[statut] ?? statut;
}

class CodeQR {
  final int id;
  final String code;
  final bool estValide;
  final bool estUtilise;
  final String expireLe;
  final String dateCreation;

  CodeQR({
    required this.id,
    required this.code,
    required this.estValide,
    required this.estUtilise,
    required this.expireLe,
    required this.dateCreation,
  });

  factory CodeQR.fromJson(Map<String, dynamic> json) {
    return CodeQR(
      id: json['id'],
      code: json['code'],
      estValide: json['est_valide'],
      estUtilise: json['est_utilise'],
      expireLe: json['expire_le'],
      dateCreation: json['date_creation'],
    );
  }
}

class Notif {
  final int id;
  final String typeNotification;
  final String priorite;
  final String titre;
  final String message;
  final bool estLu;
  final String creeLe;

  Notif({
    required this.id,
    required this.typeNotification,
    required this.priorite,
    required this.titre,
    required this.message,
    required this.estLu,
    required this.creeLe,
  });

  factory Notif.fromJson(Map<String, dynamic> json) {
    return Notif(
      id: json['id'],
      typeNotification: json['type_notification'],
      priorite: json['priorite'],
      titre: json['titre'],
      message: json['message'],
      estLu: json['est_lu'],
      creeLe: json['cree_le'],
    );
  }
}
