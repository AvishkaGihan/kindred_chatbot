import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  // Initialize services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );

      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      print('Voice service initialization error: $e');
    }
  }

  // Start listening
  Future<void> startListening({
    required Function(String) onResult,
    required Function() onError,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      onError();
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Start listening error: $e');
      onError();
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    await _speech.stop();
  }

  // Check if listening
  bool get isListening => _speech.isListening;

  // Speak text
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      print('Text-to-speech error: $e');
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // Check if available
  bool get isAvailable => _isInitialized;

  // Dispose
  Future<void> dispose() async {
    await _speech.stop();
    await _tts.stop();
  }
}
