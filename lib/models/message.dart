import 'package:flutter/foundation.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String encryptedPayload;
  final DateTime timestamp;
  final String adapterType; // 'firebase', 'nostr', 'group'
  final bool isRead;
  final String status; // 'sending', 'sent', 'failed', '' (received)
  final bool isEdited;
  final String? replyToId;
  final String? replyToText;
  final String? replyToSender;
  final DateTime? scheduledAt; // non-null when status == 'scheduled'
  /// For group messages sent by self: list of contactIds who have read it.
  final List<String> readBy;
  /// For group messages sent by self: list of contactIds who have received it.
  final List<String> deliveredTo;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.encryptedPayload,
    required this.timestamp,
    required this.adapterType,
    this.isRead = false,
    this.status = '',
    this.isEdited = false,
    this.replyToId,
    this.replyToText,
    this.replyToSender,
    this.scheduledAt,
    this.readBy = const [],
    this.deliveredTo = const [],
  });

  Message copyWith({
    String? status,
    String? encryptedPayload,
    bool? isRead,
    bool? isEdited,
    String? replyToId,
    String? replyToText,
    String? replyToSender,
    DateTime? scheduledAt,
    List<String>? readBy,
    List<String>? deliveredTo,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      timestamp: timestamp,
      adapterType: adapterType,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      replyToId: replyToId ?? this.replyToId,
      replyToText: replyToText ?? this.replyToText,
      replyToSender: replyToSender ?? this.replyToSender,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      readBy: readBy ?? this.readBy,
      deliveredTo: deliveredTo ?? this.deliveredTo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'encryptedPayload': encryptedPayload,
      'timestamp': timestamp.toIso8601String(),
      'adapterType': adapterType,
      'isRead': isRead,
      'status': status,
      'isEdited': isEdited,
      if (replyToId != null) 'replyToId': replyToId,
      if (replyToText != null) 'replyToText': replyToText,
      if (replyToSender != null) 'replyToSender': replyToSender,
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
      if (readBy.isNotEmpty) 'readBy': readBy,
      if (deliveredTo.isNotEmpty) 'deliveredTo': deliveredTo,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      encryptedPayload: json['encryptedPayload'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      adapterType: json['adapterType'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      isEdited: json['isEdited'] as bool? ?? false,
      replyToId: json['replyToId'] as String?,
      replyToText: json['replyToText'] as String?,
      replyToSender: json['replyToSender'] as String?,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      readBy: (json['readBy'] as List<dynamic>?)?.whereType<String>().toList() ?? const [],
      deliveredTo: (json['deliveredTo'] as List<dynamic>?)?.whereType<String>().toList() ?? const [],
    );
  }

  /// Safe variant of [fromJson] that returns null instead of throwing
  /// on malformed data.
  static Message? tryFromJson(Map<String, dynamic> json) {
    try {
      return Message.fromJson(json);
    } catch (e) {
      debugPrint('[Message] Failed to parse: $e');
      return null;
    }
  }
}
