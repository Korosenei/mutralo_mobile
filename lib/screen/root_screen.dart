import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import 'auth/login_screen.dart';
import 'client/client_home.dart';
import 'gestionnaire/gestionnaire_home.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.loading:
        return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppColors.primary)));
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        final utilisateur = auth.utilisateur!;
        if (utilisateur.estClient) return const ClientHome();
        if (utilisateur.estGestionnaireRestaurant)
          return const GestionnaireHome();
        return _RoleNonSupporte(
            onLogout: () => context.read<AuthProvider>().logout());
    }
  }
}

// Les rôles ADMIN et CAISSIER restent gérés via le back-office web ; cet
// écran évite un plantage silencieux si l'un d'eux se connecte ici par erreur.
class _RoleNonSupporte extends StatelessWidget {
  final VoidCallback onLogout;
  const _RoleNonSupporte({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, color: AppColors.textMuted, size: 40),
                const SizedBox(height: AppSpacing.md),
                const Text('Accès non disponible',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  "Ce compte n'a pas accès à l'application mobile. Utilisez le portail web MUTRALO RESTO pour gérer votre compte.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                    onPressed: onLogout, child: const Text('Se déconnecter')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
