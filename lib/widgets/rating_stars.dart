import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Affichage en lecture seule d'une note (ex: moyenne d'un menu).
class EtoilesAffichage extends StatelessWidget {
  final double note; // 0 à 5, décimales acceptées (demi-étoiles arrondies visuellement)
  final double taille;

  const EtoilesAffichage({super.key, required this.note, this.taille = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final seuil = i + 1;
        IconData icone;
        if (note >= seuil) {
          icone = Icons.star_rounded;
        } else if (note >= seuil - 0.5) {
          icone = Icons.star_half_rounded;
        } else {
          icone = Icons.star_border_rounded;
        }
        return Icon(icone, size: taille, color: AppColors.warning);
      }),
    );
  }
}

/// Saisie interactive d'une note de 1 à 5 (tap sur une étoile).
class EtoilesSaisie extends StatelessWidget {
  final int note; // 0 (aucune sélection) à 5
  final ValueChanged<int> onChanged;
  final double taille;

  const EtoilesSaisie({super.key, required this.note, required this.onChanged, this.taille = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final valeur = i + 1;
        final rempli = valeur <= note;
        return IconButton(
          onPressed: () => onChanged(valeur),
          icon: Icon(
            rempli ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.warning,
            size: taille,
          ),
          splashRadius: taille,
        );
      }),
    );
  }
}
