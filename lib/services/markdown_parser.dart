/// Inline markdown parser for chat-bubble messages.
///
/// Supports:
///   `**bold**`, `*italic*`, `_italic_`, `~~strike~~`, `` `code` ``,
///   ``` ```code blocks``` ```, escape with `\`.
///
/// Code segments are opaque — no nested formatting, no URL detection inside.
/// Emphasis (bold/italic/strike) requires non-whitespace adjacent to the
/// delimiter (so `2 * 3 = 6` does not become italic). Underscore italic also
/// requires word boundaries (so `snake_case_var` stays literal).
///
/// Unmatched delimiters render as literal text.
class MdSegment {
  final String text;
  final bool bold;
  final bool italic;
  final bool strike;
  final bool code; // inline `code`
  final bool codeBlock; // ```fenced```

  const MdSegment({
    required this.text,
    this.bold = false,
    this.italic = false,
    this.strike = false,
    this.code = false,
    this.codeBlock = false,
  });

  bool get isCode => code || codeBlock;
  bool get isPlain =>
      !bold && !italic && !strike && !code && !codeBlock;

  @override
  bool operator ==(Object other) =>
      other is MdSegment &&
      other.text == text &&
      other.bold == bold &&
      other.italic == italic &&
      other.strike == strike &&
      other.code == code &&
      other.codeBlock == codeBlock;

  @override
  int get hashCode =>
      Object.hash(text, bold, italic, strike, code, codeBlock);

  @override
  String toString() {
    final flags = [
      if (bold) 'B',
      if (italic) 'I',
      if (strike) 'S',
      if (code) 'C',
      if (codeBlock) 'CB',
    ].join();
    return 'MdSegment[${flags.isEmpty ? '-' : flags}]($text)';
  }
}

class MarkdownParser {
  // Hard recursion limit. Chat messages don't need deep nesting and unbounded
  // recursion would be a DoS vector on malicious input.
  static const _maxDepth = 4;

  /// Parse [input] into a flat list of styled segments.
  static List<MdSegment> parse(String input) {
    if (input.isEmpty) return const [];
    if (!_hasAnyDelimiter(input)) {
      return [MdSegment(text: input)];
    }
    final out = <MdSegment>[];
    _parseInto(input, const _Style(), 0, out);
    return _coalesce(out);
  }

  static bool _hasAnyDelimiter(String s) {
    for (int i = 0; i < s.length; i++) {
      final c = s.codeUnitAt(i);
      // *=42 _=95 `=96 ~=126 \=92
      if (c == 42 || c == 95 || c == 96 || c == 126 || c == 92) return true;
    }
    return false;
  }

  static void _parseInto(
      String input, _Style parent, int depth, List<MdSegment> out) {
    if (input.isEmpty) return;
    if (depth > _maxDepth) {
      out.add(parent.toSegment(input));
      return;
    }

    final buf = StringBuffer();
    int i = 0;
    final n = input.length;

    void flush() {
      if (buf.isNotEmpty) {
        out.add(parent.toSegment(buf.toString()));
        buf.clear();
      }
    }

    while (i < n) {
      final ch = input[i];

      // Escape: \X → literal X (works for any next char).
      if (ch == '\\' && i + 1 < n) {
        buf.write(input[i + 1]);
        i += 2;
        continue;
      }

      // ```fenced code block``` — opaque, allows newlines.
      if (i + 2 < n && ch == '`' && input[i + 1] == '`' && input[i + 2] == '`') {
        final close = _findFenceClose(input, i + 3);
        if (close != -1) {
          var content = input.substring(i + 3, close);
          // Trim a single leading/trailing newline so ``` \n code \n ``` looks
          // clean. Don't trim spaces — preserve indentation inside the block.
          if (content.startsWith('\n')) content = content.substring(1);
          if (content.endsWith('\n')) {
            content = content.substring(0, content.length - 1);
          }
          if (content.isNotEmpty) {
            flush();
            out.add(MdSegment(text: content, codeBlock: true));
          }
          i = close + 3;
          continue;
        }
      }

      // `inline code` — opaque, single-line only.
      if (ch == '`') {
        final close = _findInlineCodeClose(input, i + 1);
        if (close != -1 && close > i + 1) {
          flush();
          out.add(MdSegment(text: input.substring(i + 1, close), code: true));
          i = close + 1;
          continue;
        }
      }

      // **bold**
      if (i + 1 < n && ch == '*' && input[i + 1] == '*' && !parent.bold) {
        if (_isEmphasisOpenChar(input, i + 2)) {
          final close = _findEmphasisClose(input, i + 2, '**');
          if (close > i + 2) {
            flush();
            _parseInto(input.substring(i + 2, close),
                parent.copyWith(bold: true), depth + 1, out);
            i = close + 2;
            continue;
          }
        }
      }

      // *italic* — but never if this is the first char of '**' or part of math.
      if (ch == '*' && !parent.italic) {
        final isStartOfBold = (i + 1 < n && input[i + 1] == '*');
        if (!isStartOfBold && _isEmphasisOpenChar(input, i + 1)) {
          final close = _findEmphasisClose(input, i + 1, '*');
          if (close > i + 1) {
            flush();
            _parseInto(input.substring(i + 1, close),
                parent.copyWith(italic: true), depth + 1, out);
            i = close + 1;
            continue;
          }
        }
      }

      // _italic_ — word-boundary on open, non-whitespace before close.
      if (ch == '_' && !parent.italic && _isUnderscoreOpen(input, i)) {
        final close = _findUnderscoreClose(input, i + 1);
        if (close > i + 1) {
          flush();
          _parseInto(input.substring(i + 1, close),
              parent.copyWith(italic: true), depth + 1, out);
          i = close + 1;
          continue;
        }
      }

      // ~~strike~~
      if (i + 1 < n && ch == '~' && input[i + 1] == '~' && !parent.strike) {
        if (_isEmphasisOpenChar(input, i + 2)) {
          final close = _findEmphasisClose(input, i + 2, '~~');
          if (close > i + 2) {
            flush();
            _parseInto(input.substring(i + 2, close),
                parent.copyWith(strike: true), depth + 1, out);
            i = close + 2;
            continue;
          }
        }
      }

      // Regular character — accumulate.
      buf.write(ch);
      i++;
    }

    flush();
  }

