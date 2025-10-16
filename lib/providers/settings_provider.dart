import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _service = SettingsService();
  final Logger _logger = Logger('SettingsProvider');

  // Settings state
  ThemeMode _themeMode = AppConstants.defaultThemeMode;
  bool _isTTSEnabled = AppConstants.defaultTTSEnabled;
  double _speechRate = AppConstants.defaultSpeechRate;
  int _maxMessages = AppConstants.defaultMaxMessages;
  bool _isLoading = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isTTSEnabled => _isTTSEnabled;
  double get speechRate => _speechRate;
  int get maxMessages => _maxMessages;
  bool get isLoading => _isLoading;

  // Initialize settings from storage
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _themeMode = await _service.getThemeMode();
      _isTTSEnabled = await _service.getTTSEnabled();
      _speechRate = await _service.getSpeechRate();
      _maxMessages = await _service.getMaxMessages();
      _logger.info('Settings initialized successfully');
    } catch (e) {
      _logger.severe('Error initializing settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update theme mode
  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      await _service.setThemeMode(mode);
      _logger.info('Theme mode updated: ${mode.name}');
    } catch (e) {
      _logger.severe('Error updating theme mode: $e');
    }
  }

  // Update TTS enabled
  Future<void> updateTTSEnabled(bool enabled) async {
    _isTTSEnabled = enabled;
    notifyListeners();
    try {
      await _service.setTTSEnabled(enabled);
      _logger.info('TTS enabled updated: $enabled');
    } catch (e) {
      _logger.severe('Error updating TTS enabled: $e');
    }
  }

  // Update speech rate
  Future<void> updateSpeechRate(double rate) async {
    // Clamp to valid range
    final clampedRate = rate.clamp(
      AppConstants.minSpeechRate,
      AppConstants.maxSpeechRate,
    );
    _speechRate = clampedRate;
    notifyListeners();
    try {
      await _service.setSpeechRate(clampedRate);
      _logger.info('Speech rate updated: $clampedRate');
    } catch (e) {
      _logger.severe('Error updating speech rate: $e');
    }
  }

  // Update max messages
  Future<void> updateMaxMessages(int maxMessages) async {
    _maxMessages = maxMessages;
    notifyListeners();
    try {
      await _service.setMaxMessages(maxMessages);
      _logger.info('Max messages updated: $maxMessages');
    } catch (e) {
      _logger.severe('Error updating max messages: $e');
    }
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _setLoading(true);
    try {
      await _service.resetToDefaults();
      _themeMode = AppConstants.defaultThemeMode;
      _isTTSEnabled = AppConstants.defaultTTSEnabled;
      _speechRate = AppConstants.defaultSpeechRate;
      _maxMessages = AppConstants.defaultMaxMessages;
      notifyListeners();
      _logger.info('Settings reset to defaults');
    } catch (e) {
      _logger.severe('Error resetting settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    _setLoading(true);
    try {
      await _service.clearAllSettings();
      _themeMode = AppConstants.defaultThemeMode;
      _isTTSEnabled = AppConstants.defaultTTSEnabled;
      _speechRate = AppConstants.defaultSpeechRate;
      _maxMessages = AppConstants.defaultMaxMessages;
      notifyListeners();
      _logger.info('All settings cleared');
    } catch (e) {
      _logger.severe('Error clearing settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
