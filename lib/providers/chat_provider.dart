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

  String? _lastError;
  String? get lastError => _lastError;

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

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
    // Listen to auth state changes and initialize session when user logs in
    _authProvider.addListener(_onAuthStateChanged);

    // Initialize session if user is already logged in
    if (_authProvider.user != null) {
      initializeChatSession();
    }

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

  void _onAuthStateChanged() {
    // When user logs in, initialize the chat session
    if (_authProvider.user != null && _currentSessionId == null) {
      initializeChatSession();
    }
    // When user logs out, clear the session
    else if (_authProvider.user == null) {
      _currentSessionId = null;
      _messages.clear();
      _chatSessions.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _lastError = null; // Clear previous errors

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
      _lastError = 'Failed to send message. Please try again.';
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
      // ✅ Ensure service is also updated
      _chatService.setCurrentSession(sessionId);
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
      // ✅ Ensure service is also updated
      _chatService.setCurrentSession(sessionId);
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

  Future<void> initializeChatSession() async {
    try {
      final userId = _authProvider.user?.uid;
      debugPrint('🔄 Initializing chat session for user: $userId');

      if (userId == null) {
        debugPrint('⚠️ User ID is null, skipping session initialization');
        return;
      }

      // Try to load existing session
      final existingSessionId = await _chatService.getCurrentOrLatestSession(
        userId,
      );

      debugPrint('📌 Existing session ID: $existingSessionId');

      if (existingSessionId != null) {
        _currentSessionId = existingSessionId;
        _chatService.setCurrentSession(existingSessionId);
        debugPrint('✅ Loaded existing session: $existingSessionId');
      } else {
        // No existing sessions, create new one
        debugPrint('🆕 No existing sessions, creating new one');
        await createNewChatSession();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Initialize chat session error: $e');
      // Create new session as fallback
      await createNewChatSession();
    }
  }

  void clearCurrentChat() {
    _messages.clear();
    notifyListeners();
  }
}
