import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/chat_session_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentSessionId;

  Future<String> getAIResponse(String userMessage, String userId) async {
    try {
      // Ensure we have a current session
      if (_currentSessionId == null) {
        await _ensureCurrentSession(userId);
      }

      final ai = firebase_ai.FirebaseAI.googleAI();
      final model = ai.generativeModel(
        model: 'gemini-2.5-flash-lite',
        generationConfig: firebase_ai.GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 512,
        ),
        safetySettings: [
          firebase_ai.SafetySetting(
            firebase_ai.HarmCategory.harassment,
            firebase_ai.HarmBlockThreshold.none,
            null,
          ),
          firebase_ai.SafetySetting(
            firebase_ai.HarmCategory.hateSpeech,
            firebase_ai.HarmBlockThreshold.none,
            null,
          ),
          firebase_ai.SafetySetting(
            firebase_ai.HarmCategory.sexuallyExplicit,
            firebase_ai.HarmBlockThreshold.none,
            null,
          ),
          firebase_ai.SafetySetting(
            firebase_ai.HarmCategory.dangerousContent,
            firebase_ai.HarmBlockThreshold.none,
            null,
          ),
        ],
      );

      // The generateContent API expects content roles of 'user' or 'model'.
      // Using `Content.system` produces a 'system' role which is rejected by
      // the Google AI backend. Convert the system instruction into a
      // 'model' role Content by wrapping the instruction in a TextPart.
      final system = firebase_ai.Content.model([
        firebase_ai.TextPart(
          'You are Kindred, a friendly helpful assistant. Reply concisely.',
        ),
      ]);
      final user = firebase_ai.Content.text(userMessage);

      final response = await model.generateContent([system, user]);
      final text = response.text?.trim();

      final finalText = (text == null || text.isEmpty)
          ? "I'm having trouble responding right now. Please try again."
          : text;

      // Save bot response to Firestore
      await _saveMessage(
        MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'bot',
          text: finalText,
          timestamp: DateTime.now(),
          type: MessageType.bot,
        ),
        userId,
        _currentSessionId!,
      );

      // Update session last activity and message count
      await _updateSessionActivity(userId, _currentSessionId!);

      return finalText;
    } catch (e) {
      debugPrint('AI Response error: $e');
      return "I'm having trouble responding right now. Please try again.";
    }
  }

  Future<void> _saveMessage(
    MessageModel message,
    String userId,
    String sessionId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      debugPrint('Save message error: $e');
      rethrow;
    }
  }

  Future<void> _ensureCurrentSession(String userId) async {
    if (_currentSessionId == null) {
      _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await createNewChatSession(userId, _currentSessionId!);
    }
  }

  Future<void> _updateSessionActivity(String userId, String sessionId) async {
    try {
      // Get current message count
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .get();

      // Update session activity
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .update({
            'lastActivity': DateTime.now().millisecondsSinceEpoch,
            'messageCount': messagesSnapshot.docs.length,
            'title': await _generateSessionTitle(userId, sessionId),
          });
    } catch (e) {
      debugPrint('Update session activity error: $e');
    }
  }

  Future<String> _generateSessionTitle(String userId, String sessionId) async {
    try {
      // Get first user message to generate a title
      final firstMessageSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .where('type', isEqualTo: MessageType.user.index)
          .orderBy('timestamp')
          .limit(1)
          .get();

      if (firstMessageSnapshot.docs.isNotEmpty) {
        final firstMessage = MessageModel.fromMap(
          firstMessageSnapshot.docs.first.data(),
        );
        // Use first few words of first message as title
        final words = firstMessage.text.split(' ');
        final title = words.length > 5
            ? '${words.take(5).join(' ')}...'
            : firstMessage.text;
        return title;
      }
    } catch (e) {
      debugPrint('Generate session title error: $e');
    }

    return 'New Chat';
  }

  // Get messages for current session
  Stream<List<MessageModel>> getMessages(String userId, {String? sessionId}) {
    final targetSessionId = sessionId ?? _currentSessionId;

    debugPrint('📖 Loading messages for session: $targetSessionId');

    if (targetSessionId == null) {
      debugPrint('⚠️ No session ID available, returning empty stream');
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .doc(targetSessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          debugPrint('📬 Received ${snapshot.docs.length} messages');
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
  }

  // Get all chat sessions for a user
  Stream<List<ChatSession>> getChatSessions(String userId) {
    debugPrint('📂 Loading chat sessions for user: $userId');

    if (userId.isEmpty) {
      debugPrint('⚠️ User ID is empty, returning empty stream');
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint('📋 Received ${snapshot.docs.length} chat sessions');
          return snapshot.docs.map((doc) {
            return ChatSession.fromMap(doc.data());
          }).toList();
        });
  }

  // Get chat history (for backward compatibility)
  Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .orderBy('lastActivity', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Get chat history error: $e');
      return [];
    }
  }

  Future<void> createNewChatSession(String userId, String sessionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .set({
            'sessionId': sessionId,
            'userId': userId,
            'title': 'New Chat',
            'lastActivity': DateTime.now().millisecondsSinceEpoch,
            'messageCount': 0,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          });

      _currentSessionId = sessionId;
    } catch (e) {
      debugPrint('Create chat session error: $e');
      rethrow;
    }
  }

  Future<void> switchChatSession(String userId, String sessionId) async {
    _currentSessionId = sessionId;
  }

  Future<void> deleteChatSession(String userId, String sessionId) async {
    try {
      // Delete all messages in the session first
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .get();

      // Delete each message
      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the session document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .delete();

      // If we're deleting the current session, clear it
      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
      }
    } catch (e) {
      debugPrint('Delete chat session error: $e');
      rethrow;
    }
  }

  Future<void> saveUserMessage(MessageModel message, String userId) async {
    debugPrint('💬 Saving user message: ${message.id} for user: $userId');
    await _ensureCurrentSession(userId);
    debugPrint('📝 Current session: $_currentSessionId');
    await _saveMessage(message, userId, _currentSessionId!);
    debugPrint('✅ Message saved successfully');
    await _updateSessionActivity(userId, _currentSessionId!);
    debugPrint('✅ Session activity updated');
  }

  Future<String?> getCurrentOrLatestSession(String userId) async {
    try {
      debugPrint('🔍 Searching for latest session for user: $userId');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .orderBy('lastActivity', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final sessionId = snapshot.docs.first.data()['sessionId'] as String?;
        debugPrint('✅ Found latest session: $sessionId');
        return sessionId;
      }

      debugPrint('⚠️ No sessions found for user');
      return null;
    } catch (e) {
      debugPrint('❌ Get current session error: $e');
      return null;
    }
  }

  void setCurrentSession(String sessionId) {
    _currentSessionId = sessionId;
  }

  String? getCurrentSessionId() => _currentSessionId;

  String? get currentSessionId => _currentSessionId;
}
