// Provider configuration screen — self-contained, no external state required.
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

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({super.key});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  static const _secureStorage = FlutterSecureStorage();
  static const _nostrPrivkeyStorageKey = 'nostr_privkey';

  String _selectedProvider = 'Firebase';
  final _firebaseUrlController = TextEditingController();
  final _firebaseKeyController = TextEditingController();
  final _nostrKeyController = TextEditingController();
  final _nostrRelayController = TextEditingController();
  final _wakuNodeUrlController =
      TextEditingController(text: 'http://127.0.0.1:8645');
  final _oxenNodeUrlController = TextEditingController();
  bool _isSaving = false;
  List<Map<String, String>> _secondaryAdapters = [];

  bool _wakuDiscovering = false;
  List<WakuNodeInfo>? _wakuNodes;
  bool _showNostrAdvanced = false;
  bool _showOxenAdvanced = false;
  String? _activeNostrRelay;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _firebaseUrlController.dispose();
    _firebaseKeyController.dispose();
    _nostrKeyController.dispose();
    _nostrRelayController.dispose();
    _wakuNodeUrlController.dispose();
    _oxenNodeUrlController.dispose();
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
      if (savedKey.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedKey);
          nostrPrivkey = decoded['privkey'] ?? '';
          nostrRelay = decoded['relay'] ?? kDefaultNostrRelay;
        } catch (_) {}
        if (nostrPrivkey.isNotEmpty) {
          await _secureStorage.write(
              key: _nostrPrivkeyStorageKey, value: nostrPrivkey);
          await prefs.remove('byod_api_key');
        }
      } else {
        nostrPrivkey =
            await _secureStorage.read(key: _nostrPrivkeyStorageKey) ?? '';
        nostrRelay = prefs.getString('nostr_relay') ?? kDefaultNostrRelay;
      }
    }

    final secondaryAdapters = await _loadSecondaryAdaptersFromPrefs();

    if (!mounted) return;
    setState(() {
      _selectedProvider = provider;
      _activeNostrRelay = relay;
      _secondaryAdapters = secondaryAdapters;
      if (provider == 'Firebase') {
        try {
          final decoded = jsonDecode(savedKey);
          _firebaseUrlController.text = decoded['url'] ?? '';
          _firebaseKeyController.text = decoded['key'] ?? '';
        } catch (_) {
          _firebaseUrlController.text = savedKey;
        }
      } else if (provider == 'Nostr') {
        _nostrKeyController.text = nostrPrivkey;
        _nostrRelayController.text = nostrRelay;
      } else if (provider == 'Waku') {
        _wakuNodeUrlController.text =
            prefs.getString('waku_node_url') ?? 'http://127.0.0.1:8645';
      } else if (provider == 'Oxen') {
        _oxenNodeUrlController.text =
            prefs.getString('oxen_node_url') ?? '';
      }
    });
  }

  Future<List<Map<String, String>>> _loadSecondaryAdaptersFromPrefs() async {
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

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();

    String finalApiKey;
    String finalDbId;
    if (_selectedProvider == 'Firebase') {
      finalApiKey = jsonEncode({
        'url': _firebaseUrlController.text.trim(),
        'key': _firebaseKeyController.text.trim(),
      });
      final identity = ChatController().identity;
      finalDbId = identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
    } else if (_selectedProvider == 'Nostr') {
      await _secureStorage.write(
          key: _nostrPrivkeyStorageKey,
          value: _nostrKeyController.text.trim());
      await prefs.setString(
          'nostr_relay', _nostrRelayController.text.trim());
      finalApiKey =
          jsonEncode({'relay': _nostrRelayController.text.trim()});
      finalDbId = _nostrRelayController.text.trim();
    } else if (_selectedProvider == 'Waku') {
      final nodeUrl = _wakuNodeUrlController.text.trim().isNotEmpty
          ? _wakuNodeUrlController.text.trim()
          : 'http://127.0.0.1:8645';
      await prefs.setString('waku_node_url', nodeUrl);
      finalApiKey = jsonEncode({'nodeUrl': nodeUrl});
      finalDbId = nodeUrl;
    } else {
      final nodeUrl = _oxenNodeUrlController.text.trim();
      await prefs.setString('oxen_node_url', nodeUrl);
      finalApiKey = nodeUrl;
      finalDbId = ChatController().myAddress;
    }

    await prefs.setString('byod_provider', _selectedProvider);
    if (_selectedProvider != 'Nostr' &&
        _selectedProvider != 'Waku' &&
        _selectedProvider != 'Oxen') {
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
      if (_wakuNodeUrlController.text.trim().isEmpty) {
        final best =
            nodes.firstWhere((n) => n.online, orElse: () => nodes.first);
        if (best.online) _wakuNodeUrlController.text = best.url;
      }
    });
  }

  Future<void> _showAddSecondaryDialog() async {
    String provider = 'Firebase';
    final fbUrlCtrl = TextEditingController();
    final fbKeyCtrl = TextEditingController();
    final nostrRelayCtrl =
        TextEditingController(text: kDefaultNostrRelay);
    final nostrKeyCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
          title: Text(
            context.l10n.providerAddSecondaryInbox,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  for (final p in ['Firebase', 'Nostr']) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => provider = p),
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: provider == p
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : AppTheme.surfaceVariant,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.spacing10),
                            border: Border.all(
                                color: provider == p
                                    ? AppTheme.primary
                                    : AppTheme.surfaceVariant),
                          ),
                          child: Center(
                            child: Text(p,
                                style: GoogleFonts.inter(
                                  color: provider == p
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                  fontWeight: provider == p
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                )),
                          ),
                        ),
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
                    label: context.l10n.providerDatabaseUrlLabel,
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 10),
                  settingsField(
                    controller: fbKeyCtrl,
                    hint: context.l10n.providerOptionalHint,
                    label: context.l10n.providerWebApiKeyLabel,
                    icon: Icons.key_rounded,
                    obscure: true,
                  ),
                ] else ...[
                  settingsField(
                    controller: nostrRelayCtrl,
                    hint: 'wss://relay.damus.io',
                    label: context.l10n.providerRelayUrlLabel,
                    icon: Icons.bolt_rounded,
                  ),
                  const SizedBox(height: 10),
                  settingsField(
                    controller: nostrKeyCtrl,
                    hint: 'nsec1... or hex',
                    label: context.l10n.providerPrivateKeyLabel,
                    icon: Icons.vpn_key_rounded,
                    obscure: true,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                if (!ctx.mounted) return;
                final currentRaw =
                    prefs.getString('secondary_adapters') ?? '[]';
                List<dynamic> current;
                try {
                  current = jsonDecode(currentRaw);
                } catch (_) {
                  current = [];
                }
                Map<String, String> newEntry;
                if (provider == 'Firebase') {
                  final url = fbUrlCtrl.text.trim();
                  if (url.isEmpty) {
                    Navigator.pop(ctx);
                    return;
                  }
                  final key = fbKeyCtrl.text.trim();
                  final identity = ChatController().identity;
                  final userId =
                      identity?.adapterConfig['dbId'] ?? identity?.id ?? '';
                  final selfId = userId.isNotEmpty ? '$userId@$url' : url;
                  final apiKey = jsonEncode({'url': url, 'key': key});
                  newEntry = {
                    'provider': 'Firebase',
                    'databaseId': userId,
                    'selfId': selfId,
                    'apiKey': apiKey,
                  };
                } else {
                  final relay = nostrRelayCtrl.text.trim();
                  if (relay.isEmpty) {
                    Navigator.pop(ctx);
                    return;
                  }
                  final privkey = nostrKeyCtrl.text.trim();
                  if (privkey.isNotEmpty) {
                    final keySuffix =
                        relay.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
                    await _secureStorage.write(
                        key: 'secondary_nostr_privkey_$keySuffix',
                        value: privkey);
                  }
                  String selfId = '';
                  try {
                    if (privkey.isNotEmpty) {
                      final pubkey = deriveNostrPubkeyHex(privkey);
                      selfId = '$pubkey@$relay';
                    }
                  } catch (e) {
                    debugPrint(
                        '[Settings] Failed to derive Nostr pubkey: $e');
                  }
                  newEntry = {
                    'provider': 'Nostr',
                    'databaseId': relay,
                    'selfId': selfId,
                  };
                }
                current.add(newEntry);
                await prefs.setString(
                    'secondary_adapters', jsonEncode(current));
                final updated = await _loadSecondaryAdaptersFromPrefs();
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
              child: Text(context.l10n.add,
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

  // ── Provider chips ────────────────────────────────────────────────────────

  Widget _buildProviderChips() {
    const providers = [
      (name: 'Firebase', icon: Icons.local_fire_department_rounded, color: Color(0xFFFFAB00)),
      (name: 'Nostr', icon: Icons.bolt_rounded, color: Color(0xFF9B59B6)),
      (name: 'Waku', icon: Icons.hub_rounded, color: Color(0xFF00BCD4)),
      (name: 'Oxen', icon: Icons.security_rounded, color: Color(0xFF00695C)),
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
      onTap: () => setState(() => _selectedProvider = name),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }

  Widget _buildNostrInfoCard() {
    String pubkey = '';
    final privkey = _nostrKeyController.text.trim();
    if (privkey.isNotEmpty) {
      try {
        pubkey = deriveNostrPubkeyHex(privkey);
      } catch (_) {}
    }
    final activeRelay = _activeNostrRelay ??
        (_nostrRelayController.text.trim().isNotEmpty
            ? _nostrRelayController.text.trim()
            : kDefaultNostrRelay);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF9B59B6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
            color: const Color(0xFF9B59B6).withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        if (pubkey.isNotEmpty)
          Row(children: [
            const Icon(Icons.vpn_key_rounded,
                size: 13, color: Color(0xFF9B59B6)),
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
                style: GoogleFonts.robotoMono(
                    color: const Color(0xFF9B59B6), fontSize: 11),
                textAlign: TextAlign.end,
              ),
            ),
          ]),
        if (pubkey.isNotEmpty) const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.bolt_rounded,
              size: 13, color: Color(0xFF9B59B6)),
          const SizedBox(width: 8),
          Text(context.l10n.providerRelay,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(activeRelay,
                style: GoogleFonts.robotoMono(
                    color: const Color(0xFF9B59B6), fontSize: 11),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      ]),
    );
  }

  Widget _buildProviderConfig() {
    if (_selectedProvider == 'Firebase') {
      return Column(children: [
        settingsField(
          controller: _firebaseUrlController,
          hint: 'https://project.firebaseio.com',
          label: context.l10n.providerDatabaseUrlLabel,
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: 12),
        settingsField(
          controller: _firebaseKeyController,
          hint: context.l10n.providerOptionalForPublicDb,
          label: context.l10n.providerWebApiKeyLabel,
          icon: Icons.key_rounded,
          obscure: true,
        ),
      ]);
    } else if (_selectedProvider == 'Nostr') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            controller: _nostrRelayController,
            hint: 'wss://relay.damus.io',
            label: context.l10n.providerRelayUrlLabel,
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 12),
          settingsField(
            controller: _nostrKeyController,
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
    } else if (_selectedProvider == 'Waku') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: settingsField(
              controller: _wakuNodeUrlController,
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
        const SizedBox(height: 8),
        if (_wakuNodes != null) ...[
          ..._wakuNodes!.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: n.online
                      ? () => setState(
                          () => _wakuNodeUrlController.text = n.url)
                      : null,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusSmall),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusSmall),
                      border: _wakuNodeUrlController.text == n.url
                          ? Border.all(
                              color: const Color(0xFF00BCD4), width: 1.5)
                          : null,
                    ),
                    child: Row(children: [
                      Icon(
                        n.online
                            ? Icons.circle
                            : Icons.circle_outlined,
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
          const SizedBox(height: 4),
        ],
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
    } else if (_selectedProvider == 'Oxen') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.info_outline_rounded,
              size: 13, color: const Color(0xFF00695C)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00695C).withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusSmall),
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
          onTap: () =>
              setState(() => _showOxenAdvanced = !_showOxenAdvanced),
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
            controller: _oxenNodeUrlController,
            hint: context.l10n.providerStorageNodeHint,
            label: context.l10n.providerStorageNodeLabel,
            icon: Icons.security_rounded,
          ),
        ],
      ]);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSecondaryInboxes() {
    return Column(children: [
      for (int i = 0; i < _secondaryAdapters.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: Row(children: [
              Icon(
                _secondaryAdapters[i]['provider'] == 'Nostr'
                    ? Icons.bolt_rounded
                    : Icons.local_fire_department_rounded,
                size: 16,
                color: _secondaryAdapters[i]['provider'] == 'Nostr'
                    ? const Color(0xFF9B59B6)
                    : const Color(0xFFFFAB00),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_secondaryAdapters[i]['provider'] ?? '',
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          )),
                      Text(
                        _secondaryAdapters[i]['selfId'] ??
                            _secondaryAdapters[i]['databaseId'] ??
                            '',
                        style: GoogleFonts.jetBrainsMono(
                            color: AppTheme.textSecondary, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
              ),
              GestureDetector(
                onTap: () async {
                  final updated =
                      List<Map<String, String>>.from(_secondaryAdapters)
                        ..removeAt(i);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                      'secondary_adapters', jsonEncode(updated));
                  if (mounted) {
                    setState(() => _secondaryAdapters = updated);
                  }
                  await ChatController().reconnectInbox();
                  unawaited(ChatController().broadcastAddressUpdate());
                },
                child: Icon(Icons.close_rounded,
                    size: 18, color: AppTheme.textSecondary),
              ),
            ]),
          ),
        ),
      GestureDetector(
        onTap: _showAddSecondaryDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius:
                BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_rounded, size: 16, color: AppTheme.primary),
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
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(context.l10n.settingsProviderTitle,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          _buildProviderChips(),
          const SizedBox(height: 20),
          _buildProviderConfig(),
          const SizedBox(height: 24),
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
                          color: Colors.white, strokeWidth: 2.5))
                  : Text(context.l10n.providerSaveAndConnect,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white)),
            ),
          ),
          const SizedBox(height: 32),
          settingsSectionLabel(context.l10n.providerSecondaryInboxes),
          const SizedBox(height: 10),
          _buildSecondaryInboxes(),
        ],
      ),
    );
  }
}
