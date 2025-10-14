enum MessageType { user, ai, system }

class MessageModel {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isError;

  MessageModel({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isError = false,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(data['timestamp']),
      isError: data['isError'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }
}
