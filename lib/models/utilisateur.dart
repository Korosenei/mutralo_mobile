class Utilisateur {
  final int id;
  final String email;
  final String prenom;
  final String nom;
  final String typeUtilisateur; // CLIENT, CAISSIER, GESTIONNAIRE_RESTAURANT, ADMIN
  final String? telephone;
  final String? matricule;
  final String? photoProfilUrl;
  final int? agenceId;
  final String? agenceNom;
  final int? restaurantGereId;
  final String? restaurantGereNom;

  const Utilisateur({
    required this.id,
    required this.email,
    required this.prenom,
    required this.nom,
    required this.typeUtilisateur,
    this.telephone,
    this.matricule,
    this.photoProfilUrl,
    this.agenceId,
    this.agenceNom,
    this.restaurantGereId,
    this.restaurantGereNom,
  });

  String get nomComplet => '$prenom $nom'.trim();

  bool get estClient => typeUtilisateur == 'CLIENT';
  bool get estCaissier => typeUtilisateur == 'CAISSIER';
  bool get estGestionnaireRestaurant => typeUtilisateur == 'GESTIONNAIRE_RESTAURANT';
  bool get estAdmin => typeUtilisateur == 'ADMIN';

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      email: json['email'] as String,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      typeUtilisateur: json['type_utilisateur'] as String? ?? 'CLIENT',
      telephone: json['telephone'] as String?,
      matricule: json['matricule'] as String?,
      photoProfilUrl: json['photo_profil'] as String?,
      agenceId: json['agence'] as int?,
      agenceNom: json['agence_nom'] as String?,
      restaurantGereId: json['restaurant_gere'] as int?,
      restaurantGereNom: json['restaurant_gere_nom'] as String?,
    );
  }

  Utilisateur copyWith({String? photoProfilUrl}) {
    return Utilisateur(
      id: id,
      email: email,
      prenom: prenom,
      nom: nom,
      typeUtilisateur: typeUtilisateur,
      telephone: telephone,
      matricule: matricule,
      photoProfilUrl: photoProfilUrl ?? this.photoProfilUrl,
      agenceId: agenceId,
      agenceNom: agenceNom,
      restaurantGereId: restaurantGereId,
      restaurantGereNom: restaurantGereNom,
    );
  }
}
