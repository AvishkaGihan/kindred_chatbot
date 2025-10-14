import 'package:flutter/foundation.dart';
import '../services/voice_service.dart';
import 'chat_provider.dart';

class VoiceProvider with ChangeNotifier {
  final VoiceService _voiceService = VoiceService();
  String _recognizedText = '';
  bool _isInitialized = false;
  bool _isProcessingVoice = false;

  String get recognizedText => _recognizedText;
  bool get isListening => _voiceService.isListening;
  bool get isInitialized => _isInitialized;
  bool get isProcessingVoice => _isProcessingVoice;

  VoiceProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isInitialized = await _voiceService.initializeSpeech();
    notifyListeners();
  }

  // Enhanced method that integrates with chat
  Future<void> startListeningWithChat(ChatProvider chatProvider) async {
    if (!_isInitialized) {
      debugPrint(
        'Speech recognition not initialized - attempting to initialize...',
      );
      await _initialize();
      if (!_isInitialized) {
        debugPrint('Failed to initialize speech recognition');
        return;
      }
    }

    if (_isProcessingVoice) {
      debugPrint('Voice processing already in progress');
      return;
    }

    try {
      _isProcessingVoice = true;
      notifyListeners();

      debugPrint('Starting voice listening...');

      // Start listening and get the result
      final String? result = await _voiceService.startListening();

      if (result != null && result.trim().isNotEmpty) {
        debugPrint('Voice recognized: "$result"');

        // Update the recognized text temporarily
        _recognizedText = result.trim();
        notifyListeners();

        // Wait a moment to show the recognized text
        await Future.delayed(const Duration(milliseconds: 500));

        // Automatically send the recognized text to chat
        await chatProvider.sendMessage(result.trim());

        // Clear the recognized text after sending
        _recognizedText = '';
        notifyListeners();

        debugPrint('Voice message sent to chat successfully');
      } else {
        debugPrint('No speech recognized or speech recognition failed/timeout');
        // Clear any partial recognized text
        _recognizedText = '';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error in voice listening: $e');
      _recognizedText = '';
      notifyListeners();
    } finally {
      _isProcessingVoice = false;
      notifyListeners();
    }
  }

  // Keep the original method for other use cases
  Future<void> startListening() async {
    if (!_isInitialized) return;

    final result = await _voiceService.startListening();
    if (result != null) {
      _recognizedText = result;
      notifyListeners();
    }
  }

  void stopListening() {
    _voiceService.stopListening();
    _isProcessingVoice = false;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _voiceService.speak(text);
    }
  }

  void stopSpeaking() {
    _voiceService.stopSpeaking();
  }

  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }
}
