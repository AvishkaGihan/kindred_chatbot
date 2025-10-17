import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for improving app accessibility
class AccessibilityUtils {
  /// Minimum touch target size (48x48 dp) as per Material Design guidelines
  static const double minTouchTargetSize = 48.0;

  /// Check if a widget meets minimum touch target size
  static bool meetsMinTouchTarget(double width, double height) {
    return width >= minTouchTargetSize && height >= minTouchTargetSize;
  }

  /// Wrap a widget to ensure minimum touch target size
  static Widget ensureMinTouchTarget({
    required Widget child,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? minTouchTargetSize,
      height: height ?? minTouchTargetSize,
      child: Center(child: child),
    );
  }

  /// Create semantic label for screen readers
  static String createSemanticLabel({
    required String label,
    String? hint,
    String? value,
  }) {
    final buffer = StringBuffer(label);
    if (value != null) {
      buffer.write(', $value');
    }
    if (hint != null) {
      buffer.write('. $hint');
    }
    return buffer.toString();
  }

  /// Get appropriate contrast ratio for text
  static double getContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast ratio meets WCAG AA standard (4.5:1 for normal text)
  static bool meetsWCAGAA(
    Color foreground,
    Color background, {
    bool largeText = false,
  }) {
    final ratio = getContrastRatio(foreground, background);
    return largeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Check if contrast ratio meets WCAG AAA standard (7:1 for normal text)
  static bool meetsWCAGAAA(
    Color foreground,
    Color background, {
    bool largeText = false,
  }) {
    final ratio = getContrastRatio(foreground, background);
    return largeText ? ratio >= 4.5 : ratio >= 7.0;
  }

  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if reduce motion is enabled
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get scaled text size based on user's text scale factor
  static double getScaledTextSize(BuildContext context, double baseSize) {
    final textScaler = MediaQuery.of(context).textScaler;
    return textScaler.scale(baseSize);
  }

  /// Check if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Create accessible button with proper semantics
  static Widget createAccessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? semanticHint,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      hint: semanticHint,
      child: child,
    );
  }

  /// Create accessible text field with proper semantics
  static Widget createAccessibleTextField({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    String? semanticValue,
    bool isPassword = false,
  }) {
    return Semantics(
      textField: true,
      label: semanticLabel,
      hint: semanticHint,
      value: semanticValue,
      obscured: isPassword,
      child: child,
    );
  }

  /// Focus management helper
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Move focus to next field
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous field
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Unfocus current field
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Create semantic divider
  static Widget createSemanticDivider(String label) {
    return Semantics(label: label, child: const Divider());
  }

  /// Create semantic header
  static Widget createSemanticHeader({
    required Widget child,
    required String label,
    bool isMainHeader = false,
  }) {
    return Semantics(header: true, label: label, child: child);
  }

  /// Create semantic image
  static Widget createSemanticImage({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(image: true, label: label, hint: hint, child: child);
  }

  /// Create semantic link
  static Widget createSemanticLink({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(link: true, label: label, hint: hint, child: child);
  }

  /// Create live region for dynamic content
  static Widget createLiveRegion({
    required Widget child,
    required String label,
    bool isPolite = true,
  }) {
    return Semantics(liveRegion: true, label: label, child: child);
  }

  /// Get duration based on reduce motion setting
  static Duration getAnimationDuration(
    BuildContext context,
    Duration normalDuration,
  ) {
    if (isReduceMotionEnabled(context)) {
      return Duration.zero;
    }
    return normalDuration;
  }

  /// Get curve based on reduce motion setting
  static Curve getAnimationCurve(BuildContext context, Curve normalCurve) {
    if (isReduceMotionEnabled(context)) {
      return Curves.linear;
    }
    return normalCurve;
  }
}

/// Extension to add accessibility helpers to BuildContext
extension AccessibilityContextExtension on BuildContext {
  bool get reduceMotion => MediaQuery.of(this).disableAnimations;
  bool get highContrast => MediaQuery.of(this).highContrast;
  TextScaler get textScaler => MediaQuery.of(this).textScaler;
  bool get boldText => MediaQuery.of(this).boldText;

  void announce(String message) {
    AccessibilityUtils.announce(this, message);
  }

  void requestFocus(FocusNode focusNode) {
    AccessibilityUtils.requestFocus(this, focusNode);
  }

  void nextFocus() {
    AccessibilityUtils.nextFocus(this);
  }

  void unfocus() {
    AccessibilityUtils.unfocus(this);
  }
}
