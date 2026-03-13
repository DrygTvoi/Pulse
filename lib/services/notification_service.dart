import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';
import '../controllers/chat_controller.dart';
import '../models/contact.dart';
import '../models/message.dart';
import 'media_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  StreamSubscription? _sub;

  Future<void> initialize() async {
    try {
      await localNotifier.setup(appName: 'Pulse');
      _sub = ChatController().newMessages.listen(_onNewMessage);
    } catch (e) {
      debugPrint('[NotificationService] Init failed: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  void _onNewMessage(({String contactId, Message message}) event) {
    try {
      final Message msg = event.message;
      // All messages from newMessages stream are incoming — no isMe check needed.

      final contact = ContactManager().contacts
          .where((c) => c.id == event.contactId)
          .firstOrNull;
      final senderName = contact?.name ?? 'New message';

      final text = msg.encryptedPayload;
      final String preview;
      if (text.startsWith('E2EE||')) {
        preview = '🔒 Encrypted message';
      } else if (MediaService.isMediaPayload(text)) {
        final m = MediaService.parse(text);
        preview = m?.isImage == true ? '📷 Photo' : '📎 ${m?.name ?? 'File'}';
      } else {
        preview = text.length > 80 ? '${text.substring(0, 80)}…' : text;
      }

      final notification = LocalNotification(
        title: senderName,
        body: preview,
      );
      notification.show();
    } catch (e) {
      debugPrint('[NotificationService] Failed to show notification: $e');
    }
  }
}
