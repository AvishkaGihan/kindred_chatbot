import 'package:firebase_ai/firebase_ai.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

class AIService {
  late final GenerativeModel _model;
  late ChatSession _chatSession;

  AIService() {
    // Initialize Firebase AI Gemini model
    final ai = FirebaseAI.googleAI();
    _model = ai.generativeModel(
      model: AppConstants.aiModel,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1000,
      ),
    );

    _chatSession = _model.startChat();
  }

  // Send message and get AI response
  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Firebase AI');
      }

      return text;
    } catch (e) {
      throw Exception('Firebase AI error: $e');
    }
  }

  // Send message with chat history
  Future<String> sendMessageWithContext(
    String message,
    List<MessageModel> history,
  ) async {
    try {
      final List<Content> historyContent = history.map((msg) {
        return Content.text(msg.content);
      }).toList();

      final session = _model.startChat(history: historyContent);

      final response = await session.sendMessage(Content.text(message));

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Firebase AI');
      }

      return text;
    } catch (e) {
      throw Exception('Firebase AI error: $e');
    }
  }

  // Reset chat session
  void resetChat() {
    _chatSession = _model.startChat();
  }
}
