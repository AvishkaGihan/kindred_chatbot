import 'package:flutter/material.dart';
import '../../utils/theme/app_dimensions.dart';
import '../../utils/theme/app_colors.dart';
import '../animations/success_error_animations.dart';

/// Animated dialog showing success or error
class AnimatedResultDialog {
  /// Show success dialog with checkmark animation
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onComplete,
    Duration displayDuration = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(displayDuration, () {
          if (context.mounted) {
            Navigator.of(context).pop();
            onComplete?.call();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SuccessAnimation(size: 100, color: AppColors.success),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show error dialog with shake animation
  static Future<void> showError(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onComplete,
    Duration displayDuration = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(displayDuration, () {
          if (context.mounted) {
            Navigator.of(context).pop();
            onComplete?.call();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ErrorAnimation(size: 100, color: AppColors.error),
                const SizedBox(height: AppDimensions.spacingLg),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show celebration dialog with confetti
  static Future<void> showCelebration(
    BuildContext context, {
    required String title,
    String? message,
    VoidCallback? onComplete,
    Duration displayDuration = const Duration(seconds: 3),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(displayDuration, () {
          if (context.mounted) {
            Navigator.of(context).pop();
            onComplete?.call();
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Confetti layer
              const Positioned.fill(child: CelebrationAnimation(size: 300)),
              // Content card
              Container(
                margin: const EdgeInsets.all(AppDimensions.marginLg),
                padding: const EdgeInsets.all(AppDimensions.paddingXl),
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SuccessAnimation(size: 80, color: AppColors.success),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
