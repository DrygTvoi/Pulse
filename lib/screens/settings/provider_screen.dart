// Provider screen v2 — all inboxes shown as a unified list.
// Primary inbox + secondary inboxes are all active simultaneously.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../adapters/nostr_adapter.dart';
import '../../constants.dart';
import '../../controllers/chat_controller.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/waku_discovery_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../settings/settings_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider metadata
// ─────────────────────────────────────────────────────────────────────────────

const _kProviderMeta = <String, (IconData, Color)>{
  'Firebase': (Icons.local_fire_department_rounded, Color(0xFFFFAB00)),
  'Nostr':    (Icons.bolt_rounded,                  Color(0xFF9B59B6)),
  'Waku':     (Icons.hub_rounded,                   Color(0xFF00BCD4)),
  'Oxen':     (Icons.security_rounded,              Color(0xFF00695C)),
};

const _secureStorage = FlutterSecureStorage();

// ─────────────────────────────────────────────────────────────────────────────
// Main screen: inbox list
// ─────────────────────────────────────────────────────────────────────────────

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({super.key});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  String _primaryProvider = 'Firebase';
  String _primaryAddress = '';
  List<Map<String, String>> _secondaryAdapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString('byod_provider') ?? 'Firebase';
    final identity = ChatController().identity;

    String addr = '';
    switch (provider) {
      case 'Firebase':
        final dbId = identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
        try {
          final cfg = jsonDecode(identity?.adapterConfig['token'] ?? '{}');
          final url = (cfg['url'] as String? ?? '').replaceAll(RegExp(r'/$'), '');
          addr = url.isNotEmpty ? '$dbId@$url' : dbId;
        } catch (_) {
          addr = dbId;
        }
      case 'Nostr':
        final privkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
        final relay = prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
        if (privkey.isNotEmpty) {
          try {
            addr = '${deriveNostrPubkeyHex(privkey)}@$relay';
          } catch (_) {
            addr = relay;
          }
        } else {
          addr = relay;
        }
      case 'Waku':
        addr = prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
      case 'Oxen':
        addr = ChatController().myAddress;
    }

    final secondaries = await _loadSecondaryAdapters();
    if (!mounted) return;
    setState(() {
      _primaryProvider = provider;
      _primaryAddress = addr;
      _secondaryAdapters = secondaries;
      _loading = false;
    });
  }

  Future<List<Map<String, String>>> _loadSecondaryAdapters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('secondary_adapters');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Map<String, String>.from(
              (e as Map).map((k, v) => MapEntry(k.toString(), v.toString()))))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _removeSecondary(int index) async {
    final updated = List<Map<String, String>>.from(_secondaryAdapters)..removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secondary_adapters', jsonEncode(updated));
    setState(() => _secondaryAdapters = updated);
    await ChatController().reconnectInbox();
    unawaited(ChatController().broadcastAddressUpdate());
  }

  Future<void> _showAddDialog() async {
    String provider = 'Firebase';
    final fbUrlCtrl = TextEditingController();
    final fbKeyCtrl = TextEditingController();
    final nostrRelayCtrl = TextEditingController(text: kDefaultNostrRelay);
    final nostrKeyCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(
            ctx.l10n.providerAddSecondaryInbox,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 340,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Provider picker (Firebase / Nostr only for secondary)
              Row(children: [
                for (final p in ['Firebase', 'Nostr']) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => provider = p),
                      child: _providerToggle(p, selected: provider == p),
                    ),
                  ),
                  if (p != 'Nostr') const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 16),
              if (provider == 'Firebase') ...[
                settingsField(
                  controller: fbUrlCtrl,
                  hint: 'https://project.firebaseio.com',
                  label: ctx.l10n.providerDatabaseUrlLabel,
                  icon: Icons.link_rounded,
                ),
                const SizedBox(height: 10),
                settingsField(
                  controller: fbKeyCtrl,
                  hint: ctx.l10n.providerOptionalHint,
                  label: ctx.l10n.providerWebApiKeyLabel,
                  icon: Icons.key_rounded,
                  obscure: true,
                ),
              ] else ...[
                settingsField(
                  controller: nostrRelayCtrl,
                  hint: 'wss://relay.damus.io',
                  label: ctx.l10n.providerRelayUrlLabel,
                  icon: Icons.bolt_rounded,
                ),
                const SizedBox(height: 10),
                settingsField(
                  controller: nostrKeyCtrl,
                  hint: 'nsec1... or hex',
                  label: ctx.l10n.providerPrivateKeyLabel,
                  icon: Icons.vpn_key_rounded,
                  obscure: true,
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.l10n.cancel,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                if (!ctx.mounted) return;
                List<dynamic> current;
                try {
                  current = jsonDecode(prefs.getString('secondary_adapters') ?? '[]');
                } catch (_) {
                  current = [];
                }
                Map<String, String> newEntry;
                if (provider == 'Firebase') {
                  final url = fbUrlCtrl.text.trim();
                  if (url.isEmpty) { Navigator.pop(ctx); return; }
                  final key = fbKeyCtrl.text.trim();
                  final identity = ChatController().identity;
                  final userId = identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
                  newEntry = {
                    'provider': 'Firebase',
                    'databaseId': userId,
                    'selfId': userId.isNotEmpty ? '$userId@$url' : url,
                    'apiKey': jsonEncode({'url': url, 'key': key}),
                  };
                } else {
                  final relay = nostrRelayCtrl.text.trim();
                  if (relay.isEmpty) { Navigator.pop(ctx); return; }
                  final privkey = nostrKeyCtrl.text.trim();
                  if (privkey.isNotEmpty) {
                    final keySuffix = relay.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
                    await _secureStorage.write(
                        key: 'secondary_nostr_privkey_$keySuffix', value: privkey);
                  }
                  String selfId = '';
                  try {
                    if (privkey.isNotEmpty) selfId = '${deriveNostrPubkeyHex(privkey)}@$relay';
                  } catch (_) {}
                  newEntry = {
                    'provider': 'Nostr',
                    'databaseId': relay,
                    'selfId': selfId,
                  };
                }
                current.add(newEntry);
                await prefs.setString('secondary_adapters', jsonEncode(current));
                final updated = await _loadSecondaryAdapters();
                if (mounted) setState(() => _secondaryAdapters = updated);
                await ChatController().reconnectInbox();
                unawaited(ChatController().broadcastAddressUpdate());
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              ),
              child: Text(ctx.l10n.add,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );

    fbUrlCtrl.dispose();
    fbKeyCtrl.dispose();
    nostrRelayCtrl.dispose();
    nostrKeyCtrl.dispose();
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _providerToggle(String name, {required bool selected}) {
    final (_, color) = _kProviderMeta[name] ?? (Icons.circle, AppTheme.primary);
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.15) : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignTokens.spacing10),
        border: Border.all(
            color: selected ? color : AppTheme.surfaceVariant),
      ),
      child: Center(
        child: Text(name,
            style: GoogleFonts.inter(
              color: selected ? color : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            )),
      ),
    );
  }

  Widget _buildCard({
    required String provider,
    required String address,
    required bool isPrimary,
    VoidCallback? onEdit,
    VoidCallback? onRemove,
  }) {
    final (icon, color) = _kProviderMeta[provider] ??
        (Icons.inbox_rounded, AppTheme.textSecondary);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        border: isPrimary
            ? Border.all(color: color.withValues(alpha: 0.35), width: 1.5)
            : null,
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(DesignTokens.spacing10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(provider,
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('PRIMARY',
                      style: GoogleFonts.inter(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      )),
                ),
              ],
            ]),
            const SizedBox(height: 3),
            Text(
              address.isNotEmpty ? address : '—',
              style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textSecondary, fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ]),
        ),
        if (isPrimary && onEdit != null)
          IconButton(
            icon: Icon(Icons.settings_rounded,
                size: 18, color: AppTheme.textSecondary),
            tooltip: 'Edit',
            onPressed: onEdit,
          )
        else if (!isPrimary && onRemove != null)
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 18, color: AppTheme.textSecondary),
            tooltip: 'Remove',
            onPressed: onRemove,
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Inboxes',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // Hint row
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline_rounded,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'All active inboxes receive messages simultaneously. '
                      'The primary inbox is your main address shared with contacts.',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Primary inbox card
                _buildCard(
                  provider: _primaryProvider,
                  address: _primaryAddress,
                  isPrimary: true,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const _EditPrimaryScreen()),
                    );
                    _load();
                  },
                ),

                // Secondary inbox cards
                for (int i = 0; i < _secondaryAdapters.length; i++) ...[
                  const SizedBox(height: 8),
                  _buildCard(
                    provider: _secondaryAdapters[i]['provider'] ?? '',
                    address: _secondaryAdapters[i]['selfId'] ??
                        _secondaryAdapters[i]['databaseId'] ?? '',
                    isPrimary: false,
                    onRemove: () => _removeSecondary(i),
                  ),
                ],

                const SizedBox(height: 12),

                // Add inbox button
                GestureDetector(
                  onTap: _showAddDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLarge),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          width: 1),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(context.l10n.providerAddSecondaryInbox,
                              style: GoogleFonts.inter(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              )),
                        ]),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit primary inbox screen
