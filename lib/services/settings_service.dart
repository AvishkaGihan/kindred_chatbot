import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../utils/constants.dart';

class SettingsService {
  static const String keyThemeMode = 'theme_mode';
  static const String keyTTSEnabled = 'tts_enabled';
  static const String keySpeechRate = 'speech_rate';
  static const String keyMaxMessages = 'max_messages';

  final Logger _logger = Logger('SettingsService');

  // Get theme mode
  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(keyThemeMode) ?? 'system';
      return ThemeMode.values.firstWhere(
        (mode) => mode.name == value,
        orElse: () => AppConstants.defaultThemeMode,
      );
    } catch (e) {
      _logger.severe('Error getting theme mode: $e');
      return AppConstants.defaultThemeMode;
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyThemeMode, mode.name);
      _logger.info('Theme mode saved: ${mode.name}');
    } catch (e) {
      _logger.severe('Error saving theme mode: $e');
    }
  }

  // Get TTS enabled status
  Future<bool> getTTSEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyTTSEnabled) ?? AppConstants.defaultTTSEnabled;
    } catch (e) {
      _logger.severe('Error getting TTS enabled: $e');
      return AppConstants.defaultTTSEnabled;
    }
  }

  // Set TTS enabled status
  Future<void> setTTSEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyTTSEnabled, enabled);
      _logger.info('TTS enabled saved: $enabled');
    } catch (e) {
      _logger.severe('Error saving TTS enabled: $e');
    }
  }

  // Get speech rate
  Future<double> getSpeechRate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rate =
          prefs.getDouble(keySpeechRate) ?? AppConstants.defaultSpeechRate;
      // Ensure rate is within valid range
      return rate.clamp(AppConstants.minSpeechRate, AppConstants.maxSpeechRate);
    } catch (e) {
      _logger.severe('Error getting speech rate: $e');
      return AppConstants.defaultSpeechRate;
    }
  }

  // Set speech rate
  Future<void> setSpeechRate(double rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clamp to valid range
      final clampedRate = rate.clamp(
        AppConstants.minSpeechRate,
        AppConstants.maxSpeechRate,
      );
      await prefs.setDouble(keySpeechRate, clampedRate);
      _logger.info('Speech rate saved: $clampedRate');
    } catch (e) {
      _logger.severe('Error saving speech rate: $e');
    }
  }

  // Get max messages
  Future<int> getMaxMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(keyMaxMessages) ?? AppConstants.defaultMaxMessages;
    } catch (e) {
      _logger.severe('Error getting max messages: $e');
      return AppConstants.defaultMaxMessages;
    }
  }

  // Set max messages
  Future<void> setMaxMessages(int maxMessages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyMaxMessages, maxMessages);
      _logger.info('Max messages saved: $maxMessages');
    } catch (e) {
      _logger.severe('Error saving max messages: $e');
    }
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      await setThemeMode(AppConstants.defaultThemeMode);
      await setTTSEnabled(AppConstants.defaultTTSEnabled);
      await setSpeechRate(AppConstants.defaultSpeechRate);
      await setMaxMessages(AppConstants.defaultMaxMessages);
      _logger.info('All settings reset to defaults');
    } catch (e) {
      _logger.severe('Error resetting settings: $e');
    }
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyThemeMode);
      await prefs.remove(keyTTSEnabled);
      await prefs.remove(keySpeechRate);
      await prefs.remove(keyMaxMessages);
      _logger.info('All settings cleared');
    } catch (e) {
      _logger.severe('Error clearing settings: $e');
    }
  }
}
