import 'package:flutter/material.dart';

/// The sunrise palette comes from the existing Django portfolio stylesheet.
abstract final class PortfolioColors {
  static const sunrise = Color(0xFFFEF2A0);
  static const midday = Color(0xFFF3CD97);
  static const sunset = Color(0xFFE98B50);
  static const dusk = Color(0xFFBC4F4F);
  static const ink = Color(0xFF2B1B14);
  static const inkSoft = Color(0xFF7A5C44);
  static const paper = Color(0xFFFFFCF5);
  static const paperAlt = Color(0xFFFFF6E4);
  static const night = Color(0xFF1B120B);
  static const nightCard = Color(0xFF2A1810);
  static const nightInk = Color(0xFFF7E7C4);
}

ThemeData buildPortfolioTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: PortfolioColors.dusk,
        brightness: brightness,
      ).copyWith(
        primary: dark ? PortfolioColors.sunrise : PortfolioColors.dusk,
        onPrimary: dark ? PortfolioColors.ink : Colors.white,
        secondary: PortfolioColors.sunset,
        onSecondary: PortfolioColors.ink,
        surface: dark ? PortfolioColors.night : PortfolioColors.paper,
        onSurface: dark ? PortfolioColors.nightInk : PortfolioColors.ink,
        surfaceContainerLow: dark ? PortfolioColors.nightCard : Colors.white,
        outlineVariant: dark
            ? const Color(0xFF5A4030)
            : const Color(0xFFE8DDD2),
      );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.primary,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: scheme.primary,
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),
      shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: PortfolioColors.ink,
      contentTextStyle: TextStyle(color: PortfolioColors.paper, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
