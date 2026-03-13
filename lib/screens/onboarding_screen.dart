import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'setup_identity_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String? initialConfig;
  const OnboardingScreen({super.key, this.initialConfig});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.shield_rounded,
      iconColor: Color(0xFF4ADE80),
      title: 'Welcome to Pulse',
      body:
          'A decentralized, end-to-end encrypted messenger.\n\n'
          'No central servers. No data collection. No backdoors.\n'
          'Your conversations belong only to you.',
    ),
    _OnboardingPage(
      icon: Icons.hub_rounded,
      iconColor: Color(0xFF60A5FA),
      title: 'Transport-Agnostic',
      body:
          'Use Firebase, Nostr, or both at the same time.\n\n'
          'Messages route across networks automatically. '
          'Built-in Tor and I2P support for censorship resistance.',
    ),
    _OnboardingPage(
      icon: Icons.lock_rounded,
      iconColor: Color(0xFFA78BFA),
      title: 'Signal + Post-Quantum',
      body:
          'Every message is encrypted with the Signal Protocol '
          '(Double Ratchet + X3DH) for forward secrecy.\n\n'
          'Additionally wrapped with Kyber-1024 — a NIST-standard '
          'post-quantum algorithm — protecting against future quantum computers.',
    ),
    _OnboardingPage(
      icon: Icons.key_rounded,
      iconColor: Color(0xFFFBBF24),
      title: 'You Own Your Keys',
      body:
          'Your identity keys never leave your device.\n\n'
          'Signal fingerprints let you verify contacts out-of-band. '
          'TOFU (Trust On First Use) detects key changes automatically.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
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
                child: Text('Skip',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 14)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _PageView(page: _pages[i]),
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(_pages.length, (i) {
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
                      _page == _pages.length - 1 ? 'Get Started' : 'Next',
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

class _PageView extends StatelessWidget {
  final _OnboardingPage page;
  const _PageView({required this.page});

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
              color: Colors.white,
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
