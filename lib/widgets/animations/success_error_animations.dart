import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/theme/app_animations.dart';

/// Success checkmark animation
class SuccessAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final VoidCallback? onComplete;

  const SuccessAnimation({
    super.key,
    this.size = 80.0,
    this.color,
    this.onComplete,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.durationSlow,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: AppAnimations.curveSmooth)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: AppAnimations.curveSmooth)),
        weight: 40,
      ),
    ]).animate(_controller);

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.success;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: AnimatedBuilder(
          animation: _checkAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _CheckmarkPainter(
                progress: _checkAnimation.value,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Checkmark starting point (left side)
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;

    // Middle point (bottom of checkmark)
    final midX = size.width * 0.4;
    final midY = size.height * 0.65;

    // End point (top right)
    final endX = size.width * 0.75;
    final endY = size.height * 0.35;

    path.moveTo(startX, startY);

    if (progress < 0.5) {
      // Draw first part of checkmark
      final currentProgress = progress * 2;
      path.lineTo(
        startX + (midX - startX) * currentProgress,
        startY + (midY - startY) * currentProgress,
      );
    } else {
      // Draw first part completely
      path.lineTo(midX, midY);
      // Draw second part of checkmark
      final currentProgress = (progress - 0.5) * 2;
      path.lineTo(
        midX + (endX - midX) * currentProgress,
        midY + (endY - midY) * currentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Error shake animation with X icon
class ErrorAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final VoidCallback? onComplete;

  const ErrorAnimation({
    super.key,
    this.size = 80.0,
    this.color,
    this.onComplete,
  });

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _xAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.durationSlow,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: AppAnimations.curveSmooth)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: AppAnimations.curveSmooth)),
        weight: 40,
      ),
    ]).animate(_controller);

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.05),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.05),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.0),
        weight: 10,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.0), weight: 50),
    ]).animate(_controller);

    _xAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.error;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * widget.size, 0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: CustomPaint(
                painter: _XPainter(
                  progress: _xAnimation.value,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _XPainter extends CustomPainter {
  final double progress;
  final Color color;

  _XPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final lineLength = size.width * 0.3;

    // Draw first line (top-left to bottom-right)
    if (progress > 0) {
      final path1 = Path();
      path1.moveTo(centerX - lineLength, centerY - lineLength);
      if (progress < 0.5) {
        final currentProgress = progress * 2;
        path1.lineTo(
          centerX - lineLength + (lineLength * 2 * currentProgress),
          centerY - lineLength + (lineLength * 2 * currentProgress),
        );
      } else {
        path1.lineTo(centerX + lineLength, centerY + lineLength);
      }
      canvas.drawPath(path1, paint);
    }

    // Draw second line (top-right to bottom-left)
    if (progress > 0.5) {
      final path2 = Path();
      path2.moveTo(centerX + lineLength, centerY - lineLength);
      final currentProgress = (progress - 0.5) * 2;
      path2.lineTo(
        centerX + lineLength - (lineLength * 2 * currentProgress),
        centerY - lineLength + (lineLength * 2 * currentProgress),
      );
      canvas.drawPath(path2, paint);
    }
  }

  @override
  bool shouldRepaint(_XPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Celebration confetti animation
class CelebrationAnimation extends StatefulWidget {
  final double size;
  final VoidCallback? onComplete;

  const CelebrationAnimation({super.key, this.size = 200.0, this.onComplete});

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Generate random confetti particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_ConfettiParticle());
    }

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ConfettiPainter(
              progress: _controller.value,
              particles: _particles,
            ),
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speedX;
  final double speedY;
  final double rotation;

  _ConfettiParticle()
    : x = 0.5,
      y = 0.5,
      size = 4 + (DateTime.now().millisecond % 6),
      color = [
        AppColors.success,
        AppColors.primaryBlue,
        AppColors.accentAmber,
        AppColors.accentPink,
        AppColors.secondaryTeal,
      ][DateTime.now().microsecond % 5],
      speedX = (DateTime.now().microsecond % 100 - 50) / 100,
      speedY = -(50 + DateTime.now().millisecond % 50) / 100,
      rotation = (DateTime.now().microsecond % 360) * 3.14159 / 180;
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = size.width * (particle.x + particle.speedX * progress);
      final y =
          size.height *
          (particle.y + particle.speedY * progress + 0.5 * progress * progress);

      if (y < size.height) {
        final paint = Paint()
          ..color = particle.color.withValues(alpha: 1.0 - progress);

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(particle.rotation * progress * 10);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
