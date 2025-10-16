import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/models/message_model.dart';
import 'package:kindred_chatbot/screens/chat/widgets/message_bubble.dart';

void main() {
  testWidgets('MessageBubble displays user message correctly', (
    WidgetTester tester,
  ) async {
    final message = MessageModel(
      id: '1',
      content: 'Test message',
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MessageBubble(message: message)),
      ),
    );

    expect(find.text('Test message'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('MessageBubble displays AI message correctly', (
    WidgetTester tester,
  ) async {
    final message = MessageModel(
      id: '1',
      content: 'AI response',
      type: MessageType.ai,
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MessageBubble(message: message)),
      ),
    );

    expect(find.text('AI response'), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy), findsOneWidget);
  });
}
