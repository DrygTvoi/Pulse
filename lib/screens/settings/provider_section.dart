// Settings — Provider section: inbox provider chips, connection details,
// secondary inboxes and the Save & Connect button.
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../adapters/nostr_adapter.dart';
import '../../controllers/chat_controller.dart';
import '../../l10n/l10n_ext.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import 'settings_widgets.dart';

class ProviderSection extends StatefulWidget {
  final String selectedProvider;
  final TextEditingController firebaseUrlController;
  final TextEditingController firebaseKeyController;
  final TextEditingController nostrKeyController;
  final TextEditingController nostrRelayController;
  final TextEditingController sessionNodeUrlController;
  final TextEditingController pulseServerUrlController;
  final TextEditingController pulseInviteController;
  final bool isSaving;
  final List<Map<String, String>> secondaryAdapters;
  final VoidCallback onSave;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<List<Map<String, String>>> onSecondaryAdaptersChanged;

  const ProviderSection({
    super.key,
    required this.selectedProvider,
    required this.firebaseUrlController,
    required this.firebaseKeyController,
    required this.nostrKeyController,
    required this.nostrRelayController,
    required this.sessionNodeUrlController,
    required this.pulseServerUrlController,
    required this.pulseInviteController,
    required this.isSaving,
    required this.secondaryAdapters,
    required this.onSave,
    required this.onProviderChanged,
    required this.onSecondaryAdaptersChanged,
  });

  @override
  State<ProviderSection> createState() => _ProviderSectionState();
}

class _ProviderSectionState extends State<ProviderSection> {
  static const _secureStorage = FlutterSecureStorage();

  bool _showNostrAdvanced = false;
  bool _showSessionAdvanced = false;
  String? _activeNostrRelay;

  @override
  void initState() {
    super.initState();
    _loadActiveRelay();
  }

