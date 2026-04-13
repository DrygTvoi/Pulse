import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants.dart';
import '../l10n/l10n_ext.dart';
import '../models/contact.dart';
import '../services/blossom_service.dart';
import '../services/local_storage_service.dart';
import '../services/media_validator.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/avatar_widget.dart';

class AddContactDialog extends StatefulWidget {
  final Function(Contact) onAdd;
  const AddContactDialog({super.key, required this.onAdd});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _nameController = TextEditingController();
  List<String> _detectedAddresses = [];
  bool _fetchingProfile = false;
  String? _profileFetchStatus;
  bool _profileFound = false;
  Timer? _debounceTimer;
  Uint8List? _previewAvatarBytes;
  bool _fetchingAvatar = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  static String _detectProvider(String address) {
    final lower = address.toLowerCase();
    if (lower.startsWith('05') && lower.length == 66 &&
        RegExp(r'^[0-9a-f]{66}$').hasMatch(lower)) { return 'Session'; }
    if (lower.contains('@wss://') || lower.contains('@ws://') ||
        RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) { return 'Nostr'; }
    // Pulse: 64-char hex @ https:// (not wss://)
    if (RegExp(r'^[0-9a-f]{64}@https://', caseSensitive: false).hasMatch(lower)) { return 'Pulse'; }
    if (lower.contains('@https://')) { return 'Firebase'; }
    return 'Nostr';
  }

