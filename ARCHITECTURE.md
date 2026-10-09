# MUTRALO RESTO — Application mobile (client + gestionnaire)

Application Flutter complète, architecture SOLID en couches :

```
UI (screen/, widgets/)
   ↓
Provider (état)  →  Service (règles métier)  →  Repository (interface)
                                                      ↓
                                              RepositoryImpl (HTTP/Dio)
                                                      ↓
                                                  ApiClient
```

## Couverture fonctionnelle

### Client
- Connexion + mot de passe oublié (`screen/auth`)
- Tableau de bord, tickets, QR code (`screen/client`)
- Menus du jour de son agence par défaut, bascule vers une autre agence
  (`menus_screen.dart`)
- Réservation d'un plat (`reservations_screen.dart`)
- Historique des consommations + notation du plat consommé, pas de note de
  service (`history_screen.dart`, `widgets/evaluation_sheet.dart`)
- Classement des plats / restaurants sur une période (`shared/classement_screen.dart`)
- Header commun (notifications + profil) — navbar réduite aux 5 onglets
  principaux (Tickets, QR, Accueil, Menus, Historique)

### Gestionnaire
- Scanner QR — **verrouillé si le restaurant n'est pas programmé
  aujourd'hui** (icône cadenas dans la navbar + écran dédié)
- Vérification puis validation d'un ticket, avec **sélection obligatoire
  du plat** avant validation quand aucune réservation n'existe déjà
- Consommations (historique + stats) — **toujours accessible**, programmé
  ou non
- Mes agences (desservies, planning actif ou non) + avis clients reçus —
  **toujours accessibles**
- Mes menus — CRUD **uniquement si programmé aujourd'hui** ; lecture seule
  sinon
- Réservations — confirmer / marquer terminé
- Même header/navbar réduite que le client (Consommations, Menus, Scanner,
  Réservations, Agences)

## Endpoints backend réellement utilisés

Alignés sur `restaurants/api_urls.py`, `accounts/api_urls.py`,
`transactions/api_urls.py` fournis :

- `POST /api/accounts/login/`, `/logout/`, `/me/`, `/me/change-password/`
- `GET /api/accounts/agencies/` (lecture ouverte — utilisé pour la bascule
  d'agence côté client)
- `GET/POST /api/tickets/tickets/`, `/codes-qr/`
- `GET /api/transactions/logs-consommation/` (historique client)
- `GET/POST /api/restaurants/restaurants/`, `/plannings/`, `/menus/`,
  `/reservations/`, `/evaluations/`
- `POST /api/restaurants/evaluations/evaluer/`
- `GET /api/restaurants/evaluations/classement_menus/`,
  `/classement_restaurants/`
- `GET/POST /api/restaurants/scanner/verifier/`, `/valider/`,
  `/consommations/`

## ⚠️ Point de vigilance backend (permissions)

D'après les classes de permissions importées (noms visibles, contenu non
fourni), `RestaurantViewSet` et `PlanningRestaurantViewSet` utilisent
`EstAdminOuCaissier` **pour toutes les actions**, y compris la lecture. En
l'état, un client ou un gestionnaire ne pourrait pas lire ces endpoints.

**Action requise côté backend** : autoriser la lecture (`GET`) à tout
utilisateur authentifié sur `RestaurantViewSet` et
`PlanningRestaurantViewSet` (par exemple une permission de type
`IsAuthenticated` pour les méthodes sûres, `EstAdminOuCaissier` réservé à
l'écriture) — sans quoi `menus_screen.dart` (client) et
`GestionnaireEspaceProvider` (gestionnaire) ne pourront pas résoudre le
restaurant programmé ni les plannings.

Aucun autre TODO backend ne subsiste : mot de passe oublié, évaluations,
classements et agences sont tous branchés sur des endpoints réels.

## Mot de passe oublié

`POST /api/accounts/password/oubli/` est **appelé par le mobile** mais
n'apparaît pas dans les urls fournies — à ajouter côté backend (view
simple : reçoit un email, déclenche l'envoi du lien de réinitialisation).

## Notifications

Toujours en mock local (`NotificationRepositoryLocal`) — aucun endpoint
backend fourni pour `apps.notifs`. Le jour où il existe, remplacer
l'enregistrement dans `service_locator.dart` uniquement.

## Comment lancer

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://votre-domaine/api
```
