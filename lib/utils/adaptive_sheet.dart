import 'package:flutter/material.dart';
import 'platform_utils.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Shows a bottom sheet on mobile, a centered dialog on desktop.
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = false,
  double desktopWidth = DesignTokens.dialogMaxWidth,
}) {
  if (PlatformUtils.isDesktop) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.dialogRadius),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: desktopWidth,
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: builder(ctx),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}
