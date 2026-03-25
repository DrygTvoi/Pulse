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
import '../services/oxen_key_service.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convert/convert.dart';
import '../adapters/nostr_adapter.dart' show deriveNostrPubkeyHex;
import 'home_screen.dart';
import 'restore_account_screen.dart';
import '../l10n/l10n_ext.dart';

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

class SetupIdentityScreen extends StatefulWidget {
  final String? initialConfig;
  const SetupIdentityScreen({super.key, this.initialConfig});

  @override
  State<SetupIdentityScreen> createState() => _SetupIdentityScreenState();
}

class _SetupIdentityScreenState extends State<SetupIdentityScreen> {
  final _nameController     = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  int  _colorIndex   = 0;
  bool _isLoading    = false;
  bool _showPassword = false;
  bool _showConfirm  = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? get _passwordError {
    final p = _passwordController.text;
    if (p.isEmpty) return null;
    if (p.length < 16) return null; // validated via _canSubmit; label shown via entropy
    return null;
  }

  /// Entropy estimate penalizing repetition and requiring character variety.
  /// Returns effective bits = charset_bits * unique_char_ratio * length.
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

  String? get _confirmError {
    final c = _confirmController.text;
    if (c.isEmpty) return null;
    if (c != _passwordController.text) return null; // validated via _canSubmit; error shown when context available
    return null;
  }

  bool get _canSubmit {
    final name = _nameController.text.trim();
    final pass = _passwordController.text;
    final conf = _confirmController.text;
    return !_isLoading &&
        name.isNotEmpty &&
        pass.length >= 16 &&
        _hasVariety &&
        pass == conf;
  }

  // ── Account creation ──────────────────────────────────────────────────────

  Future<void> _createAccount() async {
    if (!_canSubmit) return;
    // F9: Guard against double-tap. Set synchronously before first await so a
    // second tap that checks _canSubmit (which reads _isLoading) sees true.
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
              'An identity already exists on this device. Creating a new one will '
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
      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);

    final name     = _nameController.text.trim();
    final password = _passwordController.text;

    // Derive Nostr key and Oxen seed from the recovery password.
    // This runs in isolates so the UI stays responsive during 600k iterations.
    final nostrKeyBytes = await KeyDerivationService.deriveNostrKey(password);
    final oxenSeedBytes = await KeyDerivationService.deriveOxenSeed(password);

    // Store Nostr private key; zero key bytes immediately after encoding
    final privkeyHex = hex.encode(nostrKeyBytes);
    await ss.write(key: 'nostr_privkey', value: privkeyHex);
    nostrKeyBytes.fillRange(0, nostrKeyBytes.length, 0);

    // Store Oxen seed so OxenKeyService picks it up on initialize()
    final oxenHex = hex.encode(oxenSeedBytes);
    await ss.write(key: 'oxen_seed', value: oxenHex);
    oxenSeedBytes.fillRange(0, oxenSeedBytes.length, 0);

    // Signal identity keys — generated fresh (per-device; re-published on connect)
    final signalService = SignalService();
    await signalService.initialize();
    final bundle = await signalService.getPublicBundle();

    final uuid         = const Uuid().v4();
    final realPubKey   = base64Encode(
        Uint8List.fromList(List<int>.from(bundle['identityKey'])));

    final relay = kDefaultNostrRelay;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nostr_relay', relay);

    final pubkeyHex = deriveNostrPubkeyHex(privkeyHex);
    final identity = Identity(
      id: uuid,
      publicKey: realPubKey,
      privateKey: '',
      preferredAdapter: 'nostr',
      adapterConfig: {'dbId': '$pubkeyHex@$relay', 'relay': relay},
    );
    await prefs.setString('user_identity', jsonEncode(identity.toJson()));
    await prefs.setString('user_profile', jsonEncode({
      'name': name,
      'about': '',
      'avatar_color': _avatarColors[_colorIndex].toARGB32().toString(),
    }));

    // Register Oxen secondary adapter
    await OxenKeyService.instance.initialize();
    final sessionId = OxenKeyService.instance.sessionId;
    await prefs.setString('secondary_adapters', jsonEncode([{
      'provider': 'Oxen',
      'apiKey': '',
      'databaseId': sessionId,
      'selfId': sessionId,
    }]));

    // Save recovery password as the app lock — one password for everything.
    final salt = _generateSalt();
    final hash = await PasswordHasher.hash(password, salt);
    await ss.write(key: 'app_password_hash',    value: hash);
    await ss.write(key: 'app_password_salt',    value: salt);
    await ss.write(key: 'app_password_enabled', value: 'true');

    // Clear password text from controllers — best-effort scrub before navigate
    _passwordController.clear();
    _confirmController.clear();

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
    final color   = _avatarColors[_colorIndex];
    final name    = _nameController.text.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(context.l10n.appTitle,
                  style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Text(context.l10n.setupCreateAnonymousAccount,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 40),

              // Avatar picker
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
              Text(context.l10n.setupTapToChangeColor,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 28),

              // Name field
              _buildField(
                controller: _nameController,
                hint: context.l10n.setupYourNickname,
                icon: Icons.person_outline_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Password field
              _buildField(
                controller: _passwordController,
                hint: context.l10n.setupRecoveryPassword,
                icon: Icons.lock_outline_rounded,
                obscure: !_showPassword,
                errorText: _passwordError,
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
              const SizedBox(height: 14),

              // Confirm field
              _buildField(
                controller: _confirmController,
                hint: context.l10n.setupConfirmPassword,
                icon: Icons.lock_outline_rounded,
                obscure: !_showConfirm,
                errorText: _confirmError,
                onChanged: (_) => setState(() {}),
                suffix: IconButton(
                  icon: Icon(
                    _showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textSecondary, size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showConfirm = !_showConfirm),
                ),
              ),
              const SizedBox(height: 16),

              // Warning banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFBBF24), size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.setupPasswordWarning,
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: purple,
                    disabledBackgroundColor: purple.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _canSubmit ? _createAccount : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(context.l10n.setupCreateAccount,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),

              // Restore link
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const RestoreAccountScreen()),
                ),
                child: Text.rich(
                  TextSpan(
                    text: context.l10n.setupAlreadyHaveAccount,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 14),
                    children: [
                      TextSpan(
                        text: context.l10n.setupRestore,
                        style: GoogleFonts.inter(
                            color: purple, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
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
    String? errorText,
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
        errorText: errorText,
        errorStyle: GoogleFonts.inter(fontSize: 11),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: errorText != null
                ? const BorderSide(color: Color(0xFFF87171), width: 1.5)
                : BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: errorText != null
                  ? const Color(0xFFF87171)
                  : purple,
              width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
