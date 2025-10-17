import 'package:flutter/material.dart';
import '../../utils/theme/app_dimensions.dart';
import '../../utils/accessibility/accessibility_utils.dart';

/// Feature tooltip widget for highlighting app features
/// Shows a tooltip pointing to a specific UI element
class FeatureTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final String? title;
  final TooltipDirection direction;
  final bool showOnInit;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;

  const FeatureTooltip({
    super.key,
    required this.child,
    required this.message,
    this.title,
    this.direction = TooltipDirection.bottom,
    this.showOnInit = false,
    this.onDismiss,
    this.backgroundColor,
  });

  @override
  State<FeatureTooltip> createState() => _FeatureTooltipState();
}

class _FeatureTooltipState extends State<FeatureTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isVisible = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.showOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        show();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void show() {
    if (_isVisible) return;

    _isVisible = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();

    // Announce to screen readers
    context.announce('Feature tip: ${widget.title ?? widget.message}');
  }

  void hide() {
    if (!_isVisible) return;

    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
      widget.onDismiss?.call();
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: hide,
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),

          // Tooltip
          Positioned(
            left: _getLeftPosition(offset, size),
            top: _getTopPosition(offset, size),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(scale: _scaleAnimation, child: child),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: _TooltipContent(
                  title: widget.title,
                  message: widget.message,
                  direction: widget.direction,
                  backgroundColor: widget.backgroundColor,
                  onDismiss: hide,
                ),
              ),
            ),
          ),

          // Highlight circle around target
          Positioned(
            left: offset.dx - 8,
            top: offset.dy - 8,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: size.width + 16,
                    height: size.height + 16,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            widget.backgroundColor ??
                            Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd + 8,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getLeftPosition(Offset offset, Size size) {
    switch (widget.direction) {
      case TooltipDirection.left:
        return offset.dx - 280; // Tooltip width + padding
      case TooltipDirection.right:
        return offset.dx + size.width + 16;
      default:
        return offset.dx - 100; // Center-ish
    }
  }

  double _getTopPosition(Offset offset, Size size) {
    switch (widget.direction) {
      case TooltipDirection.top:
        return offset.dy - 120; // Approximate tooltip height
      case TooltipDirection.bottom:
        return offset.dy + size.height + 16;
      case TooltipDirection.left:
      case TooltipDirection.right:
        return offset.dy - 40; // Center vertically
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Tooltip content card
class _TooltipContent extends StatelessWidget {
  final String? title;
  final String message;
  final TooltipDirection direction;
  final Color? backgroundColor;
  final VoidCallback onDismiss;

  const _TooltipContent({
    this.title,
    required this.message,
    required this.direction,
    this.backgroundColor,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primary;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Align(
            alignment: Alignment.centerRight,
            child: AccessibilityUtils.createAccessibleButton(
              semanticLabel: 'Got it',
              semanticHint: 'Dismiss this feature tip',
              enabled: true,
              onPressed: onDismiss,
              child: TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMd,
                    vertical: AppDimensions.paddingSm,
                  ),
                ),
                child: const Text('Got it'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Direction for tooltip arrow
enum TooltipDirection { top, bottom, left, right }

/// Feature tour manager - shows multiple tooltips in sequence
class FeatureTour {
  final BuildContext context;
  final List<FeatureTourStep> steps;
  int _currentStep = 0;

  FeatureTour({required this.context, required this.steps});

  void start() {
    if (steps.isEmpty) return;
    _showStep(_currentStep);
  }

  void _showStep(int index) {
    if (index >= steps.length) {
      _complete();
      return;
    }

    final step = steps[index];
    final overlay = Overlay.of(context);

    // Create overlay for this step
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: () => _nextStep(overlayEntry),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),

          // Step content
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(AppDimensions.paddingXl),
                padding: const EdgeInsets.all(AppDimensions.paddingLg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (step.icon != null)
                      Icon(
                        step.icon,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    if (step.icon != null)
                      const SizedBox(height: AppDimensions.spacingMd),
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Row(
                      children: [
                        // Progress indicator
                        Expanded(
                          child: Row(
                            children: List.generate(
                              steps.length,
                              (i) => Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: i == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Next/Done button
                        ElevatedButton(
                          onPressed: () => _nextStep(overlayEntry),
                          child: Text(
                            index == steps.length - 1 ? 'Done' : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);
  }

  void _nextStep(OverlayEntry currentOverlay) {
    currentOverlay.remove();
    _currentStep++;
    _showStep(_currentStep);
  }

  void _complete() {
    // Tour completed
    context.announce('Feature tour completed');
  }
}

/// Individual step in a feature tour
class FeatureTourStep {
  final String title;
  final String description;
  final IconData? icon;

  FeatureTourStep({required this.title, required this.description, this.icon});
}
