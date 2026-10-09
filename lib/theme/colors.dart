import 'package:flutter/material.dart';

/// Palette harmonisée avec le logo MUTRALO (rouge, or, blanc).
/// `primary` reprend le rouge du badge du logo ; `accent` reprend l'or du
/// texte "MUTRALO". `success` conserve un vert pour les états positifs
/// (ticket disponible, compte actif...) sans concurrencer le rouge de marque.
class AppColors {
  static const primary = Color(0xFFC8102E);
  static const primaryDark = Color(0xFF8C0A20);
  static const primaryLight = Color(0xFFFBE9EA);

  static const accent = Color(0xFFFCD116);
  static const accentDark = Color(0xFFAD7B00);

  static const success = Color(0xFF0B7B3E);
  static const successLight = Color(0xFFE6F4EC);

  static const danger = Color(0xFFD84315);
  static const dangerLight = Color(0xFFFBE4DC);

  static const warning = Color(0xFFE8A700);
  static const warningLight = Color(0xFFFDF3DC);

  static const background = Color(0xFFFAF7F5);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF241614);
  static const textMuted = Color(0xFF7C6F6C);
  static const border = Color(0xFFEDE2DF);
  static const disabled = Color(0xFFC9BEBA);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.danger,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );
}
