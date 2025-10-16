import 'package:flutter/material.dart';
import '../../utils/theme/app_dimensions.dart';
import '../../utils/theme/app_animations.dart';

/// Primary button component with consistent styling
/// Use for main actions like submit, sign in, etc.
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: AppAnimations.scaleNormal,
      end: AppAnimations.scalePressed,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.curveSnappy),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width,
          height: widget.height ?? AppDimensions.buttonHeightMd,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              padding: widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppDimensions.buttonPaddingHorizontal,
                  ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: AppDimensions.iconSm,
                    width: AppDimensions.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: AppDimensions.iconSm),
                        const SizedBox(width: AppDimensions.spacingXs),
                      ],
                      Text(widget.text),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
