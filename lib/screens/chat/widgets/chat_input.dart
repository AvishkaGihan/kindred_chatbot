import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required Future<Null> Function(dynamic message) onSendMessage,
    required Future<Null> Function() onVoiceInput,
    required bool isListening,
    required bool isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
