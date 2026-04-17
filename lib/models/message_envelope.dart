import 'dart:convert';

/// Federation envelope — wraps every message payload BEFORE encryption.
///
/// Format (JSON, encrypted before sending):
///   {"_v":1, "_from":"sender_canonical_addr", "body":"actual_message_content",
///    "_replyTo":{"id":"...","text":"...","sender":"..."}}  // optional
///
/// Backward compatible: messages without an envelope are returned as-is.
class MessageEnvelope {
  static const int _version = 1;
  static const String _keyVersion = '_v';
  static const String _keyFrom = '_from';
  static const String _keyBody = 'body';
  static const String _keyReplyTo = '_replyTo';
  static const String _keyMsgId = '_id';
  static const String _keyName = '_name';
  static const String _keyAddrs = '_addrs';

  final String from;
  final String body;
  final ({String id, String text, String sender})? replyTo;
  /// Sender's local message UUID — allows receiver to store the message under
  /// the same ID regardless of transport-layer message ID (Nostr event hash,
  /// Firebase push key, etc.). Required for cross-device reactions/deletes.
  final String? msgId;
  /// Sender's display name — used for message requests from unknown senders.
  final String? senderName;
  /// Sender's full transport address map — allows receiver to create a
  /// complete contact with all transports (Nostr, Pulse, Session, etc.).
  final Map<String, List<String>>? senderAddresses;

  const MessageEnvelope({required this.from, required this.body, this.replyTo, this.msgId, this.senderName, this.senderAddresses});

  /// Wrap [body] with sender address [from] into an envelope JSON string.
  static String wrap(String from, String body, {
    ({String id, String text, String sender})? replyTo,
    String? msgId,
    String? senderName,
    Map<String, List<String>>? senderAddresses,
  }) {
    final map = <String, dynamic>{
      _keyVersion: _version,
      _keyFrom: from,
      _keyBody: body,
    };
    if (msgId != null && msgId.isNotEmpty) map[_keyMsgId] = msgId;
    if (senderName != null && senderName.isNotEmpty) map[_keyName] = senderName;
    if (senderAddresses != null && senderAddresses.isNotEmpty) {
      map[_keyAddrs] = senderAddresses.map((k, v) => MapEntry(k, List<String>.from(v)));
    }
    if (replyTo != null) {
      map[_keyReplyTo] = {
        'id': replyTo.id,
        'text': replyTo.text,
        'sender': replyTo.sender,
      };
    }
    return jsonEncode(map);
  }

  /// Try to parse an envelope from [raw] (after Signal decryption).
  static MessageEnvelope? tryUnwrap(String raw) {
    if (!raw.startsWith('{')) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (!map.containsKey(_keyFrom) || !map.containsKey(_keyBody)) return null;
      final from = map[_keyFrom] as String?;
      final body = map[_keyBody] as String?;
      if (from == null || from.isEmpty || body == null) return null;
      final msgId = map[_keyMsgId] as String?;
      ({String id, String text, String sender})? replyTo;
      final replyMap = map[_keyReplyTo];
      if (replyMap is Map) {
        final id = replyMap['id'] as String? ?? '';
        final text = replyMap['text'] as String? ?? '';
        final sender = replyMap['sender'] as String? ?? '';
        if (id.isNotEmpty) replyTo = (id: id, text: text, sender: sender);
      }
      final senderName = map[_keyName] as String?;
      Map<String, List<String>>? senderAddresses;
      final rawAddrs = map[_keyAddrs];
      if (rawAddrs is Map) {
        senderAddresses = rawAddrs.map((k, v) => MapEntry(
          k as String,
          (v as List).whereType<String>().toList(),
        ));
      }
      return MessageEnvelope(from: from, body: body, replyTo: replyTo, msgId: msgId, senderName: senderName, senderAddresses: senderAddresses);
    } catch (_) {
      return null;
    }
  }
}
