import 'firebase_adapter.dart';
import 'nostr_adapter.dart';
import 'waku_adapter.dart';
import 'oxen_adapter.dart';

import '../models/message.dart';

// ICE server configuration is now managed by IceServerConfig.load()
// in lib/services/ice_server_config.dart.
// Signaling services call it right before creating each RTCPeerConnection.

abstract class InboxReader {
  /// Initialize with the user's personal API keys for their own inbox
  Future<void> initializeReader(String apiKey, String databaseId);

  /// Listen for incoming messages to your own inbox
  Stream<List<Message>> listenForMessages();

  /// Listen for incoming WebRTC signals
  Stream<List<Map<String, dynamic>>> listenForSignals();

  /// Emits false when the adapter becomes unreachable (N consecutive failures),
  /// true when it recovers. Default: empty stream (always considered healthy).
  Stream<bool> get healthChanges => Stream<bool>.empty();

  /// Provision a new Inbox (e.g. create a new repo or sheet) and return its ID
  Future<String?> provisionGroup(String groupName);

  /// Fetch the published public keys of the user owning this reader
  Future<Map<String, dynamic>?> fetchPublicKeys();
}

abstract class MessageSender {
  /// Initialize with the user's personal API keys (needed to push to external inboxes)
  Future<void> initializeSender(String apiKey);
  
  /// Send a message to a contact's inbox
  Future<bool> sendMessage(String targetDatabaseId, String roomId, Message message);
  
  /// Send a WebRTC signal to a contact's inbox
  Future<bool> sendSignal(String targetDatabaseId, String roomId, String senderId, String type, Map<String, dynamic> payload);
}

class InboxManager {
  static final InboxManager _instance = InboxManager._internal();
  factory InboxManager() => _instance;
  InboxManager._internal();

  InboxReader? reader;
  final Map<String, MessageSender> _senders = {};

  Future<void> configureSelf(String provider, String apiKey, String databaseId) async {
    if (provider == 'Firebase') {
      reader = FirebaseInboxReader();
    } else if (provider == 'Nostr') {
      reader = NostrInboxReader();
    } else if (provider == 'Waku') {
      reader = WakuInboxReader();
    } else if (provider == 'Oxen') {
      reader = OxenInboxReader();
    }
    await reader?.initializeReader(apiKey, databaseId);
  }

  void addSenderPlugin(String provider, MessageSender sender, String apiKey) {
    sender.initializeSender(apiKey);
    _senders[provider] = sender;
  }

  Future<bool> routeMessage(String targetProvider, String targetDatabaseId, String roomId, Message message) async {
    final sender = _senders[targetProvider];
    if (sender == null) return false;
    return await sender.sendMessage(targetDatabaseId, roomId, message);
  }

  Future<bool> sendSystemMessage(String targetProvider, String targetDatabaseId, String roomId, String senderId, String type, Map<String, dynamic> payload) async {
    final sender = _senders[targetProvider];
    if (sender == null) return false;
    // We reuse sendSignal for system messages as they are mechanically identical (hidden payload)
    return await sender.sendSignal(targetDatabaseId, roomId, senderId, type, payload);
  }

  InboxReader? createAdhocReader(String provider, String apiKey, String databaseId) {
    InboxReader? adhocReader;
    if (provider == 'Firebase') {
      adhocReader = FirebaseInboxReader();
    } else if (provider == 'Nostr') {
      adhocReader = NostrInboxReader();
    } else if (provider == 'Waku') {
      adhocReader = WakuInboxReader();
    } else if (provider == 'Oxen') {
      adhocReader = OxenInboxReader();
    }
    adhocReader?.initializeReader(apiKey, databaseId);
    return adhocReader;
  }
}
