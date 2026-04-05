import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/identity.dart';
import '../constants.dart';
import '../theme/app_theme.dart';
import '../services/signal_service.dart';
import '../services/key_derivation_service.dart';
import '../services/password_hasher.dart';
import '../services/session_key_service.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convert/convert.dart';
import '../adapters/nostr_adapter.dart' show deriveNostrPubkeyHex;
import '../controllers/chat_controller.dart';
import '../services/relay_prober.dart';
import 'home_screen.dart';
import '../l10n/l10n_ext.dart';
import '../services/nip44_service.dart' as nip44;

const _avatarColors = [
  Color(0xFF25D366),
  Color(0xFF60A5FA),
  Color(0xFFA78BFA),
  Color(0xFFFBBF24),
  Color(0xFFF87171),
  Color(0xFF34D399),
  Color(0xFFFB923C),
  Color(0xFF818CF8),
];

class RestoreAccountScreen extends StatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  State<RestoreAccountScreen> createState() => _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends State<RestoreAccountScreen> {
  final _nameController     = TextEditingController();
  final _passwordController = TextEditingController();
  int  _colorIndex   = 0;
  bool _isLoading    = false;
  bool _showPassword = false;

  Future<String>? _relayProbe;

  @override
  void initState() {
    super.initState();
    _relayProbe = probeBootstrapRelays();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// True if password meets variety requirements (3 of 4 character classes).
  bool get _hasVariety {
    final p = _passwordController.text;
    int classes = 0;
    if (p.contains(RegExp(r'[a-z]'))) classes++;
    if (p.contains(RegExp(r'[A-Z]'))) classes++;
    if (p.contains(RegExp(r'[0-9]'))) classes++;
    if (p.contains(RegExp(r'[^a-zA-Z0-9]'))) classes++;
    return classes >= 3;
  }

  bool get _canSubmit =>
      !_isLoading &&
      _nameController.text.trim().isNotEmpty &&
      _passwordController.text.length >= 16 &&
      _hasVariety;

  double get _entropyBits {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    int charset = 0;
    if (p.contains(RegExp(r'[a-z]'))) charset += 26;
    if (p.contains(RegExp(r'[A-Z]'))) charset += 26;
    if (p.contains(RegExp(r'[0-9]'))) charset += 10;
    if (p.contains(RegExp(r'[^a-zA-Z0-9]'))) charset += 32;
    if (charset == 0) charset = 26;
    // Penalize low uniqueness (repeated characters reduce effective entropy).
    final uniqueChars = p.split('').toSet().length;
    final uniqueRatio = uniqueChars / p.length;
    return p.length * (log(charset) / ln2) * uniqueRatio;
  }

  String _entropyLabel(BuildContext context) {
    final l = context.l10n;
    if (!_hasVariety && _passwordController.text.length >= 16) return l.setupEntropyWeakNeedsVariety;
    final bits = _entropyBits;
    if (bits < 50) return l.setupEntropyWeak;
    if (bits < 80) return l.setupEntropyOk;
    return l.setupEntropyStrong;
  }

  Color get _entropyColor {
    if (!_hasVariety && _passwordController.text.length >= 16) return const Color(0xFFF87171);
    final bits = _entropyBits;
    if (bits < 50) return const Color(0xFFF87171);
    if (bits < 80) return const Color(0xFFFBBF24);
    return const Color(0xFF34D399);
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  Future<void> _restore() async {
    if (!_canSubmit) return;
    // Guard against double-tap: set synchronously before first await so a
    // concurrent call that checks _canSubmit (reads _isLoading) sees true.
    _isLoading = true;

    // Guard against silently overwriting an existing identity.
    const ss = FlutterSecureStorage();
    final existingKey = await ss.read(key: 'nostr_privkey');
    if (existingKey != null && existingKey.isNotEmpty) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Replace existing identity?'),
          content: const Text(
              'An identity already exists on this device. Restoring will '
              'permanently replace your current Nostr key and Oxen seed. '
              'All contacts will lose the ability to reach your current address.\n\n'
              'This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Replace',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error))),
          ],
        ),
      );
      if (confirmed != true) {
        setState(() => _isLoading = false);
        return;
      }
    }

    setState(() => _isLoading = true);

    final name     = _nameController.text.trim();
    final password = _passwordController.text;

    // Derive all 3 keys in parallel — each runs in its own isolate.
    final results = await Future.wait([
      KeyDerivationService.deriveNostrKey(password),
      KeyDerivationService.deriveSessionSeed(password),
      KeyDerivationService.derivePulseKey(password),
    ]);
    final nostrKeyBytes = results[0];
    final sessionSeedBytes = results[1];
    final pulseKeyBytes = results[2];

    final privkeyHex = hex.encode(nostrKeyBytes);
    await ss.write(key: 'nostr_privkey', value: privkeyHex);
    nostrKeyBytes.fillRange(0, nostrKeyBytes.length, 0);

    final sessionHex = hex.encode(sessionSeedBytes);
    await ss.write(key: 'session_seed', value: sessionHex);
    sessionSeedBytes.fillRange(0, sessionSeedBytes.length, 0);

    final pulseHex = hex.encode(pulseKeyBytes);
    await ss.write(key: 'pulse_privkey', value: pulseHex);
    pulseKeyBytes.fillRange(0, pulseKeyBytes.length, 0);

    // Run Signal init, Session init, password hashing, and relay probe in parallel.
    final signalService = SignalService();
    final salt = _generateSalt();
    final parallelResults = await Future.wait([
      signalService.initialize().then((_) => signalService.getPublicBundle()),  // [0]
      SessionKeyService.instance.initialize(),                                   // [1]
      PasswordHasher.hash(password, salt),                                       // [2]
      SharedPreferences.getInstance(),                                           // [3]
      _relayProbe ?? Future.value(null),                                         // [4]
    ]);

    final bundle = parallelResults[0] as Map<String, dynamic>;
    final hash = parallelResults[2] as String;
    final prefs = parallelResults[3] as SharedPreferences;
    final probedRelay = parallelResults[4] as String?;

    final uuid       = const Uuid().v4();
    final realPubKey = base64Encode(
        Uint8List.fromList(List<int>.from(bundle['identityKey'])));

    final relay = prefs.getString('nostr_relay') ?? probedRelay ?? kDefaultNostrRelay;
    final pubkeyHex = deriveNostrPubkeyHex(privkeyHex);
    final sessionId = SessionKeyService.instance.sessionId;

    // Purge NIP-44 nonce cache before writing new identity.
    nip44.clearNonceCache();

    // Write all prefs and secure storage in parallel.
    await Future.wait([
      prefs.setString('nostr_relay', relay),
      prefs.setString('user_identity', jsonEncode(Identity(
        id: uuid,
        publicKey: realPubKey,
        privateKey: '',
        preferredAdapter: 'nostr',
        adapterConfig: {'dbId': '$pubkeyHex@$relay', 'relay': relay},
      ).toJson())),
      prefs.setString('user_profile', jsonEncode({
        'name': name,
        'about': '',
        'avatar_color': _avatarColors[_colorIndex].toARGB32().toString(),
      })),
      prefs.setString('secondary_adapters', jsonEncode([{
        'provider': 'Session',
        'apiKey': '',
        'databaseId': sessionId,
        'selfId': sessionId,
      }])),
      ss.write(key: 'app_password_hash',    value: hash),
      ss.write(key: 'app_password_salt',    value: salt),
      ss.write(key: 'app_password_enabled', value: 'true'),
    ]);

    // Fire ChatController init in background — don't block navigation.
    unawaited(ChatController().initialize());

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  String _generateSalt() {
    final rng = Random.secure();
    return hex.encode(
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256))));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFA78BFA);
    const green  = Color(0xFF34D399);
    final color   = _avatarColors[_colorIndex];
    final name    = _nameController.text.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(context.l10n.restoreTitle,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.restoreInfoBanner,
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Avatar
              GestureDetector(
                onTap: () => setState(
                    () => _colorIndex = (_colorIndex + 1) % _avatarColors.length),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: purple.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Center(
                        child: Text(initial,
                            style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.surfaceVariant, width: 2),
                      ),
                      child: const Icon(Icons.color_lens_rounded,
                          size: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(context.l10n.restoreNewNickname,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 28),

              // Name
              _buildField(
                controller: _nameController,
                hint: context.l10n.setupYourNickname,
                icon: Icons.person_outline_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Password
              _buildField(
                controller: _passwordController,
                hint: context.l10n.setupRecoveryPassword,
                icon: Icons.lock_outline_rounded,
                obscure: !_showPassword,
                onChanged: (_) => setState(() {}),
                suffix: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textSecondary, size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              if (_passwordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: _entropyColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.setupEntropyBits(_entropyLabel(context), _entropyBits.round()),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _entropyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    disabledBackgroundColor: green.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _canSubmit ? _restore : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(context.l10n.restoreButton,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    void Function(String)? onChanged,
    Widget? suffix,
  }) {
    const purple = Color(0xFFA78BFA);
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: purple, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
