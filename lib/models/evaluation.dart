/// Évaluation d'un plat consommé par un client — miroir de
/// restaurants.models.EvaluationPlat (backend livré).
///
/// Contrainte backend : OneToOne sur `consommation` (transactions.
/// LogConsommation) → un seul avis possible par consommation réelle.
/// Pas de note de service : uniquement le plat (menu.client/restaurant sont
/// des `@property` calculées côté Django à partir de la consommation).
class Evaluation {
  final int id;
  final int consommationId;
  final int? menuId;
  final String? menuNom;
  final int? restaurantId;
  final String? restaurantNom;
  final int? clientId;
  final String? clientNom;
  final int note; // 1 à 5
  final String commentaire;
  final DateTime dateCreation;

  const Evaluation({
    required this.id,
    required this.consommationId,
    required this.note,
    required this.commentaire,
    required this.dateCreation,
    this.menuId,
    this.menuNom,
    this.restaurantId,
    this.restaurantNom,
    this.clientId,
    this.clientNom,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'] as int,
      consommationId: json['consommation'] as int,
      menuId: json['menu'] as int?,
      menuNom: json['menu_nom'] as String?,
      restaurantId: json['restaurant'] as int?,
      restaurantNom: json['restaurant_nom'] as String?,
      clientId: json['client'] as int?,
      clientNom: json['client_nom'] as String?,
      note: json['note'] as int,
      commentaire: json['commentaire'] as String? ?? '',
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }
}

/// Agrégat de classement — utilisé pour les écrans "classement des menus"
/// et "classement des restaurants" (moyenne + nombre d'avis sur une période).
class ClassementEntree {
  final int id;
  final String nom;
  final double noteMoyenne;
  final int nombreEvaluations;
  final String? imageUrl;

  const ClassementEntree({
    required this.id,
    required this.nom,
    required this.noteMoyenne,
    required this.nombreEvaluations,
    this.imageUrl,
  });

  factory ClassementEntree.fromJson(Map<String, dynamic> json) {
    return ClassementEntree(
      id: json['id'] as int,
      nom: json['nom'] as String,
      noteMoyenne: (json['note_moyenne'] as num?)?.toDouble() ?? 0,
      nombreEvaluations: json['nombre_evaluations'] as int? ?? 0,
      imageUrl: json['image'] as String?,
    );
  }
}
