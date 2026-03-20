import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/signal_service.dart';
import '../l10n/l10n_ext.dart';

/// Full-screen safety number verification.
/// Shows both users' fingerprints side-by-side for out-of-band comparison.
class VerifyIdentityScreen extends StatefulWidget {
  final String contactName;
  final String contactId;
  const VerifyIdentityScreen({
    super.key,
    required this.contactName,
    required this.contactId,
  });

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> {
  String _ownFingerprint = '';
  String? _contactFingerprint;
  bool _isVerified = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final signal = SignalService();
    final ownFp = signal.ownFingerprint;
    final contactFp = await signal.getContactFingerprint(widget.contactId);

    // Check current verification status
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString('verified_identity_${widget.contactId}');
    final currentHash = await _computeCurrentHash();
    final verified = storedHash != null && storedHash == currentHash;

    if (mounted) {
      setState(() {
        _ownFingerprint = ownFp;
        _contactFingerprint = contactFp;
        _isVerified = verified;
        _loading = false;
      });
    }
  }

  /// Compute a SHA-256 hash of both identity keys concatenated.
  /// Verification is stored with this hash so it auto-invalidates on key change.
  Future<String?> _computeCurrentHash() async {
    final signal = SignalService();
    final ownB64 = signal.ownIdentityKeyB64;
    final contactB64 = await signal.getContactIdentityKeyB64(widget.contactId);
    if (ownB64.isEmpty || contactB64 == null) return null;
    final combined = '$ownB64:$contactB64';
    return sha256.convert(utf8.encode(combined)).toString();
  }

  Future<void> _markVerified() async {
    final hash = await _computeCurrentHash();
    if (hash == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verified_identity_${widget.contactId}', hash);
    if (mounted) setState(() => _isVerified = true);
  }

  Future<void> _removeVerification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('verified_identity_${widget.contactId}');
    if (mounted) setState(() => _isVerified = false);
  }

  void _copyFingerprint(String label, String fp) {
    Clipboard.setData(ClipboardData(text: fp));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.l10n.verifyFingerprintCopied(label), style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: AppTheme.surfaceVariant,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  /// Format fingerprint as spaced hex blocks: "A3 B4 C5 D6 E7 F8 ..."
  String _toHexBlocks(String colonSeparated) {
    return colonSeparated.replaceAll(':', ' ');
  }

  @override
  Widget build(BuildContext context) {
    const verifiedColor = Color(0xFF4CAF50);
    const warningColor = Color(0xFFFFA726);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.verifyTitle,
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isVerified
                          ? verifiedColor.withValues(alpha: 0.1)
                          : warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isVerified
                            ? verifiedColor.withValues(alpha: 0.3)
                            : warningColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isVerified
                              ? Icons.verified_user_rounded
                              : Icons.shield_outlined,
                          color: _isVerified ? verifiedColor : warningColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isVerified ? context.l10n.verifyIdentityVerified : context.l10n.verifyNotYetVerified,
                                style: GoogleFonts.inter(
                                  color: _isVerified ? verifiedColor : warningColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isVerified
                                    ? context.l10n.verifyVerifiedDescription(widget.contactName)
                                    : context.l10n.verifyUnverifiedDescription(widget.contactName),
                                style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Explanation text
                  Text(
                    context.l10n.verifyExplanation,
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Contact's fingerprint
                  _buildFingerprintCard(
                    label: context.l10n.verifyContactKey(widget.contactName),
                    fingerprint: _contactFingerprint,
                    icon: Icons.person_rounded,
                    onCopy: _contactFingerprint != null
                        ? () => _copyFingerprint(widget.contactName, _contactFingerprint!)
                        : null,
                  ),

                  const SizedBox(height: 14),

                  // Own fingerprint
                  _buildFingerprintCard(
                    label: context.l10n.verifyYourKey,
                    fingerprint: _ownFingerprint.isNotEmpty ? _ownFingerprint : null,
                    icon: Icons.person_outline_rounded,
                    onCopy: _ownFingerprint.isNotEmpty
                        ? () => _copyFingerprint(context.l10n.verifyYourKey, _ownFingerprint)
                        : null,
                  ),

                  const SizedBox(height: 32),

                  // Action button
                  if (_contactFingerprint != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isVerified ? _removeVerification : _markVerified,
                        icon: Icon(
                          _isVerified ? Icons.remove_circle_outline_rounded : Icons.verified_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          _isVerified ? context.l10n.verifyRemoveVerification : context.l10n.verifyMarkAsVerified,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isVerified ? AppTheme.error : verifiedColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isVerified
                          ? context.l10n.verifyAfterReinstall(widget.contactName)
                          : context.l10n.verifyOnlyMarkAfterCompare(widget.contactName),
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: AppTheme.textSecondary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.l10n.verifyNoSession,
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildFingerprintCard({
    required String label,
    required String? fingerprint,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    final hexBlocks = fingerprint != null ? _toHexBlocks(fingerprint) : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onCopy != null)
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.copy,
                          style: GoogleFonts.inter(
                            color: AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hexBlocks != null)
            SelectableText(
              hexBlocks,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            )
          else
            Text(
              context.l10n.verifyNoKeyAvailable,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