  Future<void> _loadActiveRelay() async {
    final prefs = await SharedPreferences.getInstance();
    final relay = prefs.getString('adaptive_cf_relay') ??
        prefs.getString('probe_nostr_relay') ??
        prefs.getString('nostr_relay');
    if (mounted) setState(() => _activeNostrRelay = relay);
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
    } catch (e) {
      debugPrint('[Settings] Failed to parse secondary_adapters: $e');
      return [];
    }
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.dialogRadius)),
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
                            borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                            border: Border.all(
                                color: provider == p
                                    ? AppTheme.primary
                                    : AppTheme.surfaceVariant),
                          ),
                          child: Center(
                            child: Text(
                              p,
                              style: GoogleFonts.inter(
                                color: provider == p
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                fontWeight: provider == p
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: DesignTokens.fontMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (p != 'Nostr') const SizedBox(width: DesignTokens.spacing8),
                  ],
                ]),
                const SizedBox(height: DesignTokens.spacing16),
                if (provider == 'Firebase') ...[
                  settingsField(
                    controller: fbUrlCtrl,
                    hint: context.l10n.providerFirebaseUrlHint,
                    label: context.l10n.providerDatabaseUrlLabel,
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: DesignTokens.spacing10),
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
                    hint: context.l10n.providerNostrRelayHint,
                    label: context.l10n.providerRelayUrlLabel,
                    icon: Icons.bolt_rounded,
                  ),
                  const SizedBox(height: DesignTokens.spacing10),
                  settingsField(
                    controller: nostrKeyCtrl,
                    hint: context.l10n.providerNostrPrivkeyHint,
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
                } catch (e) {
                  debugPrint('[Settings] Failed to parse adapters JSON: $e');
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
                    // F6: Use SHA256 of relay URL as key suffix to prevent
                    // collisions from regex normalisation (e.g. relay.a.com
                    // and relay_a_com would both map to relay_a_com).
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
                widget.onSecondaryAdaptersChanged(updated);
                await ChatController().reconnectInbox();
                unawaited(ChatController().broadcastAddressUpdate());
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              ),
              child: Text(
                context.l10n.add,
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
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

  Widget _buildProviderChips() {
    const providers = [
      (
        name: 'Firebase',
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFFFAB00)
      ),
      (name: 'Nostr', icon: Icons.bolt_rounded, color: Color(0xFF9B59B6)),
      (
        name: 'Session',
        icon: Icons.security_rounded,
        color: Color(0xFF00695C)
      ),
      (name: 'Pulse', icon: Icons.dns_rounded, color: Color(0xFF2196F3)),
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
    final selected = widget.selectedProvider == name;
    return GestureDetector(
      onTap: () => widget.onProviderChanged(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : AppTheme.surface,
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
            const SizedBox(width: DesignTokens.spacing6),
            Text(
              name,
              style: GoogleFonts.inter(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: DesignTokens.fontMd,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNostrInfoCard() {
    // Derive pubkey from the current private key field
    String pubkey = '';
    final privkey = widget.nostrKeyController.text.trim();
    if (privkey.isNotEmpty) {
      try {
        pubkey = deriveNostrPubkeyHex(privkey);
      } catch (e) {
        debugPrint('[Provider] Could not derive Nostr pubkey: $e');
      }
    }

    // Resolve active relay: adaptive → probe → configured → default
    final activeRelay = _activeNostrRelay ??
        (widget.nostrRelayController.text.trim().isNotEmpty
            ? widget.nostrRelayController.text.trim()
            : kDefaultNostrRelay);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing10),
      decoration: BoxDecoration(
        color: const Color(0xFF9B59B6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
            color: const Color(0xFF9B59B6).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          if (pubkey.isNotEmpty)
            Row(children: [
              const Icon(Icons.vpn_key_rounded,
                  size: 13, color: Color(0xFF9B59B6)),
              const SizedBox(width: DesignTokens.spacing8),
              Text(context.l10n.providerPublicKey,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: DesignTokens.fontSm,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: DesignTokens.spacing8),
              Expanded(
                child: Text(
                  '${pubkey.substring(0, 8)}...${pubkey.substring(pubkey.length - 8)}',
                  style: GoogleFonts.robotoMono(
                      color: const Color(0xFF9B59B6), fontSize: DesignTokens.fontSm),
                  textAlign: TextAlign.end,
                ),
              ),
            ]),
          if (pubkey.isNotEmpty) const SizedBox(height: DesignTokens.spacing6),
          Row(children: [
            const Icon(Icons.bolt_rounded,
                size: 13, color: Color(0xFF9B59B6)),
            const SizedBox(width: DesignTokens.spacing8),
            Text(context.l10n.providerRelay,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontSm,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: DesignTokens.spacing8),
            Expanded(
              child: Text(
                activeRelay,
                style: GoogleFonts.robotoMono(
                    color: const Color(0xFF9B59B6), fontSize: DesignTokens.fontSm),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildProviderConfig() {
    if (widget.selectedProvider == 'Firebase') {
      return Column(children: [
        settingsField(
          controller: widget.firebaseUrlController,
          hint: 'https://project.firebaseio.com',
          label: context.l10n.providerDatabaseUrlLabel,
          icon: Icons.link_rounded,
        ),
        const SizedBox(height: DesignTokens.spacing12),
        settingsField(
          controller: widget.firebaseKeyController,
          hint: context.l10n.providerOptionalForPublicDb,
          label: context.l10n.providerWebApiKeyLabel,
          icon: Icons.key_rounded,
          obscure: true,
        ),
      ]);
    } else if (widget.selectedProvider == 'Nostr') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNostrInfoCard(),
          const SizedBox(height: DesignTokens.spacing8),
          Row(children: [
            Icon(Icons.info_outline_rounded,
                size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: DesignTokens.spacing6),
            Expanded(
              child: Text(
                context.l10n.providerAutoConfigured,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
              ),
            ),
          ]),
          const SizedBox(height: DesignTokens.spacing4),
          GestureDetector(
            onTap: () => setState(() => _showNostrAdvanced = !_showNostrAdvanced),
            child: Row(
              children: [
                Icon(
                  _showNostrAdvanced
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: DesignTokens.iconSm,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: DesignTokens.spacing4),
                Text(
                  context.l10n.providerAdvanced,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_showNostrAdvanced) ...[
            const SizedBox(height: DesignTokens.spacing12),
            settingsField(
              controller: widget.nostrRelayController,
              hint: 'wss://relay.damus.io',
              label: context.l10n.providerRelayUrlLabel,
              icon: Icons.bolt_rounded,
            ),
            const SizedBox(height: DesignTokens.spacing12),
            settingsField(
              controller: widget.nostrKeyController,
              hint: context.l10n.providerNostrPrivkeyHintFull,
              label: context.l10n.providerPrivateKeyNsecLabel,
              icon: Icons.vpn_key_rounded,
              obscure: true,
            ),
            const SizedBox(height: DesignTokens.spacing8),
            Row(children: [
              Icon(Icons.info_outline_rounded,
                  size: 13, color: AppTheme.textSecondary),
              const SizedBox(width: DesignTokens.spacing6),
              Expanded(
                child: Text(
                  context.l10n.providerKeyStoredLocally,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
                ),
              ),
            ]),
          ],
        ],
      );
    } else if (widget.selectedProvider == 'Pulse') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settingsField(
            controller: widget.pulseServerUrlController,
            hint: context.l10n.providerPulseServerUrlHint,
            label: context.l10n.providerPulseServerUrlLabel,
            icon: Icons.dns_rounded,
          ),
          const SizedBox(height: DesignTokens.spacing12),
          settingsField(
            controller: widget.pulseInviteController,
            hint: context.l10n.providerPulseInviteHint,
            label: context.l10n.providerPulseInviteLabel,
            icon: Icons.card_giftcard_rounded,
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Row(children: [
            Icon(Icons.info_outline_rounded, size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: DesignTokens.spacing6),
            Expanded(
              child: Text(
                context.l10n.providerPulseInfo,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
              ),
            ),
          ]),
        ],
      );
    } else if (widget.selectedProvider == 'Session') {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.info_outline_rounded,
                  size: 13, color: const Color(0xFF00695C)),
              const SizedBox(width: DesignTokens.spacing6),
              Expanded(
                child: Text(
                  context.l10n.providerSessionInfo,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
                ),
              ),
            ]),
            const SizedBox(height: DesignTokens.spacing8),
            Builder(builder: (ctx) {
              final sessionId = ChatController().myAddress;
              if (sessionId.startsWith('05') &&
                  sessionId.length == 66) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    border: Border.all(
                        color: const Color(0xFF00695C)
                            .withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.fingerprint_rounded,
                        size: 14, color: Color(0xFF00695C)),
                    const SizedBox(width: DesignTokens.spacing8),
                    Expanded(
                      child: Text(
                        sessionId,
                        style: GoogleFonts.robotoMono(
                            color: const Color(0xFF00695C), fontSize: DesignTokens.fontXs),
                      ),
                    ),
                  ]),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: DesignTokens.spacing4),
            GestureDetector(
              onTap: () => setState(() => _showSessionAdvanced = !_showSessionAdvanced),
              child: Row(
                children: [
                  Icon(
                    _showSessionAdvanced
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: DesignTokens.iconSm,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: DesignTokens.spacing4),
                  Text(
                    context.l10n.providerAdvanced,
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: DesignTokens.fontBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_showSessionAdvanced) ...[
              const SizedBox(height: DesignTokens.spacing12),
              settingsField(
                controller: widget.sessionNodeUrlController,
                hint: context.l10n.providerStorageNodeHint,
                label: context.l10n.providerStorageNodeLabel,
                icon: Icons.security_rounded,
              ),
            ],
          ]);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSecondaryInboxesSection() {
    return Column(
      children: [
        for (int i = 0; i < widget.secondaryAdapters.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: DesignTokens.spacing14, vertical: DesignTokens.spacing10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.secondaryAdapters[i]['provider'] == 'Nostr'
                        ? Icons.bolt_rounded
                        : Icons.local_fire_department_rounded,
                    size: DesignTokens.iconSm,
                    color:
                        widget.secondaryAdapters[i]['provider'] == 'Nostr'
                            ? const Color(0xFF9B59B6)
                            : const Color(0xFFFFAB00),
                  ),
                  const SizedBox(width: DesignTokens.spacing10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.secondaryAdapters[i]['provider'] ?? '',
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: DesignTokens.fontMd,
                          ),
                        ),
                        Text(
                          widget.secondaryAdapters[i]['selfId'] ??
                              widget.secondaryAdapters[i]['databaseId'] ??
                              '',
                          style: GoogleFonts.jetBrainsMono(
                              color: AppTheme.textSecondary, fontSize: DesignTokens.fontXs),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final updated =
                          List<Map<String, String>>.from(
                              widget.secondaryAdapters)
                            ..removeAt(i);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'secondary_adapters', jsonEncode(updated));
                      widget.onSecondaryAdaptersChanged(updated);
                      await ChatController().reconnectInbox();
                      unawaited(
                          ChatController().broadcastAddressUpdate());
                    },
                    child: Icon(Icons.close_rounded,
                        size: 18, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        GestureDetector(
          onTap: _showAddSecondaryDialog,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: DesignTokens.spacing14, vertical: DesignTokens.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded,
                    size: DesignTokens.iconSm, color: AppTheme.primary),
                const SizedBox(width: DesignTokens.spacing8),
                Text(
                  context.l10n.providerAddSecondaryInbox,
                  style: GoogleFonts.inter(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: DesignTokens.fontMd,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Provider selection ───────────────────────────────
        settingsSectionLabel(context.l10n.providerYourInboxProvider),
        const SizedBox(height: DesignTokens.spacing12),
        _buildProviderChips(),
        const SizedBox(height: DesignTokens.spacing28),

        // ─── Provider-specific config ─────────────────────────
        settingsSectionLabel(context.l10n.providerConnectionDetails),
        const SizedBox(height: DesignTokens.spacing12),
        _buildProviderConfig(),

        const SizedBox(height: DesignTokens.spacing32),

        // ─── Save button ──────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: widget.isSaving ? null : widget.onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.buttonRadius)),
              elevation: 0,
            ),
            child: widget.isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(
                    context.l10n.providerSaveAndConnect,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: DesignTokens.fontXl,
                        color: Colors.white),
                  ),
          ),
        ),

        const SizedBox(height: DesignTokens.spacing32),

        // ─── Secondary Inboxes ────────────────────────────────
        settingsSectionLabel(context.l10n.providerSecondaryInboxes),
        const SizedBox(height: DesignTokens.spacing10),
        _buildSecondaryInboxesSection(),
      ],
    );
  }
}
