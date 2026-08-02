class Transaction {
  final int id;
  final String numeroTransaction;
  final String typeTransaction;
  final int client;
  final String clientNom;
  final int? caissier;
  final String? caissierNom;
  final int? agence;
  final String? agenceNom;
  final int nombreTickets;
  final String? premierTicket;
  final String? dernierTicket;
  final String valideDe;
  final String valideJusquA;
  final String prixUnitaire;
  final String subventionParTicket;
  final String montantTotal;
  final String subventionTotale;
  final String montantPaye;
  final String montantSubventionne;
  final String modePaiement;
  final String? referencePaiement;
  final String statut;
  final String? notes;
  final String dateTransaction;
  final String dateCreation;
  final String dateModification;

  Transaction({
    required this.id,
    required this.numeroTransaction,
    required this.typeTransaction,
    required this.client,
    required this.clientNom,
    this.caissier,
    this.caissierNom,
    this.agence,
    this.agenceNom,
    required this.nombreTickets,
    this.premierTicket,
    this.dernierTicket,
    required this.valideDe,
    required this.valideJusquA,
    required this.prixUnitaire,
    required this.subventionParTicket,
    required this.montantTotal,
    required this.subventionTotale,
    required this.montantPaye,
    required this.montantSubventionne,
    required this.modePaiement,
    this.referencePaiement,
    required this.statut,
    this.notes,
    required this.dateTransaction,
    required this.dateCreation,
    required this.dateModification,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      numeroTransaction: json['numero_transaction'] ?? '',
      typeTransaction: json['type_transaction'] ?? '',
      client: json['client'],
      clientNom: json['client_nom'] ?? '',
      caissier: json['caissier'],
      caissierNom: json['caissier_nom'],
      agence: json['agence'],
      agenceNom: json['agence_nom'],
      nombreTickets: json['nombre_tickets'] ?? 0,
      premierTicket: json['premier_ticket'],
      dernierTicket: json['dernier_ticket'],
      valideDe: json['valide_de'] ?? '',
      valideJusquA: json['valide_jusqu_a'] ?? '',
      prixUnitaire: json['prix_unitaire']?.toString() ?? '0',
      subventionParTicket: json['subvention_par_ticket']?.toString() ?? '0',
      montantTotal: json['montant_total']?.toString() ?? '0',
      subventionTotale: json['subvention_totale']?.toString() ?? '0',
      montantPaye: json['montant_paye']?.toString() ?? '0',
      montantSubventionne: json['montant_subventionne']?.toString() ?? '0',
      modePaiement: json['mode_paiement'] ?? '',
      referencePaiement: json['reference_paiement'],
      statut: json['statut'] ?? '',
      notes: json['notes'],
      dateTransaction: json['date_transaction'] ?? '',
      dateCreation: json['date_creation'] ?? '',
      dateModification: json['date_modification'] ?? '',
    );
  }

  static const statutLabels = {
    'TERMINEE': 'Terminée',
    'REMBOURSEE': 'Remboursée',
    'EN_ATTENTE': 'En attente',
    'ANNULEE': 'Annulée',
  };
  String get statutLabel => statutLabels[statut] ?? statut;

  static const typeLabels = {
    'ACHAT': 'Achat',
    'REMBOURSEMENT': 'Remboursement',
  };
  String get typeLabel => typeLabels[typeTransaction] ?? typeTransaction;

  static const modePaiementLabels = {
    'ESPECES': 'Espèces',
    'MOBILE_MONEY': 'Mobile Money',
    'VIREMENT': 'Virement',
    'CHEQUE': 'Chèque',
  };
  String get modePaiementLabel =>
      modePaiementLabels[modePaiement] ?? modePaiement;
}