// ─────────────────────────────────────────────────────────────────────────────

class _EditPrimaryScreen extends StatefulWidget {
  const _EditPrimaryScreen();

  @override
  State<_EditPrimaryScreen> createState() => _EditPrimaryScreenState();
}

class _EditPrimaryScreenState extends State<_EditPrimaryScreen> {
  String _selectedProvider = 'Firebase';
  final _firebaseUrlCtrl = TextEditingController();
  final _firebaseKeyCtrl = TextEditingController();
  final _nostrKeyCtrl = TextEditingController();
  final _nostrRelayCtrl = TextEditingController();
  final _wakuNodeUrlCtrl = TextEditingController(text: 'http://127.0.0.1:8645');
  final _oxenNodeUrlCtrl = TextEditingController();

  bool _isSaving = false;
  bool _showNostrAdvanced = false;
  bool _showOxenAdvanced = false;
  String? _activeNostrRelay;

  bool _wakuDiscovering = false;
  List<WakuNodeInfo>? _wakuNodes;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _firebaseUrlCtrl.dispose();
    _firebaseKeyCtrl.dispose();
    _nostrKeyCtrl.dispose();
    _nostrRelayCtrl.dispose();
    _wakuNodeUrlCtrl.dispose();
    _oxenNodeUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString('byod_provider') ?? 'Firebase';
    final savedKey = prefs.getString('byod_api_key') ?? '';
    final relay = prefs.getString('adaptive_cf_relay') ??
        prefs.getString('probe_nostr_relay') ??
        prefs.getString('nostr_relay');

