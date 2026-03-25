import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Core Palette — Warm Neutral + Coral ───
  static const Color ink        = Color(0xFF0D0D0D);   // near-black
  static const Color charcoal   = Color(0xFF1C1C1E);   // deep dark
  static const Color slate      = Color(0xFF3A3A3C);   // medium dark
  static const Color stone      = Color(0xFF8A8A8E);   // muted gray
  static const Color pebble     = Color(0xFFAEAEB2);   // light gray text
  static const Color silver     = Color(0xFFD1D1D6);   // border
  static const Color fog        = Color(0xFFF2F2F7);   // light bg
  static const Color snow       = Color(0xFFFFFFFF);   // white

  // ─── Accent — Warm Coral ───
  static const Color accent     = Color(0xFFFF6B47);   // coral-orange
  static const Color accentDim  = Color(0xFFFFF0EB);   // coral tint bg

  // ─── Semantic ───
  static const Color success    = Color(0xFF34C759);
  static const Color warning    = Color(0xFFFF9F0A);
  static const Color error      = Color(0xFFFF3B30);

  // ─── Functional aliases (backward-compat) ───
  static const Color black      = ink;
  static const Color darkGray   = charcoal;
  static const Color gray       = slate;
  static const Color midGray    = stone;
  static const Color lightGray  = silver;
  static const Color offWhite   = fog;
  static const Color white      = snow;
  static const Color accentLight = accentDim;

  // ─── Shadows ───
  static List<BoxShadow> get shadowXs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.07),
      blurRadius: 24,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 48,
      offset: const Offset(0, 16),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> accentShadow(double alpha) => [
    BoxShadow(
      color: accent.withValues(alpha: alpha),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  // ─── Theme ───
  static ThemeData get theme {
    final base = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: fog,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: charcoal,
        surface: snow,
        onSurface: ink,
      ),
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -2.0,
          height: 1.05,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ink,
          letterSpacing: -0.3,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ink,
          letterSpacing: -0.2,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: slate,
          height: 1.55,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: slate,
          height: 1.5,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: stone,
          height: 1.4,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ink,
          letterSpacing: 0,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: stone,
          letterSpacing: 0.2,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: pebble,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
