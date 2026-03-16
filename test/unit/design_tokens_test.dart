import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/theme/design_tokens.dart';

void main() {
  group('DesignTokens', () {
    group('spacing values', () {
      test('all spacing values are positive', () {
        const spacings = [
          DesignTokens.spacing2,
          DesignTokens.spacing4,
          DesignTokens.spacing6,
          DesignTokens.spacing8,
          DesignTokens.spacing10,
          DesignTokens.spacing12,
          DesignTokens.spacing14,
          DesignTokens.spacing16,
          DesignTokens.spacing20,
          DesignTokens.spacing24,
          DesignTokens.spacing28,
          DesignTokens.spacing32,
          DesignTokens.spacing40,
        ];
        for (final s in spacings) {
          expect(s, greaterThan(0), reason: 'Spacing $s should be positive');
        }
      });

      test('spacing values are in ascending order', () {
        const spacings = [
          DesignTokens.spacing2,
          DesignTokens.spacing4,
          DesignTokens.spacing6,
          DesignTokens.spacing8,
          DesignTokens.spacing10,
          DesignTokens.spacing12,
          DesignTokens.spacing14,
          DesignTokens.spacing16,
          DesignTokens.spacing20,
          DesignTokens.spacing24,
          DesignTokens.spacing28,
          DesignTokens.spacing32,
          DesignTokens.spacing40,
        ];
        for (var i = 1; i < spacings.length; i++) {
          expect(spacings[i], greaterThan(spacings[i - 1]),
              reason:
                  'spacing[$i] ($spacings[i]}) should be > spacing[${i - 1}] ($spacings[i - 1]})');
        }
      });
    });

    group('avatar sizes', () {
      test('all avatar sizes are positive', () {
        const sizes = [
          DesignTokens.avatarXs,
          DesignTokens.avatarSm,
          DesignTokens.avatarMd,
          DesignTokens.avatarLg,
          DesignTokens.avatarXl,
        ];
        for (final s in sizes) {
          expect(s, greaterThan(0), reason: 'Avatar size $s should be positive');
        }
      });

      test('avatar sizes are in ascending order', () {
        const sizes = [
          DesignTokens.avatarXs,
          DesignTokens.avatarSm,
          DesignTokens.avatarMd,
          DesignTokens.avatarLg,
          DesignTokens.avatarXl,
        ];
        for (var i = 1; i < sizes.length; i++) {
          expect(sizes[i], greaterThan(sizes[i - 1]),
              reason:
                  'avatar[$i] (${sizes[i]}) should be > avatar[${i - 1}] (${sizes[i - 1]})');
        }
      });
    });

    group('font sizes', () {
      test('all font sizes are positive', () {
        const fonts = [
          DesignTokens.fontXxs,
          DesignTokens.fontXs,
          DesignTokens.fontSm,
          DesignTokens.fontBody,
          DesignTokens.fontMd,
          DesignTokens.fontLg,
          DesignTokens.fontInput,
          DesignTokens.fontXl,
          DesignTokens.fontTitle,
          DesignTokens.fontHeading,
          DesignTokens.fontXxl,
          DesignTokens.fontDisplay,
          DesignTokens.fontDisplayLg,
        ];
        for (final f in fonts) {
          expect(f, greaterThan(0), reason: 'Font size $f should be positive');
        }
      });

      test('font sizes are in ascending order', () {
        const fonts = [
          DesignTokens.fontXxs,
          DesignTokens.fontXs,
          DesignTokens.fontSm,
          DesignTokens.fontBody,
          DesignTokens.fontMd,
          DesignTokens.fontLg,
          DesignTokens.fontInput,
          DesignTokens.fontXl,
          DesignTokens.fontTitle,
          DesignTokens.fontHeading,
          DesignTokens.fontXxl,
          DesignTokens.fontDisplay,
          DesignTokens.fontDisplayLg,
        ];
        for (var i = 1; i < fonts.length; i++) {
          expect(fonts[i], greaterThan(fonts[i - 1]),
              reason:
                  'font[$i] ($fonts[i]}) should be > font[${i - 1}] ($fonts[i - 1]})');
        }
      });
    });

    group('border radii', () {
      test('all radius values are positive', () {
        const radii = [
          DesignTokens.radiusXs,
          DesignTokens.radiusSmall,
          DesignTokens.radiusMedium,
          DesignTokens.radiusLarge,
          DesignTokens.radiusXl,
          DesignTokens.radiusPill,
          DesignTokens.radiusCircle,
        ];
        for (final r in radii) {
          expect(r, greaterThan(0), reason: 'Radius $r should be positive');
        }
      });

      test('radius values are in ascending order', () {
        const radii = [
          DesignTokens.radiusXs,
          DesignTokens.radiusSmall,
          DesignTokens.radiusMedium,
          DesignTokens.radiusLarge,
          DesignTokens.radiusXl,
          DesignTokens.radiusPill,
          DesignTokens.radiusCircle,
        ];
        for (var i = 1; i < radii.length; i++) {
          expect(radii[i], greaterThan(radii[i - 1]),
              reason:
                  'radius[$i] ($radii[i]}) should be > radius[${i - 1}] ($radii[i - 1]})');
        }
      });
    });

    group('icon sizes', () {
      test('all icon sizes are positive', () {
        const icons = [
          DesignTokens.iconSm,
          DesignTokens.iconMd,
          DesignTokens.iconLg,
          DesignTokens.iconXl,
        ];
        for (final s in icons) {
          expect(s, greaterThan(0), reason: 'Icon size $s should be positive');
        }
      });

      test('icon sizes are in ascending order', () {
        const icons = [
          DesignTokens.iconSm,
          DesignTokens.iconMd,
          DesignTokens.iconLg,
          DesignTokens.iconXl,
        ];
        for (var i = 1; i < icons.length; i++) {
          expect(icons[i], greaterThan(icons[i - 1]),
              reason:
                  'icon[$i] ($icons[i]}) should be > icon[${i - 1}] ($icons[i - 1]})');
        }
      });
    });

    group('chat-specific tokens', () {
      test('chat bubble values are positive', () {
        expect(DesignTokens.chatBubbleRadius, greaterThan(0));
        expect(DesignTokens.chatBubbleTailRadius, greaterThan(0));
        expect(DesignTokens.chatBubblePaddingH, greaterThan(0));
        expect(DesignTokens.chatBubblePaddingV, greaterThan(0));
        expect(DesignTokens.chatBubbleMarginOpposite, greaterThan(0));
        expect(DesignTokens.chatInputRadius, greaterThan(0));
        expect(DesignTokens.chatInputPaddingH, greaterThan(0));
        expect(DesignTokens.chatInputPaddingV, greaterThan(0));
        expect(DesignTokens.chatDateChipRadius, greaterThan(0));
      });
    });

    group('dialog tokens', () {
      test('dialog values are positive', () {
        expect(DesignTokens.dialogRadius, greaterThan(0));
        expect(DesignTokens.dialogPadding, greaterThan(0));
        expect(DesignTokens.dialogMaxWidth, greaterThan(0));
      });
    });

    group('card/tile tokens', () {
      test('card and tile values are positive', () {
        expect(DesignTokens.cardRadius, greaterThan(0));
        expect(DesignTokens.cardPadding, greaterThan(0));
        expect(DesignTokens.tilePaddingH, greaterThan(0));
        expect(DesignTokens.tilePaddingV, greaterThan(0));
        expect(DesignTokens.tileContentPaddingH, greaterThan(0));
        expect(DesignTokens.tileContentPaddingV, greaterThan(0));
      });
    });

    group('input/button tokens', () {
      test('input and button values are positive', () {
        expect(DesignTokens.inputRadius, greaterThan(0));
        expect(DesignTokens.inputContentPaddingH, greaterThan(0));
        expect(DesignTokens.inputContentPaddingV, greaterThan(0));
        expect(DesignTokens.buttonRadius, greaterThan(0));
        expect(DesignTokens.buttonPaddingH, greaterThan(0));
        expect(DesignTokens.buttonPaddingV, greaterThan(0));
      });
    });
  });
}
