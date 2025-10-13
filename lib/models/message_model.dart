class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final bool isVoiceMessage;
  final String? audioUrl; // For stored voice messages

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.type,
    this.isVoiceMessage = false,
    this.audioUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.index,
      'isVoiceMessage': isVoiceMessage,
      'audioUrl': audioUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      senderId: map['senderId'],
      text: map['text'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      type: MessageType.values[map['type']],
      isVoiceMessage: map['isVoiceMessage'] ?? false,
      audioUrl: map['audioUrl'],
    );
  }
}

enum MessageType { user, bot }
