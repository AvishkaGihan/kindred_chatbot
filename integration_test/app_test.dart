import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kindred_chatbot/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('Complete user flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 3));

      // Should navigate to login screen
      expect(find.text('Welcome to Kindred'), findsOneWidget);

      // Try to sign in (note: this requires test credentials)
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should navigate to chat screen after successful login
      expect(find.text('Kindred'), findsOneWidget);
    });
  });
}
