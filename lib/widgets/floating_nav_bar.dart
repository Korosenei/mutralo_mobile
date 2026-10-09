import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  const NavItem({required this.icon, this.selectedIcon, required this.label});
}

/// Navbar flottante réservée aux onglets de navigation PRINCIPAUX.
/// Notifications et Profil ne figurent plus ici (voir AppHeader) —
/// conformément au brief, la navbar ne doit contenir que les sections
/// structurantes de l'app (Tickets, QR, Accueil, Menus, Historique côté
/// client ; Scanner, Consommations, Agences côté gestionnaire).
class FloatingNavBar extends StatelessWidget {
  final List<NavItem> leftItems;
  final NavItem centerItem;
  final List<NavItem> rightItems;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool centerVerrouille;

  const FloatingNavBar({
    super.key,
    required this.leftItems,
    required this.centerItem,
    required this.rightItems,
    required this.currentIndex,
    required this.onTap,
    this.centerVerrouille = false,
  });

  int get _indexCentre => leftItems.length;

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...leftItems
                  .asMap()
                  .entries
                  .map((e) => Expanded(child: _item(e.value, e.key))),
              _itemCentral(),
              ...rightItems.asMap().entries.map((e) =>
                  Expanded(child: _item(e.value, _indexCentre + 1 + e.key))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(NavItem item, int index) {
    final selectionne = index == currentIndex;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 4, vertical: 6), // ← réduit de 10 à 4
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectionne ? (item.selectedIcon ?? item.icon) : item.icon,
              color: selectionne ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis, // ← empêche le débordement du texte
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selectionne ? FontWeight.w700 : FontWeight.w500,
                color: selectionne ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCentral() {
    final selectionne = _indexCentre == currentIndex;
    return InkWell(
      onTap: () => onTap(_indexCentre),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: centerVerrouille
              ? AppColors.disabled
              : (selectionne
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.85)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          centerVerrouille
              ? Icons.lock_outline
              : (selectionne
                  ? (centerItem.selectedIcon ?? centerItem.icon)
                  : centerItem.icon),
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
