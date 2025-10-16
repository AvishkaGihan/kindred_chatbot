import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/theme/app_dimensions.dart';

/// Premium badge widget - shows crown icon for premium users
class PremiumBadge extends StatelessWidget {
  final double size;
  final bool showLabel;
  final Color? backgroundColor;
  final Color? iconColor;

  const PremiumBadge({
    super.key,
    this.size = 24.0,
    this.showLabel = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        showLabel ? AppDimensions.paddingSm : size * 0.25,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(
          showLabel ? AppDimensions.radiusMd : size,
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? const Color(0xFFFFC107)).withValues(
              alpha: 0.4,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: iconColor ?? Colors.white,
            size: size,
          ),
          if (showLabel) ...[
            const SizedBox(width: AppDimensions.spacingXs),
            Text(
              'Premium',
              style: TextStyle(
                color: iconColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Premium badge overlay for avatar/profile pictures
class PremiumBadgeOverlay extends StatelessWidget {
  final Widget child;
  final bool isPremium;
  final double badgeSize;

  const PremiumBadgeOverlay({
    super.key,
    required this.child,
    required this.isPremium,
    this.badgeSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium) return child;

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(badgeSize * 0.2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: badgeSize * 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

/// Feature lock indicator for premium-only features
class FeatureLock extends StatelessWidget {
  final String featureName;
  final VoidCallback onUpgradeTap;

  const FeatureLock({
    super.key,
    required this.featureName,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Color(0xFFFFC107),
              size: 40,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            '$featureName is Premium Only',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Upgrade to Premium to unlock this feature',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ElevatedButton.icon(
            onPressed: onUpgradeTap,
            icon: const Icon(Icons.upgrade_rounded),
            label: const Text('Upgrade to Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLg,
                vertical: AppDimensions.paddingMd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Usage limit banner for free users
class UsageLimitBanner extends StatelessWidget {
  final int currentUsage;
  final int maxUsage;
  final String featureName;
  final VoidCallback onUpgradeTap;

  const UsageLimitBanner({
    super.key,
    required this.currentUsage,
    required this.maxUsage,
    required this.featureName,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (currentUsage / maxUsage).clamp(0.0, 1.0);
    final isNearLimit = percentage >= 0.8;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: isNearLimit
            ? AppColors.warning.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isNearLimit
              ? AppColors.warning
              : (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$featureName Usage',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '$currentUsage / $maxUsage',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isNearLimit ? AppColors.warning : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearLimit ? AppColors.warning : AppColors.success,
              ),
              minHeight: 8,
            ),
          ),
          if (isNearLimit) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Upgrade to Premium for unlimited $featureName',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                  ),
                ),
                TextButton(
                  onPressed: onUpgradeTap,
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
