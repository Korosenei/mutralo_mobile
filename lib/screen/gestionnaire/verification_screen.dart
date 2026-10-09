import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scanner_provider.dart';
import '../../theme/colors.dart';

class VerificationScreen extends StatefulWidget {
  final String code;
  const VerificationScreen({super.key, required this.code});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int? _menuChoisiId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScannerProvider>();
    final resultat = provider.resultatVerification;

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification du ticket')),
      body: SafeArea(
        child: resultat == null
            ? _erreur(context, provider)
            : !resultat.valide
                ? _erreur(context, provider)
                : _details(context, provider),
      ),
    );
  }

  Widget _erreur(BuildContext context, ScannerProvider provider) {
    // Le backend renvoie déjà un message précis par cas (voir
    // CodeQR.verifier_validite() et ScannerService.verifier() côté
    // Django) — on le catégorise ici pour donner une icône, un titre et
    // une couleur distincts selon le cas, plutôt qu'un écran d'erreur
    // générique uniforme. Le message brut du backend reste affiché en
    // sous-titre pour ne perdre aucune information.
    final messageBrut =
        provider.resultatVerification?.erreur ?? provider.erreur?.message;
    final info = _categoriserErreur(messageBrut);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                  color: info.couleur.withOpacity(0.12),
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(info.icone, color: info.couleur, size: 44),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              info.titre,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: info.couleur),
            ),
            if (messageBrut != null &&
                messageBrut.trim().isNotEmpty &&
                messageBrut != info.titre) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                messageBrut,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _details(BuildContext context, ScannerProvider provider) {
    final resultat = provider.resultatVerification!;
    final aUneReservation = resultat.reservation != null;
    final aDesPlats = resultat.platsDuJour.isNotEmpty;

    // Le choix explicite d'un plat est désormais TOUJOURS obligatoire dès
    // qu'il y a des plats disponibles — même si une réservation existe.
    // On pré-sélectionne le plat réservé pour ne pas alourdir le geste du
    // gestionnaire dans le cas courant, mais il reste libre de le changer
    // (ex : le plat réservé n'est en réalité plus celui servi).
    if (_menuChoisiId == null && aUneReservation) {
      _menuChoisiId = resultat.reservation!['menu_id'] as int?;
    }
    final choixRequis = aDesPlats;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryLight,
                backgroundImage:
                    (resultat.photoUrl != null && resultat.photoUrl!.isNotEmpty)
                        ? NetworkImage(resultat.photoUrl!)
                        : null,
                child: (resultat.photoUrl == null || resultat.photoUrl!.isEmpty)
                    ? const Icon(Icons.person,
                        color: AppColors.primary, size: 32)
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(resultat.client ?? '—',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              Text('${resultat.matricule ?? ''} · ${resultat.agence ?? ''}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Text(
                    'Ticket valide — ${resultat.ticketsRestants ?? 0} restant(s)',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (aUneReservation)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                const Icon(Icons.event_available, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Plat réservé : ${resultat.reservation!['menu_nom'] ?? '—'} — confirmez ou changez ci-dessous',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        if (aDesPlats) ...[
          const Text('Choisir le plat consommé',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: AppSpacing.sm),
          ...resultat.platsDuJour.map((plat) {
            final id = plat['id'] as int;
            final selectionne = _menuChoisiId == id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () => setState(() => _menuChoisiId = id),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: selectionne
                        ? AppColors.primaryLight
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color:
                            selectionne ? AppColors.primary : AppColors.border,
                        width: selectionne ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          selectionne
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selectionne
                              ? AppColors.primary
                              : AppColors.disabled),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                          child: Text(plat['nom'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (choixRequis && _menuChoisiId == null) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Sélectionnez le plat consommé pour pouvoir valider.',
              style: TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ],
        ] else
          const Text('Aucun plat disponible aujourd\'hui pour ce restaurant.',
              style: TextStyle(color: AppColors.textMuted)),
        if (provider.erreur != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(provider.erreur!.message,
              style: const TextStyle(color: AppColors.danger, fontSize: 13)),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                provider.enCours || (choixRequis && _menuChoisiId == null)
                    ? null
                    : () => _valider(context, provider),
            child: provider.enCours
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Valider la consommation'),
          ),
        ),
      ],
    );
  }

  Future<void> _valider(BuildContext context, ScannerProvider provider) async {
    final succes =
        await provider.validerCode(widget.code, menuId: _menuChoisiId);
    if (succes && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket validé avec succès.')));
      Navigator.of(context).pop();
    }
  }
}

/// Description visuelle (icône + couleur + titre court) associée à un
/// message d'erreur backend, pour rendre chaque cas immédiatement
/// reconnaissable au premier coup d'œil.
class _InfoEtatScan {
  final IconData icone;
  final Color couleur;
  final String titre;
  const _InfoEtatScan(
      {required this.icone, required this.couleur, required this.titre});
}

/// Fait correspondre le message brut renvoyé par le backend
/// (CodeQR.verifier_validite / ScannerService.verifier) à une
/// présentation explicite. La correspondance se fait par sous-chaîne
/// pour rester robuste si le backend reformule légèrement un message.
_InfoEtatScan _categoriserErreur(String? messageBrut) {
  final m = (messageBrut ?? '').toLowerCase();

  if (m.contains('déjà consommé') || m.contains('deja consomme')) {
    return const _InfoEtatScan(
      icone: Icons.no_meals_outlined,
      couleur: AppColors.warning,
      titre: 'Plat déjà consommé aujourd\'hui',
    );
  }
  if (m.contains('expiré') || m.contains('expire')) {
    return const _InfoEtatScan(
      icone: Icons.timer_off_outlined,
      couleur: AppColors.warning,
      titre: 'QR code expiré',
    );
  }
  if (m.contains('déjà utilisé') || m.contains('deja utilise')) {
    return const _InfoEtatScan(
      icone: Icons.block_outlined,
      couleur: AppColors.warning,
      titre: 'QR code déjà utilisé',
    );
  }
  if (m.contains('introuvable') || m.contains('invalide')) {
    return const _InfoEtatScan(
      icone: Icons.qr_code_2,
      couleur: AppColors.danger,
      titre: 'QR code invalide',
    );
  }
  if (m.contains('aucun ticket')) {
    return const _InfoEtatScan(
      icone: Icons.confirmation_number_outlined,
      couleur: AppColors.danger,
      titre: 'Aucun ticket disponible',
    );
  }
  if (m.contains('manquant')) {
    return const _InfoEtatScan(
      icone: Icons.error_outline,
      couleur: AppColors.danger,
      titre: 'Code manquant',
    );
  }
  // Cas générique — réseau, erreur serveur, ou message backend inconnu.
  return _InfoEtatScan(
    icone: Icons.error_outline,
    couleur: AppColors.danger,
    titre: (messageBrut != null && messageBrut.trim().isNotEmpty)
        ? messageBrut
        : "Ce QR code n'est pas valide.",
  );
}
