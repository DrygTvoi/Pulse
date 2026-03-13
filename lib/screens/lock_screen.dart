import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/local_storage_service.dart';
import '../services/password_hasher.dart';
import 'home_screen.dart';
import 'setup_identity_screen.dart';

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

  static const _ss = FlutterSecureStorage();
  static const _maxAttempts = 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final entered = _controller.text;
    if (entered.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final hash = await _ss.read(key: 'app_password_hash');
    final salt = await _ss.read(key: 'app_password_salt');

    if (hash == null || salt == null) {
      // Password was removed — go home directly
      _goHome();
      return;
    }

    // Check panic key first (before regular password)
    final panicHash = await _ss.read(key: 'app_panic_key_hash');
    final panicSalt = await _ss.read(key: 'app_panic_key_salt');
    if (panicHash != null && panicSalt != null) {
      if (await PasswordHasher.verify(entered, panicSalt, panicHash)) {
        await _wipeAll();
        return;
      }
    }

    // Check regular password
    if (await PasswordHasher.verify(entered, salt, hash)) {
      // Transparently migrate legacy SHA-256 hash to PBKDF2 on first login
      if (PasswordHasher.isLegacy(hash)) {
        final newHash = await PasswordHasher.hash(entered, salt);
        await _ss.write(key: 'app_password_hash', value: newHash);
      }
      _goHome();
      return;
    }

    // Wrong password
    _attempts++;
    _controller.clear();

    if (_attempts >= _maxAttempts) {
      setState(() => _error = 'Too many attempts. Erasing all data…');
      await Future.delayed(const Duration(seconds: 2));
      await _wipeAll();
      return;
    }

    setState(() {
      _loading = false;
      _error = _attempts >= 3
          ? 'Wrong password — $_attempts/$_maxAttempts attempts'
          : 'Wrong password';
    });
  }

  Future<void> _wipeAll() async {
    setState(() => _loading = true);

    // Clear all SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear all secure storage (keys, password hashes)
    await _ss.deleteAll();

    // Clear local message database
    await LocalStorageService().clearAll();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SetupIdentityScreen()),
      (_) => false,
    );
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_rounded,
                        color: AppTheme.primary, size: 36),
                  ),
                  const SizedBox(height: 24),

                  Text('Pulse is locked',
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Enter your password to continue',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 40),

                  // Password field
                  TextField(
                    controller: _controller,
                    obscureText: !_showPassword,
                    autofocus: true,
                    onSubmitted: (_) => _loading ? null : _unlock(),
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 16),
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
                        borderSide: BorderSide(
                            color: AppTheme.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppTheme.textSecondary,
                            size: 20),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),

                  // Error message
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF87171).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFF87171)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Color(0xFFF87171), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFF87171),
                                  fontSize: 13)),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Unlock button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _loading ? null : _unlock,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text('Unlock',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Hint about panic key
                  Text(
                    'Forgot your password? Enter your panic key to wipe all data.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontSize: 11,
                        height: 1.5),
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
