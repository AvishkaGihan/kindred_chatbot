import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Main theme configuration for the app
/// Provides both light and dark themes with Material Design 3
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryBlueLight,
        onPrimaryContainer: AppColors.primaryBlueDark,
        secondary: AppColors.secondaryTeal,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryTealLight,
        onSecondaryContainer: AppColors.secondaryTealDark,
        tertiary: AppColors.accentAmber,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.error.withValues(alpha: 0.1),
        onErrorContainer: AppColors.errorDark,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        outline: AppColors.borderLight,
        shadow: AppColors.shadowLight,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        titleTextStyle: AppTextStyles.titleLargeLight,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryLight,
          size: AppDimensions.iconMd,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        color: AppColors.backgroundLight,
        margin: const EdgeInsets.all(AppDimensions.marginMd),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: AppDimensions.inputBorderWidth * 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth * 1.5,
          ),
        ),
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        hintStyle: AppTextStyles.inputText.copyWith(
          color: AppColors.textHintLight,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppDimensions.elevation2,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMd,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMd,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMd,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          side: const BorderSide(
            color: AppColors.primaryBlue,
            width: AppDimensions.inputBorderWidth,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: AppDimensions.elevation3,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: AppDimensions.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
        ),
        backgroundColor: AppColors.backgroundLight,
        titleTextStyle: AppTextStyles.titleLargeLight,
        contentTextStyle: AppTextStyles.bodyLargeLight,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.onBackgroundLight,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.backgroundLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.snackbarRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppDimensions.elevation3,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.spacingMd,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.listTileContentPadding,
        ),
        minLeadingWidth: AppDimensions.iconLg,
        titleTextStyle: AppTextStyles.titleMediumLight,
        subtitleTextStyle: AppTextStyles.bodyMediumLight,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        disabledColor: AppColors.surfaceVariantLight,
        selectedColor: AppColors.primaryBlueLight,
        secondarySelectedColor: AppColors.secondaryTealLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSm,
          vertical: AppDimensions.paddingXs,
        ),
        labelStyle: AppTextStyles.chipText,
        secondaryLabelStyle: AppTextStyles.chipText,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondaryLight,
        selectedLabelStyle: AppTextStyles.navigationLabel,
        unselectedLabelStyle: AppTextStyles.navigationLabel,
        elevation: AppDimensions.bottomNavElevation,
        type: BottomNavigationBarType.fixed,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLargeLight,
        displayMedium: AppTextStyles.displayMediumLight,
        displaySmall: AppTextStyles.displaySmallLight,
        headlineLarge: AppTextStyles.headlineLargeLight,
        headlineMedium: AppTextStyles.headlineMediumLight,
        headlineSmall: AppTextStyles.headlineSmallLight,
        titleLarge: AppTextStyles.titleLargeLight,
        titleMedium: AppTextStyles.titleMediumLight,
        titleSmall: AppTextStyles.titleSmallLight,
        bodyLarge: AppTextStyles.bodyLargeLight,
        bodyMedium: AppTextStyles.bodyMediumLight,
        bodySmall: AppTextStyles.bodySmallLight,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Scaffold Background Color
      scaffoldBackgroundColor: AppColors.backgroundLight,
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryBlueLight,
        onPrimary: AppColors.onBackgroundDark,
        primaryContainer: AppColors.primaryBlueDark,
        onPrimaryContainer: AppColors.primaryBlueLight,
        secondary: AppColors.secondaryTealLight,
        onSecondary: AppColors.onBackgroundDark,
        secondaryContainer: AppColors.secondaryTealDark,
        onSecondaryContainer: AppColors.secondaryTealLight,
        tertiary: AppColors.accentAmber,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorDark,
        onErrorContainer: AppColors.error,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        outline: AppColors.borderDark,
        shadow: AppColors.shadowDark,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        titleTextStyle: AppTextStyles.titleLargeDark,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: AppDimensions.iconMd,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        color: AppColors.surfaceDark,
        margin: const EdgeInsets.all(AppDimensions.marginMd),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.borderDark,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.borderDark,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryBlueLight,
            width: AppDimensions.inputBorderWidth * 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth * 1.5,
          ),
        ),
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        hintStyle: AppTextStyles.inputText.copyWith(
          color: AppColors.textHintDark,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppDimensions.elevation2,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMd,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMd,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightMd,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPaddingHorizontal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          side: const BorderSide(
            color: AppColors.primaryBlueLight,
            width: AppDimensions.inputBorderWidth,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: AppDimensions.elevation3,
        backgroundColor: AppColors.primaryBlueLight,
        foregroundColor: AppColors.onBackgroundDark,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: AppDimensions.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
        ),
        backgroundColor: AppColors.surfaceDark,
        titleTextStyle: AppTextStyles.titleLargeDark,
        contentTextStyle: AppTextStyles.bodyLargeDark,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariantDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.snackbarRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppDimensions.elevation3,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.spacingMd,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.listTileContentPadding,
        ),
        minLeadingWidth: AppDimensions.iconLg,
        titleTextStyle: AppTextStyles.titleMediumDark,
        subtitleTextStyle: AppTextStyles.bodyMediumDark,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        disabledColor: AppColors.surfaceVariantDark,
        selectedColor: AppColors.primaryBlueDark,
        secondarySelectedColor: AppColors.secondaryTealDark,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSm,
          vertical: AppDimensions.paddingXs,
        ),
        labelStyle: AppTextStyles.chipText,
        secondaryLabelStyle: AppTextStyles.chipText,
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primaryBlueLight,
        unselectedItemColor: AppColors.textSecondaryDark,
        selectedLabelStyle: AppTextStyles.navigationLabel,
        unselectedLabelStyle: AppTextStyles.navigationLabel,
        elevation: AppDimensions.bottomNavElevation,
        type: BottomNavigationBarType.fixed,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLargeDark,
        displayMedium: AppTextStyles.displayMediumDark,
        displaySmall: AppTextStyles.displaySmallDark,
        headlineLarge: AppTextStyles.headlineLargeDark,
        headlineMedium: AppTextStyles.headlineMediumDark,
        headlineSmall: AppTextStyles.headlineSmallDark,
        titleLarge: AppTextStyles.titleLargeDark,
        titleMedium: AppTextStyles.titleMediumDark,
        titleSmall: AppTextStyles.titleSmallDark,
        bodyLarge: AppTextStyles.bodyLargeDark,
        bodyMedium: AppTextStyles.bodyMediumDark,
        bodySmall: AppTextStyles.bodySmallDark,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Scaffold Background Color
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}
