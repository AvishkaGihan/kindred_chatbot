// models/chat_session_model.dart
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
    return ChatSession(
      sessionId: map['sessionId'],
      userId: map['userId'],
      title: map['title'],
      lastActivity: DateTime.fromMillisecondsSinceEpoch(map['lastActivity']),
      messageCount: map['messageCount'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
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
