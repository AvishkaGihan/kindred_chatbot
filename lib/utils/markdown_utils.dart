import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Utility class for markdown content processing, styling, and validation.
///
/// This class provides essential functions for handling markdown content in the
/// Kindred chatbot application, including:
/// - Content detection and validation
/// - Theme-aware styling for markdown elements
/// - Content sanitization for security
/// - Plain text extraction for accessibility
///
/// ## Usage Examples
///
/// ### Basic Content Detection
/// ```dart
/// final content = "# Hello **World**";
/// final isMarkdown = MarkdownUtils.isMarkdownContent(content); // true
/// ```
///
/// ### Creating Styled Markdown
/// ```dart
/// Widget build(BuildContext context) {
///   return MarkdownBody(
///     data: content,
///     styleSheet: MarkdownUtils.createMarkdownStyleSheet(context),
///   );
/// }
/// ```
///
/// ### Content Sanitization
/// ```dart
/// final unsafeContent = "# Title\n<script>alert('xss')</script>";
/// final safeContent = MarkdownUtils.sanitizeMarkdown(unsafeContent);
/// ```
///
/// ### Plain Text Extraction
/// ```dart
/// final markdown = "# Header\n\n**Bold** and *italic* text";
/// final plainText = MarkdownUtils.extractPlainText(markdown);
/// // Result: "Header\n\nBold and italic text"
/// ```
class MarkdownUtils {
  // Static regex patterns for markdown detection (performance optimization)
  static final RegExp _headerPattern = RegExp(r'^#{1,6}\s+');
  static final RegExp _boldPattern1 = RegExp(r'\*\*.*?\*\*');
  static final RegExp _boldPattern2 = RegExp(r'__.*?__');
  static final RegExp _italicPattern1 = RegExp(r'\*.*?\*');
  static final RegExp _italicPattern2 = RegExp(r'_.*?_');
  static final RegExp _codeBlockPattern = RegExp(r'```[\s\S]*?```');
  static final RegExp _inlineCodePattern = RegExp(r'`[^`\n]+`');
  static final RegExp _unorderedListPattern = RegExp(r'^\s*[-*+]\s+');
  static final RegExp _orderedListPattern = RegExp(r'^\s*\d+\.\s+');
  static final RegExp _linkPattern = RegExp(r'\[.*?\]\(.*?\)');
  static final RegExp _imagePattern = RegExp(r'!\[.*?\]\(.*?\)');
  static final RegExp _blockquotePattern = RegExp(r'^\s*>');
  static final RegExp _horizontalRulePattern = RegExp(r'^\s*[-*_]{3,}\s*$');

  // Additional static regex patterns for text extraction
  static final RegExp _headerExtractPattern = RegExp(r'#+\s*');
  static final RegExp _boldExtractPattern1 = RegExp(r'\*\*(.*?)\*\*');
  static final RegExp _boldExtractPattern2 = RegExp(r'__(.*?)__');
  static final RegExp _italicExtractPattern1 = RegExp(r'\*(.*?)\*');
  static final RegExp _italicExtractPattern2 = RegExp(r'_(.*?)_');
  static final RegExp _inlineCodeExtractPattern = RegExp(r'`([^`\n]+)`');
  static final RegExp _codeBlockExtractPattern = RegExp(r'```[\s\S]*?```');
  static final RegExp _imageExtractPattern = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
  static final RegExp _linkExtractPattern = RegExp(r'\[([^\]]*)\]\([^)]*\)');
  static final RegExp _unorderedListExtractPattern = RegExp(
    r'^\s*[-*+]\s+',
    multiLine: true,
  );
  static final RegExp _orderedListExtractPattern = RegExp(
    r'^\s*\d+\.\s+',
    multiLine: true,
  );
  static final RegExp _blockquoteExtractPattern = RegExp(
    r'^\s*>+\s*',
    multiLine: true,
  );

