import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/utils/accessibility/accessibility_utils.dart';

void main() {
  group('AccessibilityUtils Tests', () {
    testWidgets('ensureMinTouchTarget wraps widget with minimum size', (
      WidgetTester tester,
    ) async {
      // Create a small button
      final smallButton = Container(width: 20, height: 20, color: Colors.blue);

      // Wrap with accessibility helper
      final accessibleButton = AccessibilityUtils.ensureMinTouchTarget(
        child: smallButton,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: accessibleButton)),
      );

      // Find the SizedBox wrapper
      final sizedBox = find.byType(SizedBox);
      expect(sizedBox, findsOneWidget);

      // Verify minimum dimensions
      final widget = tester.widget<SizedBox>(sizedBox);
      expect(
        widget.width,
        greaterThanOrEqualTo(AccessibilityUtils.minTouchTargetSize),
      );
      expect(
        widget.height,
        greaterThanOrEqualTo(AccessibilityUtils.minTouchTargetSize),
      );
    });

    test('meetsMinTouchTarget returns correct values', () {
      expect(AccessibilityUtils.meetsMinTouchTarget(48, 48), true);
      expect(AccessibilityUtils.meetsMinTouchTarget(50, 50), true);
      expect(AccessibilityUtils.meetsMinTouchTarget(30, 48), false);
      expect(AccessibilityUtils.meetsMinTouchTarget(48, 30), false);
      expect(AccessibilityUtils.meetsMinTouchTarget(20, 20), false);
    });

    test('getContrastRatio calculates correctly', () {
      // Black on white should have high contrast
      final blackWhiteRatio = AccessibilityUtils.getContrastRatio(
        Colors.black,
        Colors.white,
      );
      expect(blackWhiteRatio, greaterThan(10.0)); // Should be 21:1

      // White on white should have no contrast
      final whiteWhiteRatio = AccessibilityUtils.getContrastRatio(
        Colors.white,
        Colors.white,
      );
      expect(whiteWhiteRatio, equals(1.0));
    });

    test('meetsWCAGAA returns correct values for contrast', () {
      // Black on white meets WCAG AA
      expect(AccessibilityUtils.meetsWCAGAA(Colors.black, Colors.white), true);

      // Light gray on white doesn't meet WCAG AA
      expect(
        AccessibilityUtils.meetsWCAGAA(Colors.grey.shade300, Colors.white),
        false,
      );
    });

    test('meetsWCAGAAA returns correct values for enhanced contrast', () {
      // Black on white meets WCAG AAA
      expect(AccessibilityUtils.meetsWCAGAAA(Colors.black, Colors.white), true);

      // Medium gray on white doesn't meet WCAG AAA
      expect(
        AccessibilityUtils.meetsWCAGAAA(Colors.grey.shade600, Colors.white),
        false,
      );
    });

    testWidgets('createAccessibleButton creates proper semantics', (
      WidgetTester tester,
    ) async {
      bool buttonPressed = false;

      final button = AccessibilityUtils.createAccessibleButton(
        semanticLabel: 'Test Button',
        semanticHint: 'Press to test',
        enabled: true,
        onPressed: () => buttonPressed = true,
        child: ElevatedButton(
          onPressed: () => buttonPressed = true,
          child: const Text('Press me'),
        ),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: button)));

      // Find the Semantics widget with the specific label
      final semantics = find.bySemanticsLabel('Test Button');
      expect(semantics, findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(buttonPressed, true);
    });

    testWidgets('createAccessibleTextField creates proper semantics', (
      WidgetTester tester,
    ) async {
      final textField = AccessibilityUtils.createAccessibleTextField(
        semanticLabel: 'Email Field',
        semanticHint: 'Enter your email address',
        child: const TextField(decoration: InputDecoration(hintText: 'Email')),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: textField)));

      // Find the Semantics widget with the specific label
      final semantics = find.bySemanticsLabel('Email Field');
      expect(semantics, findsOneWidget);

      // Find the TextField
      final field = find.byType(TextField);
      expect(field, findsOneWidget);
    });

    test('createSemanticLabel creates proper label', () {
      final label = AccessibilityUtils.createSemanticLabel(
        label: 'Submit',
        hint: 'Submit the form',
        value: '5 items',
      );

      expect(label.contains('Submit'), true);
      expect(label.contains('Submit the form'), true);
      expect(label.contains('5 items'), true);
    });

    testWidgets('getAnimationDuration respects reduce motion', (
      WidgetTester tester,
    ) async {
      Duration? normalDuration;
      Duration? reducedDuration;

      // Normal duration when reduce motion is false
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: false),
            child: Builder(
              builder: (context) {
                normalDuration = AccessibilityUtils.getAnimationDuration(
                  context,
                  const Duration(milliseconds: 300),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Reduced duration when reduce motion is true
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                reducedDuration = AccessibilityUtils.getAnimationDuration(
                  context,
                  const Duration(milliseconds: 300),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(normalDuration, equals(const Duration(milliseconds: 300)));
      expect(reducedDuration, equals(Duration.zero));
    });

    testWidgets('getAnimationCurve respects reduce motion', (
      WidgetTester tester,
    ) async {
      Curve? normalCurve;
      Curve? reducedCurve;

      // Normal curve when reduce motion is false
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: false),
            child: Builder(
              builder: (context) {
                normalCurve = AccessibilityUtils.getAnimationCurve(
                  context,
                  Curves.easeInOut,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Linear curve when reduce motion is true
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                reducedCurve = AccessibilityUtils.getAnimationCurve(
                  context,
                  Curves.easeInOut,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(normalCurve, equals(Curves.easeInOut));
      expect(reducedCurve, equals(Curves.linear));
    });
  });

  group('AccessibilityContextExtension Tests', () {
    testWidgets('reduceMotion returns MediaQuery value', (
      WidgetTester tester,
    ) async {
      bool? capturedReduceMotion;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                capturedReduceMotion = context.reduceMotion;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(capturedReduceMotion, true);
    });

    testWidgets('highContrast returns MediaQuery value', (
      WidgetTester tester,
    ) async {
      bool? capturedHighContrast;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: Builder(
              builder: (context) {
                capturedHighContrast = context.highContrast;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(capturedHighContrast, true);
    });
  });
}
