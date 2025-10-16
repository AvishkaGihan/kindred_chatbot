import 'package:flutter/material.dart';
import '../../utils/theme/app_dimensions.dart';

/// Password input field with show/hide toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showStrengthIndicator;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint,
    this.validator,
    this.onChanged,
    this.showStrengthIndicator = false,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.showStrengthIndicator) {
      widget.controller.addListener(_calculatePasswordStrength);
    }
  }

  @override
  void dispose() {
    if (widget.showStrengthIndicator) {
      widget.controller.removeListener(_calculatePasswordStrength);
    }
    super.dispose();
  }

  void _calculatePasswordStrength() {
    final password = widget.controller.text;
    double strength = 0.0;

    if (password.isEmpty) {
      setState(() => _passwordStrength = 0.0);
      return;
    }

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // Contains numbers
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    setState(() => _passwordStrength = strength.clamp(0.0, 1.0));
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.3) return Colors.red;
    if (_passwordStrength < 0.6) return Colors.orange;
    if (_passwordStrength < 0.8) return Colors.yellow;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_passwordStrength < 0.3) return 'Weak';
    if (_passwordStrength < 0.6) return 'Fair';
    if (_passwordStrength < 0.8) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
              tooltip: _obscureText ? 'Show password' : 'Hide password',
            ),
          ),
        ),
        if (widget.showStrengthIndicator &&
            widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  child: LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(),
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                _getStrengthText(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getStrengthColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
