import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

/// Notifications automatiques : ce provider se rafraîchit tout seul en
/// arrière-plan (polling périodique), en plus des rafraîchissements
/// explicites déclenchés par l'UI (ouverture du header, pull-to-refresh).
/// Vivant pendant toute la durée de vie de l'app (enregistré une seule
/// fois à la racine dans main.dart), il n'a pas besoin d'être rattaché au
/// cycle de vie d'un widget précis pour fonctionner en continu au premier
/// plan.
class NotificationProvider extends ChangeNotifier {
  static const _intervalleAuto = Duration(seconds: 30);

  final NotificationService _service;
  Timer? _minuteur;

  NotificationProvider({required NotificationService service})
      : _service = service {
    charger();
    _minuteur = Timer.periodic(_intervalleAuto, (_) => charger());
  }

  List<AppNotification> _notifications = [];
  int _nonLues = 0;
  bool _chargement = false;

  List<AppNotification> get notifications => _notifications;
  int get nonLues => _nonLues;
  bool get chargement => _chargement;

  Future<void> charger() async {
    _chargement = true;
    // Pas de notifyListeners() ici : on évite de faire clignoter le badge
    // à chaque tick du minuteur automatique ; seul le résultat final
    // déclenche une mise à jour visible.
    final resultats = await Future.wait([
      _service.lister(),
      _service.nombreNonLues(),
    ]);
    _notifications = resultats[0] as List<AppNotification>;
    _nonLues = resultats[1] as int;
    _chargement = false;
    notifyListeners();
  }

  Future<void> marquerCommeLue(String id) async {
    await _service.marquerCommeLue(id);
    await charger();
  }

  Future<void> toutMarquerLu() async {
    await _service.marquerToutesCommeLues();
    await charger();
  }

  Future<void> supprimer(String id) async {
    await _service.supprimer(id);
    await charger();
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }
}
