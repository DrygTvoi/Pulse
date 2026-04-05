import 'dart:io' show Platform;

/// Centralised platform detection for desktop vs mobile behaviour.
abstract class PlatformUtils {
  PlatformUtils._();

  static final bool isDesktop =
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  static final bool isMobile = Platform.isAndroid || Platform.isIOS;

  /// True when a mouse is the primary input device (desktop).
  static final bool hasMouseInput = isDesktop;
}
