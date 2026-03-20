class Identity {
  final String id;
  final String publicKey; // E.g., the public key for Signal Protocol
  final String privateKey; // Should be handled securely!
  String preferredAdapter; // 'firebase', 'nostr'
  final Map<String, String> adapterConfig; // Info on how others can reach this user

  Identity({
    required this.id,
    required this.publicKey,
    required this.privateKey,
    required this.preferredAdapter,
    required this.adapterConfig,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicKey': publicKey,
      // intentionally omitting privateKey from typical JSON serialization
      // this needs to go into a secure storage like flutter_secure_storage
      'preferredAdapter': preferredAdapter,
      'adapterConfig': adapterConfig,
    };
  }

  Identity copyWith({
    String? preferredAdapter,
    Map<String, String>? adapterConfig,
  }) {
    return Identity(
      id: id,
      publicKey: publicKey,
      privateKey: privateKey,
      preferredAdapter: preferredAdapter ?? this.preferredAdapter,
      adapterConfig: adapterConfig ?? this.adapterConfig,
    );
  }

  factory Identity.fromJson(Map<String, dynamic> json) {
    return Identity(
      id: json['id'],
      publicKey: json['publicKey'],
      privateKey: json['privateKey'] ?? '', // Handle securely elsewhere
      preferredAdapter: json['preferredAdapter'],
      adapterConfig: Map<String, String>.from(json['adapterConfig']),
    );
  }
}
