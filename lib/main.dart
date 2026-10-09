import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/gestionnaire_reservation_provider.dart';
import 'providers/scanner_provider.dart';
import 'providers/evaluation_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/historique_provider.dart';
import 'providers/gestionnaire_espace_provider.dart';
import 'providers/consommations_provider.dart';
import 'providers/agence_provider.dart';
import 'theme/colors.dart';
import 'screen/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configurerServiceLocator();
  runApp(const MutraloApp());
}

class MutraloApp extends StatelessWidget {
  const MutraloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Chaque Provider reçoit son Service depuis le locator — jamais
        // construit "en dur" dans le widget, ce qui permet de le remplacer
        // facilement en test (locator.registerLazySingleton avec un mock).
        ChangeNotifierProvider(create: (_) => AuthProvider(authService: locator())),
        ChangeNotifierProvider(create: (_) => TicketProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => RestaurantProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => ReservationProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => GestionnaireReservationProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => ScannerProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => EvaluationProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => NotificationProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => HistoriqueProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => GestionnaireEspaceProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => ConsommationsProvider(service: locator())),
        ChangeNotifierProvider(create: (_) => AgenceProvider(service: locator())),
      ],
      child: MaterialApp(
        title: 'MUTRALO RESTO',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const RootScreen(),
      ),
    );
  }
}
