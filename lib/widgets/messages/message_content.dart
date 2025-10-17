import 'package:flutter/material.dart';
import '../markdown/markdown_message.dart';
import '../../utils/markdown_utils.dart';
import '../../utils/theme/app_colors.dart';

/// Cleaned up MessageContent: removed duplicated style builders,
/// consolidated color resolution, trimmed comments and early returns.
class MessageContent extends StatelessWidget {
  final String content;
  final TextStyle? textStyle;
  final bool isUser;
  final bool isError;
  final bool isDark;

  const MessageContent({
    super.key,
    required this.content,
    this.textStyle,
    this.isUser = false,
    this.isError = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    final resolvedStyle = _resolvedTextStyle(context);

    try {
      final hasMarkdown = MarkdownUtils.isMarkdownContent(content);
      if (hasMarkdown) {
        return MarkdownMessage(
          content: content,
          textStyle: resolvedStyle,
          selectable: true,
        );
      }
      return SelectableText(content, style: resolvedStyle);
    } catch (_) {
      // Fallback to plain selectable text if detection/rendering fails.
      return SelectableText(content, style: resolvedStyle);
    }
  }

  TextStyle? _resolvedTextStyle(BuildContext context) {
    final base = textStyle ?? Theme.of(context).textTheme.bodyMedium;
    return base?.copyWith(color: _resolveColor(), height: 1.5);
  }

  Color _resolveColor() {
    if (isUser) return Colors.white;
    if (isError) return AppColors.errorDark;
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }
}

class SimpleMessageContent extends StatelessWidget {
  final String content;
  final TextStyle? textStyle;

  const SimpleMessageContent({
    super.key,
    required this.content,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return MessageContent(
      content: content,
      textStyle: textStyle,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
  }
}
