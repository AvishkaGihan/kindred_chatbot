import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/chat_session_model.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../services/voice_service.dart';
import '../services/cache_service.dart';
import '../utils/helpers.dart';

class ChatProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final FirestoreService _firestoreService = FirestoreService();
  final VoiceService _voiceService = VoiceService();
  final CacheService _cacheService = CacheService();

  List<MessageModel> _messages = [];
  List<ChatSessionModel> _sessions = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isListening = false;
  String? _errorMessage;

  List<MessageModel> get messages => _messages;
  List<ChatSessionModel> get sessions => _sessions;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String? get errorMessage => _errorMessage;

  // Initialize chat provider
  Future<void> initialize(String userId) async {
    await _voiceService.initialize();
    await loadChatSessions(userId);
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
      _aiService.resetChat();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load chat session
  void loadChatSession(String userId, String sessionId) async {
    _currentSessionId = sessionId;

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
      _setLoading(false);
      notifyListeners();
    }
  }

  // Start voice input
  Future<void> startVoiceInput(Function(String) onResult) async {
    _isListening = true;
    notifyListeners();

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
    await _voiceService.speak(text);
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
