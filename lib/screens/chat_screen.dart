import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'call_screen.dart';
import 'group_call_screen.dart';
import 'contact_profile_sheet.dart';
import '../models/contact.dart';
import '../controllers/chat_controller.dart';
import '../models/message.dart';
import '../services/media_service.dart';
import '../services/voice_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final Contact contact;
  const ChatScreen({super.key, required this.contact});

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
  StreamSubscription? _e2eeFailSub;
  late Contact _contact;

  // Voice recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  // Message editing / replying state
  String? _editingMessageId;
  Message? _replyingTo;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctrl = context.read<ChatController>();
      await ctrl.loadRoomHistory(_contact);
      await ctrl.markRoomAsRead(_contact);
      if (mounted) setState(() => _chatTtlSeconds = ctrl.getChatTtlCached(_contact.id));
      _scrollToBottom(animated: false);
      // Restore draft
      final prefs = await SharedPreferences.getInstance();
      final draft = prefs.getString('draft_${_contact.id}') ?? '';
      if (draft.isNotEmpty && mounted) {
        _controller.text = draft;
        _controller.selection = TextSelection.collapsed(offset: draft.length);
      }
    });
    _scrollController.addListener(_onScroll);
    _controller.addListener(_onTyping);
    _typingSub = ChatController().typingUpdates.listen((contactId) {
      if (contactId == _contact.id && mounted) setState(() {});
    });
    _keyChangeSub = ChatController().keyChangeWarnings.listen((contactName) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            '⚠️ $contactName\'s security key changed. Verify out-of-band.',
            style: const TextStyle(color: Colors.white),
          )),
        ]),
        backgroundColor: const Color(0xFF7A3000),
        duration: const Duration(seconds: 8),
      ));
    });
    _e2eeFailSub = ChatController().e2eeFailures.listen((contactName) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.lock_open_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Could not encrypt message to $contactName — sent unencrypted.',
            style: const TextStyle(color: Colors.white),
          )),
        ]),
        backgroundColor: const Color(0xFF7A2600),
        duration: const Duration(seconds: 6),
      ));
    });
  }

  @override
  void dispose() {
    // Save draft
    final draft = _controller.text.trim();
    SharedPreferences.getInstance().then((prefs) {
      if (draft.isNotEmpty) {
        prefs.setString('draft_${_contact.id}', draft);
      } else {
        prefs.remove('draft_${_contact.id}');
      }
    });
    _typingDebounce?.cancel();
    _typingSub?.cancel();
    _keyChangeSub?.cancel();
    _e2eeFailSub?.cancel();
    _recordingTimer?.cancel();
    _controller.removeListener(_onTyping);
    _controller.dispose();
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
    final text = _controller.text.trim();
    _controller.clear();
    SharedPreferences.getInstance().then((p) => p.remove('draft_${_contact.id}'));
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

  String _replyPreview() {
    final m = _replyingTo;
    if (m == null) return '';
    final payload = m.encryptedPayload;
    if (MediaService.isMediaPayload(payload)) {
      final parsed = MediaService.parse(payload);
      if (parsed?.isImage == true) return '📷 Photo';
      if (parsed?.isVoice == true) return '🎙 Voice message';
      return '📎 ${parsed?.name ?? 'File'}';
    }
    return payload.length > 60 ? '${payload.substring(0, 60)}…' : payload;
  }

  void _showForwardPicker(Message msg) {
    final contacts = ContactManager().contacts
        .where((c) => c.id != _contact.id)
        .toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Forward to…',
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (ctx, i) {
                  final c = contacts[i];
                  return ListTile(
                    leading: _buildAvatar(c.name, 36),
                    title: Text(c.name, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await context.read<ChatController>().sendMessage(c, msg.encryptedPayload);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Forwarded to ${c.name}'),
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Files over 512 KB are not supported in group chats'),
            duration: Duration(seconds: 3),
          ));
          return;
        }
        await context.read<ChatController>().sendFile(_contact, raw.bytes, raw.name);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on MediaTooLargeException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File too large — maximum size is 100 MB'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    final started = await VoiceService().startRecording();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Microphone permission denied'),
          duration: Duration(seconds: 2),
        ));
      }
      return;
    }
    setState(() { _isRecording = true; _recordingSeconds = 0; });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordingSeconds++);
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final payload = await VoiceService().stopRecording();
    setState(() { _isRecording = false; _recordingSeconds = 0; });
    if (payload == null || !mounted) return;
    await context.read<ChatController>().sendMessage(_contact, payload);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    await VoiceService().cancelRecording();
    if (mounted) setState(() { _isRecording = false; _recordingSeconds = 0; });
  }

  String _fmtRecording(int s) =>
      '${(s ~/ 60).toString().padLeft(1, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _showAttachMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _attachOption(
                icon: Icons.image_rounded,
                label: 'Photo',
                color: const Color(0xFF4CAF50),
                onTap: () { Navigator.pop(context); _sendMedia(imageOnly: true); },
              ),
              _attachOption(
                icon: Icons.insert_drive_file_rounded,
                label: 'File',
                color: const Color(0xFF2196F3),
                onTap: () { Navigator.pop(context); _sendMedia(); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }

  void _showMessageMenu(Message msg) {
    final chatController = context.read<ChatController>();
    final myId = chatController.identity?.id ?? '';
    final isMe = msg.senderId == myId;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.reply_rounded, color: AppTheme.textSecondary),
              title: Text('Reply', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _replyingTo = msg);
              },
            ),
            ListTile(
              leading: Icon(Icons.forward_rounded, color: AppTheme.textSecondary),
              title: Text('Forward', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showForwardPicker(msg);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_reaction_outlined, color: AppTheme.textSecondary),
              title: Text('React', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showEmojiPicker(msg.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy_rounded, color: AppTheme.textSecondary),
              title: Text('Copy', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: msg.encryptedPayload));
              },
            ),
            if (isMe && !MediaService.isMediaPayload(msg.encryptedPayload))
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppTheme.primary),
                title: Text('Edit', style: GoogleFonts.inter(color: AppTheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _editingMessageId = msg.id;
                    _controller.text = msg.encryptedPayload;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  });
                },
              ),
            if (msg.status == 'failed')
              ListTile(
                leading: Icon(Icons.refresh_rounded, color: AppTheme.primary),
                title: Text('Retry', style: GoogleFonts.inter(color: AppTheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  chatController.retryMessage(_contact, msg);
                },
              ),
            if (msg.status == 'scheduled')
              ListTile(
                leading: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                title: Text('Cancel scheduled', style: GoogleFonts.inter(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  chatController.cancelScheduledMessage(_contact, msg.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: Text('Delete', style: GoogleFonts.inter(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                await chatController.deleteLocalMessage(_contact, msg.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReactionDetails(String emoji, List<String> senderIds) {
    final myId = context.read<ChatController>().identity?.id ?? '';
    final names = senderIds.map((id) {
      if (id == myId) return 'You';
      final c = ContactManager().contacts.cast<Contact?>().firstWhere(
        (c) => c?.databaseId == id || c?.databaseId.split('@').first == id,
        orElse: () => null,
      );
      return c?.name ?? id.substring(0, id.length.clamp(0, 10));
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            ...names.map((name) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                child: Text(name[0].toUpperCase(),
                    style: GoogleFonts.inter(
                        color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              title: Text(name, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(String msgId) {
    const emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '👎'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emojis.map((emoji) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.read<ChatController>().toggleReaction(_contact, msgId, emoji);
              },
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
            )).toList(),
          ),
        ),
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
        const SnackBar(content: Text('Scheduled time must be in the future')),
      );
      return;
    }
    _controller.clear();
    SharedPreferences.getInstance().then((p) => p.remove('draft_${_contact.id}'));
    await context.read<ChatController>().scheduleMessage(_contact, text, scheduledAt);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _showTtlDialog() {
    const options = [
      (label: 'Off', seconds: 0),
      (label: '1 hour', seconds: 3600),
      (label: '24 hours', seconds: 86400),
      (label: '7 days', seconds: 604800),
    ];
    final ctrl = context.read<ChatController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Text('Disappearing Messages',
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text('Messages delete automatically after the selected time.',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
              ),
              ...options.map((opt) => ListTile(
                title: Text(opt.label,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15)),
                trailing: _chatTtlSeconds == opt.seconds
                    ? Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () async {
                  await ctrl.setChatTtlSeconds(_contact, opt.seconds);
                  if (mounted) setState(() => _chatTtlSeconds = opt.seconds);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
        onPressed: () {
          _searchController.clear();
          setState(() { _searchActive = false; _searchQuery = ''; });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          filled: false,
        ),
      ),
    );
  }

  void _openProfile() {
    showContactProfile(
      context,
      _contact,
      isAdmin: true,
      onContactUpdated: (updated) {
        if (mounted) setState(() => _contact = updated);
      },
      onClearHistory: () {
        context.read<ChatController>().clearRoomHistory(_contact);
      },
      onDeleteContact: () async {
        await ContactManager().removeContact(_contact.id);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatController = context.watch<ChatController>();
    final room = chatController.getRoomForContact(_contact.id);
    final messages = room?.messages ?? [];
    final myId = chatController.identity?.id ?? '';

    // Auto-scroll and mark as read when new messages arrive
    if (messages.length != _lastMessageCount) {
      _lastMessageCount = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
        chatController.markRoomAsRead(_contact);
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
    final hasMore = chatController.hasMoreHistory(_contact.id) && _searchQuery.isEmpty;
    final loadingMore = chatController.isLoadingMoreHistory(_contact.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _searchActive
          ? _buildSearchBar()
          : AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _openProfile,
          child: Row(children: [
            _buildAvatar(_contact.name, 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_contact.name,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  chatController.isContactTyping(_contact.id)
                      ? _buildTypingIndicator()
                      : chatController.isOnline(_contact.id)
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('online',
                                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF4CAF50))),
                            ])
                          : chatController.lastSeenLabel(_contact.id).isNotEmpty
                              ? Text(chatController.lastSeenLabel(_contact.id),
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary))
                              : Row(children: [
                                  Icon(Icons.lock_rounded, size: 10, color: AppTheme.primary),
                                  const SizedBox(width: 3),
                                  Text('Signal E2EE',
                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w500)),
                                  if (chatController.hasPqcKey(_contact.databaseId)) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A6B3C),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('+ Kyber',
                                          style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF4ADE80), fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                  const SizedBox(width: 6),
                                  _buildProviderBadge(_contact.provider),
                                ]),
                ],
              ),
            ),
          ]),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
            onPressed: () => setState(() => _searchActive = true),
          ),
          IconButton(
            icon: Icon(Icons.call_rounded, color: AppTheme.textSecondary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => _contact.isGroup
                  ? GroupCallScreen(group: _contact, myId: myId, isVideoCall: false, isCaller: true)
                  : CallScreen(contact: _contact, myId: myId, isVideoCall: false, isCaller: true),
            )),
          ),
          IconButton(
            icon: Icon(Icons.videocam_rounded, color: AppTheme.textSecondary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => _contact.isGroup
                  ? GroupCallScreen(group: _contact, myId: myId, isVideoCall: true, isCaller: true)
                  : CallScreen(contact: _contact, myId: myId, isVideoCall: true, isCaller: true),
            )),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'search') setState(() => _searchActive = true);
              if (value == 'timer') _showTtlDialog();
              if (value == 'admin') _openProfile();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'timer',
                child: Row(children: [
                  Icon(
                    Icons.timer_outlined,
                    color: _chatTtlSeconds > 0 ? AppTheme.primary : AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _chatTtlSeconds > 0 ? 'Disappearing: on' : 'Disappearing messages',
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                  ),
                ]),
              ),
              if (_contact.isGroup)
                PopupMenuItem(
                  value: 'admin',
                  child: Row(children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        color: AppTheme.textSecondary, size: 20),
                    const SizedBox(width: 12),
                    Text('Group settings', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                  ]),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: filtered.isEmpty && _searchQuery.isNotEmpty
              ? _buildNoSearchResults()
              : messages.isEmpty
                  ? _buildEmptyConversation()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      itemCount: items.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Leading history-load header
                        if (hasMore && index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Center(
                              child: loadingMore
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : TextButton.icon(
                                      onPressed: () => chatController.loadMoreHistory(_contact),
                                      icon: const Icon(Icons.expand_less_rounded, size: 16),
                                      label: const Text('Load earlier messages'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.textSecondary,
                                        textStyle: const TextStyle(fontSize: 12),
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
                        // Resolve sender name for group chats
                        String? senderName;
                        if (_contact.isGroup && !isMe && !entry.isGrouped) {
                          final sender = ContactManager().contacts.cast<Contact?>().firstWhere(
                            (c) => c?.databaseId == msg.senderId || c?.databaseId.split('@').first == msg.senderId,
                            orElse: () => null,
                          );
                          senderName = sender?.name ?? msg.senderId.substring(0, 8);
                        }
                        // Resolve replyToSender ID → friendly name
                        String? replyFromName;
                        if (msg.replyToSender != null) {
                          if (msg.replyToSender == myId) {
                            replyFromName = 'You';
                          } else {
                            final rs = ContactManager().contacts.cast<Contact?>().firstWhere(
                              (c) => c?.databaseId == msg.replyToSender ||
                                  c?.databaseId.split('@').first == msg.replyToSender,
                              orElse: () => null,
                            );
                            replyFromName = rs?.name ?? msg.replyToSender;
                          }
                        }
                        return _SwipeableBubble(
                          onLongPress: () => _showMessageMenu(msg),
                          onSwiped: () => setState(() => _replyingTo = msg),
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
                              onReact: (e) => chatController.toggleReaction(_contact, msg.id, e),
                              onReactLongPress: (e) {
                                final r = chatController.getReactions(_contact.storageKey, msg.id);
                                final senders = r[e] ?? <String>[];
                                if (senders.isNotEmpty) _showReactionDetails(e, senders);
                              },
                              replyToText: msg.replyToText,
                              replyToSender: replyFromName,
                              uploadProgress: chatController.getUploadProgress(msg.id),
                            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05, end: 0),
                          ),
                        );
                      },
                    ),
        ),
        _buildMessageInput(),
      ]),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_rounded, size: 36, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
        const SizedBox(height: 12),
        Text('No messages found', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 4),
        Text('"$_searchQuery"', style: GoogleFonts.inter(color: AppTheme.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
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

      // Check if next message is from a different sender or >5min gap (so current = last in group)
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
      label = 'Today';
    } else if (date == yesterday) {
      label = 'Yesterday';
    } else if (now.year == date.year) {
      label = '${_monthName(date.month)} ${date.day}';
    } else {
      label = '${_monthName(date.month)} ${date.day}, ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15), thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
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
        Icon(Icons.lock_rounded, size: 32, color: AppTheme.primary.withValues(alpha: 0.4)),
        const SizedBox(height: 12),
        Text('Messages are end-to-end encrypted',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text('Say hello 👋', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
      ]),
    );
  }

  Widget _buildAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hue = (name.isNotEmpty ? name.codeUnitAt(0) * 17 + name.length * 31 : 180) % 360;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
            HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.32).toColor(),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(initial,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.42))),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('typing',
          style: GoogleFonts.inter(
              fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w500)),
      const SizedBox(width: 3),
      _TypingDots(),
    ]);
  }

  Widget _buildProviderBadge(String provider) {
    const meta = {
      'Firebase': (icon: Icons.local_fire_department_rounded, color: Color(0xFFFFAB00)),
      'Nostr': (icon: Icons.bolt_rounded, color: Color(0xFF9B59B6)),
      'group': (icon: Icons.group_rounded, color: Color(0xFF26A69A)),
    };
    final m = meta[provider];
    if (m == null) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(m.icon, size: 10, color: m.color),
      const SizedBox(width: 2),
      Text(_shortProvider(provider),
          style: GoogleFonts.inter(color: m.color, fontSize: 10, fontWeight: FontWeight.w600)),
    ]);
  }

  String _shortProvider(String p) {
    if (p == 'group') return 'Group';
    return p;
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, -1))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingTo != null)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _replyPreview(),
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _replyingTo = null),
                      child: Icon(Icons.close_rounded, size: 14, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            if (_editingMessageId != null)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Editing message',
                          style: GoogleFonts.inter(
                              color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _editingMessageId = null;
                        _controller.clear();
                      }),
                      child: const Icon(Icons.close_rounded, size: 14, color: Colors.amber),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 12),
              child: _isRecording ? _buildRecordingBar() : _buildNormalInputBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalInputBar() {
    return Row(children: [
      // Attach button
      GestureDetector(
        onTap: _showAttachMenu,
        child: Container(
          width: 42, height: 42,
          margin: const EdgeInsets.only(left: 4, right: 4),
          decoration: BoxDecoration(color: AppTheme.surfaceVariant, shape: BoxShape.circle),
          child: Icon(Icons.attach_file_rounded, color: AppTheme.textSecondary, size: 20),
        ),
      ),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(26),
          ),
          child: TextField(
            controller: _controller,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
            textInputAction: TextInputAction.send,
            minLines: 1,
            maxLines: 5,
            onSubmitted: (_) => _sendMessage(),
            decoration: InputDecoration(
              hintText: 'Message...',
              hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              fillColor: Colors.transparent,
              filled: true,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Mic button (when text field empty) or Send button
      ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final hasText = _controller.text.trim().isNotEmpty;
          if (hasText) {
            return GestureDetector(
              onTap: _sendMessage,
              onLongPress: _showSchedulePicker,
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            );
          }
          return GestureDetector(
            onTap: _startRecording,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic_rounded, color: AppTheme.textSecondary, size: 22),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildRecordingBar() {
    return Row(children: [
      // Cancel
      GestureDetector(
        onTap: _cancelRecording,
        child: Container(
          width: 42, height: 42,
          margin: const EdgeInsets.only(left: 4, right: 8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
        ),
      ),
      Expanded(
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              // Pulsing red dot
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (context, v, _) => Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: v),
                    shape: BoxShape.circle,
                  ),
                ),
                onEnd: () => setState(() {}), // rebuild to restart animation
              ),
              const SizedBox(width: 10),
              Text(
                _fmtRecording(_recordingSeconds),
                style: GoogleFonts.jetBrainsMono(
                    color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Text('Recording…',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Send voice
      GestureDetector(
        onTap: _stopRecording,
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    ]);
  }
}

/// Animated "..." dots for typing indicator in AppBar
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, a) {
        final t = _ctrl.value;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Opacity(
              opacity: ((t * 3 - i) % 1.0).clamp(0.2, 1.0),
              child: Container(
                width: 4, height: 4,
                decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              ),
            ),
          ],
        ]);
      },
    );
  }
}

