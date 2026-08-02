import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  const NavItem({required this.icon, this.selectedIcon, required this.label});
}

/// Barre de navigation flottante en forme de pilule, avec un élément central
/// surélevé. Les icônes sont réparties en deux groupes (gauche/droite) de
/// largeur égale, ce qui garde le bouton central parfaitement aligné même
/// si les deux groupes n'ont pas le même nombre d'éléments.
class FloatingNavBar extends StatelessWidget {
  final List<NavItem> leftItems;
  final List<NavItem> rightItems;
  final NavItem centerItem;
  final int currentIndex; // index dans la liste combinée : left + [center] + right
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.leftItems,
    required this.rightItems,
    required this.centerItem,
    required this.currentIndex,
    required this.onTap,
  });

  int get centerIndex => leftItems.length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SizedBox(
          height: 82,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(leftItems.length, (i) {
                          return _NavIcon(
                            item: leftItems[i],
                            selected: currentIndex == i,
                            onTap: () => onTap(i),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 58), // espace réservé sous le bouton central
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(rightItems.length, (i) {
                          final index = centerIndex + 1 + i;
                          return _NavIcon(
                            item: rightItems[i],
                            selected: currentIndex == index,
                            onTap: () => onTap(index),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 32,
                child: GestureDetector(
                  onTap: () => onTap(centerIndex),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: AppColors.background, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      currentIndex == centerIndex
                          ? (centerItem.selectedIcon ?? centerItem.icon)
                          : centerItem.icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? (item.selectedIcon ?? item.icon) : item.icon,
              color: color,
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