  /// Checks if the given content contains markdown syntax.
  ///
  /// This method performs a lightweight scan for common markdown patterns
  /// including headers, formatting, code blocks, lists, links, and more.
  /// It's designed to be fast and conservative - it may return false positives
  /// but minimizes false negatives.
  ///
  /// ## Parameters
  /// - [content]: The text content to analyze
  ///
  /// ## Returns
  /// `true` if markdown syntax is detected, `false` otherwise
  ///
  /// ## Examples
  /// ```dart
  /// MarkdownUtils.isMarkdownContent("# Header"); // true
  /// MarkdownUtils.isMarkdownContent("**bold**"); // true
  /// MarkdownUtils.isMarkdownContent("Plain text"); // false
  /// MarkdownUtils.isMarkdownContent(""); // false
  /// ```
  ///
  /// ## Supported Patterns
  /// - Headers: `# ## ###`
  /// - Formatting: `**bold**`, `*italic*`, `__bold__`, `_italic_`
  /// - Code: `` `inline` ``, ```code blocks```
  /// - Lists: `- item`, `1. item`
  /// - Links: `[text](url)`, `![alt](image)`
  /// - Blockquotes: `> quote`
  /// - Tables: `| cell | cell |`
  /// - Horizontal rules: `---`, `***`
  static bool isMarkdownContent(String content) {
    // Handle edge cases
    if (content.isEmpty || content.trim().isEmpty) {
      return false;
    }

    // Check for common markdown patterns using pre-compiled regexes
    final markdownPatterns = [
      _headerPattern,
      _boldPattern1,
      _boldPattern2,
      _italicPattern1,
      _italicPattern2,
      _codeBlockPattern,
      _inlineCodePattern,
      _unorderedListPattern,
      _orderedListPattern,
      _linkPattern,
      _imagePattern,
      _blockquotePattern,
      _horizontalRulePattern,
    ];

    return markdownPatterns.any((pattern) => pattern.hasMatch(content));
  }

