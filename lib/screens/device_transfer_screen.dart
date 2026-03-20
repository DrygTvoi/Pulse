import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/device_transfer_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

enum _Role { none, sender, receiver }

enum _Step { roleSelect, config, inProgress, verify, done, error }

class DeviceTransferScreen extends StatefulWidget {
  const DeviceTransferScreen({super.key});

  @override
  State<DeviceTransferScreen> createState() => _DeviceTransferScreenState();
}

class _DeviceTransferScreenState extends State<DeviceTransferScreen> {
  _Role _role = _Role.none;
  _Step _step = _Step.roleSelect;

  DeviceTransferService? _service;
  String _code = '';
  String _verificationCode = '';
  String _errorMessage = '';

  final _codeController = TextEditingController();
  final _relayController = TextEditingController(text: 'wss://relay.damus.io');

  @override
  void dispose() {
    _service?.dispose();
    _codeController.dispose();
    _relayController.dispose();
    super.dispose();
  }

  // ─── Sender actions ────────────────────────────────────────────────────────

  Future<void> _startLanSend() async {
    setState(() {
      _step = _Step.inProgress;
      _role = _Role.sender;
    });
    final svc = DeviceTransferService();
    _service = svc;
    try {
      final code = await svc.startLanTransfer();
      if (!mounted) return;
      setState(() => _code = code);
      await svc.exchangeComplete;
      if (!mounted) return;
      setState(() {
        _verificationCode = svc.verificationCode;
        _step = _Step.verify;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _step = _Step.error;
      });
    }
  }

