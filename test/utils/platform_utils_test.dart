import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/utils/platform/platform_utils.dart';

void main() {
  group('PlatformUtils Tests', () {
    testWidgets('getPlatformLoadingIndicator returns widget', (
      WidgetTester tester,
    ) async {
      final indicator = PlatformUtils.getPlatformLoadingIndicator();

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: indicator)));

      // Should find either CircularProgressIndicator or CupertinoActivityIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('getPlatformSwitch creates switch widget', (
      WidgetTester tester,
    ) async {
      bool value = false;

      final switchWidget = PlatformUtils.getPlatformSwitch(
        value: value,
        onChanged: (newValue) {
          value = newValue;
        },
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: switchWidget)));

      // Should find Switch widget
      expect(find.byType(Switch), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byType(Switch));
      await tester.pump();
    });

    testWidgets('getPlatformSlider creates slider widget', (
      WidgetTester tester,
    ) async {
      double value = 0.5;

      final sliderWidget = PlatformUtils.getPlatformSlider(
        value: value,
        onChanged: (newValue) {
          value = newValue;
        },
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: sliderWidget)));

      // Should find Slider widget
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('showPlatformDialog displays dialog', (
      WidgetTester tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await PlatformUtils.showPlatformDialog(
                      context: context,
                      title: 'Test Dialog',
                      content: 'This is a test',
                      confirmText: 'OK',
                      cancelText: 'Cancel',
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('This is a test'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify result
      expect(result, true);
    });

    testWidgets('showPlatformDialog cancel returns false', (
      WidgetTester tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await PlatformUtils.showPlatformDialog(
                      context: context,
                      title: 'Test',
                      content: 'Test',
                      confirmText: 'OK',
                      cancelText: 'Cancel',
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('createPlatformRoute creates MaterialPageRoute', (
      WidgetTester tester,
    ) async {
      final route = PlatformUtils.createPlatformRoute(
        builder: (context) => const Scaffold(body: Text('New Page')),
      );

      expect(route, isA<MaterialPageRoute>());
    });

    test('PlatformWidget returns correct builder', () {
      final widget = PlatformWidget(
        androidBuilder: (context) => const Text('Android'),
        iosBuilder: (context) => const Text('iOS'),
        fallbackBuilder: (context) => const Text('Fallback'),
      );

      expect(widget.androidBuilder, isNotNull);
      expect(widget.iosBuilder, isNotNull);
      expect(widget.fallbackBuilder, isNotNull);
    });
  });

  group('PlatformActionSheetAction Tests', () {
    test('creates action with all properties', () {
      final action = PlatformActionSheetAction(
        label: 'Delete',
        icon: Icons.delete,
        value: 'delete',
        isDestructive: true,
        onPressed: () {},
      );

      expect(action.label, 'Delete');
      expect(action.icon, Icons.delete);
      expect(action.value, 'delete');
      expect(action.isDestructive, true);
      expect(action.onPressed, isNotNull);
    });
  });
}
