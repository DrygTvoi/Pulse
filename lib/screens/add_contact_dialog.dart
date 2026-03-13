import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';

class AddContactDialog extends StatefulWidget {
  final Function(Contact) onAdd;
  const AddContactDialog({super.key, required this.onAdd});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _detectedProvider; // null = not detected yet
  String? _addressError;

  // Nostr profile fetch state
  bool _fetchingProfile = false;
  String? _profileFetchStatus; // "Fetching…" / "Found: Alice" / "No profile found"
  Timer? _debounceTimer;

  static const _providerColors = {
    'Nostr':    Color(0xFF9B59B6),
    'Firebase': Color(0xFFFFAB00),
    'Waku':     Color(0xFF00BCD4),
  };

  static const _providerIcons = {
    'Nostr':    Icons.bolt_rounded,
    'Firebase': Icons.local_fire_department_rounded,
    'Waku':     Icons.hub_rounded,
  };

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ── Provider auto-detection ───────────────────────────────────────────────

  String? _detectProvider(String address) {
    if (address.isEmpty) return null;
    final lower = address.toLowerCase();
    if (lower.contains('@wss://') || lower.contains('@ws://')) return 'Nostr';
    if (lower.contains('@https://')) return 'Firebase';
    if (lower.contains('@http://')) return 'Waku';
    // 64-char hex = bare Nostr pubkey
    if (RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) return 'Nostr';
    return null;
  }

  void _onAddressChanged(String value) {
    // Try to parse a pulse://add?cfg=... invite link
    if (value.startsWith('pulse://add') || value.startsWith('messenger://join')) {
      _parsePulseLink(value);
      return;
    }
    setState(() {
      _detectedProvider = _detectProvider(value);
      _addressError = null;
      _profileFetchStatus = null;
    });
    if (_detectedProvider == 'Nostr') {
      _tryScheduleNostrFetch(value);
    } else {
      _debounceTimer?.cancel();
    }
  }

  void _parsePulseLink(String link) {
    try {
      final uri = Uri.parse(link);
      final cfg64 = uri.queryParameters['cfg'];
      if (cfg64 == null) return;
      final json = jsonDecode(utf8.decode(base64Decode(cfg64)))
          as Map<String, dynamic>;
      final addr = (json['a'] as String?) ?? '';
      final name = (json['n'] as String?) ?? '';
      if (addr.isNotEmpty) {
        _addressController.text = addr;
        if (name.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = name;
        }
        setState(() {
          _detectedProvider = _detectProvider(addr);
          _addressError = null;
          _profileFetchStatus = null;
        });
        // If Nostr and name is still empty, try fetching profile
        if (_detectedProvider == 'Nostr' && _nameController.text.isEmpty) {
          _tryScheduleNostrFetch(addr);
        }
      }
    } catch (_) {
      // Not a valid link — treat as raw address
      setState(() {
        _detectedProvider = _detectProvider(link);
        _addressError = null;
        _profileFetchStatus = null;
      });
    }
  }

  // ── Nostr NIP-01 kind:0 profile fetch ─────────────────────────────────────

