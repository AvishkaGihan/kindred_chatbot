import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Log events
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logMessageSent() async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  Future<void> logVoiceInput() async {
    await _analytics.logEvent(name: 'voice_input_used');
  }

  Future<void> logChatSessionCreated() async {
    await _analytics.logEvent(name: 'chat_session_created');
  }

  // Set user properties
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Crash reporting
  Future<void> recordError(dynamic error, StackTrace? stack) async {
    await _crashlytics.recordError(error, stack);
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}
