import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/markdown_utils.dart';

/// A custom markdown widget that renders markdown content with app theming.
///
/// This widget provides rich markdown rendering with syntax highlighting,
/// theme integration, and interactive features like link handling and
/// code copying. It automatically falls back to plain text rendering
/// if markdown parsing fails.
///
/// ## Features
/// - **Theme Integration**: Matches app's Material Design theme
/// - **Syntax Highlighting**: Automatic code block highlighting with copy buttons
/// - **Link Handling**: Interactive links that open in external browser
/// - **Error Resilience**: Graceful fallback to plain text on parsing errors
/// - **Accessibility**: Maintains text selection and screen reader support
///
/// ## Usage Examples
///
/// ### Basic Usage
/// ```dart
/// MarkdownMessage(
///   content: "# Hello\n\n**Bold** and *italic* text",
///   selectable: true,
/// )
/// ```
///
/// ### With Custom Styling
/// ```dart
/// MarkdownMessage(
///   content: markdownContent,
///   textStyle: TextStyle(fontSize: 16, color: Colors.blue),
///   selectable: false,
///   padding: EdgeInsets.all(16),
/// )
/// ```
///
/// ### In Message Bubble
/// ```dart
/// MessageBubble(
///   child: MarkdownMessage(
///     content: aiResponse,
///     textStyle: theme.textTheme.bodyMedium,
///   ),
/// )
/// ```
class MarkdownMessage extends StatelessWidget {
  /// The markdown content to render.
  ///
  /// Supports standard markdown syntax including:
  /// - Headers: `# ## ### #### ##### ######`
  /// - Text formatting: `**bold**`, `*italic*`, `~~strikethrough~~`
  /// - Code: `` `inline code` ``, ```code blocks```
  /// - Lists: `- item`, `1. ordered item`
  /// - Links: `[text](url)`, `![alt](image)`
  /// - Blockquotes: `> quote`
  /// - Tables: `| col1 | col2 |`
  final String content;

  /// Whether the text should be selectable by the user.
  ///
  /// When `true`, users can select and copy text. When `false`,
  /// text selection is disabled. Defaults to `true`.
  final bool selectable;

  /// Custom text style to apply to the rendered content.
  ///
  /// If provided, this style will be merged with the default markdown
  /// styling. Useful for customizing font size, color, or weight.
  /// If `null`, uses the default theme styling.
  final TextStyle? textStyle;

  /// Padding to apply around the markdown content.
  ///
  /// If `null`, uses default padding. Set to `EdgeInsets.zero`
  /// for no padding.
  final EdgeInsetsGeometry? padding;

  const MarkdownMessage({
    super.key,
    required this.content,
    this.selectable = true,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Validate content before processing
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final sanitizedContent = MarkdownUtils.sanitizeMarkdown(content);

      return MarkdownBody(
        data: sanitizedContent,
        selectable: selectable,
        styleSheet: MarkdownUtils.createMarkdownStyleSheet(context).copyWith(
          // Apply custom text style if provided
          p: textStyle ?? MarkdownUtils.createMarkdownStyleSheet(context).p,
        ),
        onTapLink: (text, href, title) =>
            _handleLinkTap(context, text, href, title),
        builders: {'code': CodeBlockBuilder()},
        // Enable soft line breaks for better text wrapping
        softLineBreak: true,
        // Configure list indentation
        listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
      );
    } catch (e) {
      // Fallback to plain text if markdown parsing fails
      return SelectableText(
        content,
        style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      );
    }
  }

