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

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    // Reject future createdAt (replay / clock-skew attack)
    final rawCreated = DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as int?) ?? 0);
    final effectiveCreated =
        rawCreated.isAfter(now.add(const Duration(minutes: 1))) ? now : rawCreated;
    // Cap expiresAt at createdAt + 25 h to prevent "eternal" statuses
    final rawExpiry = DateTime.fromMillisecondsSinceEpoch((json['expiresAt'] as int?) ?? 0);
    final maxExpiry = effectiveCreated.add(const Duration(hours: 25));
    final effectiveExpiry = rawExpiry.isAfter(maxExpiry) ? maxExpiry : rawExpiry;

    // Size limits — text 500 chars, media 512 KB base64
    const maxTextLen = 500;
    const maxMediaLen = 512 * 1024;
    final rawText = (json['text'] as String?) ?? '';
    final rawMedia = json['media'] as String?;

    return UserStatus(
      id: (json['id'] as String?) ?? '',
      text: rawText.length > maxTextLen ? rawText.substring(0, maxTextLen) : rawText,
      mediaPayload: rawMedia != null && rawMedia.length > maxMediaLen ? null : rawMedia,
      createdAt: effectiveCreated,
      expiresAt: effectiveExpiry,
    );
  }

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
