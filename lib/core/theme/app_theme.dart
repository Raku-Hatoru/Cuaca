import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Konfigurasi tema gelap bertema biru tua (Nocturne Celestial Weather).
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        error: AppColors.errorAlert,
        outline: AppColors.borderGlass,
      ),
      dividerColor: AppColors.divider,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        modalBackgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    final manropeTextTheme = _buildTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      textTheme: manropeTextTheme,
      primaryTextTheme: manropeTextTheme,
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    const fallback = TextTheme(
      displayLarge: TextStyle(
        fontSize: 76,
        fontWeight: FontWeight.w300,
        letterSpacing: -2.5,
        height: 1.05,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textSecondary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: AppColors.textMuted,
      ),
    );

    try {
      return GoogleFonts.manropeTextTheme(base).copyWith(
        displayLarge: GoogleFonts.manrope(textStyle: fallback.displayLarge),
        headlineLarge: GoogleFonts.manrope(textStyle: fallback.headlineLarge),
        headlineMedium: GoogleFonts.manrope(textStyle: fallback.headlineMedium),
        titleMedium: GoogleFonts.manrope(textStyle: fallback.titleMedium),
        bodyLarge: GoogleFonts.manrope(textStyle: fallback.bodyLarge),
        bodyMedium: GoogleFonts.manrope(textStyle: fallback.bodyMedium),
        bodySmall: GoogleFonts.manrope(textStyle: fallback.bodySmall),
        labelMedium: GoogleFonts.manrope(textStyle: fallback.labelMedium),
        labelSmall: GoogleFonts.manrope(textStyle: fallback.labelSmall),
      );
    } catch (_) {
      return fallback;
    }
  }
}
