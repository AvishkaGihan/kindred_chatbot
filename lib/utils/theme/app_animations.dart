import 'package:flutter/material.dart';

/// App-wide animation constants
/// Standardized durations and curves for consistent animations
class AppAnimations {
  // Duration constants
  static const Duration durationInstant = Duration(milliseconds: 0);
  static const Duration durationFastest = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationSlower = Duration(milliseconds: 500);
  static const Duration durationSlowest = Duration(milliseconds: 700);

  // Specific animation durations
  static const Duration splashFadeIn = Duration(milliseconds: 800);
  static const Duration splashLogoScale = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration dialogFade = Duration(milliseconds: 200);
  static const Duration snackbarSlide = Duration(milliseconds: 250);
  static const Duration buttonPress = Duration(milliseconds: 150);
  static const Duration ripple = Duration(milliseconds: 300);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration typing = Duration(milliseconds: 500);
  static const Duration messageBubble = Duration(milliseconds: 250);
  static const Duration scrollAnimation = Duration(milliseconds: 300);
  static const Duration microInteraction = Duration(milliseconds: 100);

  // Animation curves - Common ones
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve curveLinear = Curves.linear;

  // Custom animation curves
  static const Curve curveBouncyIn = Curves.elasticOut;
  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curveSnappy = Curves.easeOutQuart;
  static const Curve curveGentle = Curves.easeInOutSine;

  // Scale values for animations
  static const double scaleMin = 0.8;
  static const double scaleNormal = 1.0;
  static const double scaleMax = 1.1;
  static const double scalePressed = 0.95;

  // Opacity values
  static const double opacityHidden = 0.0;
  static const double opacityDisabled = 0.5;
  static const double opacitySecondary = 0.7;
  static const double opacityVisible = 1.0;

  // Rotation values (in radians)
  static const double rotationQuarter = 1.5708; // 90 degrees
  static const double rotationHalf = 3.14159; // 180 degrees
  static const double rotationFull = 6.28318; // 360 degrees

  // Slide offsets
  static const double slideOffsetSmall = 0.1;
  static const double slideOffsetMedium = 0.3;
  static const double slideOffsetLarge = 0.5;
  static const double slideOffsetFull = 1.0;

  // Animation delays (for staggered animations)
  static const Duration delayShort = Duration(milliseconds: 50);
  static const Duration delayMedium = Duration(milliseconds: 100);
  static const Duration delayLong = Duration(milliseconds: 150);

  // Loading/Shimmer
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration loadingSpinDuration = Duration(milliseconds: 1000);

  // Haptic feedback delays
  static const Duration hapticDelay = Duration(milliseconds: 10);
}
