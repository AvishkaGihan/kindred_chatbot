import 'package:flutter/material.dart';
import 'version_config.dart';

class AppConstants {
  // App Info
  static const String appName = 'Kindred';
  static String get appVersion => VersionConfig.appVersion;
  static int get buildNumber => VersionConfig.buildNumber;
  static String get fullVersion => VersionConfig.fullVersion;

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

  // Default Settings Values
  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const bool defaultTTSEnabled = true;
  static const double defaultSpeechRate = 0.5;
  static const double minSpeechRate = 0.3;
  static const double maxSpeechRate = 1.0;
  static const int defaultMaxMessages = 50;
}
