// models/chat_session_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String sessionId;
  final String userId;
  final String title;
  final DateTime lastActivity;
  final int messageCount;
  final DateTime createdAt;

  ChatSession({
    required this.sessionId,
    required this.userId,
    required this.title,
    required this.lastActivity,
    required this.messageCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'title': title,
      'lastActivity': lastActivity.millisecondsSinceEpoch,
      'messageCount': messageCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    // Helper function to convert both Timestamp and int to DateTime
    DateTime convertToDateTime(dynamic value) {
      if (value is Timestamp) {
        // Old data format - Firestore Timestamp
        return value.toDate();
      } else if (value is int) {
        // New data format - milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        // Fallback to current time if something goes wrong
        return DateTime.now();
      }
    }

    return ChatSession(
      sessionId: map['sessionId'],
      userId: map['userId'],
      title: map['title'],
      lastActivity: convertToDateTime(map['lastActivity']),
      messageCount: map['messageCount'],
      createdAt: convertToDateTime(map['createdAt']),
    );
  }

  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastActivity.day}/${lastActivity.month}/${lastActivity.year}';
    }
  }
}
