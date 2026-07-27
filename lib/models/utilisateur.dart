class Utilisateur {
  final int id;
  final String email;
  final String prenom;
  final String nom;
  final String? matricule;
  final String typeUtilisateur;
  final int? agence;
  final String? agenceNom;
  final int? restaurantGere;
  final String? photoProfil;

  Utilisateur({
    required this.id,
    required this.email,
    required this.prenom,
    required this.nom,
    this.matricule,
    required this.typeUtilisateur,
    this.agence,
    this.agenceNom,
    this.restaurantGere,
    this.photoProfil,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      email: json['email'],
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      matricule: json['matricule'],
      typeUtilisateur: json['type_utilisateur'],
      agence: json['agence'],
      agenceNom: json['agence_nom'],
      restaurantGere: json['restaurant_gere'],
      photoProfil: json['photo_profil'],
    );
  }

  String get nomComplet => '$prenom $nom'.trim();

  static const roleLabels = {
    'CLIENT': 'Employé',
    'CAISSIER': 'Caissier',
    'GESTIONNAIRE_RESTAURANT': 'Gestionnaire de restaurant',
    'ADMIN': 'Administrateur',
  };

  String get roleLabel => roleLabels[typeUtilisateur] ?? typeUtilisateur;
}
