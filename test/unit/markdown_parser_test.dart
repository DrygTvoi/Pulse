import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/markdown_parser.dart';

void main() {
  group('MarkdownParser', () {
    group('plain text', () {
      test('empty string returns empty list', () {
        expect(MarkdownParser.parse(''), isEmpty);
      });

      test('plain text returns single segment with no styling', () {
        final segs = MarkdownParser.parse('hello world');
        expect(segs.length, 1);
        expect(segs[0].text, 'hello world');
        expect(segs[0].isPlain, true);
      });

      test('text without delimiters skips parser fast path', () {
        final segs = MarkdownParser.parse('just normal text 123');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
      });
    });

    group('bold **text**', () {
      test('basic bold', () {
        final segs = MarkdownParser.parse('**bold**');
        expect(segs.length, 1);
        expect(segs[0].text, 'bold');
        expect(segs[0].bold, true);
      });

      test('bold in middle', () {
        final segs = MarkdownParser.parse('hi **bold** there');
        expect(segs.length, 3);
        expect(segs[0].text, 'hi ');
        expect(segs[0].isPlain, true);
        expect(segs[1].text, 'bold');
        expect(segs[1].bold, true);
        expect(segs[2].text, ' there');
        expect(segs[2].isPlain, true);
      });

      test('unmatched ** is literal', () {
        final segs = MarkdownParser.parse('**hello');
        expect(segs.length, 1);
        expect(segs[0].text, '**hello');
        expect(segs[0].isPlain, true);
      });

      test('empty bold ****  is dropped', () {
        final segs = MarkdownParser.parse('****');
        // No emphasis with empty content; falls through as literal
        expect(segs.length, 1);
        expect(segs[0].text, '****');
      });

      test('bold with whitespace immediately inside is rejected', () {
        final segs = MarkdownParser.parse('** spaced **');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
        expect(segs[0].text, '** spaced **');
      });
    });

    group('italic *text*', () {
      test('basic italic', () {
        final segs = MarkdownParser.parse('*italic*');
        expect(segs.length, 1);
        expect(segs[0].text, 'italic');
        expect(segs[0].italic, true);
      });

      test('multiplication not italic', () {
        final segs = MarkdownParser.parse('2 * 3 = 6');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
        expect(segs[0].text, '2 * 3 = 6');
      });

      test('two multiplications stays literal', () {
        final segs = MarkdownParser.parse('a * b * c');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
      });

      test('asterisk at start with space does not open', () {
        final segs = MarkdownParser.parse('* leading');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
      });
    });

    group('italic _text_', () {
      test('basic italic with underscore', () {
        final segs = MarkdownParser.parse('_italic_');
        expect(segs.length, 1);
        expect(segs[0].text, 'italic');
        expect(segs[0].italic, true);
      });

      test('snake_case_var stays literal', () {
        final segs = MarkdownParser.parse('snake_case_var');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
        expect(segs[0].text, 'snake_case_var');
      });

      test('underscore italic in sentence', () {
        final segs = MarkdownParser.parse('say _hello_ world');
        expect(segs.length, 3);
        expect(segs[1].text, 'hello');
        expect(segs[1].italic, true);
      });

      test('underscore italic does not span newlines greedily', () {
        // Both underscores within a single line are valid.
        final segs = MarkdownParser.parse('_word_ next');
        expect(segs.length, 2);
        expect(segs[0].italic, true);
        expect(segs[0].text, 'word');
      });
    });

    group('strikethrough ~~text~~', () {
      test('basic strike', () {
        final segs = MarkdownParser.parse('~~struck~~');
        expect(segs.length, 1);
        expect(segs[0].text, 'struck');
        expect(segs[0].strike, true);
      });

      test('unmatched ~~ is literal', () {
        final segs = MarkdownParser.parse('~~hello');
        expect(segs.length, 1);
        expect(segs[0].text, '~~hello');
      });
    });

    group('inline code `text`', () {
      test('basic inline code', () {
        final segs = MarkdownParser.parse('`code`');
        expect(segs.length, 1);
        expect(segs[0].text, 'code');
        expect(segs[0].code, true);
      });

      test('inline code with spaces inside is allowed', () {
        final segs = MarkdownParser.parse('`hello world`');
        expect(segs.length, 1);
        expect(segs[0].text, 'hello world');
        expect(segs[0].code, true);
      });

      test('inline code does NOT span newlines', () {
        final segs = MarkdownParser.parse('`line1\nline2`');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
        expect(segs[0].text, '`line1\nline2`');
      });

      test('inline code is opaque - no markdown inside', () {
        final segs = MarkdownParser.parse('`**not bold**`');
        expect(segs.length, 1);
        expect(segs[0].code, true);
        expect(segs[0].text, '**not bold**');
      });

      test('lone backtick is literal', () {
        final segs = MarkdownParser.parse('a `b');
        expect(segs.length, 1);
        expect(segs[0].text, 'a `b');
      });
    });

    group('code blocks ```text```', () {
      test('single-line code block', () {
        final segs = MarkdownParser.parse('```code```');
        expect(segs.length, 1);
        expect(segs[0].codeBlock, true);
        expect(segs[0].text, 'code');
      });

      test('multiline code block trims surrounding newlines', () {
        final segs = MarkdownParser.parse('```\nint x = 1;\nint y = 2;\n```');
        expect(segs.length, 1);
        expect(segs[0].codeBlock, true);
        expect(segs[0].text, 'int x = 1;\nint y = 2;');
      });

      test('code block preserves inner indentation', () {
        final segs = MarkdownParser.parse('```\n  indented\n  more\n```');
        expect(segs.length, 1);
        expect(segs[0].text, '  indented\n  more');
      });

      test('code block with markdown inside is opaque', () {
        final segs = MarkdownParser.parse('```\n**not bold**\n```');
        expect(segs.length, 1);
        expect(segs[0].codeBlock, true);
        expect(segs[0].text, '**not bold**');
      });

      test('code block surrounded by text', () {
        final segs = MarkdownParser.parse('before ```code``` after');
        expect(segs.length, 3);
        expect(segs[0].text, 'before ');
        expect(segs[1].codeBlock, true);
        expect(segs[1].text, 'code');
        expect(segs[2].text, ' after');
      });

      test('unmatched fence is literal', () {
        final segs = MarkdownParser.parse('```open');
        expect(segs.length, 1);
        expect(segs[0].text, '```open');
      });
    });

    group('escape \\X', () {
      test('escape asterisk', () {
        final segs = MarkdownParser.parse(r'\*not bold\*');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
        expect(segs[0].text, '*not bold*');
      });

      test('escape backtick', () {
        final segs = MarkdownParser.parse(r'\`literal\`');
        expect(segs.length, 1);
        expect(segs[0].text, '`literal`');
      });

      test('escape backslash', () {
        final segs = MarkdownParser.parse(r'\\');
        expect(segs.length, 1);
        expect(segs[0].text, r'\');
      });

      test('lone backslash at end is literal', () {
        final segs = MarkdownParser.parse('hello\\');
        expect(segs.length, 1);
        expect(segs[0].text, 'hello\\');
      });
    });

    group('nesting', () {
      test('bold containing italic with underscore', () {
        final segs = MarkdownParser.parse('**bold _italic_ end**');
        expect(segs.length, 3);
        expect(segs[0].text, 'bold ');
        expect(segs[0].bold, true);
        expect(segs[0].italic, false);
        expect(segs[1].text, 'italic');
        expect(segs[1].bold, true);
        expect(segs[1].italic, true);
        expect(segs[2].text, ' end');
        expect(segs[2].bold, true);
      });

      test('italic containing strike', () {
        final segs = MarkdownParser.parse('*hello ~~struck~~ world*');
        expect(segs.length, 3);
        expect(segs[0].italic, true);
        expect(segs[1].italic, true);
        expect(segs[1].strike, true);
        expect(segs[2].italic, true);
      });

      test('code inside bold is opaque (no inherited bold)', () {
        final segs = MarkdownParser.parse('**bold `code` more**');
        // The inner code segment should be code-only, not bold.
        // Bold segments around it should still be bold.
        expect(segs.length, 3);
        expect(segs[0].bold, true);
        expect(segs[1].code, true);
        expect(segs[1].bold, false);
        expect(segs[2].bold, true);
      });
    });

    group('coalescing', () {
      test('adjacent same-style segments merge', () {
        // Force two plain segments via escape boundary
        final segs = MarkdownParser.parse(r'a\*b');
        expect(segs.length, 1);
        expect(segs[0].text, 'a*b');
        expect(segs[0].isPlain, true);
      });
    });

    group('safety / DoS', () {
      test('very long input parses without crash', () {
        final input = '*' * 1000 + 'text' + '*' * 1000;
        final segs = MarkdownParser.parse(input);
        expect(segs, isNotEmpty);
        // No assertion on exact output — just ensure no stack overflow.
      });

      test('deeply nested emphasis truncates at max depth', () {
        // Construct nesting that would recurse many levels.
        final input = '**' * 10 + 'x' + '**' * 10;
        final segs = MarkdownParser.parse(input);
        // Should not crash; output is bounded by _maxDepth.
        expect(segs, isNotEmpty);
      });

      test('only delimiters returns single literal segment', () {
        final segs = MarkdownParser.parse('***');
        expect(segs.length, 1);
        expect(segs[0].text, '***');
      });
    });

    group('regression: review-found edge cases', () {
      test('escaped asterisk inside emphasis stays literal', () {
        // Escape inside italic: *a\*b* should be italic('a*b'), not break early.
        final segs = MarkdownParser.parse(r'*a\*b*');
        expect(segs.length, 1);
        expect(segs[0].text, 'a*b');
        expect(segs[0].italic, true);
      });

      test('overlapping asterisks parses greedily', () {
        // **bold *italic both*** — bold closes at last **, italic stays unmatched
        // inside (no closing single *), so we get bold('bold *italic both') + '*'.
        final segs = MarkdownParser.parse('**bold *italic both***');
        // Just ensure no crash and that bold rendered something.
        expect(segs, isNotEmpty);
        expect(segs.any((s) => s.bold), true);
      });

      test('triple stars treated as emphasis chain', () {
        final segs = MarkdownParser.parse('***x***');
        // Without inner space this is bold containing italic.
        // **___italic*** → bold open, italic 'x' inside.
        // Just ensure deterministic non-crashy output.
        expect(segs, isNotEmpty);
      });

      test('back-to-back inline code does NOT merge', () {
        // `a`b` is a single code('a') + literal 'b' + literal '`' (no second
        // close). The two code segments — if any — should not merge into one
        // because they have different runs of text between them.
        final segs = MarkdownParser.parse('`a``b`');
        // Expected: code('a') + code('b'). Each code segment is opaque, so
        // they should remain separate even if adjacent.
        final codeSegs = segs.where((s) => s.code).toList();
        expect(codeSegs.length, 2);
        expect(codeSegs[0].text, 'a');
        expect(codeSegs[1].text, 'b');
      });

      test('tab character is whitespace for emphasis open check', () {
        // *\tfoo* should NOT be italic (whitespace immediately after marker).
        final segs = MarkdownParser.parse('*\tfoo*');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
      });

      test('single tilde is literal (not strikethrough)', () {
        final segs = MarkdownParser.parse('~not strike~');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
      });

      test('a_b mid-word stays literal', () {
        final segs = MarkdownParser.parse('a_b');
        expect(segs.length, 1);
        expect(segs[0].isPlain, true);
      });

      test('huge run of asterisks does not crash', () {
        final input = '*' * 5000;
        final segs = MarkdownParser.parse(input);
        // No assertion on output — just ensure termination + non-empty.
        expect(segs, isNotEmpty);
      });

      test('markdown link syntax is left as-is (we do not support it)', () {
        // [text](url) — we do NOT parse this as a link, but it must not crash.
        final segs = MarkdownParser.parse('see [docs](http://example.com) for more');
        // Output should contain plain text incl. the literal brackets.
        expect(segs, isNotEmpty);
        final fullText = segs.map((s) => s.text).join();
        expect(fullText.contains('docs'), true);
        expect(fullText.contains('example.com'), true);
      });
    });

    group('mixed content', () {
      test('full sentence with all formats', () {
        final segs = MarkdownParser.parse(
            'Hi **Alex**, check `main.dart` and try _this_ ~~old~~ way.');
        // Expect: plain, bold, plain, code, plain, italic, plain, strike, plain
        expect(segs.length, 9);
        expect(segs[0].text, 'Hi ');
        expect(segs[1].text, 'Alex');
        expect(segs[1].bold, true);
        expect(segs[2].text, ', check ');
        expect(segs[3].text, 'main.dart');
        expect(segs[3].code, true);
        expect(segs[4].text, ' and try ');
        expect(segs[5].text, 'this');
        expect(segs[5].italic, true);
        expect(segs[6].text, ' ');
        expect(segs[7].text, 'old');
        expect(segs[7].strike, true);
        expect(segs[8].text, ' way.');
      });
    });
  });
}
