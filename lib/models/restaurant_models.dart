class RestaurantLite {
  final int id;
  final String nom;
  final String? ville;

  RestaurantLite({required this.id, required this.nom, this.ville});

  factory RestaurantLite.fromJson(Map<String, dynamic> json) {
    return RestaurantLite(
      id: json['id'],
      nom: json['nom'] ?? '',
      ville: json['ville'],
    );
  }
}

/// Parsing défensif : le champ `restaurant` peut être renvoyé par l'API
/// comme un simple ID ou comme un objet imbriqué selon le serializer DRF
/// utilisé. On gère les deux cas pour éviter un plantage si le format
/// change côté backend.
class MenuJour {
  final int id;
  final String nom;
  final String? description;
  final String prix;
  final bool estDisponible;
  final int? quantiteDisponible;
  final int restaurantId;
  final String restaurantNom;

  MenuJour({
    required this.id,
    required this.nom,
    this.description,
    required this.prix,
    required this.estDisponible,
    this.quantiteDisponible,
    required this.restaurantId,
    required this.restaurantNom,
  });

  factory MenuJour.fromJson(Map<String, dynamic> json) {
    final restaurantField = json['restaurant'];
    int restId = 0;
    String restNom = json['restaurant_nom'] ?? '';

    if (restaurantField is Map<String, dynamic>) {
      restId = restaurantField['id'] ?? 0;
      restNom = restaurantField['nom'] ?? restNom;
    } else if (restaurantField is int) {
      restId = restaurantField;
    }

    return MenuJour(
      id: json['id'],
      nom: json['nom'] ?? '',
      description: json['description'],
      prix: (json['prix'] ?? '0').toString(),
      estDisponible: json['est_disponible'] ?? true,
      quantiteDisponible: json['quantite_disponible'],
      restaurantId: restId,
      restaurantNom: restNom,
    );
  }
}

class Reservation {
  final int id;
  final String statut;
  final String dateReservation;
  final int menuId;
  final String menuNom;
  final int restaurantId;
  final String restaurantNom;
  final String? notes;

  Reservation({
    required this.id,
    required this.statut,
    required this.dateReservation,
    required this.menuId,
    required this.menuNom,
    required this.restaurantId,
    required this.restaurantNom,
    this.notes,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final menuField = json['menu'];
    int menuId = 0;
    String menuNom = json['menu_nom'] ?? '';
    if (menuField is Map<String, dynamic>) {
      menuId = menuField['id'] ?? 0;
      menuNom = menuField['nom'] ?? menuNom;
    } else if (menuField is int) {
      menuId = menuField;
    }

    final restaurantField = json['restaurant'];
    int restId = 0;
    String restNom = json['restaurant_nom'] ?? '';
    if (restaurantField is Map<String, dynamic>) {
      restId = restaurantField['id'] ?? 0;
      restNom = restaurantField['nom'] ?? restNom;
    } else if (restaurantField is int) {
      restId = restaurantField;
    }

    return Reservation(
      id: json['id'],
      statut: json['statut'] ?? 'EN_ATTENTE',
      dateReservation: json['date_reservation'] ?? '',
      menuId: menuId,
      menuNom: menuNom,
      restaurantId: restId,
      restaurantNom: restNom,
      notes: json['notes'],
    );
  }

  static const statutLabels = {
    'EN_ATTENTE': 'En attente',
    'CONFIRME': 'Confirmée',
    'ANNULE': 'Annulée',
    'TERMINE': 'Terminée',
  };

  String get statutLabel => statutLabels[statut] ?? statut;
}

/// Détail d'une consommation (issu de LogConsommation côté backend) :
/// permet de savoir, pour un ticket consommé, dans quelle agence, quel
/// restaurant et pour quel plat il a été utilisé.
class LogConsommation {
  final int id;
  final int? ticketId;
  final int? restaurantId;
  final String restaurantNom;
  final String agenceNom;
  final String? menuNom;
  final String dateConsommation;
  final String? notes;

  LogConsommation({
    required this.id,
    this.ticketId,
    this.restaurantId,
    required this.restaurantNom,
    required this.agenceNom,
    this.menuNom,
    required this.dateConsommation,
    this.notes,
  });

  factory LogConsommation.fromJson(Map<String, dynamic> json) {
    final ticketField = json['ticket'];
    int? ticketId;
    if (ticketField is int) {
      ticketId = ticketField;
    } else if (ticketField is Map<String, dynamic>) {
      ticketId = ticketField['id'];
    }

    final restaurantField = json['restaurant'];
    int? restId;
    String restNom = json['restaurant_nom'] ?? '';
    if (restaurantField is Map<String, dynamic>) {
      restId = restaurantField['id'];
      restNom = restaurantField['nom'] ?? restNom;
    } else if (restaurantField is int) {
      restId = restaurantField;
    } else if (restaurantField is String) {
      restNom = restaurantField;
    }

    final agenceField = json['agence'];
    String agenceNom = json['agence_nom'] ?? '';
    if (agenceField is Map<String, dynamic>) {
      agenceNom = agenceField['nom'] ?? agenceNom;
    } else if (agenceField is String) {
      agenceNom = agenceField;
    }

    final menuField = json['menu_consomme'];
    String? menuNom = json['menu_nom'];
    if (menuField is Map<String, dynamic>) {
      menuNom = menuField['nom'] ?? menuNom;
    } else if (menuField is String) {
      menuNom = menuField;
    }

    return LogConsommation(
      id: json['id'],
      ticketId: ticketId,
      restaurantId: restId,
      restaurantNom: restNom,
      agenceNom: agenceNom,
      menuNom: menuNom,
      dateConsommation: json['date_consommation'] ?? '',
      notes: json['notes'],
    );
  }
}
