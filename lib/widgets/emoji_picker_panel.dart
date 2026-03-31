import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';

class EmojiPickerPanel extends StatelessWidget {
  final void Function(String emoji) onEmojiSelected;
  final VoidCallback onBackspace;

  const EmojiPickerPanel({
    super.key,
    required this.onEmojiSelected,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to pick optimal column count for screen width
    return LayoutBuilder(builder: (context, constraints) {
      // Target ~28px per cell — WhatsApp-density grid
      final cols = (constraints.maxWidth / 28).floor().clamp(8, 50);
      return SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (_, emoji) => onEmojiSelected(emoji.emoji),
          onBackspacePressed: onBackspace,
          config: Config(
            height: 250,
            checkPlatformCompatibility: !Platform.isLinux,
            emojiTextStyle: Platform.isLinux
                ? const TextStyle(fontFamily: 'Noto Color Emoji')
                : null,
            emojiViewConfig: EmojiViewConfig(
              columns: cols,
              emojiSizeMax: 22,
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              recentsLimit: cols * 3,
              buttonMode: ButtonMode.CUPERTINO,
              backgroundColor: AppTheme.surface,
              noRecents: Text(context.l10n.emojiNoRecent,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            categoryViewConfig: CategoryViewConfig(
              backgroundColor: AppTheme.surface,
              indicatorColor: AppTheme.primary,
              iconColorSelected: AppTheme.primary,
              iconColor: AppTheme.textSecondary,
              tabBarHeight: 36,
            ),
            bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
            searchViewConfig: SearchViewConfig(
              backgroundColor: AppTheme.surface,
              buttonIconColor: AppTheme.textSecondary,
              hintText: context.l10n.emojiSearchHint,
            ),
            skinToneConfig: const SkinToneConfig(
              dialogBackgroundColor: Color(0xFF2A2A2E),
              indicatorColor: Color(0xFF4CAF50),
            ),
          ),
        ),
      );
    });
  }
}