  /// Handles link tapping in markdown content
  Future<void> _handleLinkTap(
    BuildContext context,
    String text,
    String? href,
    String? title,
  ) async {
    if (href == null || href.isEmpty) return;

    try {
      final uri = Uri.parse(href);

      // Handle different URI schemes
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        // External web links - open in browser
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Opens in external browser
          );
        } else {
          // Show error if can't launch
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open link: $href'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else if (uri.scheme == 'mailto') {
        // Email links
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } else if (uri.scheme == 'tel') {
        // Phone links
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } else {
        // Other schemes - try to launch anyway
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Show error for unsupported schemes
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unsupported link type: $href'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Handle invalid URIs
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid link: $href'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// A simplified version of MarkdownMessage for basic use cases.
///
/// This widget provides a streamlined interface for common markdown rendering
/// scenarios where full customization isn't needed. It automatically enables
/// text selection and uses zero padding by default.
///
/// ## Usage Examples
///
/// ### Simple Rendering
/// ```dart
/// SimpleMarkdownMessage(
///   content: "# Title\n\nSome **formatted** text",
/// )
/// ```
///
/// ### With Custom Style
/// ```dart
/// SimpleMarkdownMessage(
///   content: markdownText,
///   textStyle: TextStyle(fontSize: 18, color: Colors.blue),
/// )
/// ```
class SimpleMarkdownMessage extends StatelessWidget {
  final String content;
  final TextStyle? textStyle;

  const SimpleMarkdownMessage({
    super.key,
    required this.content,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownMessage(
      content: content,
      selectable: true,
      textStyle: textStyle,
      padding: EdgeInsets.zero,
    );
  }
}

/// Custom code block builder that provides syntax highlighting.
///
/// This builder enhances code blocks in markdown with:
/// - **Syntax Highlighting**: Automatic language detection and highlighting
/// - **Copy Functionality**: One-click copy button for code blocks
/// - **Theme Integration**: Adapts to app's dark/light theme
/// - **Error Resilience**: Falls back to plain text if highlighting fails
/// - **Language Detection**: Automatically detects programming languages
///
/// ## Supported Languages
/// - Dart, JavaScript, Python, Java, C++, PHP, SQL, XML, Bash
/// - Falls back to JavaScript highlighting for unknown languages
///
/// ## Features
/// - Copy button with visual feedback
/// - Syntax highlighting with theme-aware colors
/// - Monospace font with consistent sizing
/// - Rounded corners with subtle borders
/// - Proper padding and spacing
///
/// ## Usage
/// This builder is automatically used by [MarkdownMessage] for code blocks.
/// No manual instantiation required.
///
/// ## Example Output
/// ```dart
/// // Code blocks in markdown are automatically enhanced:
/// ```dart
/// void main() {
///   print("Hello, World!");
/// }
/// ```
/// ```
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String code = element.textContent;
    final String? language =
        element.attributes['language'] ?? _detectLanguage(code);

    return Builder(
      builder: (context) {
        try {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent, // Let HighlightView handle background
            ),
            child: Stack(
              children: [
                HighlightView(
                  code,
                  language: language ?? 'javascript',
                  theme: _getSyntaxTheme(context),
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
                Positioned(top: 8, right: 8, child: _CopyButton(code: code)),
              ],
            ),
          );
        } catch (e) {
          // Fallback to plain text code block if syntax highlighting fails
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                SelectableText(
                  code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Positioned(top: 8, right: 8, child: _CopyButton(code: code)),
              ],
            ),
          );
        }
      },
    );
  }

  /// Detects programming language from code content
  String? _detectLanguage(String code) {
    final String trimmedCode = code.trim();

    // Common language patterns
    if (trimmedCode.contains('import ') && trimmedCode.contains(';')) {
      return 'dart';
    }
    if (trimmedCode.contains('function') ||
        trimmedCode.contains('const ') ||
        trimmedCode.contains('let ')) {
      return 'javascript';
    }
    if (trimmedCode.contains('def ') ||
        trimmedCode.contains('import ') && trimmedCode.contains(':')) {
      return 'python';
    }
    if (trimmedCode.contains('public class') ||
        trimmedCode.contains('System.out')) {
      return 'java';
    }
    if (trimmedCode.contains('#include') || trimmedCode.contains('int main')) {
      return 'cpp';
    }
    if (trimmedCode.contains('<?php')) {
      return 'php';
    }
    if (trimmedCode.contains('SELECT') ||
        trimmedCode.contains('FROM') ||
        trimmedCode.contains('WHERE')) {
      return 'sql';
    }
    if (trimmedCode.contains('<') &&
        trimmedCode.contains('>') &&
        trimmedCode.contains('/')) {
      return 'xml';
    }
    if (trimmedCode.startsWith('#!/bin/bash') ||
        trimmedCode.contains('echo ')) {
      return 'bash';
    }

    // Default to no highlighting if language can't be detected
    return null;
  }

  /// Gets the appropriate syntax highlighting theme based on app theme
  Map<String, TextStyle> _getSyntaxTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return {
        'root': TextStyle(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        'keyword': TextStyle(
          color: const Color(0xFF7C4DFF),
        ), // Purple for keywords
        'string': TextStyle(
          color: const Color(0xFF4CAF50),
        ), // Green for strings
        'number': TextStyle(
          color: const Color(0xFFFF9800),
        ), // Orange for numbers
        'comment': TextStyle(
          color: const Color(0xFF9E9E9E),
        ), // Gray for comments
        'class': TextStyle(color: const Color(0xFF2196F3)), // Blue for classes
        'function': TextStyle(
          color: const Color(0xFFFFC107),
        ), // Amber for functions
      };
    } else {
      return {
        'root': TextStyle(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        'keyword': TextStyle(
          color: const Color(0xFF7C4DFF),
        ), // Purple for keywords
        'string': TextStyle(
          color: const Color(0xFF2E7D32),
        ), // Dark green for strings
        'number': TextStyle(
          color: const Color(0xFFE65100),
        ), // Dark orange for numbers
        'comment': TextStyle(
          color: const Color(0xFF616161),
        ), // Dark gray for comments
        'class': TextStyle(
          color: const Color(0xFF1565C0),
        ), // Dark blue for classes
        'function': TextStyle(
          color: const Color(0xFFF57C00),
        ), // Dark amber for functions
      };
    }
  }
}

/// Copy button widget for code blocks.
///
/// Provides a compact button that allows users to copy code content
/// to the clipboard with visual feedback.
///
/// ## Features
/// - **Visual Feedback**: Icon changes to checkmark when copied
/// - **Toast Notification**: Shows "Code copied" message
/// - **Auto Reset**: Returns to copy icon after 2 seconds
/// - **Theme Integration**: Adapts to app's color scheme
/// - **Accessibility**: Includes tooltip and proper sizing
///
/// ## Usage
/// Automatically included in code blocks by [CodeBlockBuilder].
/// Not intended for direct use.
class _CopyButton extends StatefulWidget {
  final String code;

  const _CopyButton({required this.code});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          _isCopied ? Icons.check : Icons.copy,
          size: 16,
          color: _isCopied
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: _copyToClipboard,
        tooltip: _isCopied ? 'Copied!' : 'Copy code',
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _isCopied = true);

    // Show feedback and reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });

    // Show snackbar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
