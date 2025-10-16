import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/theme/app_colors.dart';

/// Enhanced cached image widget with better performance and error handling
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final double cacheWidth;
  final double cacheHeight;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.cacheWidth = 800,
    this.cacheHeight = 800,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth.toInt(),
      memCacheHeight: cacheHeight.toInt(),
      placeholder: (context, url) {
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            );
      },
      errorWidget: (context, url, error) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              child: Icon(
                Icons.broken_image_outlined,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                size: 32,
              ),
            );
      },
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}

/// Progressive image loader with blur effect
class ProgressiveImage extends StatelessWidget {
  final String imageUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProgressiveImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrl == null) {
      return OptimizedCachedImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Stack(
      children: [
        // Thumbnail (blurred)
        OptimizedCachedImage(
          imageUrl: thumbnailUrl!,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: 100,
          cacheHeight: 100,
        ),
        // Full image
        OptimizedCachedImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
        ),
      ],
    );
  }
}

/// Avatar image with fallback
class CachedAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;
  final Color? backgroundColor;

  const CachedAvatarImage({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor ?? AppColors.primaryBlue,
        child: Text(
          fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size / 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ClipOval(
      child: OptimizedCachedImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: size * 2,
        cacheHeight: size * 2,
        errorWidget: CircleAvatar(
          radius: size / 2,
          backgroundColor: backgroundColor ?? AppColors.primaryBlue,
          child: Text(
            fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: size / 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
