import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF243B53);
  static const Color primaryLight = Color(0xFF334E68);
  static const Color accent = Color(0xFF45C4B0);

  // Backgrounds
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF0F3F6);

  // Text
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders
  static const Color border = Color(0xFFE2E8F0);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Chat
  static const Color userMessage = Color(0xFFE8F4F2);
  static const Color assistantMessage = Color(0xFFFFFFFF);
}