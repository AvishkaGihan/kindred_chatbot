import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  String _lastResult = '';

  Future<bool> initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done') {
          _isListening = false;
        }
      },
      onError: (error) {
        debugPrint('Speech error: $error');
        _isListening = false;
      },
    );
    return available;
  }

  Future<String?> startListening() async {
    if (_isListening) {
      debugPrint('Already listening');
      return null;
    }

    _lastResult = '';

    bool started = await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastResult = result.recognizedWords;
          debugPrint('Final result: $_lastResult');
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      localeId: 'en_US',
    );

    if (started) {
      _isListening = true;
      debugPrint('Speech listening started');

      // Wait for the listening to complete and return the result
      await Future.delayed(Duration(seconds: 30));
      return _lastResult.isNotEmpty ? _lastResult : null;
    }

    return null;
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
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
