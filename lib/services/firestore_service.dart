import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/chat_session_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save message to Firestore
  Future<void> saveMessage(
    String userId,
    String sessionId,
    MessageModel message,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(sessionId)
          .collection('messages')
          .doc(message.id)
          .set(message.toFirestore());

      // Update session last updated time
      await updateChatSession(userId, sessionId);
    } catch (e) {
      throw Exception('Failed to save message: $e');
    }
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessagesStream(
    String userId,
    String sessionId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // Create new chat session
  Future<String> createChatSession(String userId) async {
    try {
      final sessionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc();

      final session = ChatSessionModel(
        id: sessionRef.id,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        title: 'New Chat',
      );

      await sessionRef.set(session.toFirestore());
      return sessionRef.id;
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  // Update chat session
  Future<void> updateChatSession(String userId, String sessionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(sessionId)
          .update({'lastUpdated': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('Failed to update chat session: $e');
    }
  }

  // Get chat sessions
  Stream<List<ChatSessionModel>> getChatSessionsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatSessionModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Delete chat session
  Future<void> deleteChatSession(String userId, String sessionId) async {
    try {
      // Delete all messages in the session
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(sessionId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the session
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(sessionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete chat session: $e');
    }
  }
}
