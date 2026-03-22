import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
    return SizedBox(
      height: 280,
      child: EmojiPicker(
        onEmojiSelected: (_, emoji) => onEmojiSelected(emoji.emoji),
        onBackspacePressed: onBackspace,
        config: Config(
          height: 280,
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 28,
            backgroundColor: AppTheme.surface,
            noRecents: const Text('No recent emojis',
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary,
            iconColorSelected: AppTheme.primary,
            iconColor: AppTheme.textSecondary,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: SearchViewConfig(
            backgroundColor: AppTheme.surface,
            buttonIconColor: AppTheme.textSecondary,
            hintText: 'Search emoji...',
          ),
          skinToneConfig: const SkinToneConfig(
            dialogBackgroundColor: Color(0xFF2A2A2E),
            indicatorColor: Color(0xFF4CAF50),
          ),
        ),
      ),
    );
  }
}
