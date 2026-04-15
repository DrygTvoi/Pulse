import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/pin_input.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convert/convert.dart';
import '../adapters/nostr_adapter.dart' show deriveNostrPubkeyHex;
import '../controllers/chat_controller.dart';
import '../services/relay_prober.dart';
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
  final _nameController = TextEditingController();
  final _verifyController = TextEditingController();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  String _generatedKey = '';
  bool _keyCopied = false;
  String? _verifyError;
  String _pin = '';
  String? _pinError;
  bool _settingPin = false; // false = first entry, true = confirm entry
  String _firstPin = '';

  Future<String>? _relayProbe;

  @override
  void initState() {
    super.initState();
    _relayProbe = probeBootstrapRelays();
    _generatedKey = RecoveryKeyService.generate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _verifyController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  // ── Page 1: Name ──────────────────────────────────────────────────────────

  bool get _canProceedName => _nameController.text.trim().isNotEmpty;

  // ── Page 2: Show Recovery Key ─────────────────────────────────────────────

  void _copyKey() {
    Clipboard.setData(ClipboardData(text: _generatedKey));
    HapticFeedback.lightImpact();
    setState(() => _keyCopied = true);
  }

  // ── Page 3: Verify Key ────────────────────────────────────────────────────

  bool get _verifyMatches =>
      RecoveryKeyService.normalize(_verifyController.text) ==
      RecoveryKeyService.normalize(_generatedKey);

  void _verifyAndProceed() {
    if (_verifyMatches) {
      _goToPage(3);
    } else {
      setState(() => _verifyError = context.l10n.setupKeyMismatch);
    }
  }

  void _skipVerification() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        title: Text(context.l10n.setupSkipVerifyTitle,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(context.l10n.setupSkipVerifyBody,
            style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel,
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.skip,
                style: GoogleFonts.inter(color: AppTheme.warning, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) _goToPage(3);
  }

  // ── Page 4: PIN Setup ─────────────────────────────────────────────────────

  void _onPinComplete(String pin) {
    if (!_settingPin) {
      // First entry
      setState(() {
        _firstPin = pin;
        _settingPin = true;
        _pin = '';
        _pinError = null;
      });
    } else {
      // Confirm entry
      if (pin == _firstPin) {
        setState(() => _pin = pin);
        _createAccount();
      } else {
        setState(() {
          _pinError = context.l10n.setupPinMismatch;
          _settingPin = false;
          _firstPin = '';
          _pin = '';
        });
      }
    }
  }

  // ── Account creation ──────────────────────────────────────────────────────

  Future<void> _createAccount() async {
    if (_isLoading) return;
    _isLoading = true;

    const ss = FlutterSecureStorage();
    final existingKey = await ss.read(key: 'nostr_privkey');
    if (existingKey != null && existingKey.isNotEmpty) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.replaceIdentityTitle),
          content: Text(context.l10n.replaceIdentityBodyCreate),
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
    // Use the normalized recovery key as the password for key derivation.
    final password = RecoveryKeyService.normalize(_generatedKey);

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

    // Hash PIN for lock screen.
    final signalService = SignalService();
    final pinSalt = _generateSalt();
    final parallelResults = await Future.wait([
      signalService.initialize().then((_) => signalService.getPublicBundle()),
      SessionKeyService.instance.initialize(),
      PasswordHasher.hash(_pin, pinSalt),
      SharedPreferences.getInstance(),
      _relayProbe ?? Future.value(null),
    ]);

    final bundle = parallelResults[0] as Map<String, dynamic>;
    final pinHash = parallelResults[2] as String;
    final prefs = parallelResults[3] as SharedPreferences;
    final probedRelay = parallelResults[4] as String?;

    final uuid = const Uuid().v4();
    final realPubKey = base64Encode(
        Uint8List.fromList(List<int>.from(bundle['identityKey'])));

    final relay = prefs.getString('nostr_relay') ?? probedRelay ?? kDefaultNostrRelay;
    final pubkeyHex = deriveNostrPubkeyHex(privkeyHex);
    final sessionId = SessionKeyService.instance.sessionId;

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
        'avatar_color': _avatarColors[Random.secure().nextInt(_avatarColors.length)].toARGB32().toString(),
      })),
      prefs.setString('secondary_adapters', jsonEncode([{
        'provider': 'Session',
        'apiKey': '',
        'databaseId': sessionId,
        'selfId': sessionId,
      }])),
      // Store PIN hash (not password hash)
      ss.write(key: 'app_pin_hash', value: pinHash),
      ss.write(key: 'app_pin_salt', value: pinSalt),
      ss.write(key: 'app_pin_enabled', value: 'true'),
    ]);

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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: List.generate(4, (i) => Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? purple : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _buildNamePage(purple),
                  _buildKeyDisplayPage(purple),
                  _buildKeyVerifyPage(purple),
                  _buildPinPage(purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Page builders ─────────────────────────────────────────────────────────

  Widget _buildNamePage(Color purple) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.shield_rounded, color: AppTheme.onPrimary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.setupCreateAnonymousAccount,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(context.l10n.setupKeyWarning,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
          const SizedBox(height: 32),
          _buildField(
            controller: _nameController,
            hint: context.l10n.setupYourNickname,
            icon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: purple,
                disabledBackgroundColor: purple.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _canProceedName ? () => _goToPage(1) : null,
              child: Text(context.l10n.setupNext,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onPrimary)),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RestoreAccountScreen()),
            ),
            child: Text.rich(
              TextSpan(
                text: context.l10n.setupAlreadyHaveAccount,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
                children: [
                  TextSpan(
                    text: context.l10n.setupRestore,
                    style: GoogleFonts.inter(color: purple, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyDisplayPage(Color purple) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.key_rounded, size: 48, color: AppTheme.warning),
          const SizedBox(height: 16),
          Text(context.l10n.setupKeyTitle,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(context.l10n.setupKeySubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 28),
          // Key display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
            ),
            child: SelectableText(
              _generatedKey,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Copy button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyKey,
              icon: Icon(_keyCopied ? Icons.check_rounded : Icons.copy_rounded, size: 18),
              label: Text(_keyCopied ? context.l10n.setupKeyCopied : context.l10n.copy),
              style: OutlinedButton.styleFrom(
                foregroundColor: _keyCopied ? AppTheme.success : AppTheme.textPrimary,
                side: BorderSide(color: _keyCopied ? AppTheme.success : AppTheme.textSecondary.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorLight.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.errorLight.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.errorLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(context.l10n.setupKeyWarnBody,
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _goToPage(2),
              child: Text(context.l10n.setupKeyWroteItDown,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyVerifyPage(Color purple) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.verified_rounded, size: 48, color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(context.l10n.setupVerifyTitle,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(context.l10n.setupVerifySubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 28),
          TextField(
            controller: _verifyController,
            inputFormatters: [RecoveryKeyFormatter()],
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() => _verifyError = null),
            style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary, fontSize: 16, letterSpacing: 1.2),
            decoration: InputDecoration(
              hintText: 'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX',
              hintStyle: GoogleFonts.jetBrainsMono(
                  color: AppTheme.textSecondary.withValues(alpha: 0.4), fontSize: 16),
              errorText: _verifyError,
              filled: true,
              fillColor: AppTheme.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: purple, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: purple,
                disabledBackgroundColor: purple.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: RecoveryKeyService.isValid(_verifyController.text)
                  ? _verifyAndProceed
                  : null,
              child: Text(context.l10n.setupVerifyButton,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onPrimary)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _skipVerification,
            child: Text(context.l10n.setupSkipVerify,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildPinPage(Color purple) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          Icon(Icons.pin_rounded, size: 48, color: purple),
          const SizedBox(height: 16),
          if (_isLoading)
            Column(children: [
              const SizedBox(height: 40),
              const SizedBox(
                  width: 32, height: 32,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
              const SizedBox(height: 16),
              Text(context.l10n.setupCreatingAccount,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
            ])
          else
            PinInput(
              key: ValueKey('pin_$_settingPin'),
              title: _settingPin
                  ? context.l10n.setupPinConfirm
                  : context.l10n.setupPinSet,
              error: _pinError,
              onComplete: _onPinComplete,
            ),
          if (!_isLoading) ...[
            const SizedBox(height: 12),
            Text(
              context.l10n.setupPinHint,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ],
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
        hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffix,
        errorText: errorText,
        errorStyle: GoogleFonts.inter(fontSize: 11),
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: errorText != null
                ? BorderSide(color: AppTheme.errorLight, width: 1.5)
                : BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: errorText != null ? AppTheme.errorLight : purple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
