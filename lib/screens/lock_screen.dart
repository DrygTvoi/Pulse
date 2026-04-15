import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../controllers/chat_controller.dart';
import '../services/local_storage_service.dart';
import '../services/password_hasher.dart';
import '../widgets/pin_input.dart';
import 'home_screen.dart';
import 'setup_identity_screen.dart';
import '../l10n/l10n_ext.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _controller = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;
  String? _error;
  int _attempts = 0;

  /// true = PIN mode (new accounts), false = legacy password mode.
  bool _isPinMode = true;
  bool _modeLoaded = false;

  static const _ss = FlutterSecureStorage();
  static const _maxAttempts = 10;
  static const _attemptsKey = 'lock_screen_attempts';

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final results = await Future.wait([
      _ss.read(key: 'app_pin_enabled'),
      _ss.read(key: 'app_password_enabled'),
      _ss.read(key: _attemptsKey),
    ]);
    final pinEnabled = results[0] == 'true';
    final pwEnabled = results[1] == 'true';
    setState(() {
      _isPinMode = pinEnabled || !pwEnabled;
      _modeLoaded = true;
      _attempts = int.tryParse(results[2] ?? '') ?? 0;
    });
  }

  Future<void> _persistAttempts() async {
    await _ss.write(key: _attemptsKey, value: '$_attempts');
  }

  Future<void> _clearAttempts() async {
    await _ss.delete(key: _attemptsKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── PIN unlock ──────────────────────────────────────────────────────────

  Future<void> _unlockWithPin(String pin) async {
    if (_loading) return;
    _loading = true;
    setState(() { _loading = true; _error = null; });

    final hash = await _ss.read(key: 'app_pin_hash');
    final salt = await _ss.read(key: 'app_pin_salt');

    if (hash == null || salt == null) {
      setState(() { _loading = false; _error = 'wrong'; });
      return;
    }

    _attempts++;
    await _persistAttempts();

    // Check panic key first
    final panicHash = await _ss.read(key: 'app_panic_key_hash');
    final panicSalt = await _ss.read(key: 'app_panic_key_salt');
    if (panicHash != null && panicSalt != null) {
      if (await PasswordHasher.verify(pin, panicSalt, panicHash)) {
        await _wipeAll();
        return;
      }
    }

    if (await PasswordHasher.verify(pin, salt, hash)) {
      if (PasswordHasher.isLegacy(hash)) {
        final newHash = await PasswordHasher.hash(pin, salt);
        await _ss.write(key: 'app_pin_hash', value: newHash);
      }
      await _clearAttempts();
      _goHome();
      return;
    }

    if (_attempts >= _maxAttempts) {
      setState(() => _error = 'too_many');
      await Future.delayed(const Duration(seconds: 2));
      await _wipeAll();
      return;
    }

    setState(() {
      _loading = false;
      _error = _attempts >= 3 ? 'wrong_with_count' : 'wrong';
    });
  }

  // ── Legacy password unlock ────────────────────────────────────────────────

  Future<void> _unlockWithPassword() async {
    final entered = _controller.text;
    if (entered.isEmpty) return;
    if (_loading) return;
    _loading = true;

    setState(() { _loading = true; _error = null; });

    final hash = await _ss.read(key: 'app_password_hash');
    final salt = await _ss.read(key: 'app_password_salt');

    if (hash == null || salt == null) {
      setState(() { _loading = false; _error = 'wrong'; });
      return;
    }

    _attempts++;
    await _persistAttempts();

    // Check panic key first
    final panicHash = await _ss.read(key: 'app_panic_key_hash');
    final panicSalt = await _ss.read(key: 'app_panic_key_salt');
    if (panicHash != null && panicSalt != null) {
      if (await PasswordHasher.verify(entered, panicSalt, panicHash)) {
        await _wipeAll();
        return;
      }
    }

    if (await PasswordHasher.verify(entered, salt, hash)) {
      if (PasswordHasher.isLegacy(hash)) {
        final newHash = await PasswordHasher.hash(entered, salt);
        await _ss.write(key: 'app_password_hash', value: newHash);
      }
      await _clearAttempts();
      _goHome();
      return;
    }

    _controller.clear();

    if (_attempts >= _maxAttempts) {
      setState(() => _error = 'too_many');
      await Future.delayed(const Duration(seconds: 2));
      await _wipeAll();
      return;
    }

    setState(() {
      _loading = false;
      _error = _attempts >= 3 ? 'wrong_with_count' : 'wrong';
    });
  }

  Future<void> _wipeAll() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _ss.deleteAll();
    await LocalStorageService().deleteAndClose();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SetupIdentityScreen()),
      (_) => false,
    );
  }

  void _goHome() {
    if (!mounted) return;
    context.read<ChatController>().broadcastAddressUpdate();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  String _resolveError(BuildContext context) {
    switch (_error) {
      case 'too_many': return context.l10n.lockTooManyAttempts;
      case 'wrong_with_count': return context.l10n.lockWrongPasswordAttempts(_attempts, _maxAttempts);
      case 'wrong': return context.l10n.lockWrongPin;
      default: return _error ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_modeLoaded) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_rounded, color: AppTheme.primary, size: 36),
                  ),
                  const SizedBox(height: 24),
                  Text(context.l10n.lockTitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    _isPinMode ? context.l10n.lockPinSubtitle : context.l10n.lockSubtitle,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 40),

                  if (_isPinMode)
                    _loading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : PinInput(
                            key: ValueKey('lock_pin_$_error'),
                            error: _error != null ? _resolveError(context) : null,
                            onComplete: _unlockWithPin,
                          )
                  else ...[
                    // Legacy password field
                    TextField(
                      controller: _controller,
                      obscureText: !_showPassword,
                      autofocus: true,
                      onSubmitted: (_) => _loading ? null : _unlockWithPassword(),
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: context.l10n.lockPasswordHint,
                        hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 16),
                        filled: true,
                        fillColor: AppTheme.surfaceVariant,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppTheme.textSecondary, size: 20),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                    // Error message
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.errorLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.errorLight.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          Icon(Icons.error_outline_rounded, color: AppTheme.errorLight, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_resolveError(context),
                                style: GoogleFonts.inter(color: AppTheme.errorLight, fontSize: 13)),
                          ),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _loading ? null : _unlockWithPassword,
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(context.l10n.lockUnlock,
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onPrimary)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    context.l10n.lockPanicHint,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
