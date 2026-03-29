import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/locale_notifier.dart';
import '../l10n/l10n_ext.dart';
import 'setup_identity_screen.dart';

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

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Choose your language',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
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
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded,
                            color: AppTheme.primary, size: 20)
                        : (e.key == systemCode
                            ? Text('System',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
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
        ),
      ),
    );
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
            const SizedBox(height: 20),

            // App name
            Text(
              'Pulse',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                context.l10n.onboardingWelcomeBody.split('\n').first,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(flex: 4),

            // Start Messaging button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _startMessaging(context),
                  child: Text(
                    context.l10n.onboardingGetStarted,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // "Continue in [Language]" link
            GestureDetector(
              onTap: () => _showLanguagePicker(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language_rounded,
                      size: 18, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Continue in $languageName',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