  void _onInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('pulse://') || trimmed.startsWith('messenger://')) {
      _parsePulseLink(trimmed);
    } else {
      setState(() {
        _detectedAddresses = [trimmed];
        _previewAvatarBytes = null;
        _fetchingAvatar = false;
      });
      if (_detectProvider(trimmed) == 'Nostr') _tryScheduleNostrFetch(trimmed);
    }
  }

  void _parsePulseLink(String link) {
    try {
      final uri = Uri.parse(link);
      final cfg64 = uri.queryParameters['cfg'];
      if (cfg64 == null) return;
      // Guard: reject oversized payloads to prevent OOM via crafted deep links.
      if (cfg64.length > 16384) {
        debugPrint('[AddContact] Deep link cfg payload too large (${cfg64.length} chars), ignoring');
        return;
      }
      final json = jsonDecode(utf8.decode(base64Decode(cfg64))) as Map<String, dynamic>;

      final dynamic rawA = json['a'];
      final List<String> addresses;
      if (rawA is List) {
        addresses = rawA
            .take(20) // cap address array length
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty && e.length <= 512)
            // Require pubkey@server format (all transports) or 66-char Oxen ID.
            // Rejects localhost/RFC-1918 injections and bare hostnames.
            .where((e) => e.contains('@') || RegExp(r'^05[0-9a-fA-F]{64}$').hasMatch(e))
            .toList();
      } else if (rawA is String && rawA.isNotEmpty && rawA.length <= 512) {
        // F2: Apply same format filter as the List path — require @-address or Oxen ID.
        // Without this check, attacker-crafted links can inject RFC-1918 or bare URLs.
        final single = rawA;
        if (!single.contains('@') && !RegExp(r'^05[0-9a-fA-F]{64}$').hasMatch(single)) {
          return;
        }
        addresses = [single];
      } else {
        return;
      }
      if (addresses.isEmpty) return;

      // Strip bidirectional override and zero-width characters to prevent
      // display-spoofing attacks (RTL override can make evil.com look like moc.live).
      final rawName = ((json['n'] as String?)?.trim() ?? '')
          .replaceAll(RegExp(r'[\u200B-\u200D\u202A-\u202E\u061C\u2066-\u2069\uFEFF]'), '');
      final name = rawName.length > 128 ? rawName.substring(0, 128) : rawName;
      // Validate and fetch avatar from Blossom if present.
      final rawAv = json['av'];
      String? avatarHash;
      if (rawAv is String &&
          rawAv.length == 64 &&
          RegExp(r'^[0-9a-f]{64}$').hasMatch(rawAv)) {
        avatarHash = rawAv;
      }

      setState(() {
        _detectedAddresses = addresses;
        _previewAvatarBytes = null;
        if (name.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = name;
        }
        // Pulse links are trusted — no NIP-0 lookup needed.
        _profileFetchStatus = null;
        _fetchingProfile = false;
      });

      if (avatarHash != null) _fetchBlossomAvatar(avatarHash);
    } catch (e) {
      // F3: Do NOT call _onInput(link) here — that causes infinite recursion
      // when the link starts with pulse:// (re-enters _parsePulseLink → throws → recurse).
      debugPrint('[AddContact] Deep link parse error: $e');
    }
  }

  void _tryScheduleNostrFetch(String address) {
    _debounceTimer?.cancel();
    final lower = address.toLowerCase();
    String pubkey;
    String relayWs;
    if (lower.contains('@wss://') || lower.contains('@ws://')) {
      final atIdx = address.indexOf('@');
      if (atIdx < 0) return;
      pubkey = address.substring(0, atIdx).toLowerCase();
      relayWs = address.substring(atIdx + 1);
    } else if (RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) {
      pubkey = lower;
      relayWs = kDefaultNostrRelay;
    } else {
      return;
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(pubkey)) return;
    _debounceTimer = Timer(const Duration(milliseconds: 600), () => _fetchNostrProfile(pubkey, relayWs));
  }

  Future<void> _fetchNostrProfile(String pubkey, String relayWs) async {
    if (!mounted) return;
    setState(() {
      _fetchingProfile = true;
      _profileFound = false;
      _profileFetchStatus = context.l10n.addContactFetchingProfile;
      _previewAvatarBytes = null;
    });
    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(relayWs));
      final subId = 'meta_${Random().nextInt(999999)}';
      channel.sink.add(jsonEncode(['REQ', subId, {'kinds': [0], 'authors': [pubkey], 'limit': 1}]));
      String? foundName;
      String? pictureUrl;
      await for (final raw in channel.stream.timeout(const Duration(seconds: 6))) {
        try {
          final msg = jsonDecode(raw as String) as List<dynamic>;
          if (msg.isEmpty) continue;
          if (msg[0] == 'EVENT' && msg.length >= 3) {
            final event = msg[2] as Map<String, dynamic>;
            if (event['kind'] == 0) {
              try {
                final content = jsonDecode(event['content'] as String) as Map<String, dynamic>;
                final n = (content['display_name'] as String?)?.trim() ??
                    (content['name'] as String?)?.trim();
                if (n != null && n.isNotEmpty) foundName = n;
                final pic = (content['picture'] as String?)?.trim();
                if (pic != null && pic.isNotEmpty && pic.length <= 2048) {
                  pictureUrl = pic;
                }
              } catch (e) {
                debugPrint('[AddContact] NIP-0 profile content parse error: $e');
              }
            }
          } else if (msg[0] == 'EOSE') { break; }
        } catch (e) {
          debugPrint('[AddContact] Nostr message parse error: $e');
          continue;
        }
      }
      if (!mounted) return;
      if (foundName != null) {
        setState(() { _fetchingProfile = false; _profileFound = true; _profileFetchStatus = context.l10n.addContactProfileFound(foundName!); });
        if (_nameController.text.isEmpty) _nameController.text = foundName;
      } else {
        setState(() { _fetchingProfile = false; _profileFound = false; _profileFetchStatus = context.l10n.addContactNoProfileFound; });
      }
      // Fetch avatar from picture URL (fire-and-forget, graceful failure)
      if (pictureUrl != null) _fetchAvatarFromUrl(pictureUrl!);
    } catch (e) {
      debugPrint('[AddContact] Profile fetch failed: $e');
      if (mounted) setState(() { _fetchingProfile = false; _profileFound = false; _profileFetchStatus = null; });
    } finally {
      channel?.sink.close();
    }
  }

  /// Download avatar from Blossom by SHA-256 hash, validate, and set preview.
  Future<void> _fetchBlossomAvatar(String hash) async {
    if (!mounted) return;
    setState(() => _fetchingAvatar = true);
    try {
      final bytes = await BlossomService.instance.download(hash);
      if (bytes == null || !mounted) {
        if (mounted) setState(() => _fetchingAvatar = false);
        return;
      }
      final validated = _validateAndDecodeAvatar(bytes);
      if (mounted) {
        setState(() {
          _previewAvatarBytes = validated;
          _fetchingAvatar = false;
        });
      }
    } catch (e) {
      debugPrint('[AddContact] Blossom avatar fetch failed: $e');
      if (mounted) setState(() => _fetchingAvatar = false);
    }
  }

  /// Fetch avatar from a URL (for Nostr profile pictures).
  /// 1 MB cap, 5s timeout, full validation pipeline.
  Future<void> _fetchAvatarFromUrl(String url) async {
    if (!mounted) return;
    setState(() => _fetchingAvatar = true);
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || (!uri.isScheme('https') && !uri.isScheme('http'))) {
        if (mounted) setState(() => _fetchingAvatar = false);
        return;
      }
      final client = http.Client();
      try {
        final resp = await client.get(uri).timeout(const Duration(seconds: 5));
        if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
          if (mounted) setState(() => _fetchingAvatar = false);
          return;
        }
        // Avatar-specific 1 MB cap
        if (resp.bodyBytes.length > 1024 * 1024) {
          debugPrint('[AddContact] Nostr avatar too large: ${resp.bodyBytes.length} bytes');
          if (mounted) setState(() => _fetchingAvatar = false);
          return;
        }
        final validated = _validateAndDecodeAvatar(resp.bodyBytes);
        if (mounted) {
          setState(() {
            _previewAvatarBytes = validated;
            _fetchingAvatar = false;
          });
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[AddContact] Nostr avatar fetch failed: $e');
      if (mounted) setState(() => _fetchingAvatar = false);
    }
  }

  /// Validate image bytes (magic bytes + dimensions) then decode→re-encode
  /// as 256×256 JPEG. Returns null on any failure.
  static Uint8List? _validateAndDecodeAvatar(Uint8List bytes) {
    // 1 MB avatar-specific cap
    if (bytes.length > 1024 * 1024) return null;
    // Magic byte + dimension check
    final validation = MediaValidator.validateImage(bytes);
    if (!validation.isValid) return null;
    // Decode, crop square, re-encode — strips all metadata/exploits
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final resized = img.copyResizeCropSquare(decoded, size: 256);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  Future<void> _submit() async {
    if (_detectedAddresses.isEmpty) return;
    // Deduplicate to prevent the same address appearing twice.
    final uniqueAddrs = _detectedAddresses.toSet().toList();
    // Classify addresses into per-transport map.
    final ta = <String, List<String>>{};
    for (final addr in uniqueAddrs) {
      final transport = _detectProvider(addr);
      (ta[transport] ??= []).add(addr);
    }
    // Transport priority: Pulse > Nostr > Session > Firebase (stable order)
    final tp = ['Pulse', 'Nostr', 'Session', 'Firebase']
        .where((t) => ta.containsKey(t))
        .toList();
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      final primaryAddr = uniqueAddrs.first;
      final atIdx = primaryAddr.indexOf('@');
      final raw = atIdx > 0 ? primaryAddr.substring(0, atIdx) : primaryAddr;
      name = raw.length > 12 ? raw.substring(0, 12) : raw;
    }
    final contactId = const Uuid().v4();
    final contact = Contact(
      id: contactId,
      name: name,
      transportAddresses: ta,
      transportPriority: tp,
      publicKey: '',
    );
    // Save fetched avatar so it appears immediately on home screen.
    if (_previewAvatarBytes != null) {
      try {
        await LocalStorageService().saveAvatar(contactId, base64Encode(_previewAvatarBytes!));
      } catch (e) {
        debugPrint('[AddContact] Failed to save preview avatar: $e');
      }
    }
    widget.onAdd(contact);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasAddresses = _detectedAddresses.isNotEmpty;

    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_add_rounded, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(context.l10n.addContactTitle, style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Paste area ───────────────────────────────────
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) _onInput(data!.text!.trim());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasAddresses
                              ? AppTheme.primary.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: hasAddresses
                          ? Text(
                              _detectedAddresses.first.length > 44
                                  ? '${_detectedAddresses.first.substring(0, 42)}…'
                                  : _detectedAddresses.first,
                              style: GoogleFonts.jetBrainsMono(
                                  color: AppTheme.textPrimary, fontSize: 11),
                            )
                          : Row(children: [
                              Icon(Icons.link_rounded, color: AppTheme.textSecondary, size: 16),
                              const SizedBox(width: 8),
                              Text(context.l10n.addContactTapToPaste,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                      fontSize: 13)),
                            ]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: context.l10n.addContactPasteTooltip,
                  child: InkWell(
                    onTap: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) _onInput(data!.text!.trim());
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 42, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.content_paste_rounded,
                          color: AppTheme.onPrimary, size: 18),
                    ),
                  ),
                ),
              ]),

              // ── Preview card (when addresses detected) ───────
              if (_detectedAddresses.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar with loading overlay
                          Stack(
                            children: [
                              AvatarWidget(
                                name: _nameController.text.trim(),
                                size: 56,
                                imageBytes: _previewAvatarBytes,
                              ),
                              if (_fetchingAvatar)
                                SizedBox(
                                  width: 56, height: 56,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: DesignTokens.spacing12),
                          // Name field + transport badges
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _nameController,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: context.l10n.addContactDisplayNameHint,
                                    hintStyle: GoogleFonts.inter(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                      fontSize: 13,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                    filled: true,
                                    fillColor: AppTheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.primary, width: 1),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Transport badge chips
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: _detectedAddresses
                                      .map(_detectProvider)
                                      .toSet()
                                      .map((t) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              t,
                                              style: GoogleFonts.inter(
                                                color: AppTheme.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Route count + status
                      Row(children: [
                        Icon(Icons.shuffle_rounded, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${_detectedAddresses.length} ${_detectedAddresses.length == 1 ? 'route' : 'routes'}',
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.online),
                        const SizedBox(width: 3),
                        Text(
                          'Ready to add',
                          style: GoogleFonts.inter(
                              color: AppTheme.online,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ]),
                      // Nostr fetch status
                      if (_profileFetchStatus != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          if (_fetchingProfile)
                            SizedBox(width: 11, height: 11,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5, color: AppTheme.primary))
                          else
                            Icon(
                              _profileFound
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.info_outline_rounded,
                              size: 12,
                              color: _profileFound
                                  ? AppTheme.online
                                  : AppTheme.textSecondary,
                            ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(_profileFetchStatus!,
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: _profileFound
                                        ? AppTheme.online
                                        : AppTheme.textSecondary)),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Add button ───────────────────────────────────
              SizedBox(
                width: double.infinity, height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: hasAddresses ? AppTheme.primary : AppTheme.surfaceVariant,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: hasAddresses ? _submit : null,
                  child: Text(context.l10n.addContactButton,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Parse a pulse:// or messenger:// deep link into {name, addresses}.
/// [addresses] contains all addresses from the `a` field (array or single string).
/// Returns null if the link is invalid.
@visibleForTesting
({String name, List<String> addresses})? parsePulseLink(String link) {
  try {
    final uri = Uri.parse(link);
    final cfg64 = uri.queryParameters['cfg'];
    if (cfg64 == null) return null;
    if (cfg64.length > 16384) return null; // OOM guard
    final json = jsonDecode(utf8.decode(base64Decode(cfg64))) as Map<String, dynamic>;
    final dynamic rawA = json['a'];
    final List<String> addresses;
    if (rawA is List) {
      addresses = rawA
          .take(20)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty && e.length <= 512)
          .where((e) => e.contains('@') || RegExp(r'^05[0-9a-fA-F]{64}$').hasMatch(e))
          .toList();
    } else if (rawA is String && rawA.isNotEmpty && rawA.length <= 512) {
      if (!rawA.contains('@') && !RegExp(r'^05[0-9a-fA-F]{64}$').hasMatch(rawA)) {
        return null;
      }
      addresses = [rawA];
    } else {
      return null;
    }
    if (addresses.isEmpty) return null;
    final rawName = ((json['n'] as String?)?.trim() ?? '')
        .replaceAll(RegExp(r'[\u200B-\u200D\u202A-\u202E\u061C\u2066-\u2069\uFEFF]'), '');
    final name = rawName.length > 128 ? rawName.substring(0, 128) : rawName;
    return (name: name, addresses: addresses);
  } catch (e) {
    debugPrint('[AddContact] Config parse error: $e');
    return null;
  }
}
