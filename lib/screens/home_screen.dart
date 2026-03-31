import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../models/user_status.dart';
import '../services/status_service.dart';
import '../services/local_storage_service.dart';
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
import '../services/signal_dispatcher.dart';
import '../models/message.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/status_row.dart';
import '../widgets/chat_tile.dart';
import '../widgets/connection_banner.dart';
import '../widgets/tor_chip.dart';
import '../widgets/chat_list_skeleton.dart';
import '../widgets/chat_filter_chips.dart';
import 'call_screen.dart';
import 'group_call_screen.dart';
import '../services/connectivity_probe_service.dart';
import '../services/tor_service.dart';
import '../services/utls_service.dart';
import '../l10n/l10n_ext.dart';
import '../models/contact_repository.dart';

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
  StreamSubscription? _groupInviteSubscription;
  StreamSubscription? _groupInviteDeclineSubscription;
  StreamSubscription? _newMsgSubscription;
  StreamSubscription? _probeSubscription;
  StreamSubscription? _statusUpdatesSubscription;
  StreamSubscription? _failoverSubscription;
  StreamSubscription? _torSubscription;
  int _torBootPercent = 0;
  bool _torRunning = false;
  bool _utlsAvailable = true; // assume available until proven otherwise
  VoidCallback? _utlsListener;
  ({Contact contact, Message message})? _banner;
  ProbeStatus? _probeStatus;
  Timer? _bannerTimer;
  Timer? _probeBannerTimer;
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Global message search state
  Timer? _searchDebounce;
  bool _globalSearching = false;
  List<({String roomId, Map<String, dynamic> message})> _globalSearchResults = [];
  bool _globalSearchDone = false; // true after a search completes (even with 0 results)
  UserStatus? _ownStatus;
  Map<String, UserStatus> _contactStatuses = {};
  Set<String> _mutedContactIds = {};
  // LRU avatar cache — keeps only the most recent _maxAvatars entries in memory
  final _avatarCache = <String, Uint8List>{};
  static const _maxAvatars = 20;
  final _avatarLoadRequested = <String>{}; // tracks lazy-load requests to avoid duplicates
  bool _loading = true;
  Contact? _selectedContact; // currently open chat in wide (split) mode
  ChatFilter _chatFilter = ChatFilter.all;

  // Sorted rooms cache — avoids re-sorting on every build when rooms haven't changed
  List<Contact>? _sortedRoomsCache;
  int _sortCacheContactCount = -1;
  int _sortCacheMsgCount = -1;

  // Unread counts cache — avoids scanning all messages per tile per rebuild
  final _unreadCounts = <String, int>{};

  @override
  void initState() {
    super.initState();
    _loadAll();
    _listenForIncomingCalls();
    _listenForIncomingGroupCalls();
    _listenForGroupInvites();
    _listenForGroupInviteDeclines();
    _searchController.addListener(_onSearchChanged);
    _probeSubscription = ConnectivityProbeService.instance.status.listen((s) {
      if (!mounted) return;
      setState(() => _probeStatus = s);
      if (s.phase == ProbePhase.done) {
        // Auto-hide banner 4 s after completion
        _probeBannerTimer?.cancel();
        _probeBannerTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) setState(() => _probeStatus = null);
        });
        // Share our working relays + TURN servers with all contacts (P2P exchange)
        if (s.found > 0) {
          ChatController().broadcastWorkingRelays();
        }
      }
    }, onError: (e) => debugPrint('[HomeScreen] probe stream error: $e'));

    _newMsgSubscription = ChatController().newMessages.listen((event) {
      if (!mounted) return;
      final contact = context.read<IContactRepository>().contacts.cast<Contact?>().firstWhere(
        (c) => c?.id == event.contactId,
        orElse: () => null,
      );
      if (contact == null || !mounted) return;
      setState(() => _banner = (contact: contact, message: event.message));
      _bannerTimer?.cancel();
      _bannerTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _banner = null);
      });
    }, onError: (e) => debugPrint('[HomeScreen] newMsg stream error: $e'));

    _statusUpdatesSubscription = ChatController().statusUpdates.listen(
      (_) { if (mounted) _loadStatuses(); },
      onError: (e) => debugPrint('[HomeScreen] statusUpdates stream error: $e'),
    );

    _failoverSubscription = ChatController().failoverEvents.listen((event) {
      if (!mounted) return;
      final shortAddr = event.to.split('@').first;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.homeTransportSwitched(shortAddr)),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ));
    }, onError: (e) => debugPrint('[HomeScreen] failover stream error: $e'));

    _torRunning = TorService.instance.isRunning;
    _torBootPercent = TorService.instance.bootstrapPercent;
    _torSubscription = TorService.instance.stateChanges.listen((_) {
      if (!mounted) return;
      setState(() {
        _torRunning = TorService.instance.isRunning;
        _torBootPercent = TorService.instance.bootstrapPercent;
      });
    }, onError: (e) => debugPrint('[HomeScreen] tor stream error: $e'));

    // Track uTLS proxy availability for "No ECH" warning chip.
    _utlsAvailable = UTLSService.instance.available.value;
    _utlsListener = () {
      if (!mounted) return;
      setState(() => _utlsAvailable = UTLSService.instance.available.value);
    };
    UTLSService.instance.available.addListener(_utlsListener!);

    _loadStatuses();
    _loadMutedChats();
    _loadContactAvatars();

    // Warn if SQLCipher is not available (DB metadata unencrypted).
    // Show only once — the user can't act on it every launch.
    if (!LocalStorageService().isSqlcipherAvailable) {
      SharedPreferences.getInstance().then((prefs) {
        const key = 'sqlcipher_warn_shown';
        if (prefs.getBool(key) == true) return;
        prefs.setBool(key, true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              context.l10n.homeDbEncryptionUnavailable,
              style: GoogleFonts.inter(fontSize: DesignTokens.fontBody),
            ),
            backgroundColor: Colors.orange.shade900,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
          ));
        });
      });
    }
  }

  @override
  void dispose() {
    _signalSubscription?.cancel();
    _groupCallSubscription?.cancel();
    _groupInviteSubscription?.cancel();
    _groupInviteDeclineSubscription?.cancel();
    _newMsgSubscription?.cancel();
    _probeSubscription?.cancel();
    _statusUpdatesSubscription?.cancel();
    _failoverSubscription?.cancel();
    _torSubscription?.cancel();
    _bannerTimer?.cancel();
    _probeBannerTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    if (_utlsListener != null) {
      UTLSService.instance.available.removeListener(_utlsListener!);
    }
    super.dispose();
  }

  Future<void> _loadStatuses() async {
    final contacts = context.read<IContactRepository>().contacts.where((c) => !c.isGroup).toList();
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

  void _cacheAvatar(String id, Uint8List bytes) {
    // Remove and re-insert to move to end (most recently used)
    _avatarCache.remove(id);
    _avatarCache[id] = bytes;
    while (_avatarCache.length > _maxAvatars) {
      _avatarCache.remove(_avatarCache.keys.first);
    }
  }

  /// Lazily load a single contact's avatar when a tile becomes visible.
  void _ensureAvatarLoaded(String contactId) {
    if (_avatarCache.containsKey(contactId)) return;
    if (_avatarLoadRequested.contains(contactId)) return;
    _avatarLoadRequested.add(contactId);
    LocalStorageService().loadAvatar(contactId).then((b64) {
      if (b64 != null && b64.isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          if (mounted) {
            setState(() => _cacheAvatar(contactId, bytes));
          }
        } catch (e) {
          debugPrint('[Home] Failed to decode avatar for $contactId: $e');
        }
      }
    });
  }

  Future<void> _loadContactAvatars() async {
    // Only pre-load a small batch (first 20) for the initially visible tiles.
    // The rest will be lazy-loaded when tiles scroll into view.
    final contactList = context.read<IContactRepository>().contacts.toList();
    final storage = LocalStorageService();
    final batch = contactList.take(_maxAvatars).toList();
    for (final c in batch) {
      final b64 = await storage.loadAvatar(c.id);
      if (b64 != null && b64.isNotEmpty) {
        try {
          _cacheAvatar(c.id, base64Decode(b64));
          _avatarLoadRequested.add(c.id);
        } catch (e) {
          debugPrint('[Home] Failed to decode avatar for ${c.id}: $e');
        }
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadMutedChats() async {
    final contactList = context.read<IContactRepository>().contacts.toList();
    final prefs = await SharedPreferences.getInstance();
    final muted = <String>{};
    for (final c in contactList) {
      if (prefs.getBool('chat_mute_${c.id}') == true) muted.add(c.id);
    }
    if (mounted) setState(() => _mutedContactIds = muted);
  }

  Future<void> _loadAll() async {
    final contactRepo = context.read<IContactRepository>();
    await contactRepo.loadContacts();
    // Pre-load room histories in parallel (was sequential — 25s for 50 contacts)
    final ctrl = ChatController();
    await Future.wait(contactRepo.contacts.map((c) => ctrl.loadRoomHistory(c)));
    // Invalidate sorted rooms cache since rooms changed
    _sortedRoomsCache = null;
    _sortCacheContactCount = -1;
    _sortCacheMsgCount = -1;
    if (mounted) setState(() => _loading = false);
    _loadStatuses();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    setState(() => _searchQuery = text.toLowerCase());
    _searchDebounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() {
        _globalSearchResults = [];
        _globalSearching = false;
        _globalSearchDone = false;
      });
      return;
    }
    // Debounce 300ms before firing the expensive decrypt-and-search.
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _runGlobalSearch(text.trim());
    });
  }

  Future<void> _runGlobalSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _globalSearching = true;
      _globalSearchDone = false;
    });
    try {
      final results = await LocalStorageService().searchMessages(
        query,
        limit: 50,
      );
      if (!mounted) return;
      // Only apply if the query hasn't changed while we were searching.
      if (_searchController.text.trim() == query) {
        setState(() {
          _globalSearchResults = results;
          _globalSearching = false;
          _globalSearchDone = true;
        });
      }
    } catch (e) {
      debugPrint('[HomeScreen] Global search error: $e');
      if (mounted) {
        setState(() {
          _globalSearching = false;
          _globalSearchDone = true;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await ChatController().reconnectInbox();
    await _loadAll();
  }

  bool _inCallScreen = false; // prevent duplicate incoming call dialogs

  void _listenForIncomingCalls() {
    _signalSubscription = ChatController().incomingCalls.listen((sig) async {
      if (sig['type'] != 'webrtc_offer') return;
      if (!mounted || _inCallScreen) return;
      final senderId = sig['senderId'] as String? ?? '';
      // Strip @relay suffix: senderId from Nostr is bare pubkey but
      // contact.databaseId includes @wss://relay — compare base parts.
      final senderBase = senderId.contains('@') ? senderId.split('@').first : senderId;
      final callerContact = context.read<IContactRepository>().contacts.cast<Contact?>().firstWhere(
        (c) {
          final dbBase = (c?.databaseId ?? '').contains('@')
              ? c!.databaseId.split('@').first
              : (c?.databaseId ?? '');
          return dbBase == senderBase || c?.id == sig['roomId'];
        },
        orElse: () => null,
      );
      if (callerContact != null) {
        final prefs = await SharedPreferences.getInstance();
        final myId = prefs.getString('my_device_id') ?? ChatController().identity?.id ?? '';
        if (mounted && !_inCallScreen) _showIncomingCallDialog(callerContact, myId);
      }
    }, onError: (e) => debugPrint('[HomeScreen] incomingCalls stream error: $e'));
  }

  void _showIncomingCallDialog(Contact caller, String myId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(context.l10n.homeIncomingCallTitle, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Row(children: [
          AvatarWidget(name: caller.name, size: 48, fontSize: DesignTokens.fontXxl),
          const SizedBox(width: DesignTokens.spacing14),
          Expanded(child: Text(context.l10n.homeIncomingCall(caller.name),
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg))),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(context.l10n.homeDecline, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.call, size: DesignTokens.iconSm),
            label: Text(context.l10n.homeAccept, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium))),
            onPressed: () {
              Navigator.pop(context);
              _inCallScreen = true;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CallScreen(contact: caller, myId: myId, isCaller: false),
              )).then((_) => _inCallScreen = false);
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
      if (!mounted) return;
      final groupContact = context.read<IContactRepository>().contacts.cast<Contact?>().firstWhere(
        (c) => c?.isGroup == true && c?.id == groupId,
        orElse: () => null,
      );
      if (groupContact == null || !mounted) return;
      final myId = ChatController().identity?.id ?? '';
      _showIncomingGroupCallDialog(groupContact, myId);
    }, onError: (e) => debugPrint('[HomeScreen] incomingGroupCalls stream error: $e'));
  }

  void _showIncomingGroupCallDialog(Contact group, String myId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(context.l10n.homeIncomingGroupCallTitle,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call_rounded,
              color: const Color(0xFF26A69A),
              size: DesignTokens.iconLg,
            ),
          ),
          const SizedBox(width: DesignTokens.spacing14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(group.name,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: DesignTokens.fontXl,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: DesignTokens.spacing4),
                Text(
                  context.l10n.homeGroupCallIncoming(context.l10n.callAudio),
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: DesignTokens.fontBody),
                ),
              ],
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(context.l10n.homeDecline, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.call_rounded, size: DesignTokens.iconSm),
            label: Text(context.l10n.homeAccept, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A69A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => GroupCallScreen(
                  group: group,
                  myId: myId,
                  isCaller: false,
                ),
              ));
            },
          ),
        ],
      ).animate().scale(curve: Curves.easeOutBack),
    );
  }

  void _listenForGroupInvites() {
    _groupInviteSubscription = ChatController().groupInvites.listen((invite) {
      if (!mounted) return;
      _showGroupInviteDialog(invite);
    }, onError: (e) => debugPrint('[HomeScreen] groupInvites stream error: $e'));
  }

  void _listenForGroupInviteDeclines() {
    _groupInviteDeclineSubscription =
        ChatController().groupInviteDeclines.listen((e) {
      if (!mounted) return;
      // Find the group name from local contacts for a human-readable snackbar.
      final group = context
          .read<IContactRepository>()
          .contacts
          .cast<Contact?>()
          .firstWhere((c) => c?.isGroup == true && c?.id == e.groupId,
              orElse: () => null);
      final groupName = group?.name ?? e.groupId;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.groupInviteDeclinedSnackbar(
            e.fromContact.name, groupName)),
        duration: const Duration(seconds: 3),
      ));
    }, onError: (err) =>
            debugPrint('[HomeScreen] groupInviteDeclines error: $err'));
  }

  void _showGroupInviteDialog(SignalGroupInviteEvent invite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(context.l10n.groupInviteTitle,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          context.l10n.groupInviteBody(invite.fromContact.name, invite.groupName),
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ChatController().declineGroupInvite(invite);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: Text(context.l10n.groupInviteDecline, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await ChatController().acceptGroupInvite(invite);
              if (mounted) _loadAll();
            },
            child: Text(context.l10n.groupInviteAccept, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ).animate().scale(curve: Curves.easeOutBack),
    );
  }

  // -- Helpers to open a chat in the appropriate mode ----

  void _openChatNarrow(Contact c) {
    Navigator.push(
      context, _slideRoute(ChatScreen(contact: c)),
    ).then((_) {
      // Invalidate caches — unread counts and sort order may have changed
      _sortedRoomsCache = null;
      _sortCacheContactCount = -1;
      _sortCacheMsgCount = -1;
      _unreadCounts.clear();
      setState(() {});
      _loadMutedChats();
      _loadContactAvatars();
    });
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // Left panel — chat list with its own AppBar
          SizedBox(
            width: 360,
            child: Consumer<ChatController>(
              builder: (context, chatCtrl, _) => _buildLeftPanel(chatCtrl, isWide: true),
            ),
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
    return Consumer<ChatController>(
      builder: (context, chatCtrl, _) => _buildLeftPanel(chatCtrl, isWide: false),
    );
  }

  // ---- Left panel (shared between wide & narrow) ----

  List<Contact> _getSortedContacts(List<Contact> contacts, int totalMsgCount, ChatController chatCtrl) {
    if (_sortedRoomsCache != null &&
        contacts.length == _sortCacheContactCount &&
        totalMsgCount == _sortCacheMsgCount) {
      return _sortedRoomsCache!;
    }
    _sortedRoomsCache = [...contacts]..sort((a, b) {
      final roomA = chatCtrl.getRoomForContact(a.id);
      final roomB = chatCtrl.getRoomForContact(b.id);
      final tA = roomA?.messages.isNotEmpty == true ? roomA!.messages.last.timestamp : DateTime(2000);
      final tB = roomB?.messages.isNotEmpty == true ? roomB!.messages.last.timestamp : DateTime(2000);
      return tB.compareTo(tA);
    });
    _sortCacheContactCount = contacts.length;
    _sortCacheMsgCount = totalMsgCount;
    // Refresh unread counts when sort cache is rebuilt
    _unreadCounts.clear();
    return _sortedRoomsCache!;
  }

  int _getUnreadCount(String contactId, String myId, ChatController chatCtrl) {
    if (_unreadCounts.containsKey(contactId)) return _unreadCounts[contactId]!;
    final room = chatCtrl.getRoomForContact(contactId);
    final messages = room?.messages ?? [];
    final count = messages.where((m) => !m.isRead && m.senderId != myId).length;
    _unreadCounts[contactId] = count;
    return count;
  }

  List<Contact> _applyFilter(List<Contact> contacts, String myId, ChatController chatCtrl) {
    switch (_chatFilter) {
      case ChatFilter.all:
        return contacts;
      case ChatFilter.unread:
        return contacts.where((c) => _getUnreadCount(c.id, myId, chatCtrl) > 0).toList();
      case ChatFilter.groups:
        return contacts.where((c) => c.isGroup).toList();
    }
  }

  Widget _buildLeftPanel(ChatController chatCtrl, {required bool isWide}) {
    final contacts = context.read<IContactRepository>().contacts;
    final myId = chatCtrl.identity?.id ?? '';

    // Compute total message count for cache invalidation
    final totalMsgCount = contacts.fold<int>(0, (sum, c) {
      final room = chatCtrl.getRoomForContact(c.id);
      return sum + (room?.messages.length ?? 0);
    });

    final allSorted = _getSortedContacts(contacts, totalMsgCount, chatCtrl);
    final searchFiltered = _searchQuery.isEmpty
        ? allSorted
        : allSorted.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();
    final sorted = _applyFilter(searchFiltered, myId, chatCtrl);

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
                  Text('Pulse',
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontDisplay, fontWeight: FontWeight.w700)),
                  const SizedBox(width: DesignTokens.spacing8),
                  _buildConnectionDot(chatCtrl.connectionStatus),
                ],
              ),
              actions: [
                // "No ECH" warning: shown when uTLS proxy is down but
                // Tor/Psiphon is active (censored network detected).
                if (!_utlsAvailable && _torRunning)
                  Tooltip(
                    message: context.l10n.homeNoEchTooltip,
                    child: Padding(
                      padding: const EdgeInsets.only(right: DesignTokens.spacing4),
                      child: Chip(
                        label: Text(context.l10n.homeNoEch,
                            style: const TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600)),
                        backgroundColor: Colors.amber.shade700,
                        labelStyle: const TextStyle(color: Colors.black87),
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                TorChip(
                  isRunning: _torRunning,
                  bootstrapPercent: _torBootPercent,
                  activePtLabel: TorService.instance.activePtLabel,
                ),
                IconButton(
                  icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                  tooltip: context.l10n.search,
                  onPressed: () => setState(() => _searchActive = true),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                  tooltip: context.l10n.moreOptions,
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLarge)),
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
                        Icon(Icons.group_add_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
                        const SizedBox(width: DesignTokens.spacing12),
                        Text(context.l10n.homeNewGroup, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(children: [
                        Icon(Icons.settings_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
                        const SizedBox(width: DesignTokens.spacing12),
                        Text(context.l10n.homeSettings, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
      body: Stack(
        children: [
          _searchActive && _searchQuery.isNotEmpty
              ? _buildGlobalSearchBody(contacts, chatCtrl, isWide)
              : _buildChatsTab(contacts, sorted, chatCtrl, myId, isWide),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.fabRadius)),
        tooltip: context.l10n.homeNewChatTooltip,
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: DesignTokens.fontDisplay),
        onPressed: () {
          Navigator.push(context, _slideRoute(const ContactsScreen())).then((_) => _loadAll());
        },
      ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildChatsTab(List<Contact> contacts, List<Contact> sorted, ChatController chatCtrl, String myId, bool isWide) {
    if (_loading && contacts.isEmpty) return const ChatListSkeleton();
    if (contacts.isEmpty) return _buildEmptyState();
    return Column(
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
        ChatFilterChips(
          selected: _chatFilter,
          onChanged: (f) => setState(() => _chatFilter = f),
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
                      final unread = _getUnreadCount(c.id, myId, chatCtrl);

                      // Lazy-load avatar when tile becomes visible
                      _ensureAvatarLoaded(c.id);

                      return ChatTile(
                        contact: c,
                        lastMsg: lastMsg,
                        unreadCount: unread,
                        myId: myId,
                        isOnline: chatCtrl.isOnline(c.id),
                        isMuted: _mutedContactIds.contains(c.id),
                        avatarBytes: _avatarCache[c.id],
                        selected: isWide && _selectedContact?.id == c.id,
                        onTap: () => isWide ? _openChatWide(c) : _openChatNarrow(c),
                      );
                    },
                  ),
          ),
        ),
      ],
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
            const SizedBox(height: DesignTokens.spacing16),
            Text(context.l10n.homeSelectConversation,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontXl)),
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
        tooltip: context.l10n.closeSearch,
        onPressed: () {
          _searchController.clear();
          setState(() {
            _searchActive = false;
            _globalSearchResults = [];
            _globalSearching = false;
            _globalSearchDone = false;
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontXl),
        decoration: InputDecoration(
          hintText: context.l10n.searchMessages,
          hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontXl),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          filled: false,
        ),
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
            tooltip: context.l10n.clearSearch,
            onPressed: () {
              _searchController.clear();
            },
          ),
      ],
    );
  }

  Widget _buildConnectionDot(ConnectionStatus status) {
    final label = switch (status) {
      ConnectionStatus.connected   => context.l10n.connected,
      ConnectionStatus.connecting  => context.l10n.connecting,
      ConnectionStatus.disconnected => context.l10n.disconnected,
    };
    if (status == ConnectionStatus.connecting) {
      return Tooltip(
        message: label,
        child: SizedBox(
          width: 9, height: 9,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.orange),
        ),
      );
    }
    return Tooltip(
      message: label,
      child: Container(
        width: DesignTokens.spacing8, height: DesignTokens.spacing8,
        decoration: BoxDecoration(
          color: status == ConnectionStatus.connected ? AppTheme.primary : AppTheme.textSecondary,
          shape: BoxShape.circle,
        ),
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
          const SizedBox(height: DesignTokens.spacing20),
          Text(context.l10n.homeNoChatsYet,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontXxl, fontWeight: FontWeight.w700))
              .animate().fadeIn(delay: 150.ms),
          const SizedBox(height: DesignTokens.spacing6),
          Text(context.l10n.homeAddContactToStart,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg))
              .animate().fadeIn(delay: 250.ms),
          const SizedBox(height: DesignTokens.spacing28),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add_rounded, size: DesignTokens.fontHeading),
            label: Text(context.l10n.homeNewChat, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing28, vertical: DesignTokens.buttonPaddingV),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLarge)),
            ),
            onPressed: () => Navigator.push(
              context, _slideRoute(const ContactsScreen()),
            ).then((_) => _loadAll()),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // ── Global search results body ──────────────────────────────────────────────

  Widget _buildGlobalSearchBody(List<Contact> contacts, ChatController chatCtrl, bool isWide) {
    // 1. Contact name matches (instant, no decryption needed).
    final contactMatches = contacts
        .where((c) => c.name.toLowerCase().contains(_searchQuery))
        .toList();

    // 2. Build a roomId → Contact lookup for message results.
    final contactByStorageKey = <String, Contact>{};
    for (final c in contacts) {
      contactByStorageKey[c.storageKey] = c;
    }

    // 3. Group message results by roomId.
    final groupedMessages = <String, List<Map<String, dynamic>>>{};
    for (final r in _globalSearchResults) {
      groupedMessages.putIfAbsent(r.roomId, () => []).add(r.message);
    }

    // Total section count.
    final hasContactSection = contactMatches.isNotEmpty;
    final hasMessageSection = groupedMessages.isNotEmpty;
    final bool showEmpty = _globalSearchDone && !_globalSearching &&
        !hasContactSection && !hasMessageSection;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Loading indicator.
        if (_globalSearching)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: DesignTokens.iconSm, height: DesignTokens.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing10),
                  Text(context.l10n.homeSearching,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
                ],
              ),
            ),
          ),

        // Contact name matches section.
        if (hasContactSection) ...[
          _buildSectionHeader(context.l10n.homeSectionChats),
          ...contactMatches.map((c) {
            final room = chatCtrl.getRoomForContact(c.id);
            final messages = room?.messages ?? [];
            final lastMsg = messages.isNotEmpty ? messages.last : null;
            final myId = chatCtrl.identity?.id ?? '';
            final unread = _getUnreadCount(c.id, myId, chatCtrl);
            return ChatTile(
              contact: c,
              lastMsg: lastMsg,
              unreadCount: unread,
              myId: myId,
              isOnline: chatCtrl.isOnline(c.id),
              isMuted: _mutedContactIds.contains(c.id),
              avatarBytes: _avatarCache[c.id],
              selected: isWide && _selectedContact?.id == c.id,
              onTap: () => isWide ? _openChatWide(c) : _openChatNarrow(c),
            );
          }),
        ],

        // Message search results section.
        if (hasMessageSection) ...[
          _buildSectionHeader(context.l10n.homeSectionMessages),
          ...groupedMessages.entries.expand((entry) {
            final contact = contactByStorageKey[entry.key];
            if (contact == null) return <Widget>[];
            return entry.value.map((msgJson) =>
                _buildMessageSearchTile(contact, msgJson, isWide));
          }),
        ],

        // No results.
        if (showEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 48,
                      color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: DesignTokens.spacing12),
                  Text(context.l10n.homeNoResults,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacing16, DesignTokens.spacing14, DesignTokens.spacing16, DesignTokens.spacing6),
      child: Text(title,
          style: GoogleFonts.inter(
            color: AppTheme.primary,
            fontSize: DesignTokens.fontMd,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          )),
    );
  }

  Widget _buildMessageSearchTile(Contact contact, Map<String, dynamic> msgJson, bool isWide) {
    final payload = msgJson['encryptedPayload'] as String? ?? '';
    final timestampStr = msgJson['timestamp']?.toString() ?? '';
    final timestamp = DateTime.tryParse(timestampStr) ?? DateTime(2000);
    final timeStr = _formatSearchTime(timestamp);

    // Build a snippet with the match highlighted.
    final snippet = _buildSnippet(payload, _searchQuery);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isWide) {
            _openChatWide(contact);
          } else {
            _openChatNarrow(contact);
          }
        },
        splashColor: AppTheme.primary.withValues(alpha: 0.07),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12, vertical: DesignTokens.spacing10),
          child: Row(
            children: [
              AvatarWidget(
                name: contact.name,
                size: 44,
                imageBytes: _avatarCache[contact.id],
                fontSize: DesignTokens.fontHeading,
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(contact.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: AppTheme.textPrimary,
                                fontSize: DesignTokens.fontLg,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        Text(timeStr,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: DesignTokens.fontSm,
                            )),
                      ],
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: snippet,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _buildSnippet(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final idx = lowerText.indexOf(lowerQuery);
    if (idx < 0) {
      // Shouldn't happen, but safety fallback.
      return TextSpan(
        text: text.length > 100 ? '${text.substring(0, 100)}...' : text,
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
      );
    }

    // Show context around the match: up to 20 chars before, the match, then after.
    final start = (idx - 20).clamp(0, text.length);
    final end = (idx + query.length + 40).clamp(0, text.length);
    final prefix = start > 0 ? '...' : '';
    final suffix = end < text.length ? '...' : '';

    final before = text.substring(start, idx);
    final match = text.substring(idx, idx + query.length);
    final after = text.substring(idx + query.length, end);

    return TextSpan(
      children: [
        TextSpan(
          text: '$prefix$before',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
        ),
        TextSpan(
          text: match,
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: DesignTokens.fontMd,
            fontWeight: FontWeight.w700,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
          ),
        ),
        TextSpan(
          text: '$after$suffix',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd),
        ),
      ],
    );
  }

  String _formatSearchTime(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(t.year, t.month, t.day);
    if (msgDay == today) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (msgDay == yesterday) return context.l10n.chatYesterday;
    if (now.year == t.year) return '${t.day}/${t.month}';
    return '${t.day}/${t.month}/${t.year % 100}';
  }

  Widget _buildNoResults() {
    return Center(
      child: Text(context.l10n.homeNoChatsMatchingQuery(_searchQuery),
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
    );
  }
}
