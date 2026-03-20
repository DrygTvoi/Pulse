// Settings — Security section: app password and panic key management.
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/password_hasher.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/password_setup_dialog.dart';
import '../../widgets/panic_key_dialog.dart';
import 'settings_widgets.dart';

class SecuritySection extends StatefulWidget {
  final bool passwordEnabled;
  final bool panicKeyEnabled;
  final ValueChanged<bool> onPasswordEnabledChanged;
  final ValueChanged<bool> onPanicKeyEnabledChanged;

  const SecuritySection({
    super.key,
    required this.passwordEnabled,
    required this.panicKeyEnabled,
    required this.onPasswordEnabledChanged,
    required this.onPanicKeyEnabledChanged,
  });

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  static const _secureStorage = FlutterSecureStorage();

  String _generateSalt() {
    final rng = Random.secure();
    final saltBytes =
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
    return hex.encode(saltBytes);
  }

  Future<bool> _showConfirmPasswordDialog(
      {required String title, required String subtitle}) async {
    final controller = TextEditingController();
    bool showPass = false;
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: !showPass,
                autofocus: true,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Current password',
                  hintStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                    borderSide: const BorderSide(
                        color: Color(0xFF60A5FA), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPass
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    onPressed: () => setS(() => showPass = !showPass),
                  ),
                ),
                onChanged: (_) => setS(() => error = null),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: GoogleFonts.inter(
                      color: const Color(0xFFF87171), fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel',
                  style:
                      GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final hash =
                    await _secureStorage.read(key: 'app_password_hash');
                final salt =
                    await _secureStorage.read(key: 'app_password_salt');
                if (hash == null || salt == null) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                  return;
                }
                if (await PasswordHasher.verify(
                    controller.text, salt, hash)) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  setS(() => error = 'Incorrect password');
                }
              },
              child: Text(
                'Confirm',
                style: GoogleFonts.inter(
                    color: const Color(0xFF60A5FA),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result == true;
  }

  Future<void> _enablePassword() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PasswordSetupDialog(
        onSet: (password) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(password, salt);
          await _secureStorage.write(key: 'app_password_hash', value: hash);
          await _secureStorage.write(key: 'app_password_salt', value: salt);
          await _secureStorage.write(
              key: 'app_password_enabled', value: 'true');
          if (ctx.mounted) Navigator.of(ctx).pop();
          widget.onPasswordEnabledChanged(true);
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
    if (widget.passwordEnabled && !widget.panicKeyEnabled) {
      await _managePanicKey();
    }
  }

  Future<void> _disablePassword() async {
    final confirmed = await _showConfirmPasswordDialog(
        title: 'Disable App Password',
        subtitle: 'Enter your current password to confirm');
    if (!confirmed) return;

    await _secureStorage.delete(key: 'app_password_hash');
    await _secureStorage.delete(key: 'app_password_salt');
    await _secureStorage.delete(key: 'app_password_enabled');
    await _secureStorage.delete(key: 'app_panic_key_hash');
    await _secureStorage.delete(key: 'app_panic_key_salt');
    widget.onPasswordEnabledChanged(false);
    widget.onPanicKeyEnabledChanged(false);
  }

  Future<void> _changePassword() async {
    final confirmed = await _showConfirmPasswordDialog(
        title: 'Change Password',
        subtitle: 'Enter your current password to proceed');
    if (!confirmed) return;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PasswordSetupDialog(
        onSet: (password) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(password, salt);
          await _secureStorage.write(key: 'app_password_hash', value: hash);
          await _secureStorage.write(key: 'app_password_salt', value: salt);
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFF34D399),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _managePanicKey() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PanicKeyDialog(
        onSet: (key) async {
          final salt = _generateSalt();
          final hash = await PasswordHasher.hash(key, salt);
          await _secureStorage.write(
              key: 'app_panic_key_hash', value: hash);
          await _secureStorage.write(
              key: 'app_panic_key_salt', value: salt);
          if (ctx.mounted) Navigator.of(ctx).pop();
          widget.onPanicKeyEnabledChanged(true);
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _removePanicKey() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Remove Panic Key',
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Emergency self-destruct will be disabled. '
          'You can re-enable it at any time.',
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style:
                    GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: GoogleFonts.inter(
                  color: const Color(0xFFF87171),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _secureStorage.delete(key: 'app_panic_key_hash');
    await _secureStorage.delete(key: 'app_panic_key_salt');
    widget.onPanicKeyEnabledChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsSectionDivider('Security'),
        const SizedBox(height: 14),

        // App Password row
        GestureDetector(
          onTap: widget.passwordEnabled ? null : _enablePassword,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Color(0xFF60A5FA), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Password',
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.passwordEnabled
                          ? 'Enabled — required on every launch'
                          : 'Disabled — app opens without password',
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.passwordEnabled,
                onChanged: (val) =>
                    val ? _enablePassword() : _disablePassword(),
                activeThumbColor: const Color(0xFF60A5FA),
              ),
            ]),
          ),
        ),

        if (widget.passwordEnabled) ...[
          const SizedBox(height: 10),
          settingsRow(
            icon: Icons.password_rounded,
            iconColor: const Color(0xFF34D399),
            title: 'Change Password',
            subtitle: 'Update your app lock password',
            onTap: _changePassword,
          ),
          const SizedBox(height: 10),
          settingsRow(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF87171),
            title: widget.panicKeyEnabled
                ? 'Change Panic Key'
                : 'Set Panic Key',
            subtitle: widget.panicKeyEnabled
                ? 'Update emergency wipe key'
                : 'One key that instantly erases all data',
            onTap: _managePanicKey,
          ),
          if (widget.panicKeyEnabled) ...[
            const SizedBox(height: 10),
            settingsRow(
              icon: Icons.remove_circle_outline_rounded,
              iconColor: AppTheme.textSecondary,
              title: 'Remove Panic Key',
              subtitle: 'Disable emergency self-destruct',
              onTap: _removePanicKey,
            ),
          ],
        ],
      ],
    );
  }
}
