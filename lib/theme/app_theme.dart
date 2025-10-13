import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2563EB); // Blue 600
  static const Color primaryBlueVariant = Color(0xFF1D4ED8); // Blue 700
  static const Color secondaryAmber = Color(0xFFF59E0B); // Amber 500
  static const Color secondaryAmberVariant = Color(0xFFD97706); // Amber 600

  // Supporting Colors
  static const Color surfaceLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure white
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500

  // Dark Theme Colors
  static const Color primaryBlueDark = Color(0xFF3B82F6); // Blue 500
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Slate 800
  static const Color backgroundDark = Color(0xFF020617); // Slate 950

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF8FAFC);

  // Create Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: textOnPrimary,
        primaryContainer: Color(0xFFDBEAFE), // Blue 100
        onPrimaryContainer: Color(0xFF1E3A8A), // Blue 800
        secondary: secondaryAmber,
        onSecondary: textPrimary,
        secondaryContainer: Color(0xFFFEF3C7), // Amber 100
        onSecondaryContainer: Color(0xFF92400E), // Amber 800
        error: errorColor,
        onError: textOnPrimary,
        surface: surfaceLight,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariantLight,
        onSurfaceVariant: textSecondary,
        outline: Color(0xFFCBD5E1), // Slate 300
        outlineVariant: Color(0xFFE2E8F0), // Slate 200
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _buildAppBarTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      cardTheme: _buildCardTheme(Brightness.light),
      dialogTheme: _buildDialogTheme(Brightness.light),
    );
  }

  // Create Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlueDark,
        onPrimary: textPrimary,
        primaryContainer: Color(0xFF1E40AF), // Blue 700
        onPrimaryContainer: Color(0xFFDBEAFE), // Blue 100
        secondary: secondaryAmber,
        onSecondary: textPrimary,
        secondaryContainer: Color(0xFFD97706), // Amber 600
        onSecondaryContainer: Color(0xFFFEF3C7), // Amber 100
        error: errorColor,
        onError: textOnPrimary,
        surface: surfaceDark,
        onSurface: textOnDark,
        surfaceContainerHighest: surfaceVariantDark,
        onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
        outline: Color(0xFF475569), // Slate 600
        outlineVariant: Color(0xFF334155), // Slate 700
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      cardTheme: _buildCardTheme(Brightness.dark),
      dialogTheme: _buildDialogTheme(Brightness.dark),
    );
  }

  // Build Text Theme with Google Fonts
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? textPrimary
        : textOnDark;
    final Color secondaryTextColor = brightness == Brightness.light
        ? textSecondary
        : Color(0xFF94A3B8);

    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  // Build AppBar Theme
  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: brightness == Brightness.light
          ? backgroundLight
          : backgroundDark,
      foregroundColor: brightness == Brightness.light
          ? textPrimary
          : textOnDark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.light ? textPrimary : textOnDark,
      ),
      centerTitle: false,
    );
  }

  // Build Elevated Button Theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    Brightness brightness,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textOnPrimary,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // Build Outlined Button Theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    Brightness brightness,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brightness == Brightness.light
            ? primaryBlue
            : primaryBlueDark,
        side: BorderSide(
          color: brightness == Brightness.light ? primaryBlue : primaryBlueDark,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // Build Input Decoration Theme
  static InputDecorationTheme _buildInputDecorationTheme(
    Brightness brightness,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light
          ? surfaceVariantLight
          : surfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? Color(0xFFE2E8F0)
              : Color(0xFF334155),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? Color(0xFFE2E8F0)
              : Color(0xFF334155),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: brightness == Brightness.light ? primaryBlue : primaryBlueDark,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.inter(
        color: brightness == Brightness.light
            ? textSecondary
            : Color(0xFF94A3B8),
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      labelStyle: GoogleFonts.inter(
        color: brightness == Brightness.light
            ? textSecondary
            : Color(0xFF94A3B8),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Build Card Theme
  static CardThemeData _buildCardTheme(Brightness brightness) {
    return CardThemeData(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: brightness == Brightness.light ? backgroundLight : surfaceDark,
      surfaceTintColor: brightness == Brightness.light
          ? primaryBlue
          : primaryBlueDark,
    );
  }

  // Build Dialog Theme
  static DialogThemeData _buildDialogTheme(Brightness brightness) {
    return DialogThemeData(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: brightness == Brightness.light
          ? backgroundLight
          : surfaceDark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.light ? textPrimary : textOnDark,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: brightness == Brightness.light
            ? textSecondary
            : Color(0xFF94A3B8),
        height: 1.5,
      ),
    );
  }

  // Utility methods for colors
  static Color getSuccessColor() => successColor;
  static Color getWarningColor() => warningColor;
  static Color getErrorColor() => errorColor;

  // Message bubble colors
  static Color getUserBubbleColor(Brightness brightness) {
    return brightness == Brightness.light ? primaryBlue : primaryBlueDark;
  }

  static Color getAiBubbleColor(Brightness brightness) {
    return brightness == Brightness.light
        ? surfaceVariantLight
        : surfaceVariantDark;
  }

  static Color getTextOnUserBubble() => textOnPrimary;

  static Color getTextOnAiBubble(Brightness brightness) {
    return brightness == Brightness.light ? textPrimary : textOnDark;
  }
}
