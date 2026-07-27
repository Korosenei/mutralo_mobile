# MUTRALO RESTO — Application Mobile (Flutter)

Version Flutter de l'app, avec la même architecture que la version Expo/React Native : un seul projet qui bascule automatiquement entre deux parcours selon le rôle renvoyé par l'API (`type_utilisateur`).

- **Client** : tickets disponibles, génération/affichage du QR code (avec compte à rebours), historique, notifications, profil.
- **Gestionnaire de restaurant** : scanner caméra, écran de vérification/validation (avec choix du plat), consommations du jour.

## Installation

```bash
flutter pub get
flutter run
```

## Configuration obligatoire avant de tester

Ouvre `lib/api/api_client.dart` et remplace `kBaseUrl` :

```dart
const String kBaseUrl = "https://ton-domaine.example.com";
// En local avec un émulateur Android : http://10.0.2.2:8000
// Sur un téléphone physique : http://<IP locale de ta machine>:8000
```

Vérifie aussi que `django-cors-headers` autorise l'origine de l'app en dev.

## Permissions caméra (déjà configurées, à vérifier après `flutter create`)

**Android** (`android/app/src/main/AndroidManifest.xml`) — ajoute si absent :
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** (`ios/Runner/Info.plist`) — ajoute si absent :
```xml
<key>NSCameraUsageDescription</key>
<string>Nécessaire pour scanner les codes QR des tickets.</string>
```

> Ce projet ne contient que le dossier `lib/` (le code Dart). Génère les dossiers `android/` et `ios/` natifs avec `flutter create .` à la racine du projet avant le premier `flutter run`, puis ajoute les permissions ci-dessus.

## Endpoints utilisés (déjà existants côté backend)

| Fonction | Endpoint |
|---|---|
| Connexion | `POST /api/accounts/login/` |
| Refresh token | `POST /api/auth/token/refresh/` |
| Profil courant | `GET /api/accounts/me/` |
| Mes tickets disponibles | `GET /api/tickets/api/tickets/mes_tickets/` |
| Historique tickets | `GET /api/tickets/api/tickets/` |
| QR code actif | `GET /api/tickets/api/codes-qr/actif/` |
| Générer QR code | `POST /api/tickets/api/codes-qr/` |
| Vérifier un QR scanné | `GET /api/restaurants/api/scanner/verifier/?code=...` |
| Valider un QR scanné | `POST /api/restaurants/api/scanner/valider/` |
| Consommations du jour | `GET /api/restaurants/api/consommations/` |
| Notifications non lues | `GET /api/notifications/api/notifications/non_lues/` |

## ⚠️ Rappel — correctif backend à faire

`scanner_verifier` et `scanner_valider` doivent vérifier que le **restaurant du gestionnaire a bien un planning actif pour l'agence du client scanné**, pas seulement que le restaurant est actif dans l'absolu. L'app affichera correctement l'erreur renvoyée par l'API une fois ce contrôle ajouté (`result.valide == false` déclenche déjà l'écran d'erreur dans `verification_screen.dart`).

## Choix techniques

- **État global** : `provider` (`ChangeNotifier`) — plus simple que Riverpod/Bloc pour un MVP à deux rôles, migrable plus tard si l'app grossit.
- **HTTP** : `dio`, avec un intercepteur qui gère le refresh JWT automatiquement (`lib/api/api_client.dart`) — mets en file d'attente les requêtes concurrentes pendant le refresh pour éviter plusieurs appels `/token/refresh/` simultanés.
- **Stockage tokens** : `flutter_secure_storage` (Keychain iOS / Keystore Android, chiffré).
- **Scanner QR** : `mobile_scanner` (CameraX sous le capot côté Android, performant).
- **Génération QR** : `qr_flutter`.
- **Navigation** : `Navigator` standard + `IndexedStack` pour les onglets (pas de `go_router` pour rester simple sur un MVP à 2 rôles).

## Structure du projet

```
lib/
  api/            → api_client.dart (Dio + JWT refresh), auth_api, tickets_api, scanner_api
  providers/      → AuthProvider (session, rôle, routage)
  screens/
    root_screen.dart      → bascule Login / Client / Gestionnaire
    auth/                 → Login
    client/                → Tickets, QRCode, Historique, Notifications, Profil, ClientHome (onglets)
    gestionnaire/           → Scanner, Vérification, Consommations, GestionnaireHome (onglets)
  widgets/        → TicketCard, CountdownTimer
  theme/          → couleurs (identité MUTRALO / drapeau BF) + ThemeData
  models/         → classes miroir de tes serializers Django (fromJson)
```

## Prochaines étapes suggérées

1. `flutter create .` à la racine pour générer les projets natifs Android/iOS, puis ajouter les permissions caméra ci-dessus.
2. Corriger le contrôle de planning côté Django (voir ci-dessus).
3. Remplacer `kBaseUrl` et tester le flux complet en conditions réelles.
4. `flutter build apk` / `flutter build ipa` une fois le MVP validé.
