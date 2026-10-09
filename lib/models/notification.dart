enum TypeNotification {
  compte,
  achat,
  consommation,
  programmation,
  menu,
  reservation,
  caisse,
  systeme,
  rappel;

  static TypeNotification depuisCode(String? code) {
    switch (code) {
      case 'COMPTE':
        return TypeNotification.compte;
      case 'ACHAT':
        return TypeNotification.achat;
      case 'CONSOMMATION':
        return TypeNotification.consommation;
      case 'PROGRAMMATION':
        return TypeNotification.programmation;
      case 'MENU':
        return TypeNotification.menu;
      case 'RESERVATION':
        return TypeNotification.reservation;
      case 'CAISSE':
        return TypeNotification.caisse;
      case 'RAPPEL':
        return TypeNotification.rappel;
      default:
        return TypeNotification.systeme;
    }
  }
}

enum PrioriteNotification {
  basse,
  moyenne,
  haute,
  urgente;

  static PrioriteNotification depuisCode(String? code) {
    switch (code) {
      case 'BASSE':
        return PrioriteNotification.basse;
      case 'HAUTE':
        return PrioriteNotification.haute;
      case 'URGENTE':
        return PrioriteNotification.urgente;
      default:
        return PrioriteNotification.moyenne;
    }
  }
}

class AppNotification {
  final String id;
  final TypeNotification type;
  final PrioriteNotification priorite;
  final String titre;
  final String message;
  final String? lien;
  final String? texteLien;
  final DateTime date;
  final bool lue;

  const AppNotification({
    required this.id,
    required this.type,
    required this.priorite,
    required this.titre,
    required this.message,
    required this.date,
    this.lien,
    this.texteLien,
    this.lue = false,
  });

  AppNotification copyWith({bool? lue}) => AppNotification(
        id: id,
        type: type,
        priorite: priorite,
        titre: titre,
        message: message,
        lien: lien,
        texteLien: texteLien,
        date: date,
        lue: lue ?? this.lue,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      type: TypeNotification.depuisCode(json['type_notification'] as String?),
      priorite: PrioriteNotification.depuisCode(json['priorite'] as String?),
      titre: json['titre'] as String,
      message: json['message'] as String,
      lien: (json['lien'] as String?)?.isNotEmpty == true
          ? json['lien'] as String
          : null,
      texteLien: (json['texte_lien'] as String?)?.isNotEmpty == true
          ? json['texte_lien'] as String
          : null,
      date: DateTime.parse(json['cree_le'] as String),
      lue: json['est_lu'] as bool? ?? false,
    );
  }
}
