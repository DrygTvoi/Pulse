import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'contact_profile_sheet.dart';
import 'verify_identity_screen.dart';
import '../models/contact.dart';
import '../controllers/chat_controller.dart';
import '../models/message.dart';
import '../services/media_service.dart';
import '../services/voice_service.dart';
import '../services/notification_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/message_menu.dart' as menu;
import '../widgets/swipeable_bubble.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/connection_banner.dart';
import '../l10n/l10n_ext.dart';
import '../models/contact_repository.dart';

class ChatScreen extends StatefulWidget {
  final Contact contact;
  /// When true, the screen is embedded in a split view (no Navigator.pop on back).
  final bool embedded;
  /// Called when the user deletes the contact while in embedded mode.
  final VoidCallback? onCloseEmbedded;
  const ChatScreen({super.key, required this.contact, this.embedded = false, this.onCloseEmbedded});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  bool _searchActive = false;
  String _searchQuery = '';
  int _chatTtlSeconds = 0;
  Timer? _typingDebounce;
  StreamSubscription? _typingSub;
  StreamSubscription? _keyChangeSub;
  StreamSubscription? _tamperWarnSub;
  StreamSubscription? _e2eeFailSub;
  late Contact _contact;

  // Voice recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  // Input focus for glow effect
  final FocusNode _inputFocusNode = FocusNode();
  bool _inputFocused = false;

  // Message editing / replying state
  String? _editingMessageId;
  Message? _replyingTo;

  bool _chatMuted = false;

  // Key change warning banner
  bool _showKeyChangeBanner = false;

  // Delete animation
  final _pendingDelete = <String>{};

