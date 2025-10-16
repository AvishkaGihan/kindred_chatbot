import 'package:flutter/material.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_dimensions.dart';
import '../../../utils/theme/app_animations.dart';
import '../../../utils/constants.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onVoiceInput;
  final bool isListening;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    required this.onVoiceInput,
    this.isListening = false,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  int _characterCount = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
        _characterCount = _controller.text.length;
      });
    });

    // Pulse animation for listening state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nearLimit = _characterCount > AppConstants.maxMessageLength * 0.9;
    final atLimit = _characterCount >= AppConstants.maxMessageLength;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character counter (shown when near limit)
            if (nearLimit && !atLimit)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$_characterCount / ${AppConstants.maxMessageLength}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (atLimit)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: AppDimensions.iconXs,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppDimensions.spacing2xs),
                    Text(
                      'Character limit reached',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 120, // ~5 lines
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? (isDark
                                  ? AppColors.primaryBlueLight
                                  : AppColors.primaryBlue)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: widget.isLoading
                            ? 'AI is thinking...'
                            : 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMd,
                          vertical: AppDimensions.paddingSm,
                        ),
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHintLight,
                            ),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: null,
                      minLines: 1,
                      maxLength: AppConstants.maxMessageLength,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null, // Hide default counter
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !widget.isLoading,
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),

                // Action button (mic/send/stop)
                AnimatedSwitcher(
                  duration: AppAnimations.durationFast,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: widget.isListening
                      ? ScaleTransition(
                          key: const ValueKey('stop'),
                          scale: _pulseAnimation,
                          child: Container(
                            width: AppDimensions.minTouchTarget,
                            height: AppDimensions.minTouchTarget,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.error, AppColors.errorDark],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.stop, color: Colors.white),
                              onPressed: widget.onVoiceInput,
                              tooltip: 'Stop recording',
                            ),
                          ),
                        )
                      : _hasText
                      ? Container(
                          key: const ValueKey('send'),
                          width: AppDimensions.minTouchTarget,
                          height: AppDimensions.minTouchTarget,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.primaryBlueDark,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                            ),
                            onPressed: widget.isLoading ? null : _sendMessage,
                            tooltip: 'Send message',
                          ),
                        )
                      : Container(
                          key: const ValueKey('mic'),
                          width: AppDimensions.minTouchTarget,
                          height: AppDimensions.minTouchTarget,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.secondaryTeal,
                                AppColors.secondaryTealDark,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondaryTeal.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.mic, color: Colors.white),
                            onPressed: widget.onVoiceInput,
                            tooltip: 'Voice input',
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
