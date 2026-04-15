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
import '../services/recovery_key_service.dart';
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
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();
  int  _colorIndex  = 0;
  bool _isLoading   = false;

  // Password setup step
  bool _showPassStep = false;
  final _passController2 = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _showPass = false;
  bool _showConfirm = false;
  String? _passError;

  Future<String>? _relayProbe;

  @override
  void initState() {
    super.initState();
    _relayProbe = probeBootstrapRelays();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _passController2.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_isLoading &&
      _nameController.text.trim().isNotEmpty &&
      RecoveryKeyService.isValid(_keyController.text);

  // ── Password step ──────────────────────────────────────────────────────

  static final _hasLetter = RegExp(r'[a-zA-Z]');
  static final _hasDigit = RegExp(r'\d');
  static final _hasSpecial = RegExp(r'[^a-zA-Z0-9]');

  void _submitPassword() {
    final pass = _passController2.text;
    final confirm = _confirmPassController.text;

    if (pass.length < 8) {
      setState(() => _passError = context.l10n.passwordMinChars);
      return;
    }
    if (!_hasLetter.hasMatch(pass) || !_hasDigit.hasMatch(pass) || !_hasSpecial.hasMatch(pass)) {
      setState(() => _passError = context.l10n.passwordNeedsVariety);
      return;
    }
    if (pass != confirm) {
      setState(() => _passError = context.l10n.passwordsDoNotMatch);
      return;
    }
    _restore(pass);
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  Future<void> _restore(String appPassword) async {
    if (_isLoading) return;
    _isLoading = true;

    const ss = FlutterSecureStorage();
    final onboardPrefs = await SharedPreferences.getInstance();
    final alreadyOnboarded = onboardPrefs.getBool('onboarding_done') ?? false;
    final existingKey = await ss.read(key: 'nostr_privkey');
    if (alreadyOnboarded && existingKey != null && existingKey.isNotEmpty) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.replaceIdentityTitle),
          content: Text(context.l10n.replaceIdentityBodyRestore),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.replace,
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

    final name = _nameController.text.trim();
    final password = RecoveryKeyService.normalize(_keyController.text);

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

    final signalService = SignalService();
    final pwSalt = _generateSalt();
    final parallelResults = await Future.wait([
      signalService.initialize().then((_) => signalService.getPublicBundle()),
      SessionKeyService.instance.initialize(),
      PasswordHasher.hash(appPassword, pwSalt),
      SharedPreferences.getInstance(),
      _relayProbe ?? Future.value(null),
    ]);

    final bundle = parallelResults[0] as Map<String, dynamic>;
    final pwHash = parallelResults[2] as String;
    final prefs = parallelResults[3] as SharedPreferences;
    final probedRelay = parallelResults[4] as String?;

    final uuid = const Uuid().v4();
    final realPubKey = base64Encode(
        Uint8List.fromList(List<int>.from(bundle['identityKey'])));

    final relay = prefs.getString('nostr_relay') ?? probedRelay ?? kDefaultNostrRelay;
    final pubkeyHex = deriveNostrPubkeyHex(privkeyHex);
    final sessionId = SessionKeyService.instance.sessionId;

    nip44.clearNonceCache();

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
      ss.write(key: 'app_password_hash', value: pwHash),
      ss.write(key: 'app_password_salt', value: pwSalt),
      ss.write(key: 'app_password_enabled', value: 'true'),
      ss.write(key: 'recovery_key', value: RecoveryKeyService.format(
          RecoveryKeyService.normalize(_keyController.text))),
    ]);

    final prefs2 = await SharedPreferences.getInstance();
    await prefs2.setBool('onboarding_done', true);
    unawaited(ChatController().initialize());

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
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
    final accent = AppTheme.primary;
    const green  = Color(0xFF34D399);
    final color   = _avatarColors[_colorIndex];
    final name    = _nameController.text.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    if (_showPassStep) return _buildPasswordScreen(accent);

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
                color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
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
                  border: Border.all(color: green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.restoreKeyInfoBanner,
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
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
                        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Center(
                        child: Text(initial,
                            style: GoogleFonts.inter(
                                fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceVariant, width: 2),
                      ),
                      child: const Icon(Icons.color_lens_rounded, size: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(context.l10n.restoreNewNickname,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 28),

              // Name
              _buildField(
                controller: _nameController,
                hint: context.l10n.setupYourNickname,
                icon: Icons.person_outline_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Recovery key input
              TextField(
                controller: _keyController,
                inputFormatters: [RecoveryKeyFormatter()],
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.textPrimary, fontSize: 15, letterSpacing: 1.2),
                decoration: InputDecoration(
                  hintText: context.l10n.restoreKeyHint,
                  hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15),
                  prefixIcon: Icon(Icons.key_rounded, color: AppTheme.textSecondary, size: 20),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _canSubmit ? () => setState(() => _showPassStep = true) : null,
                  child: Text(context.l10n.setupNext,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordScreen(Color accent) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => setState(() {
            _showPassStep = false;
            _passError = null;
          }),
        ),
        title: Text(context.l10n.restoreTitle,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                Icon(Icons.lock_rounded, size: 48, color: accent),
                const SizedBox(height: 16),
                Text(context.l10n.passwordSetAppPassword,
                    style: GoogleFonts.inter(
                        fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text(context.l10n.passwordProtectsMessages,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                const SizedBox(height: 28),
                if (_isLoading)
                  Column(children: [
                    const SizedBox(height: 40),
                    const SizedBox(
                        width: 32, height: 32,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                    const SizedBox(height: 16),
                    Text(context.l10n.setupRestoringAccount,
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
                  ])
                else ...[
                  _buildPassField(
                    controller: _passController2,
                    hint: context.l10n.passwordHint,
                    visible: _showPass,
                    onToggle: () => setState(() => _showPass = !_showPass),
                    accent: accent,
                  ),
                  const SizedBox(height: 12),
                  _buildPassField(
                    controller: _confirmPassController,
                    hint: context.l10n.passwordConfirmHint,
                    visible: _showConfirm,
                    onToggle: () => setState(() => _showConfirm = !_showConfirm),
                    accent: accent,
                  ),
                  if (_passError != null) ...[
                    const SizedBox(height: 10),
                    Text(_passError!,
                        style: GoogleFonts.inter(color: AppTheme.errorLight, fontSize: 12)),
                  ],
                  const SizedBox(height: 8),
                  Text(context.l10n.passwordRequirements,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11, height: 1.4)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        disabledBackgroundColor: const Color(0xFF34D399).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _passController2.text.length >= 8 ? _submitPassword : null,
                      child: Text(context.l10n.restoreButton,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
    required Color accent,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      onChanged: (_) => setState(() => _passError = null),
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppTheme.textSecondary, size: 20),
          onPressed: onToggle,
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
    final accent = AppTheme.primary;
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
