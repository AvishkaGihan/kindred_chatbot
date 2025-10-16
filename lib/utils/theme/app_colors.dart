import 'package:flutter/material.dart';

/// App-wide color palette
/// Maintains consistent colors across light and dark themes
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondaryTeal = Color(0xFF03DAC6);
  static const Color secondaryTealDark = Color(0xFF018786);
  static const Color secondaryTealLight = Color(0xFF4DB6AC);

  // Accent Colors
  static const Color accentAmber = Color(0xFFFFC107);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentPink = Color(0xFFE91E63);

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceVariantLight = Color(0xFFEEEEEE);
  static const Color onBackgroundLight = Color(0xFF212121);
  static const Color onSurfaceLight = Color(0xFF424242);

  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color onSurfaceDark = Color(0xFFBDBDBD);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color error = Color(0xFFF44336);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF1976D2);

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);
  static const Color textHintLight = Color(0xFF9E9E9E);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textDisabledDark = Color(0xFF616161);
  static const Color textHintDark = Color(0xFF757575);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  static const Color dividerLight = Color(0xFFBDBDBD);
  static const Color dividerDark = Color(0xFF616161);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x4D000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF03DAC6),
    Color(0xFF018786),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFFC107),
    Color(0xFFFF9800),
  ];

  static const List<Color> premiumGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
  ];

  // Message Bubble Colors
  static const Color userMessageLight = primaryBlue;
  static const Color userMessageDark = primaryBlueLight;
  static const Color aiMessageLight = Color(0xFFEEEEEE);
  static const Color aiMessageDark = Color(0xFF2C2C2C);

  // Overlay Colors
  static const Color overlayLight = Color(0x66000000);
  static const Color overlayDark = Color(0x99000000);

  // Shimmer Colors
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF424242);
}
