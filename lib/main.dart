import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'theme/theme_manager.dart';
import 'screens/home_screen.dart';
import 'screens/setup_identity_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/lock_screen.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'dart:convert';
import 'controllers/chat_controller.dart';
import 'models/contact.dart';
import 'models/contact_repository.dart';
import 'services/notification_service.dart';
import 'services/connectivity_probe_service.dart';
import 'services/utls_service.dart';
import 'services/yggdrasil_service.dart';
import 'services/tor_service.dart';
import 'services/psiphon_service.dart';
import 'services/psiphon_turn_proxy.dart';
import 'services/background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'services/locale_notifier.dart';
import 'services/blossom_service.dart';
import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Silence debugPrint in release builds — prevents log spam on user devices.
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};

  // Use bundled fonts from google_fonts/ — no runtime fetching from Google servers.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Sentry crash reporting is opt-in for privacy. User enables in Settings → About.
  final prefsForSentry = await SharedPreferences.getInstance();
  final sentryEnabled = prefsForSentry.getBool('sentry_opt_in') ?? false;

  Future<void> appMain() async {
    // Catch Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (sentryEnabled) {
        Sentry.captureException(details.exception, stackTrace: details.stack);
      }
    };

    // Catch unhandled async errors (e.g. uncaught Future exceptions)
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[FATAL] Unhandled: $error\n$stack');
      if (sentryEnabled) {
        Sentry.captureException(error, stackTrace: stack);
      }
      return true;
    };

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

      // Check if app-level password lock is enabled
      const ss = FlutterSecureStorage();
      final passwordEnabled =
          hasIdentity && await ss.read(key: 'app_password_enabled') == 'true';

      final chatController = ChatController();
      await chatController.initialize(); // Load identity and setup Inbox manager
      await NotificationService().initialize();
      NotificationService().setContactRepository(ContactManager());

      // Announce our current addresses to all contacts (in case we changed relay/provider).
      // When a password lock is enabled, defer this broadcast until AFTER the user
      // authenticates — otherwise contacts receive a presence update before the user
      // has unlocked, leaking the device-active timestamp.
      if (!passwordEnabled) {
        unawaited(chatController.broadcastAddressUpdate());
      }

      // Background connectivity probe — finds reachable relays/nodes.
      // Runs silently; if connection is already working, does nothing extra.
      // If tor is installed and direct probes fail, uses it for bootstrap only.
      // Capture relay BEFORE probe runs — probe updates the pref, so comparing
      // after would always match.
      final relayBeforeProbe = prefs.getString('nostr_relay') ?? '';
      unawaited(ConnectivityProbeService.instance.runIfNeeded());

      // Background Blossom server discovery — probes seed servers and queries
      // Nostr kind:10063 events to find active servers. Results cached 24 h.
      unawaited(BlossomService.instance.discoverServers(
        nostrRelays: [prefs.getString('nostr_relay') ?? kDefaultNostrRelay],
      ));

      // After probe finishes, reconnect only if a DIFFERENT relay was discovered.
      unawaited(ConnectivityProbeService.instance.firstRunDone.then((result) {
        if (result.bestNostrRelay != null &&
            result.bestNostrRelay != relayBeforeProbe) {
          debugPrint('[Main] Probe found better relay: ${result.bestNostrRelay} '
              '(was $relayBeforeProbe) — reconnecting');
          chatController.reconnectInbox();
        } else {
          debugPrint('[Main] Probe relay matches current — no reconnect needed');
        }
      }));
      unawaited(UTLSService.instance.ensureRunning());
      // Initialise Yggdrasil overlay once the uTLS proxy binary is up.
      UTLSService.instance.available.addListener(() {
        final port = UTLSService.instance.proxyPort;
        if (UTLSService.instance.available.value && port != null) {
          unawaited(YggdrasilService.instance.init(
            port,
            token: UTLSService.instance.proxyToken,
          ));
        }
      });
      // Android foreground service — keeps WS connections alive in background.
      BackgroundService.instance.init();
      unawaited(BackgroundService.instance.startIfEnabled());
      // Re-start bundled Tor if user had it enabled previously.
      if (prefs.getBool('bundled_tor_enabled') ?? false) {
        unawaited(TorService.instance.startPersistent());
      }
      // Re-start Psiphon if user had it enabled previously.
      if (prefs.getBool('bundled_psiphon_enabled') ?? false) {
        unawaited(PsiphonService.instance.ensureRunning().then((_) {
          if (PsiphonService.instance.isRunning) PsiphonTurnProxy.startAll();
        }));
      }

      runApp(
        MultiProvider(
          providers: [
            Provider<IContactRepository>.value(value: ContactManager()),
            ChangeNotifierProvider.value(value: ThemeNotifier.instance),
            ChangeNotifierProvider.value(value: LocaleNotifier.instance),
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

  if (sentryEnabled) {
    const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    if (sentryDsn.isEmpty && kReleaseMode) {
      debugPrint('[Sentry] WARNING: SENTRY_DSN not set in release build — crash reporting disabled');
    }
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.2;
        options.environment = kDebugMode ? 'debug' : 'release';
        options.sendDefaultPii = false;
        options.attachScreenshot = false;
        options.beforeSend = (event, hint) {
          final sanitized = event.copyWith(
            breadcrumbs: event.breadcrumbs?.map((b) => Breadcrumb(
              message: b.message, category: b.category,
              timestamp: b.timestamp, level: b.level, type: b.type,
            )).toList(),
          );
          return sanitized;
        };
      },
      appRunner: () => appMain(),
    );
  } else {
    await appMain();
  }
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

class _PulseAppState extends State<PulseApp> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  String? _initialDeepLinkConfig;
  final _navigatorKey = GlobalKey<NavigatorState>();

  /// Timestamp when app was last backgrounded; null if in foreground.
  DateTime? _backgroundedAt;

  /// Re-lock after this many seconds in background.
  static const _kLockDelay = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLinks = AppLinks();
    _handleDeepLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final bg = _backgroundedAt;
      _backgroundedAt = null;
      if (bg != null && DateTime.now().difference(bg) >= _kLockDelay) {
        _checkAndLock();
      }
    }
  }

  /// Reads current password state from SecureStorage and pushes LockScreen if needed.
  Future<void> _checkAndLock() async {
    const ss = FlutterSecureStorage();
    final enabled = await ss.read(key: 'app_password_enabled') == 'true';
    if (!enabled) return;
    final hash = await ss.read(key: 'app_password_hash');
    if (hash == null) return;
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LockScreen()),
      (_) => false,
    );
  }

  Future<void> _handleDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _processUri(initialUri);
    } catch (e) {
      debugPrint('[App] Failed to get initial deep link: $e');
    }

    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && mounted) {
        _processUri(uri);
      }
    }, onError: (err) { debugPrint('[App] URI stream error: $err'); });
  }

  void _processUri(Uri uri) {
    if ((uri.scheme == 'pulse' && uri.host == 'add') ||
        (uri.scheme == 'messenger' && uri.host == 'join')) {
      final config64 = uri.queryParameters['cfg'];
      if (config64 != null && config64.length <= 16384) {
        try {
          final configStr = utf8.decode(base64Decode(config64));
          setState(() {
            _initialDeepLinkConfig = configStr;
          });
        } catch (e) {
          debugPrint('[App] Failed to decode deep link config: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final localeNotifier = context.watch<LocaleNotifier>();

    // If we receive a deep link and we don't have an identity, pass it to setup
    // For now we just pass it, later we can auto-configure
    final deepLinkConfig = _initialDeepLinkConfig;
    if (deepLinkConfig != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _initialDeepLinkConfig = null);
      });
    }
    Widget homeWidget = widget.hasIdentity
        ? (widget.passwordEnabled
            ? const LockScreen()
            : const HomeScreen())
        : widget.showOnboarding
            ? OnboardingScreen(initialConfig: deepLinkConfig)
            : SetupIdentityScreen(initialConfig: deepLinkConfig);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.lightThemeData,
      darkTheme: themeNotifier.darkThemeData,
      themeMode: themeNotifier.themeMode,
      locale: localeNotifier.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: homeWidget,
    );
  }
}

