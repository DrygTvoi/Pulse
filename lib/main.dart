import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'theme/theme_manager.dart';
import 'screens/home_screen.dart';
import 'screens/setup_identity_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/lock_screen.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'dart:convert';
import 'controllers/chat_controller.dart';
import 'services/notification_service.dart';
import 'services/connectivity_probe_service.dart';
import 'services/utls_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  // Clear legacy auto-saved theme keys so new design defaults apply cleanly.
  if (prefs.getBool('theme_user_customized') != true) {
    await prefs.remove('theme_primary');
    await prefs.remove('theme_background');
    await prefs.remove('theme_surface');
    await prefs.remove('theme_accent');
    await prefs.remove('theme_radius');
    await prefs.remove('theme_font');
  }
  final hasIdentity = prefs.containsKey('user_identity');
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  if (!onboardingDone) await prefs.setBool('onboarding_done', true);

  // Check if app-level password lock is enabled
  const ss = FlutterSecureStorage();
  final passwordEnabled =
      hasIdentity && await ss.read(key: 'app_password_enabled') == 'true';

  final chatController = ChatController();
  await chatController.initialize(); // Load identity and setup Inbox manager
  await NotificationService().initialize();

  // Background connectivity probe — finds reachable relays/nodes.
  // Runs silently; if connection is already working, does nothing extra.
  // If tor is installed and direct probes fail, uses it for bootstrap only.
  unawaited(ConnectivityProbeService.instance.runIfNeeded());
  unawaited(UTLSService.instance.ensureRunning());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeNotifier.instance),
        ChangeNotifierProvider.value(value: chatController),
      ],
      child: PulseApp(
        hasIdentity: hasIdentity,
        showOnboarding: !onboardingDone && !hasIdentity,
        passwordEnabled: passwordEnabled,
      ),
    ),
  );
}

class PulseApp extends StatefulWidget {
  final bool hasIdentity;
  final bool showOnboarding;
  final bool passwordEnabled;
  const PulseApp({
    super.key,
    required this.hasIdentity,
    required this.showOnboarding,
    required this.passwordEnabled,
  });

  @override
  State<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends State<PulseApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  String? _initialDeepLinkConfig;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _handleDeepLinks();
  }

  Future<void> _handleDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _processUri(initialUri);
    } catch (_) {}

    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && mounted) {
        _processUri(uri);
      }
    }, onError: (err) {});
  }

  void _processUri(Uri uri) {
    if ((uri.scheme == 'pulse' && uri.host == 'add') ||
        (uri.scheme == 'messenger' && uri.host == 'join')) {
      final config64 = uri.queryParameters['cfg'];
      if (config64 != null) {
        try {
          final configStr = utf8.decode(base64Decode(config64));
          setState(() {
            _initialDeepLinkConfig = configStr;
          });
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    
    // If we receive a deep link and we don't have an identity, pass it to setup
    // For now we just pass it, later we can auto-configure
    Widget homeWidget = widget.hasIdentity
        ? (widget.passwordEnabled
            ? const LockScreen()
            : const HomeScreen())
        : widget.showOnboarding
            ? OnboardingScreen(initialConfig: _initialDeepLinkConfig)
            : SetupIdentityScreen(initialConfig: _initialDeepLinkConfig);

    return MaterialApp(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.lightThemeData,
      darkTheme: themeNotifier.darkThemeData,
      themeMode: themeNotifier.themeMode,
      home: homeWidget,
    );
  }
}

