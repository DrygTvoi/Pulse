import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import '../models/user_status.dart';
import '../services/status_service.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'contacts_screen.dart';
import 'status_creator_screen.dart';
import 'status_viewer_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../controllers/chat_controller.dart';
import '../models/message.dart';
import 'call_screen.dart';
import 'group_call_screen.dart';
import '../services/connectivity_probe_service.dart';

PageRoute _slideRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionDuration: const Duration(milliseconds: 270),
  reverseTransitionDuration: const Duration(milliseconds: 230),
  transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
    position: Tween(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  ),
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _signalSubscription;
  StreamSubscription? _groupCallSubscription;
  StreamSubscription? _newMsgSubscription;
  StreamSubscription? _probeSubscription;
  StreamSubscription? _statusUpdatesSubscription;
  ({Contact contact, Message message})? _banner;
  ProbeStatus? _probeStatus;
  Timer? _bannerTimer;
  Timer? _probeBannerTimer;
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserStatus? _ownStatus;
  Map<String, UserStatus> _contactStatuses = {};
  Set<String> _mutedContactIds = {};
  Map<String, Uint8List> _contactAvatars = {}; // contactId → JPEG bytes

  @override
  void initState() {
    super.initState();
    _loadAll();
    _listenForIncomingCalls();
    _listenForIncomingGroupCalls();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.toLowerCase()));
    _probeSubscription = ConnectivityProbeService.instance.status.listen((s) {
      if (!mounted) return;
      setState(() => _probeStatus = s);
      if (s.phase == ProbePhase.done) {
        // Auto-hide banner 4 s after completion
        _probeBannerTimer?.cancel();
        _probeBannerTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) setState(() => _probeStatus = null);
        });
      }
    });

    _newMsgSubscription = ChatController().newMessages.listen((event) {
      final contact = ContactManager().contacts.cast<Contact?>().firstWhere(
        (c) => c?.id == event.contactId,
        orElse: () => null,
      );
      if (contact == null || !mounted) return;
      setState(() => _banner = (contact: contact, message: event.message));
      _bannerTimer?.cancel();
      _bannerTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _banner = null);
      });
    });

    _statusUpdatesSubscription = ChatController().statusUpdates.listen((_) {
      if (mounted) _loadStatuses();
    });

    _loadStatuses();
    _loadMutedChats();
    _loadContactAvatars();
  }

  @override
  void dispose() {
    _signalSubscription?.cancel();
    _groupCallSubscription?.cancel();
    _newMsgSubscription?.cancel();
    _probeSubscription?.cancel();
    _statusUpdatesSubscription?.cancel();
    _bannerTimer?.cancel();
    _probeBannerTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStatuses() async {
    final contacts = ContactManager().contacts.where((c) => !c.isGroup).toList();
    final own = await StatusService.instance.getOwnStatus();
    final contactStatuses = await StatusService.instance
        .getAllActiveStatuses(contacts.map((c) => c.id).toList());
    if (mounted) {
      setState(() {
        _ownStatus = own;
        _contactStatuses = contactStatuses;
      });
    }
  }

  Future<void> _loadContactAvatars() async {
    final prefs = await SharedPreferences.getInstance();
    final avatars = <String, Uint8List>{};
    for (final c in ContactManager().contacts) {
      final b64 = prefs.getString('contact_avatar_${c.id}');
      if (b64 != null && b64.isNotEmpty) {
        try { avatars[c.id] = base64Decode(b64); } catch (_) {}
      }
    }
    if (mounted) setState(() => _contactAvatars = avatars);
  }

  Future<void> _loadMutedChats() async {
    final prefs = await SharedPreferences.getInstance();
    final muted = <String>{};
    for (final c in ContactManager().contacts) {
      if (prefs.getBool('chat_mute_${c.id}') == true) muted.add(c.id);
    }
    if (mounted) setState(() => _mutedContactIds = muted);
  }

  Future<void> _loadAll() async {
    await ContactManager().loadContacts();
    // Pre-load room histories so last-message preview works on HomeScreen
    final ctrl = ChatController();
    for (final c in ContactManager().contacts) {
      await ctrl.loadRoomHistory(c);
    }
    if (mounted) setState(() {});
    _loadStatuses();
  }

  Future<void> _onRefresh() async {
    await ChatController().reconnectInbox();
    await _loadAll();
  }

  void _listenForIncomingCalls() {
    _signalSubscription = ChatController().incomingCalls.listen((sig) async {
      if (sig['type'] != 'webrtc_offer') return;
      final callerContact = ContactManager().contacts.cast<Contact?>().firstWhere(
        (c) => c?.databaseId == sig['senderId'] || c?.id == sig['roomId'],
        orElse: () => null,
      );
      if (callerContact != null) {
        final prefs = await SharedPreferences.getInstance();
        final myId = prefs.getString('my_device_id') ?? ChatController().identity?.id ?? '';
        if (mounted) _showIncomingCallDialog(callerContact, myId);
      }
    });
  }

  void _showIncomingCallDialog(Contact caller, String myId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Incoming Call', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Row(children: [
          _buildMiniAvatar(caller.name, 48),
          const SizedBox(width: 14),
          Expanded(child: Text('${caller.name} is calling...',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14))),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text('Decline', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.call, size: 16),
            label: Text('Accept', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CallScreen(contact: caller, myId: myId, isVideoCall: false, isCaller: false),
              ));
            },
          ),
        ],
      ).animate().scale(curve: Curves.easeOutBack),
    );
  }

  void _listenForIncomingGroupCalls() {
    _groupCallSubscription = ChatController().incomingGroupCalls.listen((sig) async {
      final groupId = sig['groupId'] as String?;
      if (groupId == null) return;
      final groupContact = ContactManager().contacts.cast<Contact?>().firstWhere(
        (c) => c?.isGroup == true && c?.id == groupId,
        orElse: () => null,
      );
      if (groupContact == null || !mounted) return;
      final myId = ChatController().identity?.id ?? '';
      _showIncomingGroupCallDialog(groupContact, myId);
    });
  }

  void _showIncomingGroupCallDialog(Contact group, String myId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Incoming Group Call',
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_rounded, color: Color(0xFF26A69A), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('${group.name} — group call incoming',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text('Decline', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.video_call_rounded, size: 16),
            label: Text('Accept', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A69A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => GroupCallScreen(
                  group: group,
                  myId: myId,
                  isCaller: false,
                  isVideoCall: true,
                ),
              ));
            },
          ),
        ],
      ).animate().scale(curve: Curves.easeOutBack),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(t.year, t.month, t.day);
    if (msgDay == today) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (msgDay == yesterday) return 'Yesterday';
    if (now.year == t.year) return '${t.day}/${t.month}';
    return '${t.day}/${t.month}/${t.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    final chatCtrl = context.watch<ChatController>();
    final contacts = ContactManager().contacts;
    final myId = chatCtrl.identity?.id ?? '';

    final filtered = _searchQuery.isEmpty
        ? contacts
        : contacts.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();

    // Sort by last message time (most recent first)
    final sorted = List<Contact>.from(filtered);
    sorted.sort((a, b) {
      final roomA = chatCtrl.getRoomForContact(a.id);
      final roomB = chatCtrl.getRoomForContact(b.id);
      final tA = roomA?.messages.isNotEmpty == true ? roomA!.messages.last.timestamp : DateTime(2000);
      final tB = roomB?.messages.isNotEmpty == true ? roomB!.messages.last.timestamp : DateTime(2000);
      return tB.compareTo(tA);
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _searchActive
          ? _buildSearchBar()
          : AppBar(
              backgroundColor: AppTheme.surface,
              elevation: 0,
              centerTitle: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Chats',
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  _buildConnectionDot(chatCtrl.connectionStatus),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                  onPressed: () => setState(() => _searchActive = true),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (value) async {
                    if (value == 'settings') {
                      await Navigator.push(context, _slideRoute(const SettingsScreen()));
                      _loadAll();
                    } else if (value == 'new_group') {
                      await Navigator.push(context, _slideRoute(const ContactsScreen(createGroup: true)));
                      _loadAll();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'new_group',
                      child: Row(children: [
                        Icon(Icons.group_add_rounded, color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text('New group', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(children: [
                        Icon(Icons.settings_rounded, color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text('Settings', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
      body: Stack(
        children: [
          contacts.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildStatusRow(contacts),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.primary,
                        backgroundColor: AppTheme.surface,
                        onRefresh: _onRefresh,
                        child: sorted.isEmpty
                            ? LayoutBuilder(
                                builder: (ctx, box) => SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: box.maxHeight),
                                    child: _buildNoResults(),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: sorted.length,
                                itemBuilder: (context, index) {
                                  final c = sorted[index];
                                  final room = chatCtrl.getRoomForContact(c.id);
                                  final messages = room?.messages ?? [];
                                  Message? lastMsg = messages.isNotEmpty ? messages.last : null;
                                  final unread = messages.where((m) => !m.isRead && m.senderId != myId).length;

                                  return _buildChatTile(
                                    context: context,
                                    contact: c,
                                    lastMsg: lastMsg,
                                    unreadCount: unread,
                                    myId: myId,
                                    isOnline: chatCtrl.isOnline(c.id),
                                  ).animate()
                                    .fadeIn(delay: Duration(milliseconds: 30 * index))
                                    .slideX(begin: 0.03, end: 0);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
          if (_banner != null)
            Positioned(
              top: 0, left: 0, right: 0,
              child: _buildBanner(_banner!),
            ),
          if (_probeStatus != null && _probeStatus!.phase != ProbePhase.idle)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildProbeBanner(_probeStatus!),
            ),
          if (chatCtrl.lanModeActive)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildLanBanner(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        elevation: 3,
        shape: const CircleBorder(),
        tooltip: 'New chat',
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
        onPressed: () => Navigator.push(
          context, _slideRoute(const ContactsScreen()),
        ).then((_) => _loadAll()),
      ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildStatusRow(List<Contact> contacts) {
    final nonGroupContacts = contacts.where((c) => !c.isGroup).toList();
    final contactsWithStatus = nonGroupContacts
        .where((c) => _contactStatuses.containsKey(c.id))
        .toList();
    final hasAnyStatus = _ownStatus != null || contactsWithStatus.isNotEmpty;

    if (!hasAnyStatus) return const SizedBox.shrink();

    return Container(
      color: AppTheme.surface,
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        children: [
          // Own status item
          _buildStatusAvatar(
            name: 'My Status',
            initial: '+',
            hue: 200,
            hasStatus: _ownStatus != null,
            isOwn: true,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatusCreatorScreen()),
              );
              if (result == true) _loadStatuses();
            },
          ),
          // Contacts with active statuses
          ...contactsWithStatus.map((c) {
            return _buildStatusAvatar(
              name: c.name,
              initial: c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
              hue: c.name.isNotEmpty
                  ? (c.name.codeUnitAt(0) * 17 + c.name.length * 31) % 360
                  : 180,
              hasStatus: true,
              isOwn: false,
              onTap: () {
                final entries = contactsWithStatus.map((cc) {
                  final s = _contactStatuses[cc.id]!;
                  return (contactId: cc.id, contactName: cc.name, status: s);
                }).toList();
                final idx = contactsWithStatus.indexOf(c);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StatusViewerScreen(
                      entries: entries,
                      initialIndex: idx,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusAvatar({
    required String name,
    required String initial,
    required int hue,
    required bool hasStatus,
    required bool isOwn,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: hasStatus
                    ? Border.all(color: AppTheme.primary, width: 2.5)
                    : Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOwn
                          ? [AppTheme.primary.withValues(alpha: 0.7), AppTheme.primary]
                          : [
                              HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
                              HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.30).toColor(),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(initial,
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: isOwn ? 22 : 18)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 58,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
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
          setState(() => _searchActive = false);
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search chats...',
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

  Widget _buildChatTile({
    required BuildContext context,
    required Contact contact,
    required Message? lastMsg,
    required int unreadCount,
    required String myId,
    bool isOnline = false,
  }) {
    final initial = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';
    final hue = (contact.name.isNotEmpty ? contact.name.codeUnitAt(0) * 17 + contact.name.length * 31 : 180) % 360;

    String subtitle = 'Tap to start chatting';
    String? timeStr;
    bool isMe = false;

    if (lastMsg != null) {
      isMe = lastMsg.senderId == myId;
      timeStr = _formatTime(lastMsg.timestamp);
      final text = lastMsg.encryptedPayload;
      if (text.startsWith('⚠️ UNENCRYPTED: ')) {
        subtitle = '⚠️ ${text.substring('⚠️ UNENCRYPTED: '.length)}';
      } else if (text.startsWith('E2EE||')) {
        subtitle = isMe ? 'Message sent' : 'Encrypted message';
      } else {
        subtitle = isMe ? 'You: $text' : text;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context, _slideRoute(ChatScreen(contact: contact)),
        ).then((_) { setState(() {}); _loadMutedChats(); _loadContactAvatars(); }),
        splashColor: AppTheme.primary.withValues(alpha: 0.07),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Avatar
              Hero(
                tag: 'contact_avatar_${contact.id}',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        gradient: _contactAvatars.containsKey(contact.id) ? null : LinearGradient(
                          colors: [
                            HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
                            HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.30).toColor(),
                          ],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        image: _contactAvatars.containsKey(contact.id) ? DecorationImage(
                          image: MemoryImage(_contactAvatars[contact.id]!),
                          fit: BoxFit.cover,
                        ) : null,
                      ),
                      child: _contactAvatars.containsKey(contact.id) ? null : Center(child: Text(initial,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700))),
                    ),
                    if (contact.isGroup)
                      Positioned(bottom: -1, right: -1,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
                          child: Icon(Icons.group_rounded, size: 13, color: AppTheme.primary),
                        ),
                      ),
                    if (!contact.isGroup && isOnline)
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.background, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 13),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(contact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                            )),
                      ),
                      if (_mutedContactIds.contains(contact.id)) ...[
                        Icon(Icons.notifications_off_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                      ],
                      if (timeStr != null)
                        Text(timeStr,
                            style: GoogleFonts.inter(
                              color: unreadCount > 0 ? AppTheme.primary : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            )),
                    ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      // E2EE lock
                      Icon(Icons.lock_rounded, size: 11, color: AppTheme.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                            )),
                      ),
                      // Unread badge
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$unreadCount',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                      // SmartRouter badge: show route count if contact has alternates
                      if (unreadCount == 0 && contact.alternateAddresses.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.shuffle_rounded,
                                size: 9, color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    final hue = name.isNotEmpty ? (name.codeUnitAt(0) * 17 + name.length * 31) % 360 : 150;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
            HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.30).toColor(),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(initial,
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.42))),
    );
  }

  Widget _buildConnectionDot(ConnectionStatus status) {
    if (status == ConnectionStatus.connecting) {
      return SizedBox(
        width: 9, height: 9,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.orange),
      );
    }
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        color: status == ConnectionStatus.connected ? AppTheme.primary : AppTheme.textSecondary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProbeBanner(ProbeStatus s) {
    final (icon, label, color) = switch (s.phase) {
      ProbePhase.directProbe => (
          Icons.wifi_find_rounded,
          'Checking network connectivity…',
          const Color(0xFF546E7A),
        ),
      ProbePhase.torBoot => (
          Icons.security_rounded,
          'Starting Tor for bootstrap…',
          const Color(0xFF37474F),
        ),
      ProbePhase.torProbe => (
          Icons.vpn_lock_rounded,
          'Finding reachable relays via Tor…',
          const Color(0xFF37474F),
        ),
      ProbePhase.done => s.found > 0
          ? (
              Icons.check_circle_outline_rounded,
              'Network ready — ${s.found} relay${s.found == 1 ? '' : 's'} found',
              const Color(0xFF2E7D32),
            )
          : (
              Icons.warning_amber_rounded,
              'No reachable relays found — messages may be delayed',
              const Color(0xFFB71C1C),
            ),
      _ => (Icons.wifi_find_rounded, '', const Color(0xFF546E7A)),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: color.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Icon(icon, color: Colors.white70, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        if (s.phase != ProbePhase.done)
          const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white60),
          ),
      ]),
    );
  }

  Widget _buildBanner(({Contact contact, Message message}) banner) {
    final contact = banner.contact;
    final msg = banner.message;
    final initial = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';
    final hue = contact.name.isNotEmpty
        ? (contact.name.codeUnitAt(0) * 17 + contact.name.length * 31) % 360
        : 180;
    String preview = msg.encryptedPayload;
    if (preview.startsWith('E2EE||')) {
      preview = '🔒 Encrypted message';
    } else if (preview.startsWith('⚠️ UNENCRYPTED: ')) {
      preview = preview.substring('⚠️ UNENCRYPTED: '.length);
    }

    return GestureDetector(
      onTap: () {
        _bannerTimer?.cancel();
        setState(() => _banner = null);
        Navigator.push(
          context, _slideRoute(ChatScreen(contact: contact)),
        ).then((_) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor(),
                    HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.30).toColor(),
                  ],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(initial,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(contact.name,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _bannerTimer?.cancel();
                setState(() => _banner = null);
              },
              child: Icon(Icons.close_rounded, size: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: -1.5, end: 0, duration: 280.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildLanBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFB45309), // amber-700
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'LAN Mode — No internet · Local network only',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.5, end: 0, duration: 280.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 42, color: AppTheme.primary.withValues(alpha: 0.6)),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text('No chats yet',
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700))
              .animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 6),
          Text('Add a contact to start chatting',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14))
              .animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: Text('New Chat', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.push(
              context, _slideRoute(const ContactsScreen()),
            ).then((_) => _loadAll()),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Text('No chats matching "$_searchQuery"',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
    );
  }
}
