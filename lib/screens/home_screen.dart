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
import '../widgets/avatar_widget.dart';
import '../widgets/status_row.dart';
import '../widgets/chat_tile.dart';
import '../widgets/connection_banner.dart';
import '../widgets/tor_chip.dart';
import '../widgets/chat_list_skeleton.dart';
import 'call_screen.dart';
import 'group_call_screen.dart';
import '../services/connectivity_probe_service.dart';
import '../services/tor_service.dart';

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
  StreamSubscription? _failoverSubscription;
  StreamSubscription? _torSubscription;
  int _torBootPercent = 0;
  bool _torRunning = false;
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
  Map<String, Uint8List> _contactAvatars = {}; // contactId -> JPEG bytes
  bool _loading = true;
  Contact? _selectedContact; // currently open chat in wide (split) mode

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
        // Share our working relays with all contacts (P2P relay exchange)
        if (s.found > 0) {
          ChatController().broadcastWorkingRelays();
        }
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

    _failoverSubscription = ChatController().failoverEvents.listen((event) {
      if (!mounted) return;
      final shortAddr = event.to.split('@').first;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transport switched \u2192 $shortAddr'),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ));
    });

    _torRunning = TorService.instance.isRunning;
    _torBootPercent = TorService.instance.bootstrapPercent;
    _torSubscription = TorService.instance.stateChanges.listen((_) {
      if (!mounted) return;
      setState(() {
        _torRunning = TorService.instance.isRunning;
        _torBootPercent = TorService.instance.bootstrapPercent;
      });
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
    _failoverSubscription?.cancel();
    _torSubscription?.cancel();
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
    if (mounted) setState(() => _loading = false);
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
          AvatarWidget(name: caller.name, size: 48, fontSize: 20),
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
            child: Text('${group.name} \u2014 group call incoming',
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

  // -- Helpers to open a chat in the appropriate mode ----

  void _openChatNarrow(Contact c) {
    Navigator.push(
      context, _slideRoute(ChatScreen(contact: c)),
    ).then((_) { setState(() {}); _loadMutedChats(); _loadContactAvatars(); });
  }

  void _openChatWide(Contact c) {
    setState(() => _selectedContact = c);
  }

  void _openChatBanner(Contact c, bool isWide) {
    _bannerTimer?.cancel();
    setState(() => _banner = null);
    if (isWide) {
      _openChatWide(c);
    } else {
      Navigator.push(
        context, _slideRoute(ChatScreen(contact: c)),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        // If we shrink below threshold while a chat is selected, clear it
        // (the user can re-open via tap); this avoids stale embedded state.
        if (!isWide && _selectedContact != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedContact = null);
          });
        }

        return isWide ? _buildWideLayout(constraints) : _buildNarrowLayout();
      },
    );
  }

  // ---- Wide (split-view) layout ----

  Widget _buildWideLayout(BoxConstraints constraints) {
    final chatCtrl = context.watch<ChatController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // Left panel — chat list with its own AppBar
          SizedBox(
            width: 360,
            child: _buildLeftPanel(chatCtrl, isWide: true),
          ),
          VerticalDivider(width: 1, thickness: 1, color: AppTheme.surfaceVariant),
          // Right panel — selected chat or placeholder
          Expanded(
            child: _selectedContact != null
                ? ChatScreen(
                    contact: _selectedContact!,
                    key: ValueKey(_selectedContact!.id),
                    embedded: true,
                    onCloseEmbedded: () => setState(() => _selectedContact = null),
                  )
                : _buildEmptyDetail(),
          ),
        ],
      ),
    );
  }

  // ---- Narrow (single-column) layout ----

  Widget _buildNarrowLayout() {
    final chatCtrl = context.watch<ChatController>();

    return _buildLeftPanel(chatCtrl, isWide: false);
  }

  // ---- Left panel (shared between wide & narrow) ----

  Widget _buildLeftPanel(ChatController chatCtrl, {required bool isWide}) {
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
                TorChip(
                  isRunning: _torRunning,
                  bootstrapPercent: _torBootPercent,
                  activePtLabel: TorService.instance.activePtLabel,
                ),
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
          _loading && contacts.isEmpty
              ? const ChatListSkeleton()
              : contacts.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    StatusRow(
                      contacts: contacts,
                      ownStatus: _ownStatus,
                      contactStatuses: _contactStatuses,
                      onOwnStatusTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StatusCreatorScreen()),
                        );
                        if (result == true) _loadStatuses();
                      },
                      onContactStatusTap: (contact, contactsWithStatus) {
                        final entries = contactsWithStatus.map((cc) {
                          final s = _contactStatuses[cc.id]!;
                          return (contactId: cc.id, contactName: cc.name, status: s);
                        }).toList();
                        final idx = contactsWithStatus.indexOf(contact);
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
                    ),
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

                                  return ChatTile(
                                    contact: c,
                                    lastMsg: lastMsg,
                                    unreadCount: unread,
                                    myId: myId,
                                    isOnline: chatCtrl.isOnline(c.id),
                                    isMuted: _mutedContactIds.contains(c.id),
                                    avatarBytes: _contactAvatars[c.id],
                                    selected: isWide && _selectedContact?.id == c.id,
                                    onTap: () => isWide ? _openChatWide(c) : _openChatNarrow(c),
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
              child: NewMessageBanner(
                contact: _banner!.contact,
                message: _banner!.message,
                onTap: () => _openChatBanner(_banner!.contact, isWide),
                onDismiss: () {
                  _bannerTimer?.cancel();
                  setState(() => _banner = null);
                },
              ),
            ),
          if (_probeStatus != null && _probeStatus!.phase != ProbePhase.idle)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: ProbeBanner(status: _probeStatus!),
            ),
          if (chatCtrl.lanModeActive)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: const LanBanner(),
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

  // ---- Empty detail placeholder (wide mode right panel) ----

  Widget _buildEmptyDetail() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 64,
                color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Select a conversation',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 16)),
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
