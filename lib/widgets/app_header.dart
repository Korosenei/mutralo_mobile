import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/colors.dart';
import '../screen/shared/notifications_screen.dart';
import '../screen/shared/profile_screen.dart';

/// Header réutilisable affiché en tête des écrans principaux (client et
/// gestionnaire). Centralise l'accès aux notifications et au profil pour
/// que la bottom navbar reste réservée aux onglets de navigation
/// principaux (cf. brief : "le navbar doit être réservé aux onglets
/// principaux").
///
/// Affiche automatiquement une flèche retour quand l'écran a été empilé
/// via Navigator.push (ex: Consommations, Agences, Réservations,
/// Notifications, Profil...) — ces écrans n'ont pas de navbar visible et
/// avaient donc aucun moyen de revenir en arrière. Passe [leading] pour
/// forcer un comportement custom, ou laisse vide pour l'auto-détection.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget titre;
  final List<Widget>? actionsSupplementaires;
  final Widget? leading;

  const AppHeader({
    super.key,
    required this.titre,
    this.actionsSupplementaires,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final peutRevenir = Navigator.of(context).canPop();
    final Widget? boutonRetour = leading ??
        (peutRevenir
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Retour',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
        child: Row(
          children: [
            if (boutonRetour != null) ...[
              boutonRetour,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(child: titre),
            ...?actionsSupplementaires,
            const _ClocheNotifications(),
            const SizedBox(width: AppSpacing.sm),
            const _AvatarProfil(),
          ],
        ),
      ),
    );
  }
}

class _ClocheNotifications extends StatefulWidget {
  const _ClocheNotifications();

  @override
  State<_ClocheNotifications> createState() => _ClocheNotificationsState();
}

class _ClocheNotificationsState extends State<_ClocheNotifications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nonLues = context.watch<NotificationProvider>().nonLues;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_outlined,
                color: AppColors.text, size: 21),
            if (nonLues > 0)
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                      color: AppColors.danger, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvatarProfil extends StatelessWidget {
  const _AvatarProfil();

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final initiales = utilisateur == null
        ? '?'
        : '${utilisateur.prenom.isNotEmpty ? utilisateur.prenom[0] : ''}${utilisateur.nom.isNotEmpty ? utilisateur.nom[0] : ''}'
            .toUpperCase();

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: CircleAvatar(
        radius: 21,
        backgroundColor: AppColors.primary,
        backgroundImage: (utilisateur?.photoProfilUrl != null)
            ? NetworkImage(utilisateur!.photoProfilUrl!)
            : null,
        child: utilisateur?.photoProfilUrl == null
            ? Text(initiales,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14))
            : null,
      ),
    );
  }
}
