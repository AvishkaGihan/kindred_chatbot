import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/chat_session_model.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../services/voice_service.dart';
import '../services/cache_service.dart';
import '../services/analytics_service.dart';
import '../utils/helpers.dart';

class ChatProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final FirestoreService _firestoreService = FirestoreService();
  final VoiceService _voiceService = VoiceService();
  final CacheService _cacheService = CacheService();
  final AnalyticsService _analytics = AnalyticsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MessageModel> _messages = [];
  List<ChatSessionModel> _sessions = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isListening = false;
  String? _errorMessage;

  // Pagination support
  int _messageLimit = 50;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  // Settings
  bool _isTTSEnabled = true;
  double _speechRate = 0.5;

  List<MessageModel> get messages => _messages;
  List<ChatSessionModel> get sessions => _sessions;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Initialize chat provider
  Future<void> initialize(
    String userId, {
    double? speechRate,
    int? maxMessages,
  }) async {
    if (speechRate != null) {
      _speechRate = speechRate;
    }
    if (maxMessages != null) {
      _messageLimit = maxMessages;
    }
    await _voiceService.initialize(speechRate: _speechRate);
    await loadChatSessions(userId);
  }

  // Update settings
  void updateSettings({
    bool? ttsEnabled,
    double? speechRate,
    int? maxMessages,
  }) {
    if (ttsEnabled != null) {
      _isTTSEnabled = ttsEnabled;
    }
    if (speechRate != null) {
      _speechRate = speechRate;
      _voiceService.updateSpeechRate(speechRate);
    }
    if (maxMessages != null) {
      _messageLimit = maxMessages;
    }
    notifyListeners();
  }

  // Load chat sessions
  Future<void> loadChatSessions(String userId) async {
    _firestoreService.getChatSessionsStream(userId).listen((sessions) {
      _sessions = sessions;
      notifyListeners();
    });
  }

  // Create new chat session
  Future<void> createNewSession(String userId) async {
    try {
      _currentSessionId = await _firestoreService.createChatSession(userId);
      _messages = [];
      _hasMore = true;
      _lastDocument = null;
      _aiService.resetChat();
      await _analytics.logChatSessionCreated();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      await _analytics.recordError(e, StackTrace.current);
      notifyListeners();
    }
  }

  // Load chat session
  void loadChatSession(String userId, String sessionId) async {
    _currentSessionId = sessionId;
    _hasMore = true;
    _lastDocument = null;

    // Try to load from cache first
    final cachedMessages = await _cacheService.getCachedMessages(sessionId);
    if (cachedMessages != null) {
      _messages = cachedMessages;
      notifyListeners();
    }

    // Then load from Firestore
    _firestoreService.getMessagesStream(userId, sessionId).listen((messages) {
      _messages = messages;
      _cacheService.cacheMessages(sessionId, messages);
      notifyListeners();
    });
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages(String userId, String sessionId) async {
    if (!_hasMore || _isLoading) return;

    _setLoading(true);

    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(_messageLimit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        final newMessages = snapshot.docs
            .map(
              (doc) => MessageModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();

        _messages.insertAll(0, newMessages.reversed);
        notifyListeners();
      }

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      throw Exception('Failed to load more messages: $e');
    }
  }

  // Send message
  Future<void> sendMessage(String userId, String content) async {
    if (_currentSessionId == null) {
      await createNewSession(userId);
    }

    _setLoading(true);
    _errorMessage = null;

    // Create user message
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    // Add to local list
    _messages.add(userMessage);
    notifyListeners();

    try {
      // Save user message to Firestore
      await _firestoreService.saveMessage(
        userId,
        _currentSessionId!,
        userMessage,
      );

      // Log analytics
      await _analytics.logMessageSent();

      // Get AI response
      final aiResponse = await _aiService.sendMessageWithContext(
        content,
        _messages,
      );

      // Create AI message
      final aiMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      // Add to local list
      _messages.add(aiMessage);

      // Save AI message to Firestore
      await _firestoreService.saveMessage(
        userId,
        _currentSessionId!,
        aiMessage,
      );

      // Update chat title if this is the first message
      if (_messages.length == 2) {
        // First user message and first AI response
        final chatTitle = AppHelpers.generateChatTitle(content);
        await _firestoreService.updateChatSessionTitle(
          userId,
          _currentSessionId!,
          chatTitle,
        );
      }

      _setLoading(false);
    } catch (e) {
      // Create error message
      final errorMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error: ${e.toString()}',
        type: MessageType.system,
        timestamp: DateTime.now(),
        isError: true,
      );

      _messages.add(errorMessage);
      _errorMessage = e.toString();
      await _analytics.recordError(e, StackTrace.current);
      _setLoading(false);
      notifyListeners();
    }
  }

  // Start voice input
  Future<void> startVoiceInput(Function(String) onResult) async {
    _isListening = true;
    notifyListeners();

    await _analytics.logVoiceInput();

    await _voiceService.startListening(
      onResult: (text) {
        _isListening = false;
        notifyListeners();
        onResult(text);
      },
      onError: () {
        _isListening = false;
        _errorMessage = 'Voice input failed';
        notifyListeners();
      },
    );
  }

  // Stop voice input
  Future<void> stopVoiceInput() async {
    await _voiceService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  // Speak message
  Future<void> speakMessage(String text) async {
    if (_isTTSEnabled) {
      await _voiceService.speak(text);
    }
  }

  // Delete chat session
  Future<void> deleteSession(String userId, String sessionId) async {
    try {
      await _firestoreService.deleteChatSession(userId, sessionId);

      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
        _messages = [];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear all chat history
  Future<void> clearAllChatHistory(String userId) async {
    _setLoading(true);
    try {
      // Delete all sessions
      for (var session in _sessions) {
        await _firestoreService.deleteChatSession(userId, session.id);
      }

      // Clear local state
      _sessions = [];
      _messages = [];
      _currentSessionId = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear chat history: $e';
      await _analytics.recordError(e, StackTrace.current);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
