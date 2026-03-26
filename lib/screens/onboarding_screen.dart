import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_picker_widget.dart';
import 'setup_identity_screen.dart';
import '../l10n/l10n_ext.dart';
import '../services/locale_notifier.dart';

class OnboardingScreen extends StatefulWidget {
  final String? initialConfig;
  const OnboardingScreen({super.key, this.initialConfig});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  // 4 info pages + 1 theme page
  List<_OnboardingPage> _infoPages(BuildContext context) {
    final l = context.l10n;
    return [
      _OnboardingPage(
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFF4ADE80),
        title: l.onboardingWelcomeTitle,
        body: l.onboardingWelcomeBody,
      ),
      _OnboardingPage(
        icon: Icons.hub_rounded,
        iconColor: const Color(0xFF60A5FA),
        title: l.onboardingTransportTitle,
        body: l.onboardingTransportBody,
      ),
      _OnboardingPage(
        icon: Icons.lock_rounded,
        iconColor: const Color(0xFFA78BFA),
        title: l.onboardingSignalTitle,
        body: l.onboardingSignalBody,
      ),
      _OnboardingPage(
        icon: Icons.key_rounded,
        iconColor: const Color(0xFFFBBF24),
        title: l.onboardingKeysTitle,
        body: l.onboardingKeysBody,
      ),
    ];
  }

  // Total pages = language (1) + info pages (4) + theme picker (1)
  int get _totalPages => 6;
  bool get _isThemePage => _page == 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SetupIdentityScreen(initialConfig: widget.initialConfig),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(context.l10n.onboardingSkip,
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 14)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _totalPages,
                itemBuilder: (context, i) {
                  if (i == 0) return const _LanguagePageView();
                  final pages = _infoPages(context);
                  if (i - 1 < pages.length) {
                    return _InfoPageView(page: pages[i - 1]);
                  }
                  return const _ThemePageView();
                },
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(_totalPages, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.primary
                              : AppTheme.textSecondary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // Next / Get Started button
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _isThemePage ? context.l10n.onboardingGetStarted : context.l10n.onboardingNext,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language picker page ──────────────────────────────────────────────────

class _LanguagePageView extends StatefulWidget {
  const _LanguagePageView();

  @override
  State<_LanguagePageView> createState() => _LanguagePageViewState();
}

class _LanguagePageViewState extends State<_LanguagePageView> {
  String? _selected = LocaleNotifier.instance.locale?.languageCode;

  @override
  Widget build(BuildContext context) {
    // Sort languages: system language first, then alphabetical by native name
    final systemCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final entries = LocaleNotifier.nativeNames.entries.toList();
    entries.sort((a, b) {
      if (a.key == systemCode && b.key != systemCode) return -1;
      if (b.key == systemCode && a.key != systemCode) return 1;
      return a.value.compareTo(b.value);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language_rounded,
                size: 40, color: Color(0xFF009688)),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.onboardingLanguageTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.onboardingLanguageSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ...entries.map((e) {
            final isSelected = _selected == e.key ||
                (_selected == null && e.key == systemCode);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Material(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _selected = e.key);
                    LocaleNotifier.instance.setLocale(Locale(e.key));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.value,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (e.key == systemCode && _selected != e.key)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'System',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        if (isSelected)
                          Icon(Icons.check_rounded,
                              color: AppTheme.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Info page ──────────────────────────────────────────────────────────────

class _InfoPageView extends StatelessWidget {
  final _OnboardingPage page;
  const _InfoPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: page.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 48, color: page.iconColor),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme picker page ──────────────────────────────────────────────────────

class _ThemePageView extends StatelessWidget {
  const _ThemePageView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.palette_rounded,
                size: 36, color: Color(0xFF9B59B6)),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.onboardingThemeTitle,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.onboardingThemeBody,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          const ThemePickerWidget(),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}
