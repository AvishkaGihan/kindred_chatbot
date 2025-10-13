import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../models/message_model.dart';
import '../models/chat_session_model.dart';
import 'auth_provider.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final AuthProvider _authProvider;
  List<MessageModel> _messages = [];
  List<ChatSession> _chatSessions = [];
  bool _isProcessing = false;
  bool _isInitialLoading = true;
  String? _currentSessionId;

  List<MessageModel> get messages => _messages;
  List<ChatSession> get chatSessions => _chatSessions;
  bool get isProcessing => _isProcessing;
  bool get isInitialLoading => _isInitialLoading;
  String? get currentSessionId => _currentSessionId;

  // Stream for current session messages
  Stream<List<MessageModel>> get messagesStream {
    return _chatService.getMessages(
      _authProvider.user?.uid ?? '',
      sessionId: _currentSessionId,
    );
  }

  // Stream for chat sessions
  Stream<List<ChatSession>> get chatSessionsStream {
    return _chatService.getChatSessions(_authProvider.user?.uid ?? '');
  }

  ChatProvider(this._authProvider) {
    // Listen to messages stream
    messagesStream.listen((messages) {
      _messages = messages;
      _isInitialLoading = false;
      notifyListeners();
    });

    // Listen to chat sessions stream
    chatSessionsStream.listen((sessions) {
      _chatSessions = sessions;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _authProvider.user?.uid ?? 'user',
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.user,
    );

    _isProcessing = true;
    notifyListeners();

    try {
      // Save user message
      await _chatService.saveUserMessage(
        userMessage,
        _authProvider.user?.uid ?? '',
      );

      // Get AI response
      await _chatService.getAIResponse(text, _authProvider.user?.uid ?? '');
    } catch (e) {
      debugPrint('Send message error: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> createNewChatSession() async {
    try {
      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await _chatService.createNewChatSession(
        _authProvider.user?.uid ?? '',
        sessionId,
      );
      _currentSessionId = sessionId;
      notifyListeners();
    } catch (e) {
      debugPrint('Create new chat session error: $e');
      rethrow;
    }
  }

  Future<void> switchChatSession(String sessionId) async {
    try {
      await _chatService.switchChatSession(
        _authProvider.user?.uid ?? '',
        sessionId,
      );
      _currentSessionId = sessionId;
      notifyListeners();
    } catch (e) {
      debugPrint('Switch chat session error: $e');
      rethrow;
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _chatService.deleteChatSession(
        _authProvider.user?.uid ?? '',
        sessionId,
      );
      // If we deleted the current session, create a new one
      if (_currentSessionId == sessionId) {
        await createNewChatSession();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Delete chat session error: $e');
      rethrow;
    }
  }

  void clearCurrentChat() {
    _messages.clear();
    notifyListeners();
  }
}