  Future<void> _startNostrSend() async {
    final relay = _relayController.text.trim();
    if (relay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar('Enter a relay URL first'));
      return;
    }
    setState(() {
      _step = _Step.inProgress;
      _role = _Role.sender;
    });
    final svc = DeviceTransferService();
    _service = svc;
    try {
      final code = await svc.startNostrTransfer(relay);
      if (!mounted) return;
      setState(() => _code = code);
      await svc.exchangeComplete;
      if (!mounted) return;
      setState(() {
        _verificationCode = svc.verificationCode;
        _step = _Step.verify;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _step = _Step.error;
      });
    }
  }

  // ─── Receiver action ───────────────────────────────────────────────────────

  Future<void> _connect() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar('Paste the transfer code from the sender'));
      return;
    }
    setState(() {
      _step = _Step.inProgress;
      _role = _Role.receiver;
    });
    final svc = DeviceTransferService();
    _service = svc;
    try {
      if (code.startsWith('LAN:')) {
        await svc.receiveLanTransfer(code);
      } else if (code.startsWith('NOS:')) {
        await svc.receiveNostrTransfer(code);
      } else {
        throw FormatException('Unrecognised code format — must start with LAN: or NOS:');
      }
      if (!mounted) return;
      setState(() {
        _verificationCode = svc.verificationCode;
        _step = _Step.verify;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _step = _Step.error;
      });
    }
  }

  // ─── Verification ──────────────────────────────────────────────────────────

  void _confirm() {
    setState(() => _step = _Step.done);
  }

  void _cancel() {
    _service?.dispose();
    _service = null;
    setState(() {
      _step = _Step.roleSelect;
      _role = _Role.none;
      _code = '';
      _verificationCode = '';
      _errorMessage = '';
    });
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  SnackBar _snackBar(String msg, {bool error = false}) => SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: error ? Colors.red : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
      );

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Transfer to Another Device',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacing20, DesignTokens.spacing24, DesignTokens.spacing20, DesignTokens.spacing40),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.roleSelect:
        return _buildRoleSelect();
      case _Step.config:
        return _role == _Role.sender ? _buildSenderConfig() : _buildReceiverConfig();
      case _Step.inProgress:
        return _buildInProgress();
      case _Step.verify:
        return _buildVerify();
      case _Step.done:
        return _buildDone();
      case _Step.error:
        return _buildError();
    }
  }

  // ── Step 1: Role selection ─────────────────────────────────────────────────

  Widget _buildRoleSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          'Move your Signal identity and Nostr keys to a new device.\n'
          'Chat sessions are NOT transferred — forward secrecy is preserved.',
        ),
        const SizedBox(height: DesignTokens.spacing28),
        _roleCard(
          icon: Icons.upload_rounded,
          iconColor: const Color(0xFF3498DB),
          title: 'Send from this device',
          subtitle: 'This device has the keys. Share a code with the new device.',
          onTap: () => setState(() {
            _role = _Role.sender;
            _step = _Step.config;
          }),
        ),
        const SizedBox(height: DesignTokens.spacing14),
        _roleCard(
          icon: Icons.download_rounded,
          iconColor: const Color(0xFF2ECC71),
          title: 'Receive on this device',
          subtitle: 'This is the new device. Enter the code from the old device.',
          onTap: () => setState(() {
            _role = _Role.receiver;
            _step = _Step.config;
          }),
        ),
      ],
    );
  }

  Widget _roleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.fontHeading),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
              child: Icon(icon, color: iconColor, size: DesignTokens.iconLg),
            ),
            const SizedBox(width: DesignTokens.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: DesignTokens.fontInput)),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: DesignTokens.iconMd),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Config ─────────────────────────────────────────────────────────

  Widget _buildSenderConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(height: DesignTokens.spacing20),
        _sectionLabel('Choose Transfer Method'),
        const SizedBox(height: DesignTokens.spacing16),
        _methodCard(
          icon: Icons.wifi_rounded,
          iconColor: const Color(0xFF3498DB),
          title: 'LAN (Same Network)',
          subtitle: 'Fast, direct. Both devices must be on the same Wi-Fi.',
          onTap: _startLanSend,
        ),
        const SizedBox(height: DesignTokens.spacing14),
        _sectionLabel('Nostr Relay'),
        const SizedBox(height: DesignTokens.spacing10),
        _relayField(),
        const SizedBox(height: DesignTokens.spacing12),
        _methodCard(
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFF9B59B6),
          title: 'Nostr Relay',
          subtitle: 'Works over any network using an existing Nostr relay.',
          onTap: _startNostrSend,
        ),
      ],
    );
  }

  Widget _buildReceiverConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backButton(),
        const SizedBox(height: DesignTokens.spacing20),
        _sectionLabel('Enter Transfer Code'),
        const SizedBox(height: DesignTokens.spacing12),
        TextField(
          controller: _codeController,
          style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textPrimary, fontSize: DesignTokens.fontBody),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Paste the LAN:... or NOS:... code here',
            hintStyle:
                GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody),
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: DesignTokens.inputContentPaddingH, vertical: DesignTokens.inputContentPaddingV),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _connect,
            icon: const Icon(Icons.link_rounded, color: Colors.white),
            label: Text('Connect',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: DesignTokens.fontInput,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.inputRadius)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _methodCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(
              color: iconColor.withValues(alpha: 0.25), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DesignTokens.spacing10),
              ),
              child: Icon(icon, color: iconColor, size: DesignTokens.iconMd),
            ),
            const SizedBox(width: DesignTokens.spacing14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: DesignTokens.fontLg)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                color: iconColor, size: DesignTokens.fontHeading),
          ],
        ),
      ),
    );
  }

  Widget _relayField() {
    return TextField(
      controller: _relayController,
      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: DesignTokens.fontMd),
      decoration: InputDecoration(
        hintText: 'wss://relay.damus.io',
        labelText: 'Relay URL',
        labelStyle:
            GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody),
        prefixIcon:
            Icon(Icons.bolt_rounded, color: AppTheme.textSecondary, size: DesignTokens.fontHeading),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: DesignTokens.inputContentPaddingH, vertical: DesignTokens.inputContentPaddingV),
      ),
    );
  }

  // ── Step 3: In progress ────────────────────────────────────────────────────

  Widget _buildInProgress() {
    if (_role == _Role.sender) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DesignTokens.spacing20),
          if (_code.isEmpty) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: DesignTokens.spacing16),
            Text('Generating transfer code…',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
          ] else ...[
            Text('Share this code with the receiver:',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
            const SizedBox(height: DesignTokens.spacing16),
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              child: SelectableText(
                _code,
                style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.textPrimary, fontSize: DesignTokens.fontSm),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing12),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _code));
                ScaffoldMessenger.of(context)
                    .showSnackBar(_snackBar('Code copied to clipboard'));
              },
              icon: Icon(Icons.copy_rounded,
                  size: DesignTokens.iconSm, color: AppTheme.primary),
              label: Text('Copy Code',
                  style: GoogleFonts.inter(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.spacing10)),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing28),
            const CircularProgressIndicator(),
            const SizedBox(height: DesignTokens.spacing14),
            Text('Waiting for receiver to connect…',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
          ],
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const CircularProgressIndicator(),
          const SizedBox(height: DesignTokens.spacing20),
          Text('Connecting to sender…',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontLg)),
        ],
      );
    }
  }

  // ── Step 4: Verify ─────────────────────────────────────────────────────────

  Widget _buildVerify() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: DesignTokens.spacing20),
        Container(
          padding: const EdgeInsets.all(DesignTokens.spacing28),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.dialogRadius),
          ),
          child: Column(
            children: [
              Icon(Icons.security_rounded,
                  color: AppTheme.primary, size: 36),
              const SizedBox(height: DesignTokens.spacing16),
              Text(
                _verificationCode,
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.primary,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing16),
              Text(
                'Compare this code on both devices.\nIf they match, the transfer is secure.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.spacing28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.close_rounded, size: DesignTokens.fontHeading, color: Colors.red),
                label: Text('Cancel',
                    style: GoogleFonts.inter(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.buttonPaddingV),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacing14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_rounded,
                    size: DesignTokens.fontHeading, color: Colors.white),
                label: Text('Confirm',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.buttonPaddingV),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 5: Done ───────────────────────────────────────────────────────────

  Widget _buildDone() {
    final isSender = _role == _Role.sender;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: DesignTokens.spacing40),
        Container(
          padding: const EdgeInsets.all(DesignTokens.spacing20),
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: Color(0xFF2ECC71), size: 56),
        ),
        const SizedBox(height: DesignTokens.spacing24),
        Text(
          isSender ? 'Transfer Complete' : 'Keys Imported',
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: DesignTokens.fontDisplay),
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Text(
          isSender
              ? 'Your keys remain active on this device.\nThe receiver can now use your identity.'
              : 'Keys imported successfully.\nRestart the app to apply the new identity.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd, height: 1.6),
        ),
        const SizedBox(height: 36),
        if (isSender)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.inputRadius)),
                elevation: 0,
              ),
              child: Text('Close',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: DesignTokens.fontInput)),
            ),
          )
        else ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => exit(0),
              icon: const Icon(Icons.restart_alt_rounded,
                  color: Colors.white),
              label: Text('Restart App',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: DesignTokens.fontInput)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.inputRadius)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: DesignTokens.spacing40),
        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 56),
        const SizedBox(height: DesignTokens.spacing20),
        Text('Transfer Failed',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: DesignTokens.fontXxl)),
        const SizedBox(height: DesignTokens.spacing12),
        Text(_errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
        const SizedBox(height: DesignTokens.spacing32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _cancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.inputRadius)),
              elevation: 0,
            ),
            child: Text('Try Again',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: DesignTokens.fontInput)),
          ),
        ),
      ],
    );
  }

  // ─── Shared widgets ────────────────────────────────────────────────────────

  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.cardPadding, vertical: DesignTokens.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: DesignTokens.fontInput, color: AppTheme.primary),
          const SizedBox(width: DesignTokens.spacing10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontBody, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(),
        style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: DesignTokens.fontSm,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8));
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => setState(() {
        _step = _Step.roleSelect;
        _role = _Role.none;
      }),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_rounded,
              size: DesignTokens.fontHeading, color: AppTheme.textSecondary),
          const SizedBox(width: DesignTokens.spacing6),
          Text('Back',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: DesignTokens.fontMd)),
        ],
      ),
    );
  }
}
