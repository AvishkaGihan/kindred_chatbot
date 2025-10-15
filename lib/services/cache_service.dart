import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logging/logging.dart';
import '../models/message_model.dart';

class CacheService {
  static const String _messagesKey = 'cached_messages_';
  static const String _lastSyncKey = 'last_sync_';
  static final Logger _logger = Logger('CacheService');

  // Save messages to local cache
  Future<void> cacheMessages(
    String sessionId,
    List<MessageModel> messages,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((m) => m.toFirestore()).toList();
      await prefs.setString(
        '$_messagesKey$sessionId',
        json.encode(messagesJson),
      );
      await prefs.setString(
        '$_lastSyncKey$sessionId',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      _logger.severe('Cache save error: $e');
    }
  }

  // Load messages from cache
  Future<List<MessageModel>?> getCachedMessages(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString('$_messagesKey$sessionId');

      if (messagesString == null) return null;

      final List<dynamic> messagesJson = json.decode(messagesString);
      return messagesJson
          .map((json) => MessageModel.fromFirestore(json))
          .toList();
    } catch (e) {
      _logger.severe('Cache load error: $e');
      return null;
    }
  }

  // Clear cache for session
  Future<void> clearCache(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_messagesKey$sessionId');
      await prefs.remove('$_lastSyncKey$sessionId');
    } catch (e) {
      _logger.severe('Cache clear error: $e');
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSync(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncString = prefs.getString('$_lastSyncKey$sessionId');

      if (syncString == null) return null;
      return DateTime.parse(syncString);
    } catch (e) {
      _logger.severe('Last sync error: $e');
      return null;
    }
  }
}
