import 'dart:convert';

class UserStatus {
  final String id;
  final String text;
  final String? mediaPayload; // base64-encoded photo payload (same format as media messages)
  final DateTime createdAt;
  final DateTime expiresAt; // createdAt + 24h

  UserStatus({
    required this.id,
    required this.text,
    this.mediaPayload,
    required this.createdAt,
    required this.expiresAt,
  });

  factory UserStatus.create({required String id, required String text, String? mediaPayload}) {
    final now = DateTime.now();
    return UserStatus(
      id: id,
      text: text,
      mediaPayload: mediaPayload,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get hasMedia => mediaPayload != null && mediaPayload!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        if (mediaPayload != null) 'media': mediaPayload,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
      };

  factory UserStatus.fromJson(Map<String, dynamic> json) => UserStatus(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        mediaPayload: json['media'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as int?) ?? 0),
        expiresAt: DateTime.fromMillisecondsSinceEpoch((json['expiresAt'] as int?) ?? 0),
      );

  String toJsonString() => jsonEncode(toJson());

  static UserStatus? tryFromJsonString(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return UserStatus.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