    String nostrPrivkey = '';
    String nostrRelay = kDefaultNostrRelay;

    if (provider == 'Nostr') {
      nostrPrivkey =
          await _secureStorage.read(key: 'nostr_privkey') ?? '';
      nostrRelay = prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
    }

    if (!mounted) return;
    setState(() {
      _selectedProvider = provider;
      _activeNostrRelay = relay;
      if (provider == 'Firebase') {
        try {
          final decoded = jsonDecode(savedKey);
          _firebaseUrlCtrl.text = decoded['url'] ?? '';
          _firebaseKeyCtrl.text = decoded['key'] ?? '';
        } catch (_) {
          _firebaseUrlCtrl.text = savedKey;
        }
      } else if (provider == 'Nostr') {
        _nostrKeyCtrl.text = nostrPrivkey;
        _nostrRelayCtrl.text = nostrRelay;
      } else if (provider == 'Waku') {
        _wakuNodeUrlCtrl.text =
            prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
      } else if (provider == 'Oxen') {
        _oxenNodeUrlCtrl.text = prefs.getString('oxen_node_url') ?? '';
      }
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();

    String finalApiKey;
    String finalDbId;
    if (_selectedProvider == 'Firebase') {
      finalApiKey = jsonEncode({
        'url': _firebaseUrlCtrl.text.trim(),
        'key': _firebaseKeyCtrl.text.trim(),
      });
      final identity = ChatController().identity;
      finalDbId = identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
    } else if (_selectedProvider == 'Nostr') {
      await _secureStorage.write(
          key: 'nostr_privkey', value: _nostrKeyCtrl.text.trim());
      await prefs.setString('nostr_relay', _nostrRelayCtrl.text.trim());
      finalApiKey = jsonEncode({'relay': _nostrRelayCtrl.text.trim()});
      finalDbId = _nostrRelayCtrl.text.trim();
    } else if (_selectedProvider == 'Waku') {
      final nodeUrl = _wakuNodeUrlCtrl.text.trim().isNotEmpty
          ? _wakuNodeUrlCtrl.text.trim()
          : 'http://127.0.0.1:8645';
      await prefs.setString('waku_node_url', nodeUrl);
      finalApiKey = jsonEncode({'nodeUrl': nodeUrl});
      finalDbId = nodeUrl;
    } else {
      final nodeUrl = _oxenNodeUrlCtrl.text.trim();
      await prefs.setString('oxen_node_url', nodeUrl);
      finalApiKey = nodeUrl;
      finalDbId = ChatController().myAddress;
    }

    await prefs.setString('byod_provider', _selectedProvider);
    if (!['Nostr', 'Waku', 'Oxen'].contains(_selectedProvider)) {
      await prefs.setString('byod_api_key', finalApiKey);
    }
    await prefs.setString('byod_db_id', finalDbId);

    final chatCtrl = ChatController();
    if (chatCtrl.identity != null) {
      const adapterMap = {
        'Firebase': 'firebase',
        'Nostr': 'nostr',
        'Waku': 'waku',
        'Oxen': 'oxen',
      };
      chatCtrl.identity!.preferredAdapter =
          adapterMap[_selectedProvider] ?? 'firebase';
      chatCtrl.identity!.adapterConfig['token'] = finalApiKey;
      await prefs.setString(
          'user_identity', jsonEncode(chatCtrl.identity!.toJson()));
    }

    await chatCtrl.reconnectInbox();
    unawaited(chatCtrl.broadcastAddressUpdate());

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        context.l10n.settingsSavedConnectedTo(_selectedProvider),
        style: GoogleFonts.inter(),
      ),
      backgroundColor: AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _discoverWakuNodes() async {
    setState(() {
      _wakuDiscovering = true;
      _wakuNodes = null;
    });
    await WakuDiscoveryService.instance.clearCache();
    final nodes = await WakuDiscoveryService.instance.probeAll();
    if (!mounted) return;
    setState(() {
      _wakuDiscovering = false;
      _wakuNodes = nodes;
      if (_wakuNodeUrlCtrl.text.trim().isEmpty) {
        final best =
            nodes.firstWhere((n) => n.online, orElse: () => nodes.first);
        if (best.online) _wakuNodeUrlCtrl.text = best.url;
      }
    });
  }

  // ── Provider chips ────────────────────────────────────────────────────────

  Widget _buildProviderChips() {
    const providers = [
      (name: 'Firebase', icon: Icons.local_fire_department_rounded, color: Color(0xFFFFAB00)),
      (name: 'Nostr',    icon: Icons.bolt_rounded,                   color: Color(0xFF9B59B6)),
      (name: 'Waku',     icon: Icons.hub_rounded,                    color: Color(0xFF00BCD4)),
      (name: 'Oxen',     icon: Icons.security_rounded,               color: Color(0xFF00695C)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final p in providers)
          SizedBox(
            width: (MediaQuery.of(context).size.width - 40 - 24) / 4,
            child: _providerChip(p.name, p.icon, p.color),
          ),
      ],
    );
  }

