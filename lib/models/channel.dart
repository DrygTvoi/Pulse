import 'package:uuid/uuid.dart';

class Channel {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String adminPubkey;
  final String url;
  final int createdAt;

  const Channel({
    required this.id,
    required this.name,
    this.description = '',
    this.avatarUrl = '',
    this.adminPubkey = '',
    required this.url,
    required this.createdAt,
  });

  factory Channel.fromWellKnown(Map<String, dynamic> json, String baseUrl) {
    return Channel(
      id: const Uuid().v4(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      adminPubkey: json['admin_pubkey'] as String? ?? '',
      url: baseUrl,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'avatarUrl': avatarUrl,
    'adminPubkey': adminPubkey,
    'url': url,
    'createdAt': createdAt,
  };

  factory Channel.fromMap(Map<String, dynamic> map) => Channel(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    description: map['description'] as String? ?? '',
    avatarUrl: map['avatarUrl'] as String? ?? '',
    adminPubkey: map['adminPubkey'] as String? ?? '',
    url: map['url'] as String? ?? '',
    createdAt: map['createdAt'] as int? ?? 0,
  );

  Channel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? adminPubkey,
    String? url,
    int? createdAt,
  }) => Channel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    adminPubkey: adminPubkey ?? this.adminPubkey,
    url: url ?? this.url,
    createdAt: createdAt ?? this.createdAt,
  );
}
