import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand colors: shared between both themes.
  static const Color cyan = Color(0xFF00CDBA);
  static const Color electricBlue = Color(0xFF508BFF);
  static const Color violet = Color(0xFF9B8AFF);

  // Dark mode.
  static const Color darkBackground = Color(0xFF070B14);
  static const Color darkSurface = Color(0xFF0D1422);
  static const Color darkSurfaceLight = Color(0xFF121D30);
  static const Color darkText = Color(0xFFF1F6FF);
  static const Color darkMuted = Color(0xFF8391A8);
  static const Color darkBorder = Color(0xFF1C2A40);

  // Light mode.
  static const Color lightBackground = Color(0xFFF4F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFEAF1FA);
  static const Color lightText = Color(0xFF10233F);
  static const Color lightMuted = Color(0xFF697B95);
  static const Color lightBorder = Color(0xFFDCE5F0);
}