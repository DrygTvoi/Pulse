import 'message.dart';
import 'contact.dart';

class ChatRoom {
  final String id;
  final Contact contact;
  final List<Message> messages;
  final String adapterType; // Preferred adapter for this chat, e.g., 'github'
  final Map<String, dynamic> adapterConfig; // E.g., {'repo': 'user/repo', 'sheetId': '...'}
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.contact,
    required this.messages,
    required this.adapterType,
    required this.adapterConfig,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact': contact.toMap(), // Assuming Contact has toMap
      'messages': messages.map((m) => m.toJson()).toList(),
      'adapterType': adapterType,
      'adapterConfig': adapterConfig,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      contact: Contact.fromMap(json['contact']), // Assuming Contact has fromMap
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      adapterType: json['adapterType'],
      adapterConfig: json['adapterConfig'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