  // Scroll-to-bottom FAB
  bool _showScrollFab = false;
  int _unreadWhileScrolled = 0;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctrl = context.read<ChatController>();
      await ctrl.loadRoomHistory(_contact);
      await ctrl.markRoomAsRead(_contact);
      if (_contact.isGroup) unawaited(ctrl.markGroupMessagesRead(_contact));
      ctrl.setActiveRoom(_contact.id);
      if (mounted) setState(() => _chatTtlSeconds = ctrl.getChatTtlCached(_contact.id));
      final muted = await NotificationService().isChatMuted(_contact.id);
      if (mounted) setState(() => _chatMuted = muted);
      _scrollToBottom(animated: false);
      // Restore draft
      final draft = await LocalStorageService().loadDraft(_contact.id) ?? '';
      if (draft.isNotEmpty && mounted) {
        _controller.text = draft;
        _controller.selection = TextSelection.collapsed(offset: draft.length);
      }
    });
    _scrollController.addListener(_onScroll);
    _controller.addListener(_onTyping);
    _inputFocusNode.addListener(() {
      if (mounted) setState(() => _inputFocused = _inputFocusNode.hasFocus);
    });
    // Ctrl+Enter to send on desktop
    _inputFocusNode.onKeyEvent = (_, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter &&
          HardwareKeyboard.instance.isControlPressed) {
        _sendMessage();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _typingSub = ChatController().typingUpdates.listen(
      (contactId) { if (contactId == _contact.id && mounted) setState(() {}); },
      onError: (e) => debugPrint('[ChatScreen] typing stream error: $e'),
    );
    _keyChangeSub = ChatController().keyChangeWarnings.listen((event) {
      if (!mounted) return;
      // Show persistent banner if the key change is for the current contact
      if (event.contactId == _contact.databaseId) {
        setState(() => _showKeyChangeBanner = true);
      }
      // Also show a SnackBar for any key change (visible across chats)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            context.l10n.chatKeyChangedSnackbar(event.contactName),
            style: const TextStyle(color: Colors.white),
          )),
        ]),
        backgroundColor: const Color(0xFF7A3000),
        duration: const Duration(seconds: 8),
      ));
    }, onError: (e) => debugPrint('[ChatScreen] keyChange stream error: $e'));
    _e2eeFailSub = ChatController().e2eeFailures.listen((contactName) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.lock_open_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            context.l10n.chatEncryptionFailed(contactName),
            style: const TextStyle(color: Colors.white),
          )),
        ]),
        backgroundColor: const Color(0xFF7A2600),
        duration: const Duration(seconds: 6),
      ));
    }, onError: (e) => debugPrint('[ChatScreen] e2eeFail stream error: $e'));
    _tamperWarnSub = ChatController().tamperWarnings.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg,
              style: const TextStyle(color: Colors.white))),
        ]),
        backgroundColor: const Color(0xFF8B0000),
        duration: const Duration(seconds: 10),
      ));
    }, onError: (e) => debugPrint('[ChatScreen] tamper stream error: $e'));
  }

  @override
  void dispose() {
    context.read<ChatController>().setActiveRoom(null);
    // Save draft
    final draft = _controller.text.trim();
    final storage = LocalStorageService();
    if (draft.isNotEmpty) {
      unawaited(storage.saveDraft(_contact.id, draft));
    } else {
      unawaited(storage.deleteDraft(_contact.id));
    }
    _typingDebounce?.cancel();
    _typingSub?.cancel();
    _keyChangeSub?.cancel();
    _tamperWarnSub?.cancel();
    _e2eeFailSub?.cancel();
    _recordingTimer?.cancel();
    _controller.removeListener(_onTyping);
    _controller.dispose();
    _inputFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTyping() {
    if (_controller.text.isEmpty) return;
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 600), () {
      ChatController().sendTypingSignal(_contact);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 80) {
      final ctrl = context.read<ChatController>();
      if (ctrl.hasMoreHistory(_contact.id) && !ctrl.isLoadingMoreHistory(_contact.id)) {
        ctrl.loadMoreHistory(_contact);
      }
    }
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120;
    if (atBottom && _showScrollFab) {
      setState(() { _showScrollFab = false; _unreadWhileScrolled = 0; });
      context.read<ChatController>().markRoomAsRead(_contact);
    } else if (!atBottom && !_showScrollFab) {
      setState(() => _showScrollFab = true);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(max,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    } else {
      _scrollController.jumpTo(max);
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    final text = _controller.text.trim();
    _controller.clear();
    unawaited(LocalStorageService().deleteDraft(_contact.id));
    final ctrl = context.read<ChatController>();
    if (_editingMessageId != null) {
      final editId = _editingMessageId!;
      setState(() => _editingMessageId = null);
      await ctrl.editMessage(_contact, editId, text);
    } else {
      final replyTo = _replyingTo;
      setState(() => _replyingTo = null);
      await ctrl.sendMessage(_contact, text, replyTo: replyTo);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendMedia({bool imageOnly = false}) async {
    try {
      if (imageOnly) {
        final result = await MediaService().pickImage();
        if (result == null) return;
        if (!mounted) return;
        await context.read<ChatController>().sendMessage(_contact, result.payload);
      } else {
        final raw = await MediaService().pickFileRaw();
        if (raw == null) return;
        if (!mounted) return;
        if (_contact.isGroup && raw.bytes.length > 512 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.chatFileTooLargeGroup),
            duration: Duration(seconds: 3),
          ));
          return;
        }
        if (raw.bytes.length > 5 * 1024 * 1024) {
          final sizeMB = (raw.bytes.length / (1024 * 1024)).toStringAsFixed(1);
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog.adaptive(
              title: Text(context.l10n.chatLargeFile),
              content: Text(
                context.l10n.chatLargeFileSizeWarning(sizeMB),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(context.l10n.chatCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(context.l10n.chatSend),
                ),
              ],
            ),
          );
          if (!mounted || confirmed != true) return;
        }
        await context.read<ChatController>().sendFile(_contact, raw.bytes, raw.name);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on MediaTooLargeException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chatFileTooLarge),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on MediaSecurityException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.reason),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    HapticFeedback.mediumImpact();
    final started = await VoiceService().startRecording();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.chatMicDenied),
          duration: const Duration(seconds: 2),
        ));
      }
      return;
    }
    setState(() { _isRecording = true; _recordingSeconds = 0; });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingSeconds++);
      if (_recordingSeconds >= 120) _stopRecording();
    });
  }

  Future<void> _stopRecording() async {
    HapticFeedback.lightImpact();
    _recordingTimer?.cancel();
    final wasRecording = _recordingSeconds > 0;
    final payload = await VoiceService().stopRecording();
    setState(() { _isRecording = false; _recordingSeconds = 0; });
    if (payload == null) {
      if (wasRecording && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.chatVoiceFailed),
          duration: const Duration(seconds: 3),
        ));
      }
      return;
    }
    if (!mounted) return;
    await context.read<ChatController>().sendMessage(_contact, payload);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    await VoiceService().cancelRecording();
    if (mounted) setState(() { _isRecording = false; _recordingSeconds = 0; });
  }

  Future<void> _animateDelete(Message msg) async {
    setState(() => _pendingDelete.add(msg.id));
    await Future.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    await context.read<ChatController>().deleteMessage(_contact, msg);
    setState(() => _pendingDelete.remove(msg.id));
  }

  void _showGroupStatusDialog(Message msg) {
    final repo = context.read<IContactRepository>();
    final myId = context.read<ChatController>().identity?.id ?? '';
    // All members except self
    final allMembers = _contact.members.where((id) => id != myId).toList();
    // Buckets
    final read = msg.readBy;
    final delivered = msg.deliveredTo.where((id) => !read.contains(id)).toList();
    final pending = allMembers.where(
        (id) => !read.contains(id) && !delivered.contains(id)).toList();

    String resolveName(String id) {
      final c = repo.contacts.cast<Contact?>()
          .firstWhere((c) => c?.id == id, orElse: () => null);
      return c?.name ?? id.substring(0, id.length.clamp(0, 10));
    }

    Widget section(String header, List<String> ids, IconData icon, Color color) {
      if (ids.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: DesignTokens.spacing12, bottom: DesignTokens.spacing6),
            child: Row(children: [
              Icon(icon, size: DesignTokens.fontBody, color: color),
              const SizedBox(width: DesignTokens.spacing6),
              Text(header,
                  style: GoogleFonts.inter(
                      color: color,
                      fontSize: DesignTokens.fontBody,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
          ...ids.map((id) => Padding(
                padding: const EdgeInsets.only(
                    left: DesignTokens.spacing20, bottom: DesignTokens.spacing4),
                child: Text(resolveName(id),
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: DesignTokens.fontBody)),
              )),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(context.l10n.groupStatusDialogTitle,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: read.isEmpty && delivered.isEmpty && pending.isEmpty
            ? Text(context.l10n.groupStatusNoData,
                style: GoogleFonts.inter(color: AppTheme.textSecondary))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    section(context.l10n.groupStatusRead, read,
                        Icons.done_all_rounded, AppTheme.primary),
                    section(context.l10n.groupStatusDelivered, delivered,
                        Icons.done_all_rounded,
                        AppTheme.textSecondary.withValues(alpha: 0.7)),
                    section(context.l10n.groupStatusPending, pending,
                        Icons.schedule_rounded,
                        AppTheme.textSecondary.withValues(alpha: 0.5)),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSchedulePicker() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(minutes: 5)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(primary: AppTheme.primary, surface: AppTheme.surface),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 5))),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(primary: AppTheme.primary, surface: AppTheme.surface),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (scheduledAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chatScheduleFuture)),
      );
      return;
    }
    _controller.clear();
    unawaited(LocalStorageService().deleteDraft(_contact.id));
    await context.read<ChatController>().scheduleMessage(_contact, text, scheduledAt);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _openProfile() {
    final myId = context.read<ChatController>().identity?.id ?? '';
    final isAdmin = !_contact.isGroup || _contact.creatorId == null || _contact.creatorId == myId;
    showContactProfile(
      context,
      _contact,
      isAdmin: isAdmin,
      onContactUpdated: (updated) {
        if (mounted) setState(() => _contact = updated);
      },
      onClearHistory: () {
        context.read<ChatController>().clearRoomHistory(_contact);
      },
      onDeleteContact: () async {
        await context.read<IContactRepository>().removeContact(_contact.id);
        if (mounted) {
          if (widget.embedded) {
            widget.onCloseEmbedded?.call();
          } else {
            Navigator.pop(context);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Granular selectors — only rebuild when THIS contact's room changes,
    // not on every ChatController notification (other contacts' messages, etc.).
    final myId = context.select<ChatController, String>((c) => c.identity?.id ?? '');
    final msgCount = context.select<ChatController, int>(
        (c) => c.getRoomForContact(_contact.id)?.messages.length ?? 0);
    final hasMore = context.select<ChatController, bool>(
        (c) => c.hasMoreHistory(_contact.id)) && _searchQuery.isEmpty;
    final loadingMore = context.select<ChatController, bool>(
        (c) => c.isLoadingMoreHistory(_contact.id));
    final connectionStatus = context.select<ChatController, ConnectionStatus>(
        (c) => c.connectionStatus);

    // Use read() for actual data access and method calls (non-reactive).
    final chatController = context.read<ChatController>();
    final room = chatController.getRoomForContact(_contact.id);
    final messages = room?.messages ?? [];

    // Auto-scroll and mark as read when new messages arrive
    if (msgCount != _lastMessageCount) {
      final delta = msgCount - _lastMessageCount;
      _lastMessageCount = msgCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_showScrollFab) {
          _scrollToBottom();
          chatController.markRoomAsRead(_contact);
        } else if (delta > 0) {
          setState(() => _unreadWhileScrolled += delta);
        }
      });
    }

    // Filter messages if search is active
    final filtered = _searchQuery.isEmpty
        ? messages
        : messages.where((m) {
            final text = m.encryptedPayload.toLowerCase();
            return !text.startsWith('e2ee||') && text.contains(_searchQuery);
          }).toList();
    final items = _buildItemList(filtered);

    // Scheduled messages count for input bar
    final scheduledMsgs = messages.where((m) => m.status == 'scheduled').toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _searchActive
          ? buildSearchAppBar(
              context: context,
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              onSearchClose: () => setState(() { _searchActive = false; _searchQuery = ''; }),
            )
          : buildChatAppBar(
              context: context,
              contact: _contact,
              myId: myId,
              chatMuted: _chatMuted,
              chatTtlSeconds: _chatTtlSeconds,
              onOpenProfile: _openProfile,
              onSearchActivate: () => setState(() => _searchActive = true),
              onMuteChanged: (muted) { if (mounted) setState(() => _chatMuted = muted); },
              onTtlChanged: (seconds) { if (mounted) setState(() => _chatTtlSeconds = seconds); },
              embedded: widget.embedded,
            ),
      body: Column(children: [
        // Offline indicator (hidden while probe is still running)
        OfflineBanner(status: connectionStatus),
        // Key change warning banner
        if (_showKeyChangeBanner)
          GestureDetector(
            onTap: () {
              setState(() => _showKeyChangeBanner = false);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => VerifyIdentityScreen(
                  contactName: _contact.name,
                  contactId: _contact.databaseId,
                ),
              ));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing14, vertical: DesignTokens.spacing10),
              decoration: const BoxDecoration(
                color: Color(0xFFE65100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: DesignTokens.fontHeading),
                  const SizedBox(width: DesignTokens.spacing10),
                  Expanded(
                    child: Text(
                      context.l10n.chatSafetyNumberChanged(_contact.name),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: DesignTokens.fontMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing8),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: DesignTokens.iconMd),
                  const SizedBox(width: DesignTokens.spacing4),
                  GestureDetector(
                    onTap: () => setState(() => _showKeyChangeBanner = false),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: DesignTokens.fontHeading),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              filtered.isEmpty && _searchQuery.isNotEmpty
              ? _buildNoSearchResults()
              : messages.isEmpty
                  ? _buildEmptyConversation()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(DesignTokens.spacing12, DesignTokens.spacing12, DesignTokens.spacing12, DesignTokens.spacing8),
                      itemCount: items.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (hasMore && index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
                            child: Center(
                              child: loadingMore
                                  ? const SizedBox(
                                      width: DesignTokens.iconMd, height: DesignTokens.iconMd,
                                      child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                                  : TextButton.icon(
                                      onPressed: () => chatController.loadMoreHistory(_contact),
                                      icon: const Icon(Icons.expand_less_rounded, size: DesignTokens.iconSm),
                                      label: Text(context.l10n.homeLoadEarlier),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.textSecondary,
                                        textStyle: const TextStyle(fontSize: DesignTokens.fontBody),
                                      ),
                                    ),
                            ),
                          );
                        }
                        final item = items[hasMore ? index - 1 : index];
                        if (item is _DateLabel) return _buildDateSeparator(item.date);
                        final entry = item as _MessageEntry;
                        final msg = entry.message;
                        final isMe = msg.senderId == myId;
                        String? senderName;
                        if (_contact.isGroup && !isMe && !entry.isGrouped) {
                          final sender = context.read<IContactRepository>().contacts.cast<Contact?>().firstWhere(
                            (c) => c?.databaseId == msg.senderId || c?.databaseId.split('@').first == msg.senderId,
                            orElse: () => null,
                          );
                          senderName = sender?.name ?? msg.senderId.substring(0, 8);
                        }
                        String? replyFromName;
                        if (msg.replyToSender != null) {
                          if (msg.replyToSender == myId) {
                            replyFromName = context.l10n.chatYou;
                          } else {
                            final rs = context.read<IContactRepository>().contacts.cast<Contact?>().firstWhere(
                              (c) => c?.databaseId == msg.replyToSender ||
                                  c?.databaseId.split('@').first == msg.replyToSender,
                              orElse: () => null,
                            );
                            replyFromName = rs?.name ?? msg.replyToSender;
                          }
                        }
                        return SwipeableBubble(
                          onLongPress: () => menu.showMessageMenu(
                            context: context,
                            message: msg,
                            myId: myId,
                            contact: _contact,
                            onReply: () => setState(() => _replyingTo = msg),
                            onForward: (m) => menu.showForwardPicker(
                              context: context,
                              message: m,
                              currentContact: _contact,
                              avatarBuilder: buildChatAvatar,
                            ),
                            onShowEmojiPicker: (msgId) => menu.showEmojiPicker(
                              context: context,
                              messageId: msgId,
                              contact: _contact,
                            ),
                            onDelete: (m) => _animateDelete(m),
                            onEdit: (id, text) => setState(() {
                              _editingMessageId = id;
                              _controller.text = text;
                              _controller.selection = TextSelection.fromPosition(
                                TextPosition(offset: _controller.text.length),
                              );
                            }),
                          ),
                          onSwiped: () => setState(() => _replyingTo = msg),
                          child: AnimatedOpacity(
                            opacity: _pendingDelete.contains(msg.id) ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeIn,
                            child: AnimatedScale(
                              scale: _pendingDelete.contains(msg.id) ? 0.88 : 1.0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeIn,
                              child: Padding(
                            padding: EdgeInsets.only(bottom: entry.isGrouped ? 1 : 5),
                            child: MessageBubble(
                              message: msg.encryptedPayload,
                              timestamp: msg.timestamp,
                              isMe: isMe,
                              status: msg.status,
                              showTail: entry.isLast,
                              senderName: senderName,
                              isEdited: msg.isEdited,
                              reactions: chatController.getReactions(_contact.storageKey, msg.id),
                              onReact: (e) { HapticFeedback.selectionClick(); chatController.toggleReaction(_contact, msg.id, e); },
                              onReactLongPress: (e) {
                                final r = chatController.getReactions(_contact.storageKey, msg.id);
                                final senders = r[e] ?? <String>[];
                                if (senders.isNotEmpty) {
                                  menu.showReactionDetails(
                                    context: context,
                                    emoji: e,
                                    senderIds: senders,
                                  );
                                }
                              },
                              replyToText: msg.replyToText,
                              replyToSender: replyFromName,
                              uploadProgress: chatController.getUploadProgress(msg.id),
                              readBy: msg.readBy,
                              deliveredTo: msg.deliveredTo,
                              onGroupStatusTap: (isMe && _contact.isGroup &&
                                      (msg.readBy.isNotEmpty || msg.deliveredTo.isNotEmpty))
                                  ? () => _showGroupStatusDialog(msg)
                                  : null,
                              onRetry: msg.status == 'failed'
                                  ? () => chatController.retryMessage(_contact, msg)
                                  : null,
                            )
                            .animate()
                            .fadeIn(duration: 200.ms)
                            .slideY(begin: 0.05, end: 0),
                          ),
                          ),
                          ),
                        );
                      },
                    ),
              if (_showScrollFab)
                Positioned(
                  right: DesignTokens.spacing14,
                  bottom: DesignTokens.spacing14,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() { _showScrollFab = false; _unreadWhileScrolled = 0; });
                      _scrollToBottom();
                      chatController.markRoomAsRead(_contact);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.surfaceVariant),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8, offset: const Offset(0, 2),
                            )],
                          ),
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary, size: DesignTokens.iconLg),
                        ),
                        if (_unreadWhileScrolled > 0)
                          Positioned(
                            top: -4, right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: DesignTokens.spacing2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                              ),
                              child: Text(
                                _unreadWhileScrolled > 99 ? '99+' : '$_unreadWhileScrolled',
                                style: const TextStyle(color: Colors.white, fontSize: DesignTokens.fontXs, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 150.ms).scale(begin: const Offset(0.7, 0.7)),
                ),
            ],
          ),
        ),
        MessageInputBar(
          controller: _controller,
          focusNode: _inputFocusNode,
          inputFocused: _inputFocused,
          isRecording: _isRecording,
          recordingSeconds: _recordingSeconds,
          replyingTo: _replyingTo,
          editingMessageId: _editingMessageId,
          scheduledCount: scheduledMsgs.length,
          onSend: _sendMessage,
          onAttach: () => menu.showAttachMenu(
            context: context,
            onPickImage: () => _sendMedia(imageOnly: true),
            onPickFile: () => _sendMedia(),
          ),
          onStartRecording: _startRecording,
          onStopRecording: _stopRecording,
          onCancelRecording: _cancelRecording,
          onCancelReply: () => setState(() => _replyingTo = null),
          onCancelEdit: () => setState(() {
            _editingMessageId = null;
            _controller.clear();
          }),
          onSchedulePicker: _showSchedulePicker,
          onShowScheduledPanel: () => menu.showScheduledPanel(
            context: context,
            scheduled: scheduledMsgs,
            contact: _contact,
          ),
        ),
      ]),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_rounded, size: 36, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
        const SizedBox(height: DesignTokens.spacing12),
        Text(context.l10n.chatNoMessagesFound, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
        const SizedBox(height: DesignTokens.spacing4),
        Text('"$_searchQuery"', style: GoogleFonts.inter(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: DesignTokens.fontBody)),
      ]),
    );
  }

  List<dynamic> _buildItemList(List<Message> messages) {
    final items = <dynamic>[];
    DateTime? lastDate;
    String? lastSenderId;
    DateTime? lastTimestamp;

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final msgDay = DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);

      if (lastDate == null || lastDate != msgDay) {
        items.add(_DateLabel(msgDay));
        lastDate = msgDay;
        lastSenderId = null;
        lastTimestamp = null;
      }

      final prevTime = lastTimestamp;
      final isGrouped = lastSenderId == msg.senderId &&
          prevTime != null &&
          msg.timestamp.difference(prevTime).inMinutes < 5;

      final next = i + 1 < messages.length ? messages[i + 1] : null;
      final isLast = next == null ||
          next.senderId != msg.senderId ||
          next.timestamp.difference(msg.timestamp).inMinutes >= 5;

      items.add(_MessageEntry(message: msg, isGrouped: isGrouped, isLast: isLast));
      lastSenderId = msg.senderId;
      lastTimestamp = msg.timestamp;
    }
    return items;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    String label;
    if (date == today) {
      label = context.l10n.chatToday;
    } else if (date == yesterday) {
      label = context.l10n.chatYesterday;
    } else if (now.year == date.year) {
      label = '${_monthName(date.month)} ${date.day}';
    } else {
      label = '${_monthName(date.month)} ${date.day}, ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing12),
      child: Row(children: [
        Expanded(child: Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(DesignTokens.chatDateChipRadius),
            ),
            child: Text(label,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody, fontWeight: FontWeight.w500)),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), thickness: 0.5)),
      ]),
    );
  }

  String _monthName(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];

  Widget _buildEmptyConversation() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.lock_rounded, size: DesignTokens.iconXl, color: AppTheme.primary.withValues(alpha: 0.4)),
        const SizedBox(height: DesignTokens.spacing12),
        Text(context.l10n.chatMessagesE2ee,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
        const SizedBox(height: DesignTokens.spacing4),
        Text(context.l10n.chatSayHello, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
      ]),
    );
  }
}

class _DateLabel {
  final DateTime date;
  const _DateLabel(this.date);
}

class _MessageEntry {
  final Message message;
  final bool isGrouped;
  final bool isLast;
  const _MessageEntry({required this.message, required this.isGrouped, required this.isLast});
}
