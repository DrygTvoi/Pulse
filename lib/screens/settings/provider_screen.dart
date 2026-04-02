// Provider screen — flat single-screen layout.
// Provider chips + inline config + save button + secondary inboxes.
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../adapters/nostr_adapter.dart';
import '../../constants.dart';
import '../../controllers/chat_controller.dart';
import '../../l10n/l10n_ext.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../settings/settings_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider metadata
// ─────────────────────────────────────────────────────────────────────────────

const _kProviderMeta = <String, (IconData, Color)>{
  'Firebase': (Icons.local_fire_department_rounded, Color(0xFFFFAB00)),
  'Nostr':    (Icons.bolt_rounded,                  Color(0xFF9B59B6)),
  'Session':  (Icons.security_rounded,              Color(0xFF00695C)),
  'Pulse':    (Icons.dns_rounded,                   Color(0xFF2196F3)),
};

const _secureStorage = FlutterSecureStorage();

// ─────────────────────────────────────────────────────────────────────────────
// Single flat screen: provider config + secondary inboxes
// ─────────────────────────────────────────────────────────────────────────────

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({super.key});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  // Primary provider config
  String _selectedProvider = 'Firebase';
  final _firebaseUrlCtrl = TextEditingController();
  final _firebaseKeyCtrl = TextEditingController();
  final _nostrKeyCtrl = TextEditingController();
  final _nostrRelayCtrl = TextEditingController();
  final _sessionNodeUrlCtrl = TextEditingController();
  final _pulseServerUrlCtrl = TextEditingController();
  final _pulseInviteCtrl = TextEditingController();

  bool _isSaving = false;
  bool _showNostrAdvanced = false;
  bool _showSessionAdvanced = false;

  // Secondary inboxes
  List<Map<String, String>> _secondaryAdapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firebaseUrlCtrl.dispose();
    _firebaseKeyCtrl.dispose();
    _nostrKeyCtrl.dispose();
    _nostrRelayCtrl.dispose();
    _sessionNodeUrlCtrl.dispose();
    _pulseServerUrlCtrl.dispose();
    _pulseInviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = prefs.getString('byod_provider') ?? 'Firebase';
    final savedKey = prefs.getString('byod_api_key') ?? '';

    String nostrPrivkey = '';
    String nostrRelay = kDefaultNostrRelay;

    if (provider == 'Nostr') {
      nostrPrivkey = await _secureStorage.read(key: 'nostr_privkey') ?? '';
      nostrRelay = prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
    }

    final secondaries = await _loadSecondaryAdapters();
    if (!mounted) return;
    setState(() {
      _selectedProvider = provider;
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
      } else if (provider == 'Session') {
        _sessionNodeUrlCtrl.text = prefs.getString('session_node_url') ?? prefs.getString('oxen_node_url') ?? '';
      } else if (provider == 'Pulse') {
        _pulseServerUrlCtrl.text = prefs.getString('pulse_server_url') ?? '';
        _pulseInviteCtrl.text = prefs.getString('pulse_invite_code') ?? '';
      }
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

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _isValidUrl(String url, {required List<String> schemes}) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    return schemes.contains(uri.scheme);
  }

  /// Returns error message if current provider config is invalid, null if OK.
  String? _validateConfig() {
    switch (_selectedProvider) {
      case 'Firebase':
        final url = _firebaseUrlCtrl.text.trim();
        if (url.isNotEmpty && !_isValidUrl(url, schemes: ['https', 'http'])) {
          return context.l10n.providerErrorInvalidFirebaseUrl;
        }
      case 'Nostr':
        final relay = _nostrRelayCtrl.text.trim();
        if (relay.isNotEmpty && !_isValidUrl(relay, schemes: ['wss', 'ws'])) {
          return context.l10n.providerErrorInvalidRelayUrl;
        }
      case 'Pulse':
        final url = _pulseServerUrlCtrl.text.trim();
        if (url.isNotEmpty && !_isValidUrl(url, schemes: ['https', 'http'])) {
          return context.l10n.providerErrorInvalidPulseUrl;
        }
    }
    return null;
  }

  // ── Save primary ──────────────────────────────────────────────────────────

  Future<void> _saveSettings() async {
    final error = _validateConfig();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error, style: GoogleFonts.inter()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
      ));
      return;
    }
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
      ChatController().invalidateNostrPrivkeyCache();
      await prefs.setString('nostr_relay', _nostrRelayCtrl.text.trim());
      finalApiKey = jsonEncode({'relay': _nostrRelayCtrl.text.trim()});
      finalDbId = _nostrRelayCtrl.text.trim();
    } else if (_selectedProvider == 'Pulse') {
      final serverUrl = _pulseServerUrlCtrl.text.trim();
      final invite = _pulseInviteCtrl.text.trim();
      await prefs.setString('pulse_server_url', serverUrl);
      await prefs.setString('pulse_invite_code', invite);
      // Private key is derived from recovery password; read from secure storage
      final privkey = await _secureStorage.read(key: 'pulse_privkey') ?? '';
      finalApiKey = jsonEncode({'privkey': privkey, 'serverUrl': serverUrl, 'invite': invite});
      finalDbId = serverUrl;
    } else {
      final nodeUrl = _sessionNodeUrlCtrl.text.trim();
      await prefs.setString('session_node_url', nodeUrl);
      finalApiKey = nodeUrl;
      finalDbId = ChatController().myAddress;
    }

    await prefs.setString('byod_provider', _selectedProvider);
    if (!['Nostr', 'Session', 'Pulse'].contains(_selectedProvider)) {
      await prefs.setString('byod_api_key', finalApiKey);
    }
    await prefs.setString('byod_db_id', finalDbId);

    final chatCtrl = ChatController();
    if (chatCtrl.identity != null) {
      const adapterMap = {
        'Firebase': 'firebase',
        'Nostr': 'nostr',
        'Session': 'session',
        'Pulse': 'pulse',
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
  }

  // ── Secondary inboxes ─────────────────────────────────────────────────────

  Future<void> _removeSecondary(int index) async {
    final updated = List<Map<String, String>>.from(_secondaryAdapters)
      ..removeAt(index);
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
                  hint: ctx.l10n.providerFirebaseUrlHint,
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
                  hint: ctx.l10n.providerNostrRelayHint,
                  label: ctx.l10n.providerRelayUrlLabel,
                  icon: Icons.bolt_rounded,
                ),
                const SizedBox(height: 10),
                settingsField(
                  controller: nostrKeyCtrl,
                  hint: ctx.l10n.providerNostrPrivkeyHint,
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
                // Validate URLs before saving
                if (provider == 'Firebase') {
                  final url = fbUrlCtrl.text.trim();
                  if (url.isEmpty) { Navigator.pop(ctx); return; }
                  if (!_isValidUrl(url, schemes: ['https', 'http'])) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(ctx.l10n.providerErrorInvalidFirebaseUrl),
                      backgroundColor: Colors.redAccent,
                    ));
                    return;
                  }
                } else {
                  final relay = nostrRelayCtrl.text.trim();
                  if (relay.isEmpty) { Navigator.pop(ctx); return; }
                  if (!_isValidUrl(relay, schemes: ['wss', 'ws'])) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(ctx.l10n.providerErrorInvalidRelayUrl),
                      backgroundColor: Colors.redAccent,
                    ));
                    return;
                  }
                }
                final prefs = await SharedPreferences.getInstance();
                if (!ctx.mounted) return;
                List<dynamic> current;
                try {
                  current = jsonDecode(
                      prefs.getString('secondary_adapters') ?? '[]');
                } catch (_) {
                  current = [];
                }
                Map<String, String> newEntry;
                if (provider == 'Firebase') {
                  final url = fbUrlCtrl.text.trim();
                  final key = fbKeyCtrl.text.trim();
                  final identity = ChatController().identity;
                  final userId =
                      identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
                  newEntry = {
                    'provider': 'Firebase',
                    'databaseId': userId,
                    'selfId':
                        userId.isNotEmpty ? '$userId@$url' : url,
                    'apiKey': jsonEncode({'url': url, 'key': key}),
                  };
                } else {
                  final relay = nostrRelayCtrl.text.trim();
                  if (relay.isEmpty) {
                    Navigator.pop(ctx);
                    return;
                  }
                  final privkey = nostrKeyCtrl.text.trim();
                  if (privkey.isNotEmpty) {
                    // F6: SHA256 of relay URL prevents suffix collisions.
                    final keySuffix = sha256
                        .convert(utf8.encode(relay))
                        .toString()
                        .substring(0, 16);
                    await _secureStorage.write(
                        key: 'secondary_nostr_privkey_$keySuffix',
                        value: privkey);
                  }
                  String selfId = '';
                  try {
                    if (privkey.isNotEmpty) {
                      selfId = '${deriveNostrPubkeyHex(privkey)}@$relay';
                    }
                  } catch (_) {}
                  newEntry = {
                    'provider': 'Nostr',
                    'databaseId': relay,
                    'selfId': selfId,
                  };
                }
                current.add(newEntry);
                await prefs.setString(
                    'secondary_adapters', jsonEncode(current));
                final updated = await _loadSecondaryAdapters();
                if (mounted) setState(() => _secondaryAdapters = updated);
                await ChatController().reconnectInbox();
                unawaited(ChatController().broadcastAddressUpdate());
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.spacing10)),
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

  // ── Widgets ─────────────────────────────────────────────────────────────

  Widget _providerToggle(String name, {required bool selected}) {
    final (_, color) =
        _kProviderMeta[name] ?? (Icons.circle, AppTheme.primary);
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(alpha: 0.15)
            : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignTokens.spacing10),
        border:
            Border.all(color: selected ? color : AppTheme.surfaceVariant),
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

  // ── Provider chips ────────────────────────────────────────────────────────

  Widget _buildProviderChips() {
    const providers = [
      (name: 'Firebase', icon: Icons.local_fire_department_rounded, color: Color(0xFFFFAB00)),
      (name: 'Nostr',    icon: Icons.bolt_rounded,                   color: Color(0xFF9B59B6)),
      (name: 'Session',  icon: Icons.security_rounded,               color: Color(0xFF00695C)),
      (name: 'Pulse',    icon: Icons.dns_rounded,                    color: Color(0xFF2196F3)),
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
        _showSessionAdvanced = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color:
              selected ? color.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(DesignTokens.spacing10),
          border: Border.all(
            color: selected ? color : AppTheme.surfaceVariant,
            width: 1.5,
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              size: 15,
              color: selected ? color : AppTheme.textSecondary),
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
      try {
        pubkey = deriveNostrPubkeyHex(privkey);
      } catch (_) {}
    }
    final configuredRelay = _nostrRelayCtrl.text.trim().isNotEmpty
        ? _nostrRelayCtrl.text.trim()
        : kDefaultNostrRelay;
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
            child: Text(configuredRelay,
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
          hint: context.l10n.providerFirebaseUrlHint,
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
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNostrInfoCard(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  setState(() => _showNostrAdvanced = !_showNostrAdvanced),
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
                hint: context.l10n.providerNostrRelayHint,
                label: context.l10n.providerRelayUrlLabel,
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(height: 12),
              settingsField(
                controller: _nostrKeyCtrl,
                hint: context.l10n.providerNostrPrivkeyHintFull,
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

    if (_selectedProvider == 'Pulse') {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            settingsField(
              controller: _pulseServerUrlCtrl,
              hint: context.l10n.providerPulseServerUrlHint,
              label: context.l10n.providerPulseServerUrlLabel,
              icon: Icons.dns_rounded,
            ),
            const SizedBox(height: 12),
            settingsField(
              controller: _pulseInviteCtrl,
              hint: context.l10n.providerPulseInviteHint,
              label: context.l10n.providerPulseInviteLabel,
              icon: Icons.card_giftcard_rounded,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.info_outline_rounded,
                  size: 13, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    context.l10n.providerPulseInfo,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ),
            ]),
          ]);
    }

    // Session
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.info_outline_rounded,
            size: 13, color: Color(0xFF00695C)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(context.l10n.providerSessionInfo,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ),
      ]),
      const SizedBox(height: 8),
      Builder(builder: (ctx) {
        final sessionId = ChatController().myAddress;
        if (sessionId.startsWith('05') && sessionId.length == 66) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusSmall),
              border: Border.all(
                  color:
                      const Color(0xFF00695C).withValues(alpha: 0.3)),
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
        onTap: () =>
            setState(() => _showSessionAdvanced = !_showSessionAdvanced),
        child: Row(children: [
          Icon(
            _showSessionAdvanced
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
      if (_showSessionAdvanced) ...[
        const SizedBox(height: 12),
        settingsField(
          controller: _sessionNodeUrlCtrl,
          hint: context.l10n.providerStorageNodeHint,
          label: context.l10n.providerStorageNodeLabel,
          icon: Icons.security_rounded,
        ),
      ],
    ]);
  }

  // ── Secondary inbox card ──────────────────────────────────────────────────

  Widget _buildSecondaryCard({
    required String provider,
    required String address,
    required VoidCallback onRemove,
  }) {
    final (icon, color) = _kProviderMeta[provider] ??
        (Icons.inbox_rounded, AppTheme.textSecondary);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider,
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
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
        IconButton(
          icon: Icon(Icons.close_rounded,
              size: 18, color: AppTheme.textSecondary),
          tooltip: context.l10n.providerRemoveTooltip,
          onPressed: onRemove,
        ),
      ]),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.providerScreenTitle,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // Provider chips
                _buildProviderChips(),
                const SizedBox(height: 20),

                // Inline config for selected provider
                _buildConfig(),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              DesignTokens.buttonRadius)),
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

                // Secondary inboxes section
                if (_secondaryAdapters.isNotEmpty ||
                    true) ...[
                  const SizedBox(height: 28),
                  Row(children: [
                    Expanded(
                        child: Divider(
                            color: AppTheme.surfaceVariant, height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(context.l10n.providerSecondaryInboxesHeader,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          )),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppTheme.surfaceVariant, height: 1)),
                  ]),
                  const SizedBox(height: 12),

                  // Hint
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 13,
                            color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.l10n.providerSecondaryInboxesInfo,
                            style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                height: 1.5),
                          ),
                        ),
                      ]),
                  const SizedBox(height: 10),

                  // Secondary cards
                  for (int i = 0;
                      i < _secondaryAdapters.length;
                      i++) ...[
                    _buildSecondaryCard(
                      provider:
                          _secondaryAdapters[i]['provider'] ?? '',
                      address: _secondaryAdapters[i]['selfId'] ??
                          _secondaryAdapters[i]['databaseId'] ??
                          '',
                      onRemove: () => _removeSecondary(i),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Add secondary button
                  GestureDetector(
                    onTap: _showAddDialog,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(
                            DesignTokens.radiusLarge),
                        border: Border.all(
                            color: AppTheme.primary
                                .withValues(alpha: 0.3),
                            width: 1),
                      ),
                      child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 16,
                                color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                                context
                                    .l10n.providerAddSecondaryInbox,
                                style: GoogleFonts.inter(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                )),
                          ]),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
