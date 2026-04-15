import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../services/locale_notifier.dart';
import '../l10n/l10n_ext.dart';
import '../utils/platform_utils.dart';
import 'setup_identity_screen.dart';
import 'restore_account_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final String? initialConfig;
  const OnboardingScreen({super.key, this.initialConfig});

  void _startMessaging(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SetupIdentityScreen(initialConfig: initialConfig),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final systemCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final entries = LocaleNotifier.nativeNames.entries.toList();
    entries.sort((a, b) {
      if (a.key == systemCode && b.key != systemCode) return -1;
      if (b.key == systemCode && a.key != systemCode) return 1;
      return a.value.compareTo(b.value);
    });

    Widget languageList(BuildContext ctx, {ScrollController? scrollController}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!PlatformUtils.isDesktop) ...[
            const SizedBox(height: DesignTokens.spacing12),
            Container(
              width: 36,
              height: DesignTokens.spacing4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: DesignTokens.opacityMedium),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacing16),
            child: Text(
              'Choose your language',
              style: GoogleFonts.inter(
                fontSize: DesignTokens.fontHeading,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              shrinkWrap: PlatformUtils.isDesktop,
              itemCount: entries.length,
              itemBuilder: (ctx, i) {
                final e = entries[i];
                final current =
                    LocaleNotifier.instance.locale?.languageCode;
                final isSelected = current == e.key ||
                    (current == null && e.key == systemCode);
                return ListTile(
                  title: Text(
                    e.value,
                    style: GoogleFonts.inter(
                      fontSize: DesignTokens.fontXl,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: AppTheme.primary, size: DesignTokens.iconMd)
                      : (e.key == systemCode
                          ? Text(context.l10n.systemLabel,
                              style: GoogleFonts.inter(
                                  fontSize: DesignTokens.fontBody,
                                  color: AppTheme.textSecondary))
                          : null),
                  onTap: () {
                    LocaleNotifier.instance.setLocale(Locale(e.key));
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    if (PlatformUtils.isDesktop) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DesignTokens.dialogMaxWidth, maxHeight: 500),
            child: languageList(ctx),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.dialogRadius)),
        ),
        isScrollControlled: true,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollController) =>
              languageList(ctx, scrollController: scrollController),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine current language name for the bottom button
    final currentCode = LocaleNotifier.instance.locale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final languageName =
        LocaleNotifier.nativeNames[currentCode] ?? 'English';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.shield_rounded,
                  color: Colors.white, size: 52),
            ),
            const SizedBox(height: DesignTokens.spacing20),

            // App name
            Text(
              'Pulse',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing48),
              child: Text(
                context.l10n.onboardingWelcomeBody.split('\n').first,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: DesignTokens.fontInput,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(flex: 4),

            // Start Messaging button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    ),
                  ),
                  onPressed: () => _startMessaging(context),
                  child: Text(
                    context.l10n.onboardingGetStarted,
                    style: GoogleFonts.inter(
                      fontSize: DesignTokens.fontXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing20),

            // "Already have an account? Restore"
            GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_done', true);
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const RestoreAccountScreen(),
                  ),
                );
              },
              child: Text.rich(
                TextSpan(
                  text: context.l10n.setupAlreadyHaveAccount,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: DesignTokens.fontLg,
                  ),
                  children: [
                    TextSpan(
                      text: context.l10n.setupRestore,
                      style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),

            // "Continue in [Language]" link
            GestureDetector(
              onTap: () => _showLanguagePicker(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language_rounded,
                      size: 18, color: AppTheme.primary),
                  const SizedBox(width: DesignTokens.spacing6),
                  Text(
                    'Continue in $languageName',
                    style: GoogleFonts.inter(
                      fontSize: DesignTokens.fontLg,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.spacing40),
          ],
        ),
      ),
    );
  }
}
