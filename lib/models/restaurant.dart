class Restaurant {
  final int id;
  final String nom;
  final String code;
  final String ville;
  final String statut; // ACTIF, INACTIF, SUSPENDU
  final String? logoUrl;
  final String? imageCouvertureUrl;
  final double? noteMoyenne; // calculée côté backend sur les évaluations de plats
  final int? nombreEvaluations;

  const Restaurant({
    required this.id,
    required this.nom,
    required this.code,
    required this.ville,
    required this.statut,
    this.logoUrl,
    this.imageCouvertureUrl,
    this.noteMoyenne,
    this.nombreEvaluations,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as int,
      nom: json['nom'] as String,
      code: json['code'] as String,
      ville: json['ville'] as String? ?? '',
      statut: json['statut'] as String? ?? 'ACTIF',
      logoUrl: json['logo'] as String?,
      imageCouvertureUrl: json['image_couverture'] as String?,
      noteMoyenne: (json['note_moyenne'] as num?)?.toDouble(),
      nombreEvaluations: json['nombre_evaluations'] as int?,
    );
  }
}

class PlanningRestaurant {
  final int id;
  final int restaurantId;
  final String? restaurantNom;
  final int agenceId;
  final String? agenceNom;
  final DateTime dateDebut;
  final DateTime dateFin;
  final bool estActif;

  const PlanningRestaurant({
    required this.id,
    required this.restaurantId,
    required this.agenceId,
    required this.dateDebut,
    required this.dateFin,
    required this.estActif,
    this.restaurantNom,
    this.agenceNom,
  });

  /// Vrai si le planning couvre la date du jour et est actif — c'est cette
  /// condition qui autorise (ou non) le gestionnaire à scanner des QR codes.
  bool get estActuel {
    final aujourdhui = DateTime.now();
    final debut = DateTime(dateDebut.year, dateDebut.month, dateDebut.day);
    final fin = DateTime(dateFin.year, dateFin.month, dateFin.day);
    final jour = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    return estActif && !jour.isBefore(debut) && !jour.isAfter(fin);
  }

  factory PlanningRestaurant.fromJson(Map<String, dynamic> json) {
    return PlanningRestaurant(
      id: json['id'] as int,
      restaurantId: json['restaurant'] as int,
      restaurantNom: json['restaurant_nom'] as String?,
      agenceId: json['agence'] as int,
      agenceNom: json['agence_nom'] as String?,
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
      estActif: json['est_actif'] as bool? ?? true,
    );
  }
}

class Menu {
  final int id;
  final int restaurantId;
  final String? restaurantNom;
  final String jourSemaine;
  final DateTime? date;
  final String nom;
  final String description;
  final String plats;
  final bool estDisponible;
  final int? quantiteDisponible;
  final int quantiteConsomme;
  final String prix;
  final String? imageUrl;
  final double? noteMoyenne;
  final int? nombreEvaluations;

  const Menu({
    required this.id,
    required this.restaurantId,
    required this.jourSemaine,
    required this.nom,
    required this.description,
    required this.plats,
    required this.estDisponible,
    required this.quantiteConsomme,
    required this.prix,
    this.restaurantNom,
    this.date,
    this.quantiteDisponible,
    this.imageUrl,
    this.noteMoyenne,
    this.nombreEvaluations,
  });

  int? get quantiteRestante =>
      quantiteDisponible == null ? null : (quantiteDisponible! - quantiteConsomme).clamp(0, quantiteDisponible!);

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as int,
      restaurantId: json['restaurant'] as int,
      restaurantNom: json['restaurant_nom'] as String?,
      jourSemaine: json['jour_semaine'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      nom: json['nom'] as String,
      description: json['description'] as String? ?? '',
      plats: json['plats'] as String? ?? '',
      estDisponible: json['est_disponible'] as bool? ?? true,
      quantiteDisponible: json['quantite_disponible'] as int?,
      quantiteConsomme: json['quantite_consomme'] as int? ?? 0,
      prix: json['prix'].toString(),
      imageUrl: json['image'] as String?,
      noteMoyenne: (json['note_moyenne'] as num?)?.toDouble(),
      nombreEvaluations: json['nombre_evaluations'] as int?,
    );
  }
}

/// Ligne de l'historique des consommations d'un restaurant — résultat de
/// GET /api/restaurants/consommations/ (accessible au gestionnaire même
/// si son restaurant n'est pas programmé aujourd'hui).
class ConsommationHistorique {
  final int id;
  final String numeroTicket;
  final String client;
  final String matricule;
  final String agence;
  final String menu;
  final DateTime dateConsommation;

  const ConsommationHistorique({
    required this.id,
    required this.numeroTicket,
    required this.client,
    required this.matricule,
    required this.agence,
    required this.menu,
    required this.dateConsommation,
  });

  factory ConsommationHistorique.fromJson(Map<String, dynamic> json) {
    return ConsommationHistorique(
      id: json['id'] as int,
      numeroTicket: json['numero_ticket'] as String? ?? '',
      client: json['client'] as String? ?? '',
      matricule: json['matricule'] as String? ?? '',
      agence: json['agence'] as String? ?? '',
      menu: json['menu'] as String? ?? '—',
      dateConsommation: DateTime.parse(json['date_consommation'] as String),
    );
  }
}

class StatsConsommations {
  final int totalFiltre;
  final int aujourdhui;
  final int cetteSemaine;
  final int ceMois;

  const StatsConsommations({
    required this.totalFiltre,
    required this.aujourdhui,
    required this.cetteSemaine,
    required this.ceMois,
  });

  factory StatsConsommations.fromJson(Map<String, dynamic> json) {
    return StatsConsommations(
      totalFiltre: json['total_filtre'] as int? ?? 0,
      aujourdhui: json['aujourd_hui'] as int? ?? 0,
      cetteSemaine: json['cette_semaine'] as int? ?? 0,
      ceMois: json['ce_mois'] as int? ?? 0,
    );
  }
}

class Reservation {
  final int id;
  final int menuId;
  final String? menuNom;
  final int restaurantId;
  final String? restaurantNom;
  final int? clientId;
  final String? clientNom;
  final String? clientMatricule;
  final DateTime dateReservation;
  final int quantite;
  final String statut; // EN_ATTENTE, CONFIRME, ANNULE, TERMINE

  const Reservation({
    required this.id,
    required this.menuId,
    required this.restaurantId,
    required this.dateReservation,
    required this.quantite,
    required this.statut,
    this.menuNom,
    this.restaurantNom,
    this.clientId,
    this.clientNom,
    this.clientMatricule,
  });

  bool get estAnnulable => statut == 'EN_ATTENTE' || statut == 'CONFIRME';

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      menuId: json['menu'] as int,
      menuNom: json['menu_nom'] as String?,
      restaurantId: json['restaurant'] as int,
      restaurantNom: json['restaurant_nom'] as String?,
      clientId: json['client'] as int?,
      clientNom: json['client_nom'] as String?,
      clientMatricule: json['client_matricule'] as String?,
      dateReservation: DateTime.parse(json['date_reservation'] as String),
      quantite: json['quantite'] as int? ?? 1,
      statut: json['statut'] as String,
    );
  }
}
