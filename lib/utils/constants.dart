class AppConstants {
  // App Info
  static const String appName = 'Kindred';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Firebase AI Model
  static const String aiModel = 'gemini-2.5-flash';

  // Message Limits
  static const int maxMessageLength = 1000;
  static const int maxHistoryMessages = 50;

  // Voice Settings
  static const double speechRate = 0.5;
  static const double speechVolume = 1.0;
  static const double speechPitch = 1.0;

  // Timeouts
  static const Duration aiResponseTimeout = Duration(seconds: 30);
  static const Duration voiceListenTimeout = Duration(seconds: 30);
}
