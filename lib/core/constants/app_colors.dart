import 'package:flutter/material.dart';

/// Palet warna Nocturne Celestial Weather sesuai DESIGN.md dan PRD.
class AppColors {
  AppColors._();

  // Gradien background utama
  static const Color backgroundTop = Color(0xFF071433);
  static const Color backgroundBottom = Color(0xFF0B1F5C);
  static const Color surface = Color(0xFF051231);

  // Kontainer permukaan
  static const Color surfaceContainerLowest = Color(0xFF010C2B);
  static const Color surfaceContainerLow = Color(0xFF0E1A39);
  static const Color surfaceContainer = Color(0xFF121E3D);
  static const Color surfaceContainerHigh = Color(0xFF1D2948);
  static const Color surfaceContainerHighest = Color(0xFF283454);

  // Efek glow dan aksen elektrik
  static const Color electricGlow = Color(0xFF1E4FD8);
  static const Color accentStart = Color(0xFF4C8DFF);
  static const Color accentEnd = Color(0xFF2B5BE0);

  // Warna aksen Material
  static const Color primary = Color(0xFFAEC6FF);
  static const Color onPrimary = Color(0xFF002E6A);
  static const Color primaryContainer = Color(0xFF4E8EFF);
  static const Color onPrimaryContainer = Color(0xFF00275D);
  static const Color secondary = Color(0xFFB7C4FF);
  static const Color secondaryContainer = Color(0xFF0443CE);
  static const Color onSecondaryContainer = Color(0xFFB6C3FF);

  // Teks
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA9B8DC);
  static const Color textMuted = Color(0xFF687B9E);

  // Permukaan kaca & garis
  static const Color surfaceGlass = Color(0x12FFFFFF);
  static const Color surfaceGlassActive = Color(0x24FFFFFF);
  static const Color borderGlass = Color(0x1AFFFFFF);
  static const Color ringOuter = Color(0x2EFFFFFF);
  static const Color divider = Color(0x1AFFFFFF);

  // Status
  static const Color warning = Color(0xFFFDB44B);
  static const Color errorAlert = Color(0xFFFF5A5F);
  static const Color success = Color(0xFF4ADE80);
  static const Color navBarFill = Color(0xE0091B4A);
}
