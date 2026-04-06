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
import '../../l10n/l10n_ext.dart';
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
    int attempts = 0;
    const maxAttempts = 5;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: DesignTokens.fontXl,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
              const SizedBox(height: DesignTokens.spacing16),
              TextField(
                controller: controller,
                obscureText: !showPass,
                autofocus: true,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: DesignTokens.fontInput),
                decoration: InputDecoration(
                  hintText: context.l10n.settingsCurrentPassword,
                  hintStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg),
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
                      horizontal: DesignTokens.spacing14, vertical: DesignTokens.spacing12),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPass
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.textSecondary,
                      size: DesignTokens.fontHeading,
                    ),
                    onPressed: () => setS(() => showPass = !showPass),
                  ),
                ),
                onChanged: (_) => setS(() => error = null),
              ),
              if (error != null) ...[
                const SizedBox(height: DesignTokens.spacing8),
                Text(
                  error!,
                  style: GoogleFonts.inter(
                      color: const Color(0xFFF87171), fontSize: DesignTokens.fontBody),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(context.l10n.cancel,
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
                  // FINDING-12 fix: fail closed — storage integrity error.
                  // Silently granting would allow physical accessor with adb
                  // to bypass auth by deleting the secure storage keys.
                  setS(() => error = 'Security storage error — restart the app');
                  return;
                }
                if (attempts >= maxAttempts) return; // already locked
                if (await PasswordHasher.verify(
                    controller.text, salt, hash)) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  attempts++;
                  if (attempts >= maxAttempts) {
                    // Lock the dialog: too many wrong guesses.
                    setS(() => error = context.l10n.lockTooManyAttempts);
                    await Future.delayed(const Duration(seconds: 1));
                    if (ctx.mounted) Navigator.of(ctx).pop(false);
                  } else {
                    setS(() => error = context.l10n.securityIncorrectPassword);
                  }
                }
              },
              child: Text(
                context.l10n.confirm,
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
        title: context.l10n.settingsDisableAppPassword,
        subtitle: context.l10n.settingsEnterCurrentPassword);
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
        title: context.l10n.settingsChangePassword,
        subtitle: context.l10n.settingsChangePasswordProceed);
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
          content: Text(context.l10n.securityPasswordUpdated,
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFF34D399),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _managePanicKey() async {
    // Require current password before allowing panic key changes — an attacker
    // with brief physical access to an unlocked phone could otherwise replace
    // the panic key with their own, defeating the duress wipe mechanism.
    if (widget.passwordEnabled) {
      final confirmed = await _showConfirmPasswordDialog(
        title: context.l10n.panicSetPanicKey,
        subtitle: context.l10n.settingsEnterCurrentPassword,
      );
      if (!confirmed || !mounted) return;
    }
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
    // Same guard as _managePanicKey — prevent attacker from silently
    // disabling the duress wipe by removing the panic key.
    if (widget.passwordEnabled) {
      final confirmed = await _showConfirmPasswordDialog(
        title: context.l10n.settingsRemovePanicKey,
        subtitle: context.l10n.settingsEnterCurrentPassword,
      );
      if (!confirmed || !mounted) return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        backgroundColor: AppTheme.surface,
        title: Text(
          context.l10n.settingsRemovePanicKey,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.l10n.settingsRemovePanicKeyBody,
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel,
                style:
                    GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.l10n.remove,
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
        settingsSectionDivider(context.l10n.settingsSecurity),
        const SizedBox(height: DesignTokens.spacing14),

        settingsGroup(children: [
          // App Password row
          InkWell(
            onTap: widget.passwordEnabled ? null : _enablePassword,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.cardPadding),
              child: Row(children: [
                Container(
                  width: DesignTokens.avatarXs,
                  height: DesignTokens.avatarXs,
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA).withValues(alpha: DesignTokens.opacityLight),
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Color(0xFF60A5FA), size: DesignTokens.fontHeading),
                ),
                const SizedBox(width: DesignTokens.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.settingsAppPassword,
                        style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: DesignTokens.fontLg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.passwordEnabled
                            ? context.l10n.settingsPasswordEnabled
                            : context.l10n.settingsPasswordDisabled,
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: widget.passwordEnabled,
                  onChanged: (val) =>
                      val ? _enablePassword() : _disablePassword(),
                  activeThumbColor: const Color(0xFF60A5FA),
                ),
              ]),
            ),
          ),

          if (widget.passwordEnabled) ...[
            settingsGroupRow(
              icon: Icons.password_rounded,
              iconColor: const Color(0xFF34D399),
              title: context.l10n.settingsChangePassword,
              subtitle: context.l10n.settingsChangePasswordSubtitle,
              onTap: _changePassword,
            ),
            settingsGroupRow(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFF87171),
              title: widget.panicKeyEnabled
                  ? context.l10n.settingsChangePanicKey
                  : context.l10n.settingsSetPanicKey,
              subtitle: widget.panicKeyEnabled
                  ? context.l10n.settingsPanicKeySetSubtitle
                  : context.l10n.settingsPanicKeyUnsetSubtitle,
              onTap: _managePanicKey,
            ),
            if (widget.panicKeyEnabled)
              settingsGroupRow(
                icon: Icons.remove_circle_outline_rounded,
                iconColor: AppTheme.textSecondary,
                title: context.l10n.settingsRemovePanicKey,
                subtitle: context.l10n.settingsRemovePanicKeySubtitle,
                onTap: _removePanicKey,
              ),
          ],
          settingsGroupRow(
            icon: Icons.shield_rounded,
            iconColor: AppTheme.primary,
            title: context.l10n.settingsSignalProtocol,
            subtitle: context.l10n.settingsSignalProtocolSubtitle,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: DesignTokens.opacityLight),
                borderRadius: BorderRadius.circular(DesignTokens.spacing6),
              ),
              child: Text(
                context.l10n.settingsActive,
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontSize: DesignTokens.fontSm,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }
}