  Widget _providerChip(String name, IconData icon, Color color) {
    final selected = _selectedProvider == name;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedProvider = name;
        _showNostrAdvanced = false;
        _showOxenAdvanced = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(DesignTokens.spacing10),
          border: Border.all(
            color: selected ? color : AppTheme.surfaceVariant,
            width: 1.5,
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: selected ? color : AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(name,
              style: GoogleFonts.inter(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              )),
        ]),
      ),
    );
  }

  // ── Config forms ──────────────────────────────────────────────────────────

  Widget _buildNostrInfoCard() {
    String pubkey = '';
    final privkey = _nostrKeyCtrl.text.trim();
    if (privkey.isNotEmpty) {
      try { pubkey = deriveNostrPubkeyHex(privkey); } catch (_) {}
    }
    final activeRelay = _activeNostrRelay ??
        (_nostrRelayCtrl.text.trim().isNotEmpty
            ? _nostrRelayCtrl.text.trim()
            : kDefaultNostrRelay);
    const color = Color(0xFF9B59B6);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        if (pubkey.isNotEmpty) ...[
          Row(children: [
            const Icon(Icons.vpn_key_rounded, size: 13, color: color),
            const SizedBox(width: 8),
            Text(context.l10n.providerPublicKey,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${pubkey.substring(0, 8)}...${pubkey.substring(pubkey.length - 8)}',
                style: GoogleFonts.robotoMono(color: color, fontSize: 11),
                textAlign: TextAlign.end,
              ),
            ),
          ]),
          const SizedBox(height: 6),
        ],
        Row(children: [
          const Icon(Icons.bolt_rounded, size: 13, color: color),
          const SizedBox(width: 8),
          Text(context.l10n.providerRelay,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(activeRelay,
                style: GoogleFonts.robotoMono(color: color, fontSize: 11),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      ]),
    );
  }

  Widget _buildConfig() {
    if (_selectedProvider == 'Firebase') {
      return Column(children: [
        settingsField(
          controller: _firebaseUrlCtrl,
          hint: 'https://project.firebaseio.com',
          label: context.l10n.providerDatabaseUrlLabel,
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: 12),
        settingsField(
          controller: _firebaseKeyCtrl,
          hint: context.l10n.providerOptionalForPublicDb,
          label: context.l10n.providerWebApiKeyLabel,
          icon: Icons.key_rounded,
          obscure: true,
        ),
      ]);
    }

    if (_selectedProvider == 'Nostr') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildNostrInfoCard(),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _showNostrAdvanced = !_showNostrAdvanced),
          child: Row(children: [
            Icon(
              _showNostrAdvanced
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(context.l10n.providerAdvanced,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        if (_showNostrAdvanced) ...[
          const SizedBox(height: 12),
          settingsField(
            controller: _nostrRelayCtrl,
            hint: 'wss://relay.damus.io',
            label: context.l10n.providerRelayUrlLabel,
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 12),
          settingsField(
            controller: _nostrKeyCtrl,
            hint: 'nsec1... or hex private key',
            label: context.l10n.providerPrivateKeyNsecLabel,
            icon: Icons.vpn_key_rounded,
            obscure: true,
          ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.info_outline_rounded,
                size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(context.l10n.providerKeyStoredLocally,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ),
          ]),
        ],
      ]);
    }

    if (_selectedProvider == 'Waku') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: settingsField(
              controller: _wakuNodeUrlCtrl,
              hint: context.l10n.providerWakuUrlHint,
              label: context.l10n.providerWakuUrlLabel,
              icon: Icons.hub_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: context.l10n.providerWakuProbeTooltip,
            child: SizedBox(
              height: 48,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF00BCD4).withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: _wakuDiscovering ? null : _discoverWakuNodes,
                child: _wakuDiscovering
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF00BCD4)),
                      )
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.radar_rounded,
                            size: 16, color: Color(0xFF00BCD4)),
                        const SizedBox(width: 6),
                        Text(context.l10n.settingsDiscover,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF00BCD4),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ]),
              ),
            ),
          ),
        ]),
        if (_wakuNodes != null) ...[
          const SizedBox(height: 8),
          ..._wakuNodes!.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: n.online
                      ? () => setState(() => _wakuNodeUrlCtrl.text = n.url)
                      : null,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusSmall),
                      border: _wakuNodeUrlCtrl.text == n.url
                          ? Border.all(
                              color: const Color(0xFF00BCD4), width: 1.5)
                          : null,
                    ),
                    child: Row(children: [
                      Icon(
                        n.online ? Icons.circle : Icons.circle_outlined,
                        size: 8,
                        color: n.online
                            ? const Color(0xFF4CAF50)
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(n.label,
                            style: GoogleFonts.jetBrainsMono(
                              color: n.online
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                              fontSize: 11,
                            )),
                      ),
                      Text(n.latencyLabel,
                          style: GoogleFonts.inter(
                            color: n.online
                                ? const Color(0xFF4CAF50)
                                : AppTheme.textSecondary,
                            fontSize: 11,
                          )),
                      if (n.online) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: AppTheme.textSecondary),
                      ],
                    ]),
                  ),
                ),
              )),
        ],
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.info_outline_rounded,
              size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(context.l10n.providerWakuAutoDiscovery,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ),
        ]),
      ]);
    }

    // Oxen
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.info_outline_rounded,
            size: 13, color: Color(0xFF00695C)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(context.l10n.providerOxenInfo,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ),
      ]),
      const SizedBox(height: 8),
      Builder(builder: (ctx) {
        final sessionId = ChatController().myAddress;
        if (sessionId.startsWith('05') && sessionId.length == 66) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              border: Border.all(
                  color: const Color(0xFF00695C).withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.fingerprint_rounded,
                  size: 14, color: Color(0xFF00695C)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(sessionId,
                    style: GoogleFonts.robotoMono(
                        color: const Color(0xFF00695C), fontSize: 10)),
              ),
            ]),
          );
        }
        return const SizedBox.shrink();
      }),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () => setState(() => _showOxenAdvanced = !_showOxenAdvanced),
        child: Row(children: [
          Icon(
            _showOxenAdvanced
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(context.l10n.providerAdvanced,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
      if (_showOxenAdvanced) ...[
        const SizedBox(height: 12),
        settingsField(
          controller: _oxenNodeUrlCtrl,
          hint: context.l10n.providerStorageNodeHint,
          label: context.l10n.providerStorageNodeLabel,
          icon: Icons.security_rounded,
        ),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Edit Primary Inbox',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          _buildProviderChips(),
          const SizedBox(height: 20),
          _buildConfig(),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.buttonRadius)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(context.l10n.providerSaveAndConnect,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
