import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/identity.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_isLoading &&
      _nameController.text.trim().isNotEmpty &&
      _passwordController.text.length >= 8;

  // ── Restore ───────────────────────────────────────────────────────────────

  Future<void> _restore() async {
    if (!_canSubmit) return;
    setState(() => _isLoading = true);

    final name     = _nameController.text.trim();
    final password = _passwordController.text;

    // Derive the same keys from the recovery password.
    final nostrKeyBytes = await KeyDerivationService.deriveNostrKey(password);
    final oxenSeedBytes = await KeyDerivationService.deriveOxenSeed(password);

    const ss = FlutterSecureStorage();
    final privkeyHex = hex.encode(nostrKeyBytes);

    await ss.write(key: 'nostr_privkey', value: privkeyHex);
    await ss.write(key: 'oxen_seed',     value: hex.encode(oxenSeedBytes));

    // Fresh Signal keys — old sessions will re-establish automatically.
    final signalService = SignalService();
    await signalService.initialize();
    final bundle = await signalService.getPublicBundle();

    final uuid       = const Uuid().v4();
    final realPubKey = base64Encode(
        Uint8List.fromList(List<int>.from(bundle['identityKey'])));

    const relay = 'wss://relay.damus.io';
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

    // Re-initialise Oxen with restored seed
    await OxenKeyService.instance.initialize();
    final sessionId = OxenKeyService.instance.sessionId;
    await prefs.setString('secondary_adapters', jsonEncode([{
      'provider': 'Oxen',
      'apiKey': '',
      'databaseId': sessionId,
      'selfId': sessionId,
    }]));

    // Save as app lock
    final salt = _generateSalt();
    final hash = await PasswordHasher.hash(password, salt);
    await ss.write(key: 'app_password_hash',    value: hash);
    await ss.write(key: 'app_password_salt',    value: salt);
    await ss.write(key: 'app_password_enabled', value: 'true');

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
        title: Text('Восстановление аккаунта',
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
                        'Введите пароль восстановления — ваш адрес (Nostr + Session) '
                        'будет восстановлен автоматически. '
                        'Контакты и сообщения хранились только локально.',
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
              Text('Новый псевдоним (можно изменить)',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 28),

              // Name
              _buildField(
                controller: _nameController,
                hint: 'Ваш псевдоним',
                icon: Icons.person_outline_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Password
              _buildField(
                controller: _passwordController,
                hint: 'Пароль восстановления',
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
                      : Text('Восстановить аккаунт',
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
