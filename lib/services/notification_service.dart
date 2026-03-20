import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/chat_controller.dart';
import '../models/contact_repository.dart';
import '../models/message.dart';
import 'media_service.dart';

// local_notifier is desktop-only (Linux / Windows / macOS).
// On Android/iOS we show notifications via flutter_local_notifications.
// Import conditionally so the build doesn't fail on mobile.
import 'package:local_notifier/local_notifier.dart'
    if (dart.library.html) 'notification_stub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static const String _mutePrefix = 'chat_mute_';

  IContactRepository? _contacts;
  StreamSubscription? _sub;
  fln.FlutterLocalNotificationsPlugin? _flnPlugin;

  /// Inject the contact repository. Call this from main() after initialization.
  void setContactRepository(IContactRepository repo) {
    _contacts = repo;
  }

  Future<bool> isChatMuted(String contactId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_mutePrefix$contactId') ?? false;
  }

  Future<void> setChatMuted(String contactId, bool muted) async {
    final prefs = await SharedPreferences.getInstance();
    if (muted) {
      await prefs.setBool('$_mutePrefix$contactId', true);
    } else {
      await prefs.remove('$_mutePrefix$contactId');
    }
  }

  bool get _isDesktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  bool get _isMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    try {
      if (_isDesktop) {
        await localNotifier.setup(appName: 'Pulse');
      } else if (_isMobile) {
        final plugin = fln.FlutterLocalNotificationsPlugin();
        const androidSettings = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosSettings = fln.DarwinInitializationSettings();
        await plugin.initialize(
          const fln.InitializationSettings(
            android: androidSettings,
            iOS: iosSettings,
          ),
        );
        _flnPlugin = plugin;
      }
      _sub = ChatController().newMessages.listen((e) => unawaited(_onNewMessage(e)));
    } catch (e) {
      debugPrint('[NotificationService] Init failed: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> _onNewMessage(({String contactId, Message message}) event) async {
    try {
      if (await isChatMuted(event.contactId)) return;
      final Message msg = event.message;

      final contact = (_contacts?.contacts ?? [])
          .where((c) => c.id == event.contactId)
          .firstOrNull;
      final senderName = contact?.name ?? 'New message';

      final text = msg.encryptedPayload;
      final String preview;
      if (text.startsWith('E2EE||')) {
        preview = '🔒 Encrypted message';
      } else if (MediaService.isMediaPayload(text)) {
        final m = MediaService.parse(text);
        if (m?.isImage == true) {
          preview = '📷 Photo';
        } else if (m?.isVoice == true) {
          preview = '🎤 Voice message';
        } else {
          preview = '📎 ${m?.name ?? 'File'}';
        }
      } else {
        preview = text.length > 80 ? '${text.substring(0, 80)}…' : text;
      }

      if (_isDesktop) {
        final notification = LocalNotification(
          title: senderName,
          body: preview,
        );
        notification.show();
      } else if (_flnPlugin != null) {
        _flnPlugin!.show(
          0,
          senderName,
          preview,
          const fln.NotificationDetails(
            android: fln.AndroidNotificationDetails(
              'pulse_messages',
              'Messages',
              channelDescription: 'Pulse incoming message notifications',
              importance: fln.Importance.high,
              priority: fln.Priority.high,
            ),
            iOS: fln.DarwinNotificationDetails(),
          ),
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] Failed to show notification: $e');
    }
  }
}
