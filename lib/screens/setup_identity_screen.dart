import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/identity.dart';
import '../theme/app_theme.dart';
import '../services/signal_service.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:convert/convert.dart';
import '../services/password_hasher.dart';
import '../adapters/nostr_adapter.dart' show deriveNostrPubkeyHex;
import '../services/oxen_key_service.dart';
import '../widgets/password_setup_dialog.dart';
import '../widgets/panic_key_dialog.dart';
import 'home_screen.dart';

// ─── Avatar colour palette ────────────────────────────────────────────────────
const _avatarColors = [
  Color(0xFF25D366), // green
  Color(0xFF60A5FA), // blue
  Color(0xFFA78BFA), // purple
  Color(0xFFFBBF24), // amber
  Color(0xFFF87171), // red
  Color(0xFF34D399), // teal
  Color(0xFFFB923C), // orange
  Color(0xFF818CF8), // indigo
];

class SetupIdentityScreen extends StatefulWidget {
  final String? initialConfig;
  const SetupIdentityScreen({super.key, this.initialConfig});

  @override
  State<SetupIdentityScreen> createState() => _SetupIdentityScreenState();
}

class _SetupIdentityScreenState extends State<SetupIdentityScreen> {
  // ── Mode: null = choose, 'anonymous', 'advanced' ──────────────────────────
  String? _mode;

  // ── Anonymous ─────────────────────────────────────────────────────────────
  final _anonNameController = TextEditingController();
  int _anonColorIndex = 0;

  // ── Advanced ──────────────────────────────────────────────────────────────
  String _selectedAdapter = 'nostr';
  final _firebaseUrlController = TextEditingController();
  final _firebaseKeyController = TextEditingController();
  final _nostrRelayController = TextEditingController(text: 'wss://relay.damus.io');
  final _nostrKeyController = TextEditingController();
  final _wakuNodeUrlController = TextEditingController(text: 'http://127.0.0.1:8645');

  bool _isLoading = false;