  void _tryScheduleNostrFetch(String address) {
    _debounceTimer?.cancel();

    // Extract pubkey and relay from address
    String pubkey;
    String? relayWs;

    final lower = address.toLowerCase();
    if (lower.contains('@wss://') || lower.contains('@ws://')) {
      final atIdx = address.indexOf('@');
      if (atIdx < 0) return;
      pubkey = address.substring(0, atIdx).toLowerCase();
      relayWs = address.substring(atIdx + 1);
    } else if (RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) {
      pubkey = lower;
      relayWs = 'wss://relay.damus.io'; // default public relay for bare pubkeys
    } else {
      return;
    }

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(pubkey)) return;

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _fetchNostrProfile(pubkey, relayWs!);
    });
  }

  Future<void> _fetchNostrProfile(String pubkey, String relayWs) async {
    if (!mounted) return;
    setState(() {
      _fetchingProfile = true;
      _profileFetchStatus = 'Fetching Nostr profile…';
    });

    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(relayWs));
      final subId = 'meta_${Random().nextInt(999999)}';
      final req = jsonEncode([
        'REQ',
        subId,
        {'kinds': [0], 'authors': [pubkey], 'limit': 1}
      ]);
      channel.sink.add(req);

      String? foundName;
      await for (final raw in channel.stream.timeout(const Duration(seconds: 6))) {
        final msg = jsonDecode(raw as String) as List<dynamic>;
        if (msg.isEmpty) continue;
        final type = msg[0] as String;
        if (type == 'EVENT' && msg.length >= 3) {
          final event = msg[2] as Map<String, dynamic>;
          if (event['kind'] == 0) {
            try {
              final content = jsonDecode(event['content'] as String)
                  as Map<String, dynamic>;
              final name = (content['display_name'] as String?)?.trim() ??
                  (content['name'] as String?)?.trim();
              if (name != null && name.isNotEmpty) {
                foundName = name;
              }
            } catch (_) {}
          }
        } else if (type == 'EOSE') {
          break;
        }
      }

      if (!mounted) return;
      if (foundName != null) {
        setState(() {
          _fetchingProfile = false;
          _profileFetchStatus = 'Found: $foundName';
        });
        // Auto-fill only if the user hasn't typed anything yet
        if (_nameController.text.isEmpty) {
          _nameController.text = foundName;
        }
      } else {
        setState(() {
          _fetchingProfile = false;
          _profileFetchStatus = 'No profile on this relay';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _fetchingProfile = false;
        _profileFetchStatus = 'Could not reach relay';
      });
    } finally {
      channel?.sink.close();
    }
  }

  // ── Paste from clipboard ──────────────────────────────────────────────────

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;
    _addressController.text = data!.text!.trim();
    _onAddressChanged(data.text!.trim());
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submit() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() => _addressError = 'Address is required');
      return;
    }

    final provider = _detectedProvider ?? 'Nostr';
    String name = _nameController.text.trim();

    // Fall back to short address ID if name is blank
    if (name.isEmpty) {
      final atIdx = address.indexOf('@');
      final raw = atIdx > 0 ? address.substring(0, atIdx) : address;
      name = raw.length > 12 ? raw.substring(0, 12) : raw;
    }

    final contact = Contact(
      id: const Uuid().v4(),
      name: name,
      provider: provider,
      databaseId: address,
      publicKey: '',
    );
    widget.onAdd(contact);
    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final providerColor =
        _providerColors[_detectedProvider] ?? AppTheme.textSecondary;
    final providerIcon =
        _providerIcons[_detectedProvider] ?? Icons.person_add_rounded;

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
              // Header
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_add_rounded,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Add Contact',
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]),
              const SizedBox(height: 20),

              // Address field
              _label('Address or Invite Link'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    autofocus: true,
                    onChanged: _onAddressChanged,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText:
                          'pubkey@wss://relay  ·  userId@https://firebase  ·  pulse://add?...',
                      hintStyle: GoogleFonts.inter(
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                          fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.surfaceVariant,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: _addressError != null
                                ? const Color(0xFFF87171)
                                : (_detectedProvider != null
                                    ? providerColor
                                    : AppTheme.primary),
                            width: 1.5),
                      ),
                      errorText: _addressError,
                      errorStyle: GoogleFonts.inter(
                          color: const Color(0xFFF87171), fontSize: 11),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Paste button
                Tooltip(
                  message: 'Paste from clipboard',
                  child: InkWell(
                    onTap: _pasteFromClipboard,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.content_paste_rounded,
                          color: AppTheme.textSecondary, size: 18),
                    ),
                  ),
                ),
              ]),

              // Provider chip (auto-detected)
              if (_detectedProvider != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: providerColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(providerIcon, color: providerColor, size: 13),
                      const SizedBox(width: 5),
                      Text(_detectedProvider!,
                          style: GoogleFonts.inter(
                              color: providerColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(width: 6),
                  Text('detected',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ]),
              ],
              const SizedBox(height: 16),

              // Name field
              _label('Display Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _detectedProvider == 'Nostr'
                      ? 'Optional — auto-filled from Nostr profile'
                      : 'What do you want to call them?',
                  hintStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 12),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),

              // Nostr profile fetch status
              if (_detectedProvider == 'Nostr' && _profileFetchStatus != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  if (_fetchingProfile)
                    SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: _providerColors['Nostr'],
                      ),
                    )
                  else
                    Icon(
                      _profileFetchStatus!.startsWith('Found')
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 13,
                      color: _profileFetchStatus!.startsWith('Found')
                          ? const Color(0xFF4CAF50)
                          : AppTheme.textSecondary,
                    ),
                  const SizedBox(width: 5),
                  Text(
                    _profileFetchStatus!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _profileFetchStatus!.startsWith('Found')
                          ? const Color(0xFF4CAF50)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _detectedProvider != null
                        ? providerColor
                        : AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _addressController.text.trim().isEmpty
                      ? null
                      : _submit,
                  child: Text('Add Contact',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.inter(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));
}
