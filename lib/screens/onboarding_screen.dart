import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_picker_widget.dart';
import 'setup_identity_screen.dart';
import '../l10n/l10n_ext.dart';

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

  // Total pages = info pages (4) + theme picker
  int get _totalPages => 5;
  bool get _isThemePage => _page == 4;

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
                  final pages = _infoPages(context);
                  if (i < pages.length) {
                    return _InfoPageView(page: pages[i]);
                  }
                  return _ThemePageView();
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