  @override
  void dispose() {
    _anonNameController.dispose();
    _firebaseUrlController.dispose();
    _firebaseKeyController.dispose();
    _nostrRelayController.dispose();
    _nostrKeyController.dispose();
    _wakuNodeUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      try {
        final decoded = jsonDecode(widget.initialConfig!);
        if (decoded['url'] != null) {
          _mode = 'advanced';
          _selectedAdapter = 'firebase';
          _firebaseUrlController.text = decoded['url'];
          _firebaseKeyController.text = decoded['key'] ?? '';
        }
      } catch (_) {}
    }
  }

  // ── Anonymous account creation ────────────────────────────────────────────

  Future<void> _createAnonymous() async {
    final name = _anonNameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    final rng = Random.secure();

    final colorIndex = _anonColorIndex;

    final signalService = SignalService();
    await signalService.initialize();
    final bundle = await signalService.getPublicBundle();

    final uuid = const Uuid().v4();
    final realPublicKey = base64Encode(
        Uint8List.fromList(List<int>.from(bundle['identityKey'])));

    // Auto-generate Nostr keypair
    const secureStorage = FlutterSecureStorage();
    final keyBytes =
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
    final privkey = hex.encode(keyBytes);
    const relay = 'wss://relay.damus.io';
    await secureStorage.write(key: 'nostr_privkey', value: privkey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nostr_relay', relay);

    final pubkey = deriveNostrPubkeyHex(privkey);
    final identity = Identity(
      id: uuid,
      publicKey: realPublicKey,
      privateKey: '',
      preferredAdapter: 'nostr',
      adapterConfig: {'dbId': '$pubkey@$relay', 'relay': relay},
    );
    await prefs.setString('user_identity', jsonEncode(identity.toJson()));
    await prefs.setString('user_profile', jsonEncode({
      'name': name,
      'about': '',
      'avatar_color': _avatarColors[colorIndex].toARGB32().toString(),
    }));
    await _registerOxenSecondary(prefs);

    if (!mounted) return;
    setState(() => _isLoading = false);
    await _showPasswordSetup();
  }

  // ── Post-creation security flow ───────────────────────────────────────────

  Future<void> _showPasswordSetup() async {
    if (!mounted) return;
    final wasSet = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PasswordSetupDialog(
        onSet: (password) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(password, salt);
          const ss = FlutterSecureStorage();
          await ss.write(key: 'app_password_hash', value: hash);
          await ss.write(key: 'app_password_salt', value: salt);
          await ss.write(key: 'app_password_enabled', value: 'true');
          if (ctx.mounted) Navigator.of(ctx).pop(true);
        },
        onSkip: () => Navigator.of(ctx).pop(false),
      ),
    );
    if (wasSet == true) {
      await _showPanicKeySetup();
    } else {
      _goHome();
    }
  }

  Future<void> _showPanicKeySetup() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PanicKeyDialog(
        onSet: (key) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(key, salt);
          const ss = FlutterSecureStorage();
          await ss.write(key: 'app_panic_key_hash', value: hash);
          await ss.write(key: 'app_panic_key_salt', value: salt);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
    _goHome();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // ── Oxen secondary adapter ────────────────────────────────────────────────

  /// Initialises the Oxen/Session keypair and registers Oxen as a secondary
  /// adapter so the user is reachable on both Nostr and Session out-of-the-box.
  Future<void> _registerOxenSecondary(SharedPreferences prefs) async {
    await OxenKeyService.instance.initialize();
    final sessionId = OxenKeyService.instance.sessionId;
    final nodeUrl = prefs.getString('oxen_node_url') ?? '';
    final entry = {
      'provider': 'Oxen',
      'apiKey': nodeUrl,
      'databaseId': sessionId,
      'selfId': sessionId,
    };
    final existing = prefs.getString('secondary_adapters');
    List<dynamic> list = [];
    if (existing != null && existing.isNotEmpty) {
      try { list = jsonDecode(existing) as List; } catch (_) {}
    }
    // Avoid duplicates
    list.removeWhere((e) => (e as Map)['provider'] == 'Oxen');
    list.add(entry);
    await prefs.setString('secondary_adapters', jsonEncode(list));
  }

  // ── Crypto helpers ────────────────────────────────────────────────────────

  String _generateSalt() {
    final rng = Random.secure();
    final saltBytes =
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
    return hex.encode(saltBytes);
  }

  // ── Advanced setup ────────────────────────────────────────────────────────

  Future<void> _finishSetup() async {
    setState(() => _isLoading = true);

    final signalService = SignalService();
    await signalService.initialize();
    final bundle = await signalService.getPublicBundle();

    final uuid = const Uuid().v4();
    final realPublicKey = base64Encode(
        Uint8List.fromList(List<int>.from(bundle['identityKey'])));

    Map<String, String> config = {};
    if (_selectedAdapter == 'firebase') {
      config['dbId'] = uuid;
      config['token'] = jsonEncode({
        'url': _firebaseUrlController.text.trim(),
        'key': _firebaseKeyController.text.trim(),
      });
    } else if (_selectedAdapter == 'nostr') {
      String privkey = _nostrKeyController.text.trim();
      if (privkey.isEmpty) {
        final rng = Random.secure();
        privkey = hex.encode(
            Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256))));
      }
      final relay = _nostrRelayController.text.trim().isNotEmpty
          ? _nostrRelayController.text.trim()
          : 'wss://relay.damus.io';
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'nostr_privkey', value: privkey);
      final prefs2 = await SharedPreferences.getInstance();
      await prefs2.setString('nostr_relay', relay);
      try {
        final pubkey = deriveNostrPubkeyHex(privkey);
        config['dbId'] = '$pubkey@$relay';
      } catch (_) {
        config['dbId'] = uuid;
      }
      config['relay'] = relay;
    } else if (_selectedAdapter == 'waku') {
      final nodeUrl = _wakuNodeUrlController.text.trim().isNotEmpty
          ? _wakuNodeUrlController.text.trim()
          : 'http://127.0.0.1:8645';
      final prefs2 = await SharedPreferences.getInstance();
      await prefs2.setString('waku_node_url', nodeUrl);
      config['nodeUrl'] = nodeUrl;
      config['token'] = jsonEncode({'nodeUrl': nodeUrl});
    }

    final identity = Identity(
      id: uuid,
      publicKey: realPublicKey,
      privateKey: '',
      preferredAdapter: _selectedAdapter,
      adapterConfig: config,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_identity', jsonEncode(identity.toJson()));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('Pulse',
                    style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('Private by design. No central server. No identity.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 40),

              if (_mode == null) ...[
                _buildChooseMode(),
              ] else if (_mode == 'anonymous') ...[
                _buildAnonymousProfile(),
              ] else ...[
                _buildAdvanced(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Mode selection ────────────────────────────────────────────────────────

  Widget _buildChooseMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How do you want to get started?',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),

        // ── Anonymous Account ─────────────────────────────────────────────
        _AnonymousCard(
          isLoading: _isLoading,
          onTap: () => setState(() => _mode = 'anonymous'),
        ),
        const SizedBox(height: 14),

        // Advanced card
        _ModeCard(
          icon: Icons.tune_rounded,
          iconColor: const Color(0xFF60A5FA),
          title: 'Advanced Setup',
          subtitle: 'Choose your transport:\nFirebase, Nostr, or Waku.\nBring your own infrastructure.',
          onTap: () => setState(() => _mode = 'advanced'),
        ),
      ],
    );
  }

  // ── Anonymous profile form ────────────────────────────────────────────────

  Widget _buildAnonymousProfile() {
    const purple = Color(0xFFA78BFA);
    final color = _avatarColors[_anonColorIndex];
    final name = _anonNameController.text.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _mode = null),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white54, size: 22),
          ),
          const SizedBox(width: 12),
          Text('Anonymous Account',
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 32),

        // Avatar picker
        Center(
          child: GestureDetector(
            onTap: () => setState(() =>
                _anonColorIndex = (_anonColorIndex + 1) % _avatarColors.length),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 88,
                  height: 88,
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
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppTheme.surfaceVariant, width: 2),
                  ),
                  child: const Icon(Icons.color_lens_rounded,
                      size: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text('Tap to change colour',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ),
        const SizedBox(height: 28),

        // Name field (required)
        TextField(
          controller: _anonNameController,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Your display name',
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
              borderSide: const BorderSide(color: purple, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),

        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: purple.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            const Icon(Icons.masks_rounded, color: purple, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Keys are generated locally and never leave your device. '
                'You get two addresses automatically: Nostr pubkey + Oxen Session ID. '
                'No email, no phone.',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.5),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: (_isLoading || _anonNameController.text.trim().isEmpty) ? null : _createAnonymous,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text('Create Account',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Advanced Setup form ───────────────────────────────────────────────────

  Widget _buildAdvanced() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _mode = null),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white54, size: 22),
          ),
          const SizedBox(width: 12),
          Text('Advanced Setup',
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 28),

        _sectionLabel('Transport'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAdapter,
              isExpanded: true,
              dropdownColor: AppTheme.surfaceVariant,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontSize: 15),
              items: const [
                DropdownMenuItem(
                    value: 'nostr',
                    child: Text('Nostr — Decentralized relays')),
                DropdownMenuItem(
                    value: 'firebase',
                    child: Text('Firebase — Realtime DB')),
                DropdownMenuItem(
                    value: 'waku',
                    child: Text('Waku v2 — P2P, no relay needed')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedAdapter = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_selectedAdapter == 'firebase') ...[
          _sectionLabel('Database URL'),
          const SizedBox(height: 8),
          _field(_firebaseUrlController,
              hint: 'https://my-project.firebaseio.com',
              icon: Icons.link_rounded),
          const SizedBox(height: 12),
          _sectionLabel('Web API Key (optional)'),
          const SizedBox(height: 8),
          _field(_firebaseKeyController,
              hint: 'Optional for public databases',
              icon: Icons.vpn_key_rounded,
              obscure: true),
        ] else if (_selectedAdapter == 'nostr') ...[
          _infoCard(Icons.bolt_rounded,
              'Your key is generated locally and never leaves your device.'),
          const SizedBox(height: 12),
          _sectionLabel('Relay URL'),
          const SizedBox(height: 8),
          _field(_nostrRelayController,
              hint: 'wss://relay.damus.io', icon: Icons.bolt_rounded),
          const SizedBox(height: 12),
          _sectionLabel('Private Key (leave blank to auto-generate)'),
          const SizedBox(height: 8),
          _field(_nostrKeyController,
              hint: 'hex private key or leave blank',
              icon: Icons.vpn_key_rounded,
              obscure: true),
        ] else if (_selectedAdapter == 'waku') ...[
          _infoCard(Icons.hub_rounded,
              'Run nwaku locally (default port 8645). '
              'Your identity is auto-generated and stored on device.'),
          const SizedBox(height: 12),
          _sectionLabel('nwaku Node URL'),
          const SizedBox(height: 8),
          _field(_wakuNodeUrlController,
              hint: 'http://127.0.0.1:8645', icon: Icons.hub_rounded),
        ],

        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _finishSetup,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text('Create Account',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.inter(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5));

  Widget _field(TextEditingController ctrl,
      {required String hint, required IconData icon, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
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
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _infoCard(IconData icon, String text) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
        ]),
      );
}

// ─── Mode selection card ──────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: iconColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.5)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── Anonymous Account card ───────────────────────────────────────────────────

class _AnonymousCard extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AnonymousCard({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFFA78BFA);
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1B69), Color(0xFF1A1040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: purple.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: purple.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                height: 52,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  ),
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.masks_rounded,
                        color: purple, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('Anonymous Account',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: purple.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('No server',
                                style: GoogleFonts.inter(
                                    color: purple,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          'Pick a name, keys stay on device.\nNostr + Session auto-configured.',
                          style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: Colors.white38),
                ],
              ),
      ),
    );
  }
}
