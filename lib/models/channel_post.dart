import 'dart:convert';

class ChannelPost {
  final String id;
  final String channelId;
  final String content;
  final String signature;
  final List<String> media;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;

  bool get isEdited => updatedAt.difference(createdAt).inSeconds > 1;

  const ChannelPost({
    required this.id,
    required this.channelId,
    this.content = '',
    this.signature = '',
    this.media = const [],
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
  });

  factory ChannelPost.fromJson(Map<String, dynamic> json) {
    // Parse media: could be JSON string or list
    List<String> mediaList;
    final rawMedia = json['media'];
    if (rawMedia is List) {
      mediaList = rawMedia.cast<String>();
    } else if (rawMedia is String && rawMedia.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMedia);
        if (decoded is List) {
          mediaList = decoded.cast<String>();
        } else {
          mediaList = [];
        }
      } catch (_) {
        mediaList = [];
      }
    } else {
      mediaList = [];
    }

    final createdAtRaw = json['created_at'];
    final updatedAtRaw = json['updated_at'];

    return ChannelPost(
      id: json['id'] as String? ?? '',
      channelId: json['channel_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      media: mediaList,
      createdAt: _parseTimestamp(createdAtRaw),
      updatedAt: _parseTimestamp(updatedAtRaw ?? createdAtRaw),
      viewCount: json['view_count'] as int? ?? 0,
    );
  }

  static DateTime _parseTimestamp(dynamic ts) {
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    if (ts is double) return DateTime.fromMillisecondsSinceEpoch((ts * 1000).toInt());
    if (ts is String) {
      final parsed = int.tryParse(ts);
      if (parsed != null) return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'channel_id': channelId,
    'content': content,
    'signature': signature,
    'media': media,
    'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
    'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    'view_count': viewCount,
  };

  ChannelPost copyWith({
    String? id,
    String? channelId,
    String? content,
    String? signature,
    List<String>? media,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
  }) => ChannelPost(
    id: id ?? this.id,
    channelId: channelId ?? this.channelId,
    content: content ?? this.content,
    signature: signature ?? this.signature,
    media: media ?? this.media,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    viewCount: viewCount ?? this.viewCount,
  );
}

class PostReaction {
  final String emoji;
  final int count;

  const PostReaction({required this.emoji, required this.count});

  factory PostReaction.fromJson(Map<String, dynamic> json) => PostReaction(
    emoji: json['emoji'] as String? ?? '',
    count: json['count'] as int? ?? 0,
  );
}
