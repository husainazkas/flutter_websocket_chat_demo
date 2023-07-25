class Message {
  final String text;
  final int receiverId;
  final int senderId;
  final MessageStatus? status;
  final DateTime createdAt;

  const Message({
    required this.text,
    required this.receiverId,
    required this.senderId,
    this.status,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String,
      receiverId: json['receiver_id'] as int,
      senderId: json['sender_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'receiver_id': receiverId,
      'sender_id': senderId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Message copyWith({
    String? text,
    int? receiverId,
    int? senderId,
    MessageStatus? status,
    DateTime? createdAt,
  }) {
    return Message(
      text: text ?? this.text,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum MessageStatus { sending, success, failure }