  static int _findFenceClose(String input, int from) {
    final n = input.length;
    for (int j = from; j + 2 < n; j++) {
      if (input[j] == '`' && input[j + 1] == '`' && input[j + 2] == '`') {
        return j;
      }
    }
    return -1;
  }

  static int _findInlineCodeClose(String input, int from) {
    final n = input.length;
    for (int j = from; j < n; j++) {
      // Inline code does NOT span newlines.
      if (input[j] == '\n') return -1;
      if (input[j] == '`') return j;
    }
    return -1;
  }

  static int _findEmphasisClose(String input, int from, String marker) {
    final n = input.length;
    final mlen = marker.length;
    for (int j = from; j <= n - mlen; j++) {
      // Skip over escaped chars.
      if (input[j] == '\\') {
        j++;
        continue;
      }
      if (!_startsWithAt(input, marker, j)) continue;
      // Char immediately before marker must be non-whitespace.
      if (j == 0) return -1;
      final before = input[j - 1];
      if (_isWhitespace(before)) continue;
      return j;
    }
    return -1;
  }

  static bool _isEmphasisOpenChar(String input, int at) {
    if (at >= input.length) return false;
    final c = input[at];
    return !_isWhitespace(c);
  }

  static bool _isUnderscoreOpen(String input, int i) {
    // Char immediately after must exist and be non-underscore non-whitespace.
    if (i + 1 >= input.length) return false;
    final next = input[i + 1];
    if (next == '_' || _isWhitespace(next)) return false;
    // Char immediately before must be start-of-string, whitespace, or punctuation.
    // This prevents `snake_case_var` from being parsed.
    if (i == 0) return true;
    final prev = input[i - 1];
    return _isWhitespace(prev) || _isPunctuation(prev);
  }

  static int _findUnderscoreClose(String input, int from) {
    final n = input.length;
    for (int j = from; j < n; j++) {
      if (input[j] == '\\') {
        j++;
        continue;
      }
      if (input[j] != '_') continue;
      if (j == 0) return -1;
      // Char before must be non-whitespace.
      if (_isWhitespace(input[j - 1])) continue;
      // Char after must NOT be a word character (else inside snake_case).
      if (j + 1 < n && _isWordChar(input[j + 1])) continue;
      return j;
    }
    return -1;
  }

  static bool _startsWithAt(String input, String marker, int at) {
    final mlen = marker.length;
    if (at + mlen > input.length) return false;
    for (int k = 0; k < mlen; k++) {
      if (input[at + k] != marker[k]) return false;
    }
    return true;
  }

  static bool _isWhitespace(String c) {
    if (c.isEmpty) return false;
    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
  }

  static bool _isPunctuation(String c) {
    if (c.isEmpty) return false;
    // Common ASCII punctuation that may legitimately precede emphasis.
    const punct = '.,;:!?()[]{}<>"\'\u2014\u2013-/\\@#\$%^&|+=';
    return punct.contains(c);
  }

  static bool _isWordChar(String c) {
    if (c.isEmpty) return false;
    final code = c.codeUnitAt(0);
    return (code >= 48 && code <= 57) || // 0-9
        (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        code == 95; // _
  }

  /// Merge adjacent identical-style segments to keep the list compact. Code
  /// segments are NEVER merged — each `` `a` `` `` `b` `` is the user's
  /// deliberate choice and should render as two separate boxes, not one.
  static List<MdSegment> _coalesce(List<MdSegment> segs) {
    if (segs.length < 2) return segs;
    final out = <MdSegment>[];
    for (final s in segs) {
      if (out.isEmpty) {
        out.add(s);
        continue;
      }
      final last = out.last;
      // Don't merge code — it's an opaque visual unit.
      if (last.isCode || s.isCode) {
        out.add(s);
        continue;
      }
      if (last.bold == s.bold &&
          last.italic == s.italic &&
          last.strike == s.strike) {
        out[out.length - 1] = MdSegment(
          text: last.text + s.text,
          bold: last.bold,
          italic: last.italic,
          strike: last.strike,
        );
      } else {
        out.add(s);
      }
    }
    return out;
  }
}

class _Style {
  final bool bold;
  final bool italic;
  final bool strike;

  const _Style({this.bold = false, this.italic = false, this.strike = false});

  _Style copyWith({bool? bold, bool? italic, bool? strike}) => _Style(
        bold: bold ?? this.bold,
        italic: italic ?? this.italic,
        strike: strike ?? this.strike,
      );

  MdSegment toSegment(String text) =>
      MdSegment(text: text, bold: bold, italic: italic, strike: strike);
}
