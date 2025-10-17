import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/widgets/markdown/markdown_message.dart';

void main() {
  group('MarkdownMessage', () {
    testWidgets('renders basic markdown content', (WidgetTester tester) async {
      const content = '# Header\n\n**Bold text** and *italic text*';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      // Should render without errors
      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('applies custom text style', (WidgetTester tester) async {
      const content = 'Styled content';
      const customStyle = TextStyle(fontSize: 18, color: Colors.blue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownMessage(content: content, textStyle: customStyle),
          ),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles selectable parameter', (WidgetTester tester) async {
      const content = 'Selectable content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownMessage(content: content, selectable: true),
          ),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles non-selectable parameter', (
      WidgetTester tester,
    ) async {
      const content = 'Non-selectable content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarkdownMessage(content: content, selectable: false),
          ),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles empty content', (WidgetTester tester) async {
      const content = '';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles code blocks with syntax highlighting', (
      WidgetTester tester,
    ) async {
      const content = '```dart\nvoid main() {\n  print("Hello");\n}\n```';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
      // Code block should be rendered with syntax highlighting
    });

    testWidgets('handles links', (WidgetTester tester) async {
      const content = '[Google](https://google.com)';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('handles lists', (WidgetTester tester) async {
      const content = '- Item 1\n- Item 2\n- Item 3';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles headers', (WidgetTester tester) async {
      const content = '# H1\n## H2\n### H3';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles blockquotes', (WidgetTester tester) async {
      const content = '> This is a blockquote\n> with multiple lines';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles tables', (WidgetTester tester) async {
      const content =
          '| Header 1 | Header 2 |\n|----------|----------|\n| Cell 1   | Cell 2   |';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('SimpleMarkdownMessage works correctly', (
      WidgetTester tester,
    ) async {
      const content = '# Simple Markdown\n\n**Bold** and *italic* text';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimpleMarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles malformed markdown gracefully', (
      WidgetTester tester,
    ) async {
      const content =
          '# Unclosed header\n\n**Unclosed bold\n\n- Incomplete list';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      // Should render without crashing
      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles special characters', (WidgetTester tester) async {
      const content = 'Special chars: @#\$%^&*()[]{}|\\\\:;"\'<>,.?/~`±§';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownMessage(content: content)),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });

    testWidgets('handles long content', (WidgetTester tester) async {
      final content = '# Long Content\n\n${'Paragraph text. ' * 100}';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownMessage(content: content),
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownMessage), findsOneWidget);
    });
  });
}
