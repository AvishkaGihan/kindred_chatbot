import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_indicator.dart';

/// A login screen that provides email/password authentication and Google sign-in.
/// Supports both sign-in and sign-up modes with smooth animations.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isSignUp = false;

  // Animation variables
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Constants
  static const double _cardMaxWidth = 440.0;
  static const double _iconSize = 40.0;
  static const double _buttonHeight = 52.0;
  static const Duration _animationDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initializes the entrance animations for the login form.
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.primaryBlueVariant,
              AppTheme.primaryBlueVariant.withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo and Title Section
                              _buildHeader(theme),
                              const SizedBox(height: 40),

                              // Email Field
                              _buildEmailField(theme),
                              const SizedBox(height: 16),

                              // Password Field
                              _buildPasswordField(theme),
                              const SizedBox(height: 32),

                              // Action Buttons
                              if (_isLoading)
                                const LoadingIndicator(size: 40)
                              else
                                _buildActionButtons(theme),

                              const SizedBox(height: 24),

                              // Toggle Sign In/Sign Up
                              _buildToggleButton(theme),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // App Icon with gradient background
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueVariant],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            size: _iconSize,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Kindred',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your AI Companion',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.email_outlined,
            size: 20,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submitForm(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 20,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
      validator: _validatePassword,
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        // Primary Action Button (Sign In / Sign Up)
        SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Semantics(
              label: _isSignUp ? 'Create new account button' : 'Sign in button',
              child: Text(
                _isSignUp ? 'Create Account' : 'Sign In',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),

        // Google Sign In Button
        // Note: we show an inline loading indicator for Google sign-in
        // instead of toggling the full-page `_isLoading` state. This
        // avoids replacing the whole form with a global spinner and
        // provides a better UX.
        SizedBox(
          width: double.infinity,
          height: _buttonHeight,
          child: OutlinedButton(
            onPressed: _isGoogleLoading ? null : _signInWithGoogle,
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
                if (states.contains(WidgetState.disabled)) {
                  return BorderSide(
                    color: theme.disabledColor.withValues(alpha: 0.25),
                    width: 1.5,
                  );
                }
                return BorderSide(color: theme.colorScheme.outline, width: 1.5);
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) => states.contains(WidgetState.disabled)
                    ? theme.disabledColor.withValues(alpha: 0.7)
                    : null,
              ),
              // subtle background change when disabled
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return theme.colorScheme.surface.withValues(alpha: 0.02);
                }
                return null;
              }),
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return theme.colorScheme.primary.withValues(alpha: 0.08);
                }
                return null;
              }),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google icon tile - adjust visuals when disabled
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isGoogleLoading
                        ? theme.colorScheme.surface.withValues(alpha: 0.7)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.g_mobiledata_rounded,
                    size: 24,
                    color: _isGoogleLoading
                        ? theme.disabledColor.withValues(alpha: 0.9)
                        : AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                // Show text or inline loader while Google sign-in is in progress
                if (_isGoogleLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                    ),
                  ),
                ] else ...[
                  Semantics(
                    label: 'Continue with Google button',
                    child: Text(
                      'Continue with Google',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(ThemeData theme) {
    return Semantics(
      label: _isSignUp ? 'Switch to sign in mode' : 'Switch to sign up mode',
      button: true,
      child: TextButton(
        onPressed: _toggleAuthMode,
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              TextSpan(
                text: _isSignUp
                    ? 'Already have an account? '
                    : "Don't have an account? ",
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              TextSpan(
                text: _isSignUp ? 'Sign In' : 'Sign Up',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Toggles between sign-in and sign-up modes.
  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
    // Clear form when switching modes
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
  }

  /// Validates the email input field.
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates the password input field.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Submits the authentication form.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = _isSignUp
          ? await authProvider.signUpWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            )
          : await authProvider.signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );

      if (!success && mounted) {
        _showErrorSnackBar(
          _isSignUp
              ? 'Failed to create account. Please try again.'
              : 'Invalid email or password. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handles Google sign-in authentication.
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signInWithGoogle();

      if (!success && mounted) {
        _showErrorSnackBar('Google sign-in failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  /// Shows an error snackbar with the given message.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
