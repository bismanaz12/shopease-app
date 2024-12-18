import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class ChatMessage {
  String id;
  String text;
  String name;
  bool type;
  String userId;
  DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.name,
    required this.type,
    required this.userId,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    text: json['text'],
    name: json['name'],
    type: json['type'],
    userId: json['userId'],
    timestamp: (json['timestamp'] as firestore.Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'name': name,
    'type': type,
    'userId': userId,
    'timestamp': firestore.Timestamp.fromDate(timestamp),
  };
}
