import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App-wide text styles
/// Based on Material Design 3 typography scale
class AppTextStyles {
  // Display Styles - Largest text, for hero sections
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );

  // Headline Styles - For headings
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Title Styles - For smaller headings and titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Body Styles - For body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label Styles - For buttons and labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // Custom App Styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const TextStyle messageText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.47,
  );

  static const TextStyle timestamp = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle chipText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.14,
  );

  static const TextStyle navigationLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // Helper methods for colored text
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  // Light theme text styles
  static TextStyle get displayLargeLight =>
      withColor(displayLarge, AppColors.textPrimaryLight);
  static TextStyle get displayMediumLight =>
      withColor(displayMedium, AppColors.textPrimaryLight);
  static TextStyle get displaySmallLight =>
      withColor(displaySmall, AppColors.textPrimaryLight);

  static TextStyle get headlineLargeLight =>
      withColor(headlineLarge, AppColors.textPrimaryLight);
  static TextStyle get headlineMediumLight =>
      withColor(headlineMedium, AppColors.textPrimaryLight);
  static TextStyle get headlineSmallLight =>
      withColor(headlineSmall, AppColors.textPrimaryLight);

  static TextStyle get titleLargeLight =>
      withColor(titleLarge, AppColors.textPrimaryLight);
  static TextStyle get titleMediumLight =>
      withColor(titleMedium, AppColors.textPrimaryLight);
  static TextStyle get titleSmallLight =>
      withColor(titleSmall, AppColors.textPrimaryLight);

  static TextStyle get bodyLargeLight =>
      withColor(bodyLarge, AppColors.textPrimaryLight);
  static TextStyle get bodyMediumLight =>
      withColor(bodyMedium, AppColors.textPrimaryLight);
  static TextStyle get bodySmallLight =>
      withColor(bodySmall, AppColors.textSecondaryLight);

  // Dark theme text styles
  static TextStyle get displayLargeDark =>
      withColor(displayLarge, AppColors.textPrimaryDark);
  static TextStyle get displayMediumDark =>
      withColor(displayMedium, AppColors.textPrimaryDark);
  static TextStyle get displaySmallDark =>
      withColor(displaySmall, AppColors.textPrimaryDark);

  static TextStyle get headlineLargeDark =>
      withColor(headlineLarge, AppColors.textPrimaryDark);
  static TextStyle get headlineMediumDark =>
      withColor(headlineMedium, AppColors.textPrimaryDark);
  static TextStyle get headlineSmallDark =>
      withColor(headlineSmall, AppColors.textPrimaryDark);

  static TextStyle get titleLargeDark =>
      withColor(titleLarge, AppColors.textPrimaryDark);
  static TextStyle get titleMediumDark =>
      withColor(titleMedium, AppColors.textPrimaryDark);
  static TextStyle get titleSmallDark =>
      withColor(titleSmall, AppColors.textPrimaryDark);

  static TextStyle get bodyLargeDark =>
      withColor(bodyLarge, AppColors.textPrimaryDark);
  static TextStyle get bodyMediumDark =>
      withColor(bodyMedium, AppColors.textPrimaryDark);
  static TextStyle get bodySmallDark =>
      withColor(bodySmall, AppColors.textSecondaryDark);
}
