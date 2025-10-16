import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/version_config.dart';
import '../utils/theme/app_colors.dart';
import '../utils/theme/app_dimensions.dart';
import '../utils/theme/app_animations.dart';
import '../widgets/loading_widget.dart';
import 'auth/login_screen.dart';
import 'chat/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _taglineAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthState();
  }

  void _setupAnimations() {
    // Fade animation for logo
    _fadeController = AnimationController(
      duration: AppAnimations.splashFadeIn,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: AppAnimations.curveSmooth,
      ),
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: AppAnimations.splashLogoScale,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppAnimations.curveBouncyIn,
      ),
    );

    // Tagline fade animation (delayed)
    _taglineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  void _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Fade out before navigation
    await _fadeController.reverse();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            authProvider.isAuthenticated
            ? const ChatScreen()
            : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppAnimations.pageTransition,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.backgroundDark, AppColors.surfaceVariantDark]
                : [
                    AppColors.primaryBlue.withValues(alpha: 0.05),
                    AppColors.secondaryTeal.withValues(alpha: 0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingXl),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.secondaryTeal,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: AppDimensions.icon3xl,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // App Name
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Kindred',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingSm),

                // Tagline
                FadeTransition(
                  opacity: _taglineAnimation,
                  child: Text(
                    'Your AI Companion',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing2xl),

                // Loading Indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const LoadingWidget(),
                ),

                const SizedBox(height: AppDimensions.spacing2xl),

                // Version Number
                FadeTransition(
                  opacity: _taglineAnimation,
                  child: Text(
                    'v${VersionConfig.appVersion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textDisabledDark
                          : AppColors.textDisabledLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