class _DateLabel {
  final DateTime date;
  const _DateLabel(this.date);
}

class _MessageEntry {
  final Message message;
  final bool isGrouped; // part of consecutive same-sender group → less top padding
  final bool isLast;    // last in group → show bubble tail
  const _MessageEntry({required this.message, required this.isGrouped, required this.isLast});
}

/// Wraps a message bubble with swipe-right-to-reply gesture.
class _SwipeableBubble extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPress;
  final VoidCallback onSwiped;

  const _SwipeableBubble({
    required this.child,
    required this.onLongPress,
    required this.onSwiped,
  });

  @override
  State<_SwipeableBubble> createState() => _SwipeableBubbleState();
}

class _SwipeableBubbleState extends State<_SwipeableBubble>
    with SingleTickerProviderStateMixin {
  double _offset = 0.0;
  bool _triggered = false;
  late AnimationController _springCtrl;
  Animation<double>? _springAnim;

  static const double _threshold = 72.0;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_springCtrl.isAnimating) return;
    if (d.delta.dx > 0) {
      setState(() => _offset = (_offset + d.delta.dx).clamp(0.0, _threshold + 20.0));
    }
  }

  void _onDragEnd(DragEndDetails d) {
    if (_offset >= _threshold && !_triggered) {
      _triggered = true;
      widget.onSwiped();
    }
    _springBack();
  }

  void _springBack() {
    if (_offset == 0.0) {
      _triggered = false;
      return;
    }
    _springAnim = Tween<double>(begin: _offset, end: 0.0).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
    )..addListener(() {
      if (mounted) setState(() => _offset = _springAnim!.value);
    })..addStatusListener((s) {
      if (s == AnimationStatus.completed) _triggered = false;
    });
    _springCtrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (_offset / _threshold).clamp(0.0, 1.0);
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(_offset, 0),
            child: widget.child,
          ),
          if (_offset > 4)
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: 0.5 + 0.5 * opacity,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.reply_rounded,
                          size: 16, color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
