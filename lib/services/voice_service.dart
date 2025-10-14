import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  String _lastResult = '';
  Completer<String?>? _listeningCompleter;
  String? _localeId;
  Timer? _completionTimer;

  Future<void> _loadSystemLocale() async {
    try {
      final systemLocale = await _speech.systemLocale();
      _localeId = systemLocale?.localeId;
      if (_localeId != null) {
        debugPrint('Using system speech locale: $_localeId');
      } else {
        debugPrint('System speech locale not available, defaulting to en_US');
        _localeId = 'en_US';
      }
    } catch (e) {
      debugPrint('Failed to get system speech locale: $e');
      _localeId = 'en_US';
    }
  }

  Future<bool> initializeSpeech() async {
    if (_speech.isAvailable) {
      debugPrint('Speech recognition already initialized');
      return true;
    }

    debugPrint('Initializing speech recognition...');
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'listening') {
          _isListening = true;
          return;
        }
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          // Debounce completion briefly to allow a trailing onResult(final)
          _scheduleCompletion(const Duration(milliseconds: 250));
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        _isListening = false;
        // If we had partial results before error, complete with them after a brief delay
        _scheduleCompletion(const Duration(milliseconds: 100));
      },
    );

    debugPrint('Speech recognition available: $available');
    if (!available) {
      debugPrint(
        'Speech recognition initialization failed. This might be due to:',
      );
      debugPrint('1. Running on an emulator without speech recognition');
      debugPrint('2. Microphone permissions not granted');
      debugPrint('3. Speech recognition service disabled on device');
    }
    if (available) {
      await _loadSystemLocale();
    }
    return available;
  }

  Future<String?> startListening() async {
    if (_isListening) {
      debugPrint('Already listening');
      return null;
    }

    // Check if speech recognition is available
    if (!_speech.isAvailable) {
      debugPrint('Speech recognition not available - reinitializing...');
      bool reinit = await _speech.initialize();
      if (!reinit) {
        debugPrint('Failed to reinitialize speech recognition');
        return null;
      }
      await _loadSystemLocale();
    }

    _lastResult = '';
    _listeningCompleter = Completer<String?>();

    try {
      // Ensure we have a locale to use
      _localeId ??= 'en_US';

      // Start listening - the listen method may return null, so we don't assign it
      await _speech.listen(
        onResult: (result) {
          debugPrint(
            'Speech result: "${result.recognizedWords}" (final: ${result.finalResult})',
          );
          // Always capture the latest recognized words (partial or final)
          if (result.recognizedWords.isNotEmpty) {
            _lastResult = result.recognizedWords;
          }

          // If engine provides a final result, complete immediately
          if (result.finalResult) {
            debugPrint('Final result: "$_lastResult"');
            _completionTimer?.cancel();
            _completeListening();
          }
        },
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(milliseconds: 2500),
        localeId: _localeId,
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );

      _isListening = true;
      debugPrint('Speech listening started successfully');

      // Wait for the listening to complete with shorter timeout
      return await _listeningCompleter!.future.timeout(
        const Duration(seconds: 18), // Slightly longer than listenFor
        onTimeout: () {
          debugPrint('Speech recognition timed out');
          stopListening();
          return null;
        },
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      _listeningCompleter?.complete(null);
      _listeningCompleter = null;
      return null;
    }
  }

  void _completeListening() {
    _completionTimer?.cancel();
    if (_listeningCompleter != null && !_listeningCompleter!.isCompleted) {
      final result = _lastResult.isNotEmpty ? _lastResult : null;
      _listeningCompleter!.complete(result);
      _listeningCompleter = null;
    }
  }

  void _scheduleCompletion([
    Duration delay = const Duration(milliseconds: 300),
  ]) {
    _completionTimer?.cancel();
    _completionTimer = Timer(delay, () {
      _completeListening();
    });
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      _completionTimer?.cancel();
      _completeListening();
      debugPrint('Speech listening stopped');
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
      debugPrint('Speaking: $text');
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    debugPrint('Speech stopped');
  }

  bool get isListening => _isListening;
}