  /// Creates a markdown style sheet that matches the app theme.
  ///
  /// This method generates a comprehensive [MarkdownStyleSheet] that integrates
  /// seamlessly with the app's Material Design theme, ensuring consistent
  /// typography, colors, and spacing across light and dark themes.
  ///
  /// ## Parameters
  /// - [context]: The build context used to access the current theme
  ///
  /// ## Returns
  /// A [MarkdownStyleSheet] configured for the current app theme
  ///
  /// ## Features
  /// - **Theme Integration**: Uses app colors, typography, and spacing
  /// - **Dark/Light Mode**: Automatically adapts to theme brightness
  /// - **Accessibility**: Maintains proper contrast ratios
  /// - **Consistent Spacing**: Applies uniform line heights and margins
  ///
  /// ## Usage
  /// ```dart
  /// final styleSheet = MarkdownUtils.createMarkdownStyleSheet(context);
  /// return MarkdownBody(
  ///   data: markdownContent,
  ///   styleSheet: styleSheet,
  /// );
  /// ```
  ///
  /// ## Styled Elements
  /// - Headers (H1-H6) with hierarchical sizing and primary color accents
  /// - Text elements (paragraphs, bold, italic) with consistent line heights
  /// - Code blocks with syntax highlighting backgrounds
  /// - Lists with proper indentation and bullet styling
  /// - Blockquotes with subtle background and left border
  /// - Links with primary color and underline decoration
  /// - Tables with outline borders and proper padding
  /// - Horizontal rules with theme-aware colors
  static MarkdownStyleSheet createMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      // Headers with proper hierarchy and spacing
      h1: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
        height: 1.2,
      ),
      h2: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
        height: 1.3,
      ),
      h3: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
        height: 1.4,
      ),
      h4: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      h5: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      h6: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),

      // Text elements with consistent line height
      p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
      strong: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.6,
      ),
      em: theme.textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
        height: 1.6,
      ),

      // Code with monospace font and proper background
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodyMedium?.fontSize ?? 14,
        backgroundColor: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerLowest,
        color: theme.colorScheme.onSurface,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(16),

      // Lists with proper indentation and spacing
      listBullet: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
      listBulletPadding: const EdgeInsets.only(right: 12),
      listIndent: 24,

      // Blockquotes with subtle styling
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
        color:
            (isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerLowest)
                .withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.6,
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      // Links with hover states
      a: TextStyle(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: theme.colorScheme.primary.withValues(alpha: 0.7),
      ),

      // Tables with proper borders and spacing
      tableHead: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      tableBody: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
      tableBorder: TableBorder.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        width: 1,
      ),
      tableHeadAlign: TextAlign.center,
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      // Horizontal rules with subtle styling
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),

      // Additional spacing for better readability
      blockSpacing: 16,
    );
  }

  /// Sanitizes markdown content to prevent XSS and ensure safe rendering.
  ///
  /// This method performs basic sanitization by removing potentially dangerous
  /// HTML tags that could be embedded in markdown content. It's designed as
  /// a first line of defense against malicious content.
  ///
  /// ## Parameters
  /// - [content]: The markdown content to sanitize
  ///
  /// ## Returns
  /// Sanitized markdown content with dangerous HTML tags removed
  ///
  /// ## Security Notes
  /// - Removes `<script>`, `<iframe>`, `<object>`, and `<embed>` tags
  /// - Case-insensitive matching
  /// - Returns original content if sanitization fails
  /// - For production use, consider additional security measures
  ///
  /// ## Examples
  /// ```dart
  /// final unsafe = "# Title\n<script>alert('xss')</script>";
  /// final safe = MarkdownUtils.sanitizeMarkdown(unsafe);
  /// // Result: "# Title\n"
  /// ```
  ///
  /// ## Limitations
  /// This is basic sanitization. For comprehensive security, consider:
  /// - HTML sanitization libraries
  /// - Content validation on the server side
  /// - CSP (Content Security Policy) headers
  static String sanitizeMarkdown(String content) {
    // Handle edge cases
    if (content.isEmpty) return content;

    try {
      // Remove potentially dangerous HTML tags that might be in markdown
      // This is a basic sanitization - in production, consider using a proper sanitizer
      return content
          .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<object[^>]*(?:>.*?</object>|/?>)', caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'<embed[^>]*(?:>.*?</embed>|/?>)', caseSensitive: false),
            '',
          );
    } catch (e) {
      // Return original content if sanitization fails
      return content;
    }
  }

  /// Extracts plain text from markdown content for accessibility.
  ///
  /// This method strips markdown syntax while preserving the readable text
  /// content. It's useful for accessibility features, search indexing, and
  /// plain text fallbacks.
  ///
  /// ## Parameters
  /// - [markdownContent]: The markdown content to convert
  ///
  /// ## Returns
  /// Plain text with markdown syntax removed
  ///
  /// ## Examples
  /// ```dart
  /// final markdown = "# Header\n\n**Bold** and *italic* text";
  /// final plain = MarkdownUtils.extractPlainText(markdown);
  /// // Result: "Header\n\nBold and italic text"
  /// ```
  ///
  /// ## Processed Elements
  /// - Headers: Removes `#` symbols
  /// - Formatting: Removes `**`, `*`, `__`, `_` markers
  /// - Code: Removes backticks and code block markers
  /// - Links: Keeps link text, removes URLs
  /// - Images: Keeps alt text, removes image syntax
  /// - Lists: Removes bullet points and numbering
  /// - Blockquotes: Removes `>` markers
  ///
  /// ## Error Handling
  /// Returns the original content if text extraction fails
  static String extractPlainText(String markdownContent) {
    // Handle edge cases
    if (markdownContent.isEmpty) return markdownContent;

    try {
      // Remove markdown syntax and return plain text
      return markdownContent
          .replaceAll(_headerExtractPattern, '') // Headers
          .replaceAllMapped(
            _boldExtractPattern1,
            (match) => match.group(1) ?? '',
          ) // Bold
          .replaceAllMapped(
            _boldExtractPattern2,
            (match) => match.group(1) ?? '',
          ) // Bold alternative
          .replaceAllMapped(
            _italicExtractPattern1,
            (match) => match.group(1) ?? '',
          ) // Italic
          .replaceAllMapped(
            _italicExtractPattern2,
            (match) => match.group(1) ?? '',
          ) // Italic alternative
          .replaceAllMapped(
            _inlineCodeExtractPattern,
            (match) => match.group(1) ?? '',
          ) // Inline code
          .replaceAll(_codeBlockExtractPattern, '') // Code blocks
          .replaceAllMapped(
            _imageExtractPattern,
            (match) => match.group(1) ?? '',
          ) // Images
          .replaceAllMapped(
            _linkExtractPattern,
            (match) => match.group(1) ?? '',
          ) // Links
          .replaceAllMapped(
            _unorderedListExtractPattern,
            (match) => '',
          ) // Unordered lists
          .replaceAllMapped(
            _orderedListExtractPattern,
            (match) => '',
          ) // Ordered lists
          .replaceAllMapped(
            _blockquoteExtractPattern,
            (match) => '\n',
          ) // Blockquotes
          .trim();
    } catch (e) {
      // Return original content if extraction fails
      return markdownContent;
    }
  }
}

/// ## Best Practices
///
/// ### Content Validation
/// Always validate content before rendering:
/// ```dart
/// String safeContent = MarkdownUtils.sanitizeMarkdown(userInput);
/// if (MarkdownUtils.isMarkdownContent(safeContent)) {
///   // Render as markdown
/// } else {
///   // Render as plain text
/// }
/// ```
///
/// ### Error Handling
/// Wrap markdown rendering in try-catch blocks:
/// ```dart
/// try {
///   final styleSheet = MarkdownUtils.createMarkdownStyleSheet(context);
///   return MarkdownBody(data: content, styleSheet: styleSheet);
/// } catch (e) {
///   return SelectableText(content); // Fallback
/// }
/// ```
///
/// ### Performance Considerations
/// - Cache style sheets when possible
/// - Use [isMarkdownContent] to avoid unnecessary processing
/// - Consider lazy loading for long content
///
/// ### Accessibility
/// - Use [extractPlainText] for screen readers
/// - Ensure sufficient color contrast in custom themes
/// - Maintain text selection capabilities
///
/// ### Security
/// - Always sanitize user-generated content
/// - Validate URLs before launching
/// - Consider server-side validation for critical applications
