import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logging/logging.dart';
import '../utils/constants.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  double _currentSpeechRate = AppConstants.defaultSpeechRate;

  final Logger _logger = Logger('VoiceService');

  // Initialize services
  Future<void> initialize({double? speechRate}) async {
    if (_isInitialized) return;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => _logger.severe('Speech recognition error: $error'),
        onStatus: (status) =>
            _logger.info('Speech recognition status: $status'),
      );

      _currentSpeechRate = speechRate ?? AppConstants.defaultSpeechRate;
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(_currentSpeechRate);
      await _tts.setVolume(AppConstants.speechVolume);
      await _tts.setPitch(AppConstants.speechPitch);
    } catch (e) {
      _logger.severe('Voice service initialization error: $e');
    }
  }

  // Update speech rate
  Future<void> updateSpeechRate(double rate) async {
    _currentSpeechRate = rate;
    await _tts.setSpeechRate(rate);
    _logger.info('Speech rate updated: $rate');
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
        listenFor: AppConstants.voiceListenTimeout,
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      _logger.severe('Start listening error: $e');
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
      _logger.severe('Text-to-speech error: $e');
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
