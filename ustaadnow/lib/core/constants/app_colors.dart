import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Brand Gradient
  static const Color primaryDark = Color(0xFF0A6F49);
  static const Color primary = Color(0xFF0F9A66);
  static const Color primaryLight = Color(0xFF0FB877);

  // Accent
  static const Color accent = Color(0xFFFFB13B);
  static const Color accentLight = Color(0xFFFFCC7A);

  // Neutrals - Light Mode
  static const Color background = Color(0xFFF8FAF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F3);
  static const Color border = Color(0xFFE2EAE6);
  static const Color divider = Color(0xFFEEF2F0);

  // Neutrals - Dark Mode
  static const Color backgroundDark = Color(0xFF0D1512);
  static const Color surfaceDark = Color(0xFF182019);
  static const Color surfaceVariantDark = Color(0xFF1F2B22);
  static const Color borderDark = Color(0xFF2A3D2E);

  // Text
  static const Color textPrimary = Color(0xFF0D1F18);
  static const Color textSecondary = Color(0xFF4A6356);
  static const Color textHint = Color(0xFF8EA89B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFE8F5EF);
  static const Color textSecondaryDark = Color(0xFF7BAE97);

  // Chat Bubbles
  static const Color userBubble = Color(0xFF0F9A66);
  static const Color aiBubble = Color(0xFFFFFFFF);
  static const Color aiBubbleDark = Color(0xFF1F2B22);

  // Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Status Badge Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF16A34A);
  static const Color statusInProgress = Color(0xFF2563EB);
  static const Color statusCompleted = Color(0xFF0F9A66);
  static const Color statusCancelled = Color(0xFFDC2626);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F9A66), Color(0xFF0FB877)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB13B), Color(0xFFFFCC7A)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAF9), Color(0xFFEEF8F4)],
  );

  // Shadow
  static const Color shadowLight = Color(0x1A0F9A66);
  static const Color shadowCard = Color(0x0F000000);
}
