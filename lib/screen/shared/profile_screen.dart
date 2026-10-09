import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;

    if (utilisateur == null) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── En-tête : avatar + nom + rôle ────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary,
                    backgroundImage: utilisateur.photoProfilUrl != null
                        ? NetworkImage(utilisateur.photoProfilUrl!)
                        : null,
                    child: utilisateur.photoProfilUrl == null
                        ? Text(
                            utilisateur.prenom.isNotEmpty
                                ? utilisateur.prenom[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(utilisateur.nomComplet,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(_libelleRole(utilisateur.typeUtilisateur),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Carte : informations personnelles ─────────────────────
            _CarteInfo(
              children: [
                _LigneInfo(
                    icone: Icons.email_outlined,
                    label: 'Email',
                    valeur: utilisateur.email),
                if (utilisateur.telephone != null &&
                    utilisateur.telephone!.isNotEmpty)
                  _LigneInfo(
                      icone: Icons.phone_outlined,
                      label: 'Téléphone',
                      valeur: utilisateur.telephone!),
                if (utilisateur.matricule != null)
                  _LigneInfo(
                      icone: Icons.badge_outlined,
                      label: 'Matricule',
                      valeur: utilisateur.matricule!),
                if (utilisateur.agenceNom != null)
                  _LigneInfo(
                      icone: Icons.apartment_outlined,
                      label: 'Agence',
                      valeur: utilisateur.agenceNom!),
                if (utilisateur.restaurantGereNom != null)
                  _LigneInfo(
                      icone: Icons.storefront_outlined,
                      label: 'Restaurant géré',
                      valeur: utilisateur.restaurantGereNom!),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Section : sécurité ───────────────────────────────────
            const _SectionTitle('Sécurité'),

            const SizedBox(height: AppSpacing.sm),

            _TuileAction(
              icone: Icons.lock_reset_outlined,
              label: 'Changer mon mot de passe',
              sousTitre: 'Modifier votre mot de passe de connexion',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Bouton : déconnexion ─────────────────────────────────
            OutlinedButton.icon(
              onPressed: () => _confirmerDeconnexion(context),
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Se déconnecter',
                  style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }

  String _libelleRole(String type) {
    switch (type) {
      case 'CLIENT':
        return 'Employé';
      case 'GESTIONNAIRE_RESTAURANT':
        return 'Gestionnaire de restaurant';
      case 'CAISSIER':
        return 'Caissier';
      case 'ADMIN':
        return 'Administrateur';
      default:
        return type;
    }
  }

  void _confirmerDeconnexion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
            'Vous devrez vous reconnecter pour accéder à votre compte.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Se déconnecter',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Sous-widgets
// ══════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String texte;
  const _SectionTitle(this.texte);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        texte.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _CarteInfo extends StatelessWidget {
  final List<Widget> children;
  const _CarteInfo({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valeur;
  const _LigneInfo(
      {required this.icone, required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icone, size: 20, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                Text(valeur,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tuile cliquable réutilisable — cohérente avec le style des cartes
/// d'information, mais avec un chevron à droite pour indiquer l'action.
class _TuileAction extends StatelessWidget {
  final IconData icone;
  final String label;
  final String? sousTitre;
  final VoidCallback onTap;

  const _TuileAction({
    required this.icone,
    required this.label,
    required this.onTap,
    this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icone, size: 22, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (sousTitre != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(sousTitre!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}