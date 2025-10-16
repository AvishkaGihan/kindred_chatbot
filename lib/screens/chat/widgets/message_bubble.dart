import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/message_model.dart';
import '../../../utils/helpers.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_dimensions.dart';
import '../../../utils/theme/app_animations.dart';
import '../../../widgets/snackbar/custom_snackbar.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final VoidCallback? onSpeak;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.showAvatar = true,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: AppAnimations.messageBubble,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.curveSmooth),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AppAnimations.curveSmooth,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    CustomSnackbar.showSuccess(
      context,
      message: 'Message copied to clipboard',
      duration: const Duration(seconds: 2),
    );
  }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Message'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard();
              },
            ),
            if (!widget.message.isError &&
                widget.message.type == MessageType.ai &&
                widget.onSpeak != null)
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Read Aloud'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onSpeak?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.type == MessageType.user;
    final isError = widget.message.isError;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: AppDimensions.messageSpacing,
            left: isUser ? AppDimensions.spacing2xl : 0,
            right: isUser ? 0 : AppDimensions.spacing2xl,
          ),
          child: GestureDetector(
            onLongPress: _showMessageOptions,
            child: Row(
              mainAxisAlignment: isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUser && widget.showAvatar) ...[
                  Container(
                    width: AppDimensions.avatarSm,
                    height: AppDimensions.avatarSm,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isError
                          ? LinearGradient(
                              colors: [AppColors.error, AppColors.errorDark],
                            )
                          : const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.secondaryTeal,
                              ],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: isError
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isError ? Icons.error_outline : Icons.smart_toy,
                      color: Colors.white,
                      size: AppDimensions.iconSm,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.messageBubblePadding,
                      vertical: AppDimensions.paddingSm,
                    ),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.primaryBlueDark,
                              ],
                            )
                          : null,
                      color: isUser
                          ? null
                          : isError
                          ? (isDark
                                ? AppColors.errorDark.withValues(alpha: 0.2)
                                : AppColors.error.withValues(alpha: 0.1))
                          : isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          isUser
                              ? AppDimensions.messageBubbleRadius
                              : AppDimensions.radiusSm,
                        ),
                        topRight: Radius.circular(
                          isUser
                              ? AppDimensions.radiusSm
                              : AppDimensions.messageBubbleRadius,
                        ),
                        bottomLeft: Radius.circular(
                          AppDimensions.messageBubbleRadius,
                        ),
                        bottomRight: Radius.circular(
                          AppDimensions.messageBubbleRadius,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? AppColors.shadowDark
                              : AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          widget.message.content,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isUser
                                    ? Colors.white
                                    : isError
                                    ? AppColors.errorDark
                                    : isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.spacing2xs),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppHelpers.formatTimestamp(
                                widget.message.timestamp,
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isUser
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    fontSize: 10,
                                  ),
                            ),
                            if (!isUser &&
                                !isError &&
                                widget.onSpeak != null) ...[
                              const SizedBox(width: AppDimensions.spacingXs),
                              InkWell(
                                onTap: widget.onSpeak,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.spacing2xs,
                                  ),
                                  child: Icon(
                                    Icons.volume_up,
                                    size: AppDimensions.iconXs,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isUser && widget.showAvatar) ...[
                  const SizedBox(width: AppDimensions.spacingXs),
                  Container(
                    width: AppDimensions.avatarSm,
                    height: AppDimensions.avatarSm,
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
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: AppDimensions.iconSm,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
