import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../models/contact.dart';
import '../models/user_status.dart';
import '../services/status_service.dart';
import '../services/local_storage_service.dart';
import '../services/group_invite_link.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'create_group_dialog.dart';
import 'add_contact_dialog.dart';
import 'join_channel_dialog.dart';
import 'status_creator_screen.dart';
import 'status_viewer_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../controllers/chat_controller.dart';
import '../services/signal_dispatcher.dart';
import '../models/message.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/status_row.dart';
import '../widgets/chat_tile.dart';
import '../widgets/connection_banner.dart';

import '../widgets/chat_list_skeleton.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_search_body.dart';
import '../widgets/channel_tile.dart';
import '../models/channel.dart';
import '../models/channel_post.dart';
import '../services/channel_service.dart';
import 'channel_screen.dart';
import 'call_screen.dart';
import 'group_call_screen.dart';
import 'sfu_call_screen.dart';
import '../services/active_call_service.dart';
import '../services/connectivity_probe_service.dart';
import '../widgets/minimized_call_banner.dart';
import '../services/notification_service.dart';
import '../services/tor_service.dart';
import '../services/utls_service.dart';
import '../l10n/l10n_ext.dart';
import '../models/contact_repository.dart';
import 'package:flutter/services.dart';

PageRoute _slideRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionDuration: const Duration(milliseconds: 150),
  reverseTransitionDuration: const Duration(milliseconds: 120),
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
  StreamSubscription? _groupUpdateSubscription;
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
  Uint8List? _ownAvatarBytes;
  String _ownName = '';
  bool _loading = true;
  Contact? _selectedContact; // currently open chat in wide (split) mode
  Channel? _selectedChannel; // currently open channel in wide (split) mode
  final ScrollController _chatListScrollController = ScrollController();
  final FocusNode _homeKeyFocus = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _homeRebuildVersion = 0;
  Timer? _uiCoalesceTimer;

  // Draggable split divider
  static const double _minPanelWidth = 72.0;
  static const double _defaultPanelWidth = 360.0;
  static const String _panelWidthKey = 'home_left_panel_width';
  final ValueNotifier<double> _leftPanelWidth = ValueNotifier<double>(_defaultPanelWidth);

  // Sorted items cache — avoids re-sorting on every build when rooms haven't changed
  List<_HomeItem>? _sortedItemsCache;
  int _sortCacheVersion = -1;

  StreamSubscription? _unreadSubscription;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _listenForIncomingCalls();
    _listenForIncomingGroupCalls();
    _listenForGroupInvites();
    _listenForGroupInviteDeclines();
    _listenForGroupUpdates();
    _listenForGroupInviteLinks();
    _searchController.addListener(_onSearchChanged);
    _probeSubscription = ConnectivityProbeService.instance.status.listen((s) {
      if (!mounted) return;
      _probeStatus = s;
      _scheduleUiRefresh();
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

    _unreadSubscription = ChatController().unreadChanged.listen((contactId) {
      if (!mounted) return;
      _homeRebuildVersion++;
      _scheduleUiRefresh();
    }, onError: (e) => debugPrint('[HomeScreen] unreadChanged error: $e'));

    _newMsgSubscription = ChatController().newMessages.listen((event) {
      if (!mounted) return;
      _homeRebuildVersion++;
      final contact = context.read<IContactRepository>().findById(event.contactId);
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
      _torRunning = TorService.instance.isRunning;
      _torBootPercent = TorService.instance.bootstrapPercent;
      _scheduleUiRefresh();
    }, onError: (e) => debugPrint('[HomeScreen] tor stream error: $e'));

    // Track uTLS proxy availability for "No ECH" warning chip.
    _utlsAvailable = UTLSService.instance.available.value;
    _utlsListener = () {
      if (!mounted) return;
      _utlsAvailable = UTLSService.instance.available.value;
      _scheduleUiRefresh();
    };
    UTLSService.instance.available.addListener(_utlsListener!);

    // Listen for minimized call state changes so the banner appears/disappears.
    ActiveCallService.instance.addListener(_onActiveCallChanged);

    _loadStatuses();
    _loadMutedChats();
    _loadContactAvatars();
    _loadPanelWidth();

    // Listen to channel service changes
    ChannelService().addListener(_onChannelServiceChanged);

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

  /// Coalesce rapid non-critical UI updates into a single rebuild.
  void _scheduleUiRefresh() {
    _uiCoalesceTimer?.cancel();
    _uiCoalesceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() {});
    });
  }

  void _onActiveCallChanged() {
    // When call ends (endCall sets contact=null), reset _inCallScreen immediately
    // rather than waiting for Navigator.pop animation (.then callback).
    // Prevents second incoming offer from being silently dropped.
    // NOTE: We intentionally do NOT call _scheduleUiRefresh() here.
    // The MinimizedCallBanner is wrapped in its own ListenableBuilder, so
    // timer ticks no longer rebuild the entire HomeScreen.
    if (ActiveCallService.instance.contact == null) {
      _inCallScreen = false;
    }
  }

  void _onChannelServiceChanged() {
    if (!mounted) return;
    _sortedItemsCache = null;
    _homeRebuildVersion++;
    _scheduleUiRefresh();
  }

  @override
  void dispose() {
    ChannelService().removeListener(_onChannelServiceChanged);
    ActiveCallService.instance.removeListener(_onActiveCallChanged);
    _signalSubscription?.cancel();
    _groupCallSubscription?.cancel();
    _groupInviteSubscription?.cancel();
    _groupInviteDeclineSubscription?.cancel();
    _groupUpdateSubscription?.cancel();
    _newMsgSubscription?.cancel();
    _unreadSubscription?.cancel();
    _probeSubscription?.cancel();
    _statusUpdatesSubscription?.cancel();
    _failoverSubscription?.cancel();
    _torSubscription?.cancel();
    _uiCoalesceTimer?.cancel();
    _bannerTimer?.cancel();
    _probeBannerTimer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    if (_utlsListener != null) {
      UTLSService.instance.available.removeListener(_utlsListener!);
    }
    _leftPanelWidth.dispose();
    _chatListScrollController.dispose();
    _homeKeyFocus.dispose();
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
  /// Uses the shared `_scheduleUiRefresh` coalescer (100 ms) instead of
  /// `setState` per resolve — cold-scroll through N contacts triggers
  /// N avatar decodes that previously rebuilt the full ListView N times;
  /// coalesced, it's ~1 rebuild per 100 ms frame regardless of N.
  void _ensureAvatarLoaded(String contactId) {
    if (_avatarCache.containsKey(contactId)) return;
    if (_avatarLoadRequested.contains(contactId)) return;
    _avatarLoadRequested.add(contactId);
    LocalStorageService().loadAvatar(contactId).then((b64) {
      if (b64 != null && b64.isNotEmpty) {
        try {
          final bytes = base64Decode(b64);
          if (mounted) {
            _cacheAvatar(contactId, bytes);
            _scheduleUiRefresh();
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

  Future<void> _loadPanelWidth() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_panelWidthKey);
    if (saved != null && mounted) {
      _leftPanelWidth.value = saved;
    }
  }

  Future<void> _savePanelWidth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_panelWidthKey, _leftPanelWidth.value);
  }

  Future<void> _loadAll() async {
    final contactRepo = context.read<IContactRepository>();
    await contactRepo.loadContacts();
    // Pre-load room histories in parallel (was sequential — 25s for 50 contacts)
    final ctrl = ChatController();
    await Future.wait(contactRepo.contacts.map((c) => ctrl.loadRoomHistory(c)));
    // Init channel service
    await ChannelService().init();
    // Invalidate sorted items cache since rooms changed
    _sortedItemsCache = null;
    _homeRebuildVersion++;
    // Load own profile avatar
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      if (profileJson != null) {
        final profile = jsonDecode(profileJson) as Map<String, dynamic>;
        final name = profile['name'] as String? ?? '';
        final avatarB64 = profile['avatar'] as String?;
        if (mounted) {
          setState(() {
            _ownName = name;
            _ownAvatarBytes = (avatarB64 != null && avatarB64.isNotEmpty) ? base64Decode(avatarB64) : null;
          });
        }
      }
    } catch (e) {
      debugPrint('[Home] Failed to load own profile: $e');
    }
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
      // Strip @relay suffix to get the bare pubkey/id. The caller's senderId
      // reflects THEIR primary transport (may be Nostr, Pulse, Session, …)
      // which is frequently different from the primary we have for them
      // locally — so matching only on our stored databaseId misses the
      // call. Compare against every address we know for each contact.
      final senderBase = senderId.contains('@') ? senderId.split('@').first : senderId;
      bool contactMatches(Contact? c) {
        if (c == null) return false;
        if (c.id == sig['roomId']) return true;
        for (final addrs in c.transportAddresses.values) {
          for (final addr in addrs) {
            final base = addr.contains('@') ? addr.split('@').first : addr;
            if (base == senderBase) return true;
          }
        }
        return false;
      }
      final callerContact = context.read<IContactRepository>().contacts
          .cast<Contact?>()
          .firstWhere(contactMatches, orElse: () => null);
      if (callerContact != null) {
        final prefs = await SharedPreferences.getInstance();
        final myId = prefs.getString('my_device_id') ?? ChatController().identity?.id ?? '';
        if (mounted && !_inCallScreen) _showIncomingCallDialog(callerContact, myId);
      }
    }, onError: (e) => debugPrint('[HomeScreen] incomingCalls stream error: $e'));
  }

  void _showIncomingCallDialog(Contact caller, String myId) {
    StreamSubscription? hangupSub;
    final callerBase = caller.databaseId.contains('@')
        ? caller.databaseId.split('@').first
        : caller.databaseId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        // Listen for remote hangup while the dialog is open
        hangupSub = ChatController().signalStream.listen((sig) {
          final sigType = sig['type'] as String? ?? '';
          if (sigType != 'webrtc_hangup') return;
          final sigSender = sig['senderId'] as String? ?? '';
          final sigBase = sigSender.contains('@') ? sigSender.split('@').first : sigSender;
          if (sigBase == callerBase) {
            hangupSub?.cancel();
            if (Navigator.canPop(dialogCtx)) Navigator.pop(dialogCtx);
          }
        });

        return AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(dialogCtx.l10n.homeIncomingCallTitle, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: Row(children: [
            AvatarWidget(name: caller.name, size: DesignTokens.spacing48, fontSize: DesignTokens.fontXxl),
            const SizedBox(width: DesignTokens.spacing14),
            Expanded(child: Text(dialogCtx.l10n.homeIncomingCall(caller.name),
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg))),
          ]),
          actions: [
            TextButton(
              onPressed: () {
                hangupSub?.cancel();
                Navigator.pop(dialogCtx);
                ChatController().sendHangupSignal(caller);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: Text(dialogCtx.l10n.homeDecline, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.call, size: DesignTokens.iconSm),
              label: Text(dialogCtx.l10n.homeAccept, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium))),
              onPressed: () {
                hangupSub?.cancel();
                Navigator.pop(dialogCtx);
                _inCallScreen = true;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CallScreen(contact: caller, myId: myId, isCaller: false),
                )).then((_) => _inCallScreen = false);
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure subscription is cancelled if dialog dismissed by any other means
      hangupSub?.cancel();
    });
  }

  void _listenForIncomingGroupCalls() {
    _groupCallSubscription = ChatController().incomingGroupCalls.listen((sig) async {
      final groupId = sig['groupId'] as String?;
      if (groupId == null) return;
      if (!mounted) return;
      final groupContact = context.read<IContactRepository>().findById(groupId);
      if (groupContact == null || !mounted) return;
      final myId = ChatController().identity?.id ?? '';
      _showIncomingGroupCallDialog(groupContact, myId, sig);
    }, onError: (e) => debugPrint('[HomeScreen] incomingGroupCalls stream error: $e'));
  }

  void _showIncomingGroupCallDialog(
      Contact group, String myId, Map<String, dynamic> sig) {
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
            width: DesignTokens.spacing48, height: DesignTokens.spacing48,
            decoration: BoxDecoration(
              color: AppTheme.providerPulse.withValues(alpha: DesignTokens.opacityLight),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call_rounded,
              color: AppTheme.providerPulse,
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
              backgroundColor: AppTheme.providerPulse,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // SFU-hosted call? Skip the mesh setup and join the room
              // directly with the room id + token from the invite.
              final sfuRoomId = sig['sfuRoomId'] as String?;
              final sfuToken = sig['sfuToken'] as String?;
              if (sfuRoomId != null && sfuToken != null) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SfuCallScreen(
                    group: group,
                    myId: myId,
                    isCaller: false,
                    existingRoomId: sfuRoomId,
                    existingToken: sfuToken,
                  ),
                ));
                return;
              }
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
      ),
    );
  }

  /// Wire the deep-link `pulse://group?cfg=…` channel. main.dart pushes
  /// parsed payloads into [PendingGroupInvite.notifier]; we drain on every
  /// change and show a confirm dialog before joining.
  void _listenForGroupInviteLinks() {
    void check() {
      final invite = PendingGroupInvite.consume();
      if (invite == null || !mounted) return;
      _showGroupInviteLinkDialog(invite);
    }
    // Drain anything already sitting in the buffer (link clicked while we
    // were on the lock screen / setup) and listen for future arrivals.
    WidgetsBinding.instance.addPostFrameCallback((_) => check());
    PendingGroupInvite.notifier.addListener(check);
  }

  /// "Join group by link" — paste-the-URL dialog. Auto-fills from clipboard
  /// if it looks like a `pulse://group?cfg=…` URL so the common case is one
  /// tap. Validates the link and routes to the existing accept dialog.
  Future<void> _showJoinGroupByLinkDialog() async {
    final clip = await Clipboard.getData('text/plain');
    final initial =
        (clip?.text != null && clip!.text!.startsWith('pulse://group')) ? clip.text! : '';
    final controller = TextEditingController(text: initial);
    if (!mounted) return;
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(ctx.l10n.drawerJoinGroup,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'pulse://group?cfg=…',
            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(ctx.l10n.next,
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null || url.isEmpty) return;
    final invite = GroupInviteLink.tryParse(url);
    if (invite == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.drawerJoinGroupByLinkInvalid),
        duration: const Duration(seconds: 3),
      ));
      return;
    }
    if (!mounted) return;
    _showGroupInviteLinkDialog(invite);
  }

  void _showGroupInviteLinkDialog(GroupInvitePayload invite) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
        title: Text(ctx.l10n.groupInviteLinkTitle,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          ctx.l10n.groupInviteLinkBody(invite.name, invite.members.length),
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ChatController().acceptGroupInviteFromLink(invite);
              if (mounted) _loadAll();
            },
            child: Text(ctx.l10n.groupInviteLinkJoin,
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _listenForGroupInvites() {
    _groupInviteSubscription = ChatController().groupInvites.listen((invite) async {
      if (!mounted) return;
      // Testing baseline: auto-accept every incoming invite so invitees
      // see the group in their list immediately. Accept/Decline UI will
      // come back in a follow-up step once the rest of the group flow
      // (kick / delete propagation, messaging) is verified end-to-end.
      await ChatController().acceptGroupInvite(invite);
      if (mounted) _loadAll();
    }, onError: (e) => debugPrint('[HomeScreen] groupInvites stream error: $e'));
  }

  /// Refresh the chat list on any roster change — the group_update handler
  /// in ChatController may have removed the group locally (tombstone /
  /// self-kick) or updated its member list. Without this the chat-tile
  /// stays visible until the user manually reloads.
  void _listenForGroupUpdates() {
    _groupUpdateSubscription = ChatController().groupUpdates.listen((_) {
      if (mounted) _loadAll();
    }, onError: (e) => debugPrint('[HomeScreen] groupUpdates stream error: $e'));
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
      ),
    );
  }

  // -- Helpers to open a chat in the appropriate mode ----

  void _openChatNarrow(Contact c) {
    Navigator.push(
      context, _slideRoute(ChatScreen(contact: c)),
    ).then((_) {
      // Invalidate caches — sort order may have changed
      _sortedItemsCache = null;
      _homeRebuildVersion++;
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
        if (!isWide && (_selectedContact != null || _selectedChannel != null)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() { _selectedContact = null; _selectedChannel = null; });
          });
        }

        return isWide ? _buildWideLayout(constraints) : _buildNarrowLayout();
      },
    );
  }

  // ---- Wide (split-view) layout ----

  Widget _buildWideLayout(BoxConstraints constraints) {
    final maxPanelWidth = constraints.maxWidth * 0.5;

    // Left panel content — driven by Selector (chat data changes), NOT by drag.
    // A nested ValueListenableBuilder handles only the compactMode threshold.
    final leftPanelContent = Selector<ChatController, ({ConnectionStatus conn, int ver})>(
      selector: (_, c) => (conn: c.connectionStatus, ver: _homeRebuildVersion),
      builder: (context, data, _) {
        final chatCtrl = context.read<ChatController>();
        return ValueListenableBuilder<double>(
          valueListenable: _leftPanelWidth,
          builder: (context, width, child) {
            final compactMode = width.clamp(_minPanelWidth, maxPanelWidth) < 150;
            return _buildLeftPanel(chatCtrl, isWide: true, compactMode: compactMode);
          },
        );
      },
    );

    // Right panel — depends on _selectedContact/_selectedChannel (setState-driven),
    // but must NOT rebuild during divider drag.
    final rightPanelContent = _selectedContact != null
        ? ChatScreen(
            contact: _selectedContact!,
            key: ValueKey(_selectedContact!.id),
            embedded: true,
            onCloseEmbedded: () => setState(() => _selectedContact = null),
          )
        : _selectedChannel != null
            ? ChannelScreen(
                channel: _selectedChannel!,
                key: ValueKey('ch_${_selectedChannel!.id}'),
                embedded: true,
                onCloseEmbedded: () => setState(() => _selectedChannel = null),
              )
            : _buildEmptyDetail();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: ValueListenableBuilder<double>(
        valueListenable: _leftPanelWidth,
        // The child parameter carries widgets that do NOT depend on the notifier
        // value, so Flutter skips rebuilding them during drag.
        child: rightPanelContent,
        builder: (context, width, rightPanel) {
          final clampedWidth = width.clamp(_minPanelWidth, maxPanelWidth);

          return Stack(
            children: [
              Row(
                children: [
                  // Left panel — width driven by ValueNotifier
                  SizedBox(
                    width: clampedWidth,
                    child: leftPanelContent,
                  ),
                  // Thin divider line (0.5px, same as original)
                  Container(width: 0.5, color: AppTheme.surfaceVariant),
                  // Right panel — unchanged during drag (passed as child)
                  Expanded(child: rightPanel!),
                ],
              ),
              // Invisible drag handle over the divider
              Positioned(
                left: clampedWidth - 3,
                top: 0,
                bottom: 0,
                width: 7,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      _leftPanelWidth.value = (_leftPanelWidth.value + details.delta.dx)
                          .clamp(_minPanelWidth, maxPanelWidth);
                    },
                    onHorizontalDragEnd: (_) => _savePanelWidth(),
                    onDoubleTap: () {
                      _leftPanelWidth.value = _defaultPanelWidth;
                      _savePanelWidth();
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---- Narrow (single-column) layout ----

  Widget _buildNarrowLayout() {
    return Selector<ChatController, ({ConnectionStatus conn, int ver})>(
      selector: (_, c) => (conn: c.connectionStatus, ver: _homeRebuildVersion),
      builder: (context, data, _) {
        final chatCtrl = context.read<ChatController>();
        return _buildLeftPanel(chatCtrl, isWide: false, compactMode: false);
      },
    );
  }

  // ---- Left panel (shared between wide & narrow) ----

  List<_HomeItem> _getSortedItems(List<Contact> contacts, ChatController chatCtrl) {
    if (_sortedItemsCache != null && _homeRebuildVersion == _sortCacheVersion) {
      return _sortedItemsCache!;
    }

    final items = <_HomeItem>[];
    for (final c in contacts) {
      // Hidden contacts are routing-only scaffolds (e.g. group members
      // we know by pubkey but not as a personal contact). They must NOT
      // appear as their own chat tile, otherwise the user sees ghost
      // entries like "Member abc12345" that — when tapped — try to start
      // a brand-new 1-on-1 chat that ends up routed to whatever person
      // owns that pubkey (typically the group creator). Stay out of the
      // home list entirely; the group contact still includes them
      // for fan-out via `memberPubkeys`.
      if (c.isHidden) continue;
      final room = chatCtrl.getRoomForContact(c.id);
      final messages = room?.messages ?? [];
      final lastTime = messages.isNotEmpty ? messages.last.timestamp : DateTime(2000);
      items.add(_HomeItem.contact(c, lastTime));
    }

    final channelService = ChannelService();
    for (final ch in channelService.channels) {
      final latestPost = channelService.latestPost(ch.id);
      final lastTime = latestPost?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(ch.createdAt);
      items.add(_HomeItem.channel(ch, lastTime, latestPost));
    }

    items.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    _sortedItemsCache = items;
    _sortCacheVersion = _homeRebuildVersion;
    return _sortedItemsCache!;
  }


  Widget _buildLeftPanel(ChatController chatCtrl, {required bool isWide, required bool compactMode}) {
    final contacts = context.read<IContactRepository>().contacts;
    final myId = chatCtrl.identity?.id ?? '';

    final allItems = _getSortedItems(contacts, chatCtrl);
    final filteredItems = _searchQuery.isEmpty
        ? allItems
        : allItems.where((item) {
            final name = item.isChannel ? item.channelData!.name : item.contactData!.name;
            return name.toLowerCase().contains(_searchQuery);
          }).toList();

    return Focus(
      autofocus: true,
      focusNode: _homeKeyFocus,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        // Escape → clear search
        if (event.logicalKey == LogicalKeyboardKey.escape && _searchQuery.isNotEmpty) {
          _searchController.clear();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.background,
        drawer: HomeDrawer(
          ownName: _ownName,
          ownAvatarBytes: _ownAvatarBytes,
          connectionStatus: chatCtrl.connectionStatus,
          torRunning: _torRunning,
          torBootPercent: _torBootPercent,
          torPtLabel: TorService.instance.activePtLabel,
          showNoEch: !_utlsAvailable && _torRunning,
          onAddContact: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => AddContactDialog(onAdd: (contact) async {
                await context.read<IContactRepository>().addContact(contact);
                _loadAll();
              }),
            ).then((_) => _loadAll());
          },
          onNewGroup: () {
            Navigator.pop(context); // close drawer
            showDialog(
              context: context,
              builder: (ctx) => CreateGroupDialog(
                onCreate: (group) async {
                  final repo = context.read<IContactRepository>();
                  final ctrl = context.read<ChatController>();
                  // Fill `memberPubkeys` from our own contact list so
                  // invitees can map member UUIDs back to real Nostr
                  // identities without guessing. Then persist and invite.
                  final enriched =
                      await ctrl.enrichGroupMemberPubkeys(group);
                  await repo.addContact(enriched);
                  for (final memberId in enriched.members) {
                    final memberContact = repo.findById(memberId);
                    if (memberContact == null) continue;
                    unawaited(ctrl.sendGroupInvite(memberContact, enriched));
                  }
                  _loadAll();
                  if (!context.mounted) return;
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreen(contact: enriched),
                  ));
                },
              ),
            );
          },
          onJoinChannel: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => JoinChannelDialog(onJoined: (_) => _loadAll()),
            );
          },
          onJoinGroup: () {
            Navigator.pop(context);
            _showJoinGroupByLinkDialog();
          },
          onSettings: () {
            Navigator.pop(context);
            Navigator.push(context, _slideRoute(const SettingsScreen())).then((_) => _loadAll());
          },
        ),
        appBar: compactMode
            ? AppBar(
                backgroundColor: AppTheme.surface,
                elevation: 0,
                centerTitle: true,
                leading: const SizedBox.shrink(),
                leadingWidth: 0,
                title: IconButton(
                  icon: Icon(Icons.menu_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconLg),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  tooltip: context.l10n.settingsTitle,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(DesignTokens.spacing8),
                  constraints: const BoxConstraints(),
                ),
                actions: const [],
              )
            : AppBar(
              backgroundColor: AppTheme.surface,
              elevation: 0,
              scrolledUnderElevation: 2.0,
              shadowColor: Colors.black.withValues(alpha: DesignTokens.opacityMedium),
              centerTitle: false,
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: DesignTokens.spacing6),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconLg),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      tooltip: context.l10n.settingsTitle,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(DesignTokens.spacing8),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: DesignTokens.spacing6),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing12),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
                            const SizedBox(width: DesignTokens.spacing8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontLg),
                                decoration: InputDecoration(
                                  hintText: context.l10n.search,
                                  hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w400),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  filled: false,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () => _searchController.clear(),
                                child: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconSm),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: const [],
            ),
      body: Stack(
        children: [
          _searchQuery.isNotEmpty && !compactMode
              ? HomeSearchBody(
                  contacts: contacts,
                  chatCtrl: chatCtrl,
                  isWide: isWide,
                  searchQuery: _searchQuery,
                  globalSearching: _globalSearching,
                  globalSearchDone: _globalSearchDone,
                  globalSearchResults: _globalSearchResults,
                  avatarCache: _avatarCache,
                  mutedContactIds: _mutedContactIds,
                  selectedContact: _selectedContact,
                  onChatOpen: _openChatNarrow,
                  onChatOpenWide: _openChatWide,
                  onContextMenu: _showChatTileContextMenu,
                )
              : _buildChatsTab(contacts, filteredItems, chatCtrl, myId, isWide, compactMode: compactMode),
          Positioned(
            top: 0, left: 0, right: 0,
            child: ListenableBuilder(
              listenable: ActiveCallService.instance,
              builder: (context, _) {
                if (!ActiveCallService.instance.isMinimized) return const SizedBox.shrink();
                return MinimizedCallBanner(
                  contact: ActiveCallService.instance.contact!,
                  onTap: () {
                    final svc = ActiveCallService.instance;
                    final sig = svc.signaling;
                    final contact = svc.contact!;
                    final myId = svc.myId!;
                    final isCaller = svc.isCaller!;
                    final elapsed = svc.elapsed;
                    svc.restore();
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => CallScreen(
                        contact: contact,
                        myId: myId,
                        isCaller: isCaller,
                        existingSignaling: sig,
                        resumedDuration: elapsed,
                      ),
                    ));
                  },
                  onHangUp: () {
                    final svc = ActiveCallService.instance;
                    final contact = svc.contact;
                    final myId = svc.myId;
                    final isCaller = svc.isCaller;
                    final elapsed = svc.elapsed;
                    svc.signaling?.hangUp();
                    svc.endCall();
                    // Save call record — this path skips CallScreen._hangUp()
                    if (contact != null && myId != null && isCaller != null) {
                      unawaited(CallScreen.saveCallRecord(
                        contact: contact,
                        myId: myId,
                        isCaller: isCaller,
                        duration: elapsed,
                      ));
                    }
                  },
                );
              },
            ),
          ),
          if (_banner != null)
            Positioned(
              top: ActiveCallService.instance.isMinimized ? 56 : 0,
              left: 0, right: 0,
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
      ),
    );
  }

  Widget _buildChatsTab(List<Contact> contacts, List<_HomeItem> items, ChatController chatCtrl, String myId, bool isWide, {bool compactMode = false}) {
    final channels = ChannelService().channels;
    final hasContent = contacts.isNotEmpty || channels.isNotEmpty;
    if (_loading && !hasContent) return const ChatListSkeleton();
    if (!hasContent) return _buildEmptyState();

    return Column(
      children: [
        if (!compactMode) StatusRow(
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
            child: items.isEmpty
                ? LayoutBuilder(
                    builder: (ctx, box) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: box.maxHeight),
                        child: _buildNoResults(),
                      ),
                    ),
                  )
                : Scrollbar(
                    controller: _chatListScrollController,
                    child: ListView.builder(
                      controller: _chatListScrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        if (item.isChannel) {
                          final ch = item.channelData!;
                          final latestPost = item.latestPost;
                          return RepaintBoundary(
                            key: ValueKey('ch_${ch.id}'),
                            child: ChannelTile(
                              channel: ch,
                              latestPostPreview: latestPost?.content,
                              latestPostTime: latestPost?.createdAt,
                              selected: isWide && _selectedChannel?.id == ch.id,
                              onTap: () {
                                if (isWide) {
                                  setState(() { _selectedContact = null; _selectedChannel = ch; });
                                } else {
                                  Navigator.push(context, _slideRoute(ChannelScreen(channel: ch)))
                                      .then((_) => setState(() {}));
                                }
                              },
                            ),
                          );
                        }

                        final c = item.contactData!;
                        final room = chatCtrl.getRoomForContact(c.id);
                        final messages = room?.messages ?? [];
                        Message? lastMsg = messages.isNotEmpty ? messages.last : null;
                        final unread = chatCtrl.getUnreadCount(c.id);

                        // Lazy-load avatar when tile becomes visible
                        _ensureAvatarLoaded(c.id);

                        if (compactMode) {
                          return RepaintBoundary(
                            key: ValueKey(c.id),
                            child: _buildCompactTile(c, unread, isWide, chatCtrl),
                          );
                        }

                        return RepaintBoundary(
                          key: ValueKey(c.id),
                          child: ChatTile(
                            contact: c,
                            lastMsg: lastMsg,
                            unreadCount: unread,
                            myId: myId,
                            isOnline: chatCtrl.isOnline(c.id),
                            isMuted: _mutedContactIds.contains(c.id),
                            avatarBytes: _avatarCache[c.id],
                            selected: isWide && _selectedContact?.id == c.id,
                            onTap: () {
                              if (isWide) {
                                _selectedChannel = null;
                                _openChatWide(c);
                              } else {
                                _openChatNarrow(c);
                              }
                            },
                            onSecondaryTapUp: (details) {
                              _showChatTileContextMenu(details.globalPosition, c, chatCtrl);
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showChatTileContextMenu(Offset position, Contact c, ChatController chatCtrl) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, position.dy, position.dx, position.dy,
      ),
      color: AppTheme.surface,
      elevation: 8,
      shadowColor: Colors.black54,
      constraints: const BoxConstraints(minWidth: 200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLarge)),
      popUpAnimationStyle: AnimationStyle(duration: const Duration(milliseconds: 120)),
      items: c.isGroup
          ? _groupContextMenuItems(c, chatCtrl)
          : _contactContextMenuItems(c),
    ).then((value) async {
      if (!mounted || value == null) return;
      if (value == 'mute') {
        final newMuted = !_mutedContactIds.contains(c.id);
        await NotificationService().setChatMuted(c.id, newMuted);
        _loadMutedChats();
      } else if (value == 'clear') {
        chatCtrl.clearRoomHistory(c);
      } else if (value == 'delete') {
        // 1:1 contact: just local remove, nothing to broadcast.
        await context.read<IContactRepository>().removeContact(c.id);
        _loadAll();
      } else if (value == 'leave') {
        // Member leaves a group: remove locally. Creator-side roster
        // update (our UUID disappears) is deferred to a follow-up step;
        // today it's fire-and-forget so peers still see us in their
        // roster until the creator's next broadcast.
        await context.read<IContactRepository>().removeContact(c.id);
        _loadAll();
      } else if (value == 'delete_group') {
        // Creator deletes: tombstone sent to current members + local remove.
        await chatCtrl.deleteGroup(c);
        _loadAll();
      } else if (value == 'block') {
        await ContactManager().blockContact(c.id);
        _loadAll();
      }
    });
  }

  /// Long-press menu items for a 1:1 contact.
  List<PopupMenuEntry<String>> _contactContextMenuItems(Contact c) {
    return [
      PopupMenuItem(value: 'mute', height: 44, child: Row(children: [
        Icon(_mutedContactIds.contains(c.id) ? Icons.notifications_rounded : Icons.notifications_off_rounded,
            color: AppTheme.textSecondary, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spacing12),
        Text(_mutedContactIds.contains(c.id) ? context.l10n.appBarUnmute : context.l10n.appBarMute,
            style: GoogleFonts.inter(color: AppTheme.textPrimary)),
      ])),
      PopupMenuItem(value: 'clear', height: 44, child: Row(children: [
        Icon(Icons.delete_sweep_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spacing12),
        Text(context.l10n.profileClearChatHistory, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
      ])),
      PopupMenuItem(value: 'delete', height: 44, child: Row(children: [
        Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spacing12),
        Text(context.l10n.profileDeleteContact, style: GoogleFonts.inter(color: Colors.redAccent)),
      ])),
      PopupMenuItem(value: 'block', height: 44, child: Row(children: [
        Icon(Icons.block_rounded, color: Colors.redAccent, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spacing12),
        Text(context.l10n.blockContact, style: GoogleFonts.inter(color: Colors.redAccent)),
      ])),
    ];
  }

  /// Long-press menu items for a group. Mute + clear history are common;
  /// the destructive action is "Leave group" for members and "Delete group"
  /// for the creator. Never "Delete contact" — groups have no contact-style
  /// identity to remove. (Step 1: actions only remove locally; full
  /// group_leave / tombstone propagation comes in a later step.)
  List<PopupMenuEntry<String>> _groupContextMenuItems(Contact group, ChatController ctrl) {
    final myId = ctrl.identity?.id ?? '';
    final isCreator = group.creatorId != null && group.creatorId == myId;
    return [
      PopupMenuItem(value: 'mute', height: 44, child: Row(children: [
        Icon(_mutedContactIds.contains(group.id) ? Icons.notifications_rounded : Icons.notifications_off_rounded,
            color: AppTheme.textSecondary, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spacing12),
        Text(_mutedContactIds.contains(group.id) ? context.l10n.appBarUnmute : context.l10n.appBarMute,
            style: GoogleFonts.inter(color: AppTheme.textPrimary)),
      ])),
      PopupMenuItem(value: 'clear', height: 44, child: Row(children: [
        Icon(Icons.delete_sweep_rounded, color: AppTheme.textSecondary, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spacing12),
        Text(context.l10n.profileClearChatHistory, style: GoogleFonts.inter(color: AppTheme.textPrimary)),
      ])),
      if (isCreator)
        PopupMenuItem(value: 'delete_group', height: 44, child: Row(children: [
          Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: DesignTokens.iconMd),
          const SizedBox(width: DesignTokens.spacing12),
          Text(context.l10n.profileDeleteGroup, style: GoogleFonts.inter(color: Colors.redAccent)),
        ]))
      else
        PopupMenuItem(value: 'leave', height: 44, child: Row(children: [
          Icon(Icons.exit_to_app_rounded, color: Colors.redAccent, size: DesignTokens.iconMd),
          const SizedBox(width: DesignTokens.spacing12),
          Text(context.l10n.profileLeaveGroup, style: GoogleFonts.inter(color: Colors.redAccent)),
        ])),
    ];
  }

  Widget _buildCompactTile(Contact c, int unread, bool isWide, ChatController chatCtrl) {
    final selected = isWide && _selectedContact?.id == c.id;
    return Tooltip(
      message: c.name,
      waitDuration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => isWide ? _openChatWide(c) : _openChatNarrow(c),
        onSecondaryTapUp: (details) {
          _showChatTileContextMenu(details.globalPosition, c, chatCtrl);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          ),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarWidget(
                  name: c.name,
                  size: 44,
                  imageBytes: _avatarCache[c.id],
                  fontSize: DesignTokens.fontHeading,
                ),
                if (unread > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.background, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
                color: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityMedium)),
            const SizedBox(height: DesignTokens.spacing16),
            Text(context.l10n.homeSelectConversation,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontXl)),
          ],
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
              color: AppTheme.primary.withValues(alpha: DesignTokens.opacitySubtle),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 42, color: AppTheme.primary.withValues(alpha: DesignTokens.opacityHeavy)),
          ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
          const SizedBox(height: DesignTokens.spacing20),
          Text(context.l10n.homeNoChatsYet,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontXxl, fontWeight: FontWeight.w700))
              .animate().fadeIn(delay: 50.ms),
          const SizedBox(height: DesignTokens.spacing6),
          Text(context.l10n.homeAddContactToStart,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg))
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: DesignTokens.spacing28),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add_rounded, size: DesignTokens.fontHeading),
            label: Text(context.l10n.homeNewChat, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing28, vertical: DesignTokens.buttonPaddingV),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLarge)),
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddContactDialog(onAdd: (contact) async {
                await context.read<IContactRepository>().addContact(contact);
                _loadAll();
              }),
            ).then((_) => _loadAll()),
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Text(context.l10n.homeNoChatsMatchingQuery(_searchQuery),
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
    );
  }
}

/// Wrapper for unified home list items (contact or channel).
class _HomeItem {
  final Contact? contactData;
  final Channel? channelData;
  final DateTime lastActivity;
  final ChannelPost? latestPost;

  bool get isChannel => channelData != null;

  _HomeItem._({this.contactData, this.channelData, required this.lastActivity, this.latestPost});

  factory _HomeItem.contact(Contact c, DateTime lastActivity) =>
      _HomeItem._(contactData: c, lastActivity: lastActivity);

  factory _HomeItem.channel(Channel ch, DateTime lastActivity, ChannelPost? latestPost) =>
      _HomeItem._(channelData: ch, lastActivity: lastActivity, latestPost: latestPost);
}
