import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.privacyPolicyTitle,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: DesignTokens.fontTitle,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24, vertical: DesignTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heading(l.privacyOverviewHeading),
            _body(l.privacyOverviewBody),
            _heading(l.privacyDataCollectionHeading),
            _body(l.privacyDataCollectionBody),
            _heading(l.privacyEncryptionHeading),
            _body(l.privacyEncryptionBody),
            _heading(l.privacyNetworkHeading),
            _body(l.privacyNetworkBody),
            _heading(l.privacyStunHeading),
            _body(l.privacyStunBody),
            _heading(l.privacyCrashHeading),
            _body(l.privacyCrashBody),
            _heading(l.privacyPasswordHeading),
            _body(l.privacyPasswordBody),
            _heading(l.privacyFontsHeading),
            _body(l.privacyFontsBody),
            _heading(l.privacyThirdPartyHeading),
            _body(l.privacyThirdPartyBody),
            _heading(l.privacyOpenSourceHeading),
            _body(l.privacyOpenSourceBody),
            _heading(l.privacyContactHeading),
            _body(l.privacyContactBody),
            const SizedBox(height: DesignTokens.spacing32),
            Center(
              child: Text(
                l.privacyLastUpdated,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: DesignTokens.fontSm),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
          ],
        ),
      ),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacing24, bottom: DesignTokens.spacing8),
      child: Text(text,
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: DesignTokens.fontXl,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _body(String text) {
    return Text(text,
        style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: DesignTokens.fontMd,
            height: 1.6));
  }
}
