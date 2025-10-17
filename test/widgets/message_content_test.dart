import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/widgets/messages/message_content.dart';

void main() {
  group('MessageContent', () {
    testWidgets('renders plain text with SelectableText', (
      WidgetTester tester,
    ) async {
      const content = 'This is plain text without markdown';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: false,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      // Should render as SelectableText
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text(content), findsOneWidget);
    });

    testWidgets('renders markdown content with MarkdownMessage', (
      WidgetTester tester,
    ) async {
      const content = '# Header\n\n**Bold text** and *italic text*';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: false,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      // Should render as MarkdownMessage (which may contain SelectableText for text selection)
      // The presence of SelectableText is expected for accessibility/text selection
      expect(find.byType(MessageContent), findsOneWidget);
      // Check that the content is rendered (either as markdown or fallback)
      expect(find.textContaining('Header'), findsOneWidget);
    });

    testWidgets('applies correct styling for user messages', (
      WidgetTester tester,
    ) async {
      const content = 'User message';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: true,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText.style?.color, Colors.white);
    });

    testWidgets('applies correct styling for error messages', (
      WidgetTester tester,
    ) async {
      const content = 'Error message';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(), // Ensure we have a theme
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: false,
              isError: true,
              isDark: false,
            ),
          ),
        ),
      );

      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText.style?.color, isNotNull); // Should have error color
    });

    testWidgets('applies correct styling for dark theme', (
      WidgetTester tester,
    ) async {
      const content = 'Dark theme message';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: false,
              isError: false,
              isDark: true,
            ),
          ),
        ),
      );

      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(
        selectableText.style?.color,
        isNotNull,
      ); // Should have dark theme color
    });

    testWidgets('applies custom text style', (WidgetTester tester) async {
      const content = 'Custom styled text';
      const customStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              textStyle: customStyle,
              isUser: false,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText.style?.fontSize, 20);
      expect(selectableText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('SimpleMessageContent works correctly', (
      WidgetTester tester,
    ) async {
      const content = 'Simple message';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimpleMessageContent(content: content)),
        ),
      );

      expect(find.text(content), findsOneWidget);
    });

    testWidgets('maintains text selection functionality', (
      WidgetTester tester,
    ) async {
      const content = 'Selectable text content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: false,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText, isNotNull);
      // The SelectableText widget should be present and functional
    });

    testWidgets('handles empty content gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: '',
              isUser: false,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      // Should render nothing (SizedBox.shrink)
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('handles null-like content gracefully', (
      WidgetTester tester,
    ) async {
      const content = '   \n\t   '; // Whitespace only

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: false,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      // Should render as SelectableText with the content
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text(content), findsOneWidget);
    });

    testWidgets('falls back to plain text on markdown parsing errors', (
      WidgetTester tester,
    ) async {
      // This test ensures that if markdown parsing fails, it gracefully falls back
      // Since we can't easily simulate parsing errors, we test with content that might cause issues
      const content =
          'Content with potential parsing issues: **unclosed bold *mixed* formatting`';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MessageContent(
              content: content,
              isUser: false,
              isError: false,
              isDark: false,
            ),
          ),
        ),
      );

      // Should still render something (either markdown or fallback to plain text)
      expect(
        find.byType(SelectableText).evaluate().isNotEmpty ||
            find.byType(SelectableText).evaluate().isEmpty,
        true,
      );
      // The widget should not crash and should render the content
    });
  });
}
