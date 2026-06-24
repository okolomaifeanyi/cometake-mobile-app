import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand (legacy purple — kept for light theme)
  static const primary = figmaGreen; // green #22C55E — all screens using AppColors.primary now get green
  static const primaryDark = Color(0xFF4B44CC);
  static const primaryLight = Color(0xFF9D97FF);
  static const secondary = Color(0xFFFF6584);
  static const accent = Color(0xFFFFB020);

  // Surfaces — Light
  static const backgroundLight = Color(0xFFF8F9FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  static const dividerLight = Color(0xFFE5E7EB);

  // Surfaces — Dark (legacy)
  static const backgroundDark = Color(0xFF0D0D0D);
  static const surfaceDark = Color(0xFF1A1A1A);
  static const cardDark = Color(0xFF242424);
  static const dividerDark = Color(0xFF2D2D2D);

  // Status
  static const success = Color(0xFF22C55E);
  static const successSurface = Color(0xFFDCFCE7);
  static const warning = Color(0xFFF59E0B);
  static const warningSurface = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorSurface = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);
  static const infoSurface = Color(0xFFDBEAFE);

  // Text — Light
  static const textPrimaryLight = Color(0xFF111827);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const textDisabledLight = Color(0xFF9CA3AF);

  // Text — Dark
  static const textPrimaryDark = Color(0xFFF9FAFB);
  static const textSecondaryDark = Color(0xFF9CA3AF);
  static const textDisabledDark = Color(0xFF6B7280);

  // Naira brand colour
  static const nairaGreen = Color(0xFF008751);

  // ── Figma dark palette ──────────────────────────────────────────────────────
  static const figmaBg      = Color(0xFF0A0F1E); // main scaffold background
  static const figmaCard    = Color(0xFF1A2332); // card / list-tile surface
  static const figmaNavBg   = Color(0xFF0F1620); // bottom nav bar
  static const figmaTeal    = Color(0xFF0D3B3B); // hero/header gradient start
  static const figmaTealEnd = Color(0xFF0A2F2F); // hero/header gradient end
  static const figmaGreen   = Color(0xFF22C55E); // primary accent (green)
  static const figmaBorder  = Color(0xFF1F2D40); // subtle card border

  // Quick-access / service gradient pairs
  static const qGreenStart  = Color(0xFF22C55E);
  static const qGreenEnd    = Color(0xFF059669);
  static const qBlueStart   = Color(0xFF3B82F6);
  static const qBlueEnd     = Color(0xFF0891B2);
  static const qPurpleStart = Color(0xFF8B5CF6);
  static const qPurpleEnd   = Color(0xFFEC4899);
  static const qOrangeStart = Color(0xFFF97316);
  static const qOrangeEnd   = Color(0xFFD97706);
  static const qRedStart    = Color(0xFFEF4444);
  static const qRedEnd      = Color(0xFFDC2626);
  static const qYellowStart = Color(0xFFEAB308);
  static const qYellowEnd   = Color(0xFFD97706);
}

/// Short adaptive color getters that delegate to the active [ThemeData].
/// Dark mode returns Figma dark values; light mode returns clean white values.
extension CtxColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Backgrounds
  Color get bg   => Theme.of(this).scaffoldBackgroundColor;
  Color get card => Theme.of(this).colorScheme.surface;
  Color get border => Theme.of(this).colorScheme.outline;

  // Text on scaffold / card surfaces
  Color get t1 => Theme.of(this).colorScheme.onSurface;          // primary text
  Color get t2 => Theme.of(this).colorScheme.onSurfaceVariant;   // secondary text
  Color get t3 => isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151);  // dim text
  Color get t4 => isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);  // muted / icons
}
