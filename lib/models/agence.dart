class Agence {
  final int id;
  final String nom;
  final String code;
  final String ville;

  const Agence({required this.id, required this.nom, required this.code, required this.ville});

  factory Agence.fromJson(Map<String, dynamic> json) {
    return Agence(
      id: json['id'] as int,
      nom: json['nom'] as String,
      code: json['code'] as String,
      ville: json['ville'] as String? ?? '',
    );
  }
}
