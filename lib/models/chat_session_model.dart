class ChatSessionModel {
  final String id;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String title;

  ChatSessionModel({
    required this.id,
    required this.createdAt,
    required this.lastUpdated,
    required this.title,
  });

  factory ChatSessionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatSessionModel(
      id: id,
      createdAt: DateTime.parse(data['createdAt']),
      lastUpdated: DateTime.parse(data['lastUpdated']),
      title: data['title'] ?? 'New Chat',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'title': title,
    };
  }
}
