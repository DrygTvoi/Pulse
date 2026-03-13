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
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      encryptedPayload: json['encryptedPayload'],
      timestamp: DateTime.parse(json['timestamp']),
      adapterType: json['adapterType'],
      isRead: json['isRead'] ?? false,
      status: json['status'] ?? '',
      isEdited: json['isEdited'] ?? false,
      replyToId: json['replyToId'] as String?,
      replyToText: json['replyToText'] as String?,
      replyToSender: json['replyToSender'] as String?,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
    );
  }
}
