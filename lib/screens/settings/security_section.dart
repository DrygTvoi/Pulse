// Settings — Security section: app lock (PIN / legacy password) and panic key management.
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
import '../../widgets/pin_input.dart';
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

  /// true if using PIN-based auth, false if legacy password.
  bool _isPinMode = false;

  @override
  void initState() {
    super.initState();
    _detectMode();
  }

  Future<void> _detectMode() async {
    final pinEnabled = await _secureStorage.read(key: 'app_pin_enabled') == 'true';
    if (mounted) setState(() => _isPinMode = pinEnabled);
  }

  String _generateSalt() {
    final rng = Random.secure();
    final saltBytes =
        Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
    return hex.encode(saltBytes);
  }

  // ── Confirm current PIN dialog ──────────────────────────────────────────

  Future<bool> _showConfirmPinDialog({
    required String title,
    required String subtitle,
  }) async {
    int attempts = 0;
    const maxAttempts = 5;
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          title: Text(title,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: DesignTokens.fontXl)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle,
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
              const SizedBox(height: DesignTokens.spacing16),
              PinInput(
                key: ValueKey('confirm_pin_$error'),
                error: error,
                onComplete: (pin) async {
                  final hash = await _secureStorage.read(key: 'app_pin_hash');
                  final salt = await _secureStorage.read(key: 'app_pin_salt');
                  if (hash == null || salt == null) {
                    setS(() => error = context.l10n.securityStorageError);
                    return;
                  }
                  if (attempts >= maxAttempts) return;
                  if (await PasswordHasher.verify(pin, salt, hash)) {
                    if (ctx.mounted) Navigator.of(ctx).pop(true);
                  } else {
                    attempts++;
                    if (attempts >= maxAttempts) {
                      setS(() => error = context.l10n.lockTooManyAttempts);
                      await Future.delayed(const Duration(seconds: 1));
                      if (ctx.mounted) Navigator.of(ctx).pop(false);
                    } else {
                      setS(() => error = context.l10n.lockWrongPin);
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(context.l10n.cancel,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
    return result == true;
  }

  // ── Confirm current password dialog (legacy) ─────────────────────────────

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
              SettingsPasswordField(
                controller: controller,
                obscure: !showPass,
                onToggleObscure: () => setS(() => showPass = !showPass),
                hintText: context.l10n.settingsCurrentPassword,
                autofocus: true,
                errorText: error,
                onChanged: (_) => setS(() => error = null),
              ),
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
                  setS(() => error = context.l10n.securityStorageError);
                  return;
                }
                if (attempts >= maxAttempts) return;
                if (await PasswordHasher.verify(
                    controller.text, salt, hash)) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  attempts++;
                  if (attempts >= maxAttempts) {
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
                    color: AppTheme.info,
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

  /// Confirm using whichever mode is active.
  Future<bool> _confirmAuth({required String title, required String subtitle}) {
    if (_isPinMode) {
      return _showConfirmPinDialog(title: title, subtitle: subtitle);
    }
    return _showConfirmPasswordDialog(title: title, subtitle: subtitle);
  }

  // ── Change PIN ──────────────────────────────────────────────────────────

  Future<void> _changePin() async {
    final confirmed = await _showConfirmPinDialog(
      title: context.l10n.settingsChangePin,
      subtitle: context.l10n.settingsEnterCurrentPin,
    );
    if (!confirmed || !mounted) return;

    // Show new PIN entry dialog
    String? firstPin;
    String? error;
    final newPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog.adaptive(
          backgroundColor: AppTheme.surface,
          title: Text(
            firstPin == null ? context.l10n.setupPinSet : context.l10n.setupPinConfirm,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700,
                fontSize: DesignTokens.fontXl),
          ),
          content: PinInput(
            key: ValueKey('new_pin_${firstPin != null}$error'),
            error: error,
            onComplete: (pin) {
              if (firstPin == null) {
                setS(() { firstPin = pin; error = null; });
              } else if (pin == firstPin) {
                Navigator.of(ctx).pop(pin);
              } else {
                setS(() { firstPin = null; error = context.l10n.setupPinMismatch; });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(context.l10n.cancel,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
    if (newPin == null || !mounted) return;

    final salt = _generateSalt();
    final hash = await PasswordHasher.hash(newPin, salt);
    await _secureStorage.write(key: 'app_pin_hash', value: hash);
    await _secureStorage.write(key: 'app_pin_salt', value: salt);
    if (mounted) showSuccessSnackBar(context, context.l10n.settingsPinChanged);
  }

  // ── Enable password (legacy) ────────────────────────────────────────────

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

  Future<void> _disableLock() async {
    final confirmed = await _confirmAuth(
        title: context.l10n.settingsDisableAppPassword,
        subtitle: _isPinMode
            ? context.l10n.settingsEnterCurrentPin
            : context.l10n.settingsEnterCurrentPassword);
    if (!confirmed) return;

    await Future.wait([
      _secureStorage.delete(key: 'app_password_hash'),
      _secureStorage.delete(key: 'app_password_salt'),
      _secureStorage.delete(key: 'app_password_enabled'),
      _secureStorage.delete(key: 'app_pin_hash'),
      _secureStorage.delete(key: 'app_pin_salt'),
      _secureStorage.delete(key: 'app_pin_enabled'),
      _secureStorage.delete(key: 'app_panic_key_hash'),
      _secureStorage.delete(key: 'app_panic_key_salt'),
    ]);
    widget.onPasswordEnabledChanged(false);
    widget.onPanicKeyEnabledChanged(false);
    setState(() => _isPinMode = false);
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
      showSuccessSnackBar(context, context.l10n.securityPasswordUpdated);
    }
  }

  Future<void> _managePanicKey() async {
    if (widget.passwordEnabled) {
      final confirmed = await _confirmAuth(
        title: context.l10n.panicSetPanicKey,
        subtitle: _isPinMode
            ? context.l10n.settingsEnterCurrentPin
            : context.l10n.settingsEnterCurrentPassword,
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
    if (widget.passwordEnabled) {
      final confirmed = await _confirmAuth(
        title: context.l10n.settingsRemovePanicKey,
        subtitle: _isPinMode
            ? context.l10n.settingsEnterCurrentPin
            : context.l10n.settingsEnterCurrentPassword,
      );
      if (!confirmed || !mounted) return;
    }
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.settingsRemovePanicKey,
      message: context.l10n.settingsRemovePanicKeyBody,
      confirmLabel: context.l10n.remove,
      destructive: true,
    );
    if (!ok) return;
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
          // App Lock row
          InkWell(
            onTap: widget.passwordEnabled ? null : _enablePassword,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.cardPadding),
              child: Row(children: [
                Container(
                  width: DesignTokens.avatarXs,
                  height: DesignTokens.avatarXs,
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: DesignTokens.opacityLight),
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10),
                  ),
                  child: Icon(Icons.lock_rounded,
                      color: AppTheme.info, size: DesignTokens.fontHeading),
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
                            ? (_isPinMode
                                ? context.l10n.settingsPinEnabled
                                : context.l10n.settingsPasswordEnabled)
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
                      val ? _enablePassword() : _disableLock(),
                  activeThumbColor: AppTheme.info,
                ),
              ]),
            ),
          ),

          if (widget.passwordEnabled) ...[
            if (_isPinMode)
              settingsGroupRow(
                icon: Icons.pin_rounded,
                iconColor: const Color(0xFF34D399),
                title: context.l10n.settingsChangePin,
                subtitle: context.l10n.settingsChangePinSubtitle,
                onTap: _changePin,
              )
            else
              settingsGroupRow(
                icon: Icons.password_rounded,
                iconColor: const Color(0xFF34D399),
                title: context.l10n.settingsChangePassword,
                subtitle: context.l10n.settingsChangePasswordSubtitle,
                onTap: _changePassword,
              ),
            // Recovery key info (PIN mode only)
            if (_isPinMode)
              settingsGroupRow(
                icon: Icons.key_rounded,
                iconColor: AppTheme.warning,
                title: context.l10n.settingsRecoveryKeyInfo,
                subtitle: context.l10n.settingsRecoveryKeyInfoSubtitle,
                onTap: () {},
              ),
            settingsGroupRow(
              icon: Icons.warning_amber_rounded,
              iconColor: AppTheme.errorLight,
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
