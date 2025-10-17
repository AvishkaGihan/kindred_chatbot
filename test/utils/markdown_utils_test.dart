import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/utils/markdown_utils.dart';

void main() {
  group('MarkdownUtils', () {
    group('isMarkdownContent', () {
      test('returns false for empty content', () {
        expect(MarkdownUtils.isMarkdownContent(''), false);
      });

      test('returns false for plain text', () {
        expect(MarkdownUtils.isMarkdownContent('Hello world'), false);
        expect(
          MarkdownUtils.isMarkdownContent('This is a normal message.'),
          false,
        );
      });

      test('detects headers', () {
        expect(MarkdownUtils.isMarkdownContent('# Header'), true);
        expect(MarkdownUtils.isMarkdownContent('## Subheader'), true);
        expect(MarkdownUtils.isMarkdownContent('### H3'), true);
        expect(MarkdownUtils.isMarkdownContent('#### H4'), true);
        expect(MarkdownUtils.isMarkdownContent('##### H5'), true);
        expect(MarkdownUtils.isMarkdownContent('###### H6'), true);
      });

      test('detects bold text', () {
        expect(MarkdownUtils.isMarkdownContent('**bold text**'), true);
        expect(MarkdownUtils.isMarkdownContent('__bold text__'), true);
      });

      test('detects italic text', () {
        expect(MarkdownUtils.isMarkdownContent('*italic text*'), true);
        expect(MarkdownUtils.isMarkdownContent('_italic text_'), true);
      });

      test('detects code blocks', () {
        expect(
          MarkdownUtils.isMarkdownContent('```\nprint("hello")\n```'),
          true,
        );
        expect(
          MarkdownUtils.isMarkdownContent('```dart\nvoid main() {}\n```'),
          true,
        );
      });

      test('detects inline code', () {
        expect(MarkdownUtils.isMarkdownContent('Use `print()` function'), true);
        expect(MarkdownUtils.isMarkdownContent('The `main` function'), true);
      });

      test('detects lists', () {
        expect(MarkdownUtils.isMarkdownContent('- Item 1\n- Item 2'), true);
        expect(MarkdownUtils.isMarkdownContent('* Item 1\n* Item 2'), true);
        expect(MarkdownUtils.isMarkdownContent('+ Item 1\n+ Item 2'), true);
        expect(MarkdownUtils.isMarkdownContent('1. First\n2. Second'), true);
      });

      test('detects links', () {
        expect(
          MarkdownUtils.isMarkdownContent('[Google](https://google.com)'),
          true,
        );
        expect(MarkdownUtils.isMarkdownContent('[Link](url)'), true);
      });

      test('detects images', () {
        expect(MarkdownUtils.isMarkdownContent('![Alt](image.jpg)'), true);
        expect(
          MarkdownUtils.isMarkdownContent(
            '![Image](https://example.com/img.png)',
          ),
          true,
        );
      });

      test('detects blockquotes', () {
        expect(MarkdownUtils.isMarkdownContent('> This is a quote'), true);
        expect(MarkdownUtils.isMarkdownContent('>> Nested quote'), true);
      });

      test('detects horizontal rules', () {
        expect(MarkdownUtils.isMarkdownContent('---'), true);
        expect(MarkdownUtils.isMarkdownContent('***'), true);
        expect(MarkdownUtils.isMarkdownContent('___'), true);
      });

      test('handles mixed content', () {
        expect(
          MarkdownUtils.isMarkdownContent(
            '# Title\n\n**Bold** and *italic* text.\n\n- List item\n- Another item\n\n```dart\ncode block\n```',
          ),
          true,
        );
      });
    });

    group('sanitizeMarkdown', () {
      test('removes script tags', () {
        const input = 'Hello <script>alert("xss")</script> world';
        const expected = 'Hello  world';
        expect(MarkdownUtils.sanitizeMarkdown(input), expected);
      });

      test('removes iframe tags', () {
        const input = 'Content <iframe src="evil.com"></iframe> more content';
        const expected = 'Content  more content';
        expect(MarkdownUtils.sanitizeMarkdown(input), expected);
      });

      test('removes object tags', () {
        const input = 'Text <object data="malicious.swf"></object> end';
        const expected = 'Text  end';
        expect(MarkdownUtils.sanitizeMarkdown(input), expected);
      });

      test('removes embed tags', () {
        const input = 'Start <embed src="bad.exe"> end';
        const expected = 'Start  end';
        expect(MarkdownUtils.sanitizeMarkdown(input), expected);
      });

      test('preserves normal markdown', () {
        const input = '# Header\n\n**bold** and *italic* text\n\n- List item';
        expect(MarkdownUtils.sanitizeMarkdown(input), input);
      });
    });

    group('extractPlainText', () {
      test('removes headers', () {
        expect(MarkdownUtils.extractPlainText('# Header'), 'Header');
        expect(MarkdownUtils.extractPlainText('## Subheader'), 'Subheader');
      });

      test('removes bold formatting', () {
        expect(MarkdownUtils.extractPlainText('**bold**'), 'bold');
        expect(MarkdownUtils.extractPlainText('__bold__'), 'bold');
      });

      test('removes italic formatting', () {
        expect(MarkdownUtils.extractPlainText('*italic*'), 'italic');
        expect(MarkdownUtils.extractPlainText('_italic_'), 'italic');
      });

      test('removes inline code', () {
        expect(
          MarkdownUtils.extractPlainText('Use `print()` function'),
          'Use print() function',
        );
      });

      test('removes code blocks', () {
        const input = 'Text\n```\ncode block\n```\nmore text';
        expect(MarkdownUtils.extractPlainText(input), 'Text\n\nmore text');
      });

      test('removes links', () {
        expect(
          MarkdownUtils.extractPlainText('[Google](https://google.com)'),
          'Google',
        );
      });

      test('removes images', () {
        expect(MarkdownUtils.extractPlainText('![Alt](image.jpg)'), 'Alt');
      });

      test('removes list markers', () {
        const input = '- Item 1\n- Item 2\n1. Numbered item';
        expect(
          MarkdownUtils.extractPlainText(input),
          'Item 1\nItem 2\nNumbered item',
        );
      });

      test('removes blockquotes', () {
        expect(MarkdownUtils.extractPlainText('> Quote text'), 'Quote text');
      });

      test('handles complex markdown', () {
        const input =
            '# Title\n\nThis is **bold** and *italic* text.\n\n- List item 1\n- List item 2\n\n```dart\ncode here\n```\n\n> Quote\n\n[Link](url)';
        const expected =
            'Title\n\nThis is bold and italic text.\nList item 1\nList item 2\n\nQuote\n\nLink';
        expect(MarkdownUtils.extractPlainText(input), expected);
      });

      test('handles edge cases', () {
        // Empty content
        expect(MarkdownUtils.isMarkdownContent(''), false);
        expect(MarkdownUtils.extractPlainText(''), '');
        expect(MarkdownUtils.sanitizeMarkdown(''), '');

        // Whitespace only - extractPlainText trims, so expect trimmed result
        expect(MarkdownUtils.isMarkdownContent('   \n\t  '), false);
        expect(MarkdownUtils.extractPlainText('   \n\t  '), '');

        // Null-like content (should not crash)
        expect(MarkdownUtils.isMarkdownContent('null'), false);
        expect(MarkdownUtils.extractPlainText('null'), 'null');
      });

      test('handles malformed markdown gracefully', () {
        // Unclosed markdown elements should be left as-is (since regex only matches complete patterns)
        expect(
          MarkdownUtils.extractPlainText('**unclosed bold'),
          'unclosed bold',
        );
        expect(
          MarkdownUtils.extractPlainText('*unclosed italic'),
          '*unclosed italic',
        );
        expect(
          MarkdownUtils.extractPlainText('`unclosed code'),
          '`unclosed code',
        );
        expect(
          MarkdownUtils.extractPlainText('[incomplete link'),
          '[incomplete link',
        );
        expect(
          MarkdownUtils.extractPlainText('![incomplete image'),
          '![incomplete image',
        );
      });

      test('handles special characters', () {
        // Unicode and special characters should be preserved
        const specialText = 'Hello 🌟 with émojis and spëcial chärs!';
        expect(MarkdownUtils.extractPlainText(specialText), specialText);
        expect(MarkdownUtils.isMarkdownContent(specialText), false);
      });

      test('sanitization handles edge cases', () {
        // Malformed HTML should be handled gracefully
        expect(
          MarkdownUtils.sanitizeMarkdown('<script>'),
          '<script>',
        ); // Incomplete script tag
        expect(MarkdownUtils.sanitizeMarkdown('<incomplete'), '<incomplete');
        expect(
          MarkdownUtils.sanitizeMarkdown(
            '<script>alert(1)</script> normal text',
          ),
          ' normal text',
        );
      });
    });
  });
}
