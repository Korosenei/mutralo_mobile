import 'package:flutter/foundation.dart';
import '../core/utils/result.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService _service;
  TicketProvider({required TicketService service}) : _service = service;

  List<Ticket> _disponibles = [];
  List<Ticket> _historique = [];
  CodeQR? _codeQR;
  bool _chargement = false;
  bool _generationEnCours = false;
  Failure? _erreur;

  List<Ticket> get disponibles => _disponibles;
  List<Ticket> get historique => _historique;
  CodeQR? get codeQR => _codeQR;
  bool get chargement => _chargement;
  bool get generationEnCours => _generationEnCours;
  Failure? get erreur => _erreur;

  Future<void> charger() async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    final resultats = await Future.wait([
      _service.ticketsDisponibles(),
      _service.historiqueComplet(),
      _service.codeQRActif(),
    ]);

    (resultats[0] as Result<List<Ticket>>).when(
      success: (t) => _disponibles = t,
      failure: (f) => _erreur = f,
    );
    (resultats[1] as Result<List<Ticket>>).when(
      success: (t) => _historique = t,
      failure: (f) => _erreur ??= f,
    );
    (resultats[2] as Result<CodeQR?>).when(
      success: (qr) => _codeQR = qr,
      failure: (f) => _erreur ??= f,
    );

    _chargement = false;
    notifyListeners();
  }

  Future<bool> genererCodeQR() async {
    _generationEnCours = true;
    _erreur = null;
    notifyListeners();

    final result = await _service.genererCodeQR();
    bool succes = false;
    result.when(
      success: (qr) {
        _codeQR = qr;
        succes = true;
      },
      failure: (f) => _erreur = f,
    );

    _generationEnCours = false;
    notifyListeners();
    return succes;
  }
}
