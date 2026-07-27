class PlatDuJour {
  final int id;
  final String nom;
  final int? quantiteDisponible;

  PlatDuJour({required this.id, required this.nom, this.quantiteDisponible});

  factory PlatDuJour.fromJson(Map<String, dynamic> json) {
    return PlatDuJour(
      id: json['id'],
      nom: json['nom'],
      quantiteDisponible: json['quantite_disponible'],
    );
  }
}

class ReservationInfo {
  final int id;
  final int menuId;
  final String menuNom;
  final String statut;

  ReservationInfo({
    required this.id,
    required this.menuId,
    required this.menuNom,
    required this.statut,
  });

  factory ReservationInfo.fromJson(Map<String, dynamic> json) {
    return ReservationInfo(
      id: json['id'],
      menuId: json['menu_id'],
      menuNom: json['menu_nom'],
      statut: json['statut'],
    );
  }
}

class ScannerVerifierResponse {
  final bool valide;
  final String? error;
  final String? code;
  final String? client;
  final String? matricule;
  final String? agence;
  final String? ticketNumero;
  final int? ticketsRestants;
  final String? photoUrl;
  final List<PlatDuJour> platsDuJour;
  final ReservationInfo? reservation;

  ScannerVerifierResponse({
    required this.valide,
    this.error,
    this.code,
    this.client,
    this.matricule,
    this.agence,
    this.ticketNumero,
    this.ticketsRestants,
    this.photoUrl,
    this.platsDuJour = const [],
    this.reservation,
  });

  factory ScannerVerifierResponse.fromJson(Map<String, dynamic> json) {
    return ScannerVerifierResponse(
      valide: json['valide'] ?? false,
      error: json['error'],
      code: json['code'],
      client: json['client'],
      matricule: json['matricule'],
      agence: json['agence'],
      ticketNumero: json['ticket_numero'],
      ticketsRestants: json['tickets_restants'],
      photoUrl: json['photo_url'],
      platsDuJour: (json['plats_du_jour'] as List<dynamic>? ?? [])
          .map((e) => PlatDuJour.fromJson(e))
          .toList(),
      reservation: json['reservation'] != null
          ? ReservationInfo.fromJson(json['reservation'])
          : null,
    );
  }
}

class ScannerValiderResponse {
  final bool valide;
  final String? error;
  final String? message;
  final String? client;
  final String? matricule;
  final String? agence;
  final String? ticketNumero;
  final String? plat;

  ScannerValiderResponse({
    required this.valide,
    this.error,
    this.message,
    this.client,
    this.matricule,
    this.agence,
    this.ticketNumero,
    this.plat,
  });

  factory ScannerValiderResponse.fromJson(Map<String, dynamic> json) {
    return ScannerValiderResponse(
      valide: json['valide'] ?? false,
      error: json['error'],
      message: json['message'],
      client: json['client'],
      matricule: json['matricule'],
      agence: json['agence'],
      ticketNumero: json['ticket_numero'],
      plat: json['plat'],
    );
  }
}

class ConsommationItem {
  final int id;
  final String numeroTicket;
  final String client;
  final String matricule;
  final String agence;
  final String dateConsommation;

  ConsommationItem({
    required this.id,
    required this.numeroTicket,
    required this.client,
    required this.matricule,
    required this.agence,
    required this.dateConsommation,
  });

  factory ConsommationItem.fromJson(Map<String, dynamic> json) {
    return ConsommationItem(
      id: json['id'],
      numeroTicket: json['numero_ticket'],
      client: json['client'],
      matricule: json['matricule'] ?? '',
      agence: json['agence'] ?? '',
      dateConsommation: json['date_consommation'],
    );
  }
}

class ConsommationsResponse {
  final int totalFiltre;
  final int aujourdHui;
  final int cetteSemaine;
  final int ceMois;
  final List<ConsommationItem> resultats;

  ConsommationsResponse({
    required this.totalFiltre,
    required this.aujourdHui,
    required this.cetteSemaine,
    required this.ceMois,
    required this.resultats,
  });

  factory ConsommationsResponse.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    return ConsommationsResponse(
      totalFiltre: stats['total_filtre'] ?? 0,
      aujourdHui: stats['aujourd_hui'] ?? 0,
      cetteSemaine: stats['cette_semaine'] ?? 0,
      ceMois: stats['ce_mois'] ?? 0,
      resultats: (json['resultats'] as List<dynamic>)
          .map((e) => ConsommationItem.fromJson(e))
          .toList(),
    );
  }
}
