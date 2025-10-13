import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message_model.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.type == MessageType.user;
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final timeFormatted = _formatTime(message.timestamp);

    // Semantic label for screen readers
    final semanticLabel = isUserMessage
        ? 'You said: ${message.text}. Sent at $timeFormatted'
        : 'Kindred replied: ${message.text}. Sent at $timeFormatted';

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Row(
          mainAxisAlignment: isUserMessage
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUserMessage) ...[
              Semantics(
                label: 'AI assistant avatar',
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUserMessage
                      ? AppTheme.getUserBubbleColor(brightness)
                      : AppTheme.getAiBubbleColor(brightness),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUserMessage ? 20 : 4),
                    bottomRight: Radius.circular(isUserMessage ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isVoiceMessage) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isUserMessage
                                      ? Colors.white
                                      : AppTheme.primaryBlue)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mic,
                              size: 14,
                              color: isUserMessage
                                  ? AppTheme.getTextOnUserBubble().withValues(
                                      alpha: 0.8,
                                    )
                                  : AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Voice Message',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isUserMessage
                                    ? AppTheme.getTextOnUserBubble().withValues(
                                        alpha: 0.8,
                                      )
                                    : AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: theme.textTheme.bodyMedium?.copyWith(
                          color: isUserMessage
                              ? AppTheme.getTextOnUserBubble()
                              : AppTheme.getTextOnAiBubble(brightness),
                          height: 1.4,
                        ),
                        strong: theme.textTheme.bodyMedium?.copyWith(
                          color: isUserMessage
                              ? AppTheme.getTextOnUserBubble()
                              : AppTheme.getTextOnAiBubble(brightness),
                          fontWeight: FontWeight.w600,
                        ),
                        code: theme.textTheme.bodySmall?.copyWith(
                          color: isUserMessage
                              ? AppTheme.getTextOnUserBubble().withValues(
                                  alpha: 0.9,
                                )
                              : AppTheme.getTextOnAiBubble(
                                  brightness,
                                ).withValues(alpha: 0.9),
                          fontFamily: 'monospace',
                          backgroundColor:
                              (isUserMessage ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        _formatTime(message.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isUserMessage
                              ? AppTheme.getTextOnUserBubble().withValues(
                                  alpha: 0.7,
                                )
                              : AppTheme.getTextOnAiBubble(
                                  brightness,
                                ).withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUserMessage) ...[
              const SizedBox(width: 12),
              Semantics(
                label: 'Your profile avatar',
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlueVariant,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
