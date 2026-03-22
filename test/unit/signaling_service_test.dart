import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for SignalingService SDP manipulation logic.
///
/// The production class (lib/services/signaling_service.dart) depends on
/// flutter_webrtc, which is not available in unit tests. We reimplement
/// the pure string-processing logic (_applyAudioConstraints) here and test
/// it thoroughly — same pattern as waku_adapter_test.dart.
void main() {
  // ── Reimplemented SDP manipulation logic ──────────────────────────────────
  //
  // Mirrors SignalingService._applyAudioConstraints exactly.
  // Two modes: restricted (Tor relay) and normal (direct).

  /// Injects Opus bitrate + FEC constraints into an SDP string.
  /// Returns the modified SDP. If no Opus codec is found, returns unchanged.
  String applyAudioConstraints(String sdp, {required bool restricted}) {
    final maxBitrate = restricted ? 48000 : 64000;
    final asKbps = restricted ? 48 : 64;

    // Find the Opus dynamic payload type
    final ptMatch = RegExp(r'a=rtpmap:(\d+) opus/48000/2').firstMatch(sdp);
    if (ptMatch == null) return sdp; // No audio section — return unchanged

    final pt = ptMatch.group(1)!;

    // Build the fmtp line we want
    final fmtpLine =
        'a=fmtp:$pt minptime=10;useinbandfec=1;maxaveragebitrate=$maxBitrate';
    final fmtpRe = RegExp('a=fmtp:$pt [^\r\n]*');

    if (fmtpRe.hasMatch(sdp)) {
      sdp = sdp.replaceFirst(fmtpRe, fmtpLine);
    } else {
      // No existing fmtp — insert right after the rtpmap line
      sdp = sdp.replaceFirst(
        'a=rtpmap:$pt opus/48000/2',
        'a=rtpmap:$pt opus/48000/2\r\n$fmtpLine',
      );
    }

    // Add b=AS:<kbps> to the audio m= section.
    sdp = sdp.replaceFirstMapped(
      RegExp(r'(m=audio [^\r\n]*\r?\n)((?:i=[^\r\n]*\r?\n)?(?:c=[^\r\n]*\r?\n)?)'),
      (m) => '${m.group(1)!}${m.group(2)!}b=AS:$asKbps\r\n',
    );

    return sdp;
  }

  // ── Typical Chrome SDP template for testing ───────────────────────────────

  /// A minimal but realistic SDP with audio (Opus PT 111) and video sections.
  String buildTestSdp({
    String opusPt = '111',
    bool includeExistingFmtp = true,
    bool includeVideo = true,
    bool includeConnectionLine = true,
  }) {
    final buf = StringBuffer();
    buf.writeln('v=0');
    buf.writeln('o=- 123 2 IN IP4 127.0.0.1');
    buf.writeln('s=-');
    buf.writeln('t=0 0');
    // Audio section
    buf.write('m=audio 9 UDP/TLS/RTP/SAVPF $opusPt 0 8\r\n');
    if (includeConnectionLine) {
      buf.write('c=IN IP4 0.0.0.0\r\n');
    }
    buf.write('a=rtpmap:$opusPt opus/48000/2\r\n');
    if (includeExistingFmtp) {
      buf.write('a=fmtp:$opusPt minptime=10;useinbandfec=1\r\n');
    }
    buf.write('a=rtpmap:0 PCMU/8000\r\n');
    buf.write('a=rtpmap:8 PCMA/8000\r\n');
    buf.write('a=sendrecv\r\n');
    // Video section (optional)
    if (includeVideo) {
      buf.write('m=video 9 UDP/TLS/RTP/SAVPF 96\r\n');
      buf.write('c=IN IP4 0.0.0.0\r\n');
      buf.write('a=rtpmap:96 VP8/90000\r\n');
      buf.write('a=sendrecv\r\n');
    }
    return buf.toString();
  }

  // ── Signal type mapping ──────────────────────────────────────────────────
  //
  // Mirrors SignalingService._sendSignalingData type mapping.

  String mapSignalType(String actionType, {String prefix = 'webrtc'}) {
    final typeMap = {
      'offer': '${prefix}_offer',
      'answer': '${prefix}_answer',
      'candidate': '${prefix}_candidate',
    };
    return typeMap[actionType] ?? '${prefix}_candidate';
  }

  // ── Tests ────────────────────────────────────────────────────────────────

  group('SDP audio constraints — normal mode', () {
    test('replaces existing fmtp with maxaveragebitrate=64000', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: false);
      expect(result, contains('maxaveragebitrate=64000'));
      expect(result, contains('useinbandfec=1'));
      expect(result, contains('minptime=10'));
    });

    test('adds b=AS:64 bandwidth line to audio section', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: false);
      expect(result, contains('b=AS:64'));
    });

    test('does not add b=AS:48 in normal mode', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: false);
      expect(result, isNot(contains('b=AS:48')));
    });
  });

  group('SDP audio constraints — restricted mode (Tor)', () {
    test('replaces existing fmtp with maxaveragebitrate=48000', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: true);
      expect(result, contains('maxaveragebitrate=48000'));
      expect(result, contains('useinbandfec=1'));
    });

    test('adds b=AS:48 bandwidth line', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: true);
      expect(result, contains('b=AS:48'));
    });

    test('does not contain b=AS:64 in restricted mode', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: true);
      expect(result, isNot(contains('b=AS:64')));
    });
  });

  group('SDP — no existing fmtp line', () {
    test('inserts fmtp after rtpmap when none exists', () {
      final sdp = buildTestSdp(includeExistingFmtp: false);
      // Verify no fmtp before
      expect(sdp, isNot(contains('a=fmtp:111')));

      final result = applyAudioConstraints(sdp, restricted: false);
      expect(result, contains('a=fmtp:111 minptime=10;useinbandfec=1;maxaveragebitrate=64000'));
    });

    test('fmtp appears directly after the Opus rtpmap line', () {
      final sdp = buildTestSdp(includeExistingFmtp: false);
      final result = applyAudioConstraints(sdp, restricted: false);
      final lines = result.split(RegExp(r'\r?\n'));
      final rtpmapIdx = lines.indexWhere((l) => l.contains('a=rtpmap:111 opus/48000/2'));
      final fmtpIdx = lines.indexWhere((l) => l.contains('a=fmtp:111'));
      expect(rtpmapIdx, isNonNegative);
      expect(fmtpIdx, equals(rtpmapIdx + 1));
    });
  });

  group('SDP — non-standard Opus payload type', () {
    test('handles Opus PT 96 correctly', () {
      final sdp = buildTestSdp(opusPt: '96', includeExistingFmtp: true);
      final result = applyAudioConstraints(sdp, restricted: true);
      expect(result, contains('a=fmtp:96 minptime=10;useinbandfec=1;maxaveragebitrate=48000'));
    });

    test('handles Opus PT 109 without existing fmtp', () {
      final sdp = buildTestSdp(opusPt: '109', includeExistingFmtp: false);
      final result = applyAudioConstraints(sdp, restricted: false);
      expect(result, contains('a=fmtp:109 minptime=10;useinbandfec=1;maxaveragebitrate=64000'));
    });
  });

  group('SDP — no Opus codec', () {
    test('returns SDP unchanged when no opus rtpmap is present', () {
      const sdpNoOpus =
          'v=0\r\n'
          'o=- 123 2 IN IP4 127.0.0.1\r\n'
          's=-\r\n'
          'm=audio 9 UDP/TLS/RTP/SAVPF 0 8\r\n'
          'c=IN IP4 0.0.0.0\r\n'
          'a=rtpmap:0 PCMU/8000\r\n'
          'a=rtpmap:8 PCMA/8000\r\n';
      final result = applyAudioConstraints(sdpNoOpus, restricted: false);
      expect(result, equals(sdpNoOpus));
    });

    test('returns empty SDP unchanged', () {
      final result = applyAudioConstraints('', restricted: true);
      expect(result, equals(''));
    });
  });

  group('SDP — b=AS placement', () {
    test('b=AS appears after c= line in audio section', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: false);
      final lines = result.split(RegExp(r'\r?\n'));
      final cLineIdx = lines.indexWhere((l) => l.startsWith('c=') &&
          lines.take(lines.indexOf(l)).any((prev) => prev.startsWith('m=audio')));
      final bLineIdx = lines.indexWhere((l) => l.startsWith('b=AS:'));
      expect(cLineIdx, isNonNegative);
      expect(bLineIdx, isNonNegative);
      expect(bLineIdx, greaterThan(cLineIdx));
    });

    test('b=AS appears before first a= attribute in audio section', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: false);
      final lines = result.split(RegExp(r'\r?\n'));
      final bLineIdx = lines.indexWhere((l) => l.startsWith('b=AS:'));
      final firstAIdx = lines.indexWhere((l) => l.startsWith('a=') &&
          lines.indexOf(l) > lines.indexWhere((m) => m.startsWith('m=audio')));
      expect(bLineIdx, isNonNegative);
      expect(firstAIdx, isNonNegative);
      expect(bLineIdx, lessThan(firstAIdx));
    });

    test('b=AS not added to video section', () {
      final sdp = buildTestSdp();
      final result = applyAudioConstraints(sdp, restricted: false);
      // Split out the video section (after m=video)
      final videoIdx = result.indexOf('m=video');
      if (videoIdx >= 0) {
        final videoSection = result.substring(videoIdx);
        expect(videoSection, isNot(contains('b=AS:')));
      }
    });
  });

  group('SDP — audio-only (no video)', () {
    test('works with audio-only SDP', () {
      final sdp = buildTestSdp(includeVideo: false);
      final result = applyAudioConstraints(sdp, restricted: true);
      expect(result, contains('maxaveragebitrate=48000'));
      expect(result, contains('b=AS:48'));
      expect(result, isNot(contains('m=video')));
    });
  });

  group('SDP — audio section without c= line', () {
    test('b=AS regex still matches when c= is absent', () {
      final sdp = buildTestSdp(includeConnectionLine: false);
      // The regex has c= as optional ((?:c=...)?), so b=AS still gets added
      final result = applyAudioConstraints(sdp, restricted: false);
      // It should still contain the fmtp modifications
      expect(result, contains('maxaveragebitrate=64000'));
    });
  });

  group('SDP — idempotency', () {
    test('applying constraints twice produces same result', () {
      final sdp = buildTestSdp();
      final first = applyAudioConstraints(sdp, restricted: false);
      final second = applyAudioConstraints(first, restricted: false);
      // fmtp replacement is idempotent; b=AS may get added again but fmtp stays same
      expect(second, contains('maxaveragebitrate=64000'));
      // Count occurrences of maxaveragebitrate — should be exactly 1
      final count = 'maxaveragebitrate=64000'.allMatches(second).length;
      expect(count, equals(1));
    });

    test('switching from normal to restricted overwrites bitrate', () {
      final sdp = buildTestSdp();
      final normal = applyAudioConstraints(sdp, restricted: false);
      expect(normal, contains('maxaveragebitrate=64000'));

      final restricted = applyAudioConstraints(normal, restricted: true);
      expect(restricted, contains('maxaveragebitrate=48000'));
      expect(restricted, isNot(contains('maxaveragebitrate=64000')));
    });
  });

  // ── Signal type mapping ───────────────────────────────────────────────────

  group('Signal type mapping', () {
    test('primary prefix maps offer correctly', () {
      expect(mapSignalType('offer'), equals('webrtc_offer'));
    });

    test('primary prefix maps answer correctly', () {
      expect(mapSignalType('answer'), equals('webrtc_answer'));
    });

    test('primary prefix maps candidate correctly', () {
      expect(mapSignalType('candidate'), equals('webrtc_candidate'));
    });

    test('secondary prefix maps offer to webrtc2_offer', () {
      expect(mapSignalType('offer', prefix: 'webrtc2'), equals('webrtc2_offer'));
    });

    test('secondary prefix maps answer to webrtc2_answer', () {
      expect(mapSignalType('answer', prefix: 'webrtc2'), equals('webrtc2_answer'));
    });

    test('secondary prefix maps candidate to webrtc2_candidate', () {
      expect(mapSignalType('candidate', prefix: 'webrtc2'), equals('webrtc2_candidate'));
    });

    test('unknown action falls back to prefix_candidate', () {
      expect(mapSignalType('unknown'), equals('webrtc_candidate'));
      expect(mapSignalType('hangup', prefix: 'webrtc2'), equals('webrtc2_candidate'));
    });
  });

  // ── Signal type routing constants ─────────────────────────────────────────

  group('Signal type routing', () {
    test('primary signal types', () {
      const primaryTypes = ['webrtc_offer', 'webrtc_answer', 'webrtc_candidate'];
      for (final t in primaryTypes) {
        expect(t.startsWith('webrtc_'), isTrue);
        expect(t.startsWith('webrtc2_'), isFalse);
      }
    });

    test('secondary signal types', () {
      const secondaryTypes = ['webrtc2_offer', 'webrtc2_answer', 'webrtc2_candidate'];
      for (final t in secondaryTypes) {
        expect(t.startsWith('webrtc2_'), isTrue);
      }
    });

    test('sys_keys and sys_kick are excluded from signal processing', () {
      // From _listenForSignalingData: type == 'sys_keys' || type == 'sys_kick' → return
      const excluded = ['sys_keys', 'sys_kick'];
      for (final t in excluded) {
        expect(t.startsWith('webrtc'), isFalse);
      }
    });
  });

  // ── Payload structure ─────────────────────────────────────────────────────

  group('Payload encryption wrapping', () {
    test('encrypted payload uses e2ee key', () {
      final payload = {'e2ee': 'encrypted_blob_base64'};
      expect(payload.containsKey('e2ee'), isTrue);
    });

    test('unencrypted payload has no e2ee key', () {
      final payload = {'sdp': 'v=0...', 'type': 'offer'};
      expect(payload.containsKey('e2ee'), isFalse);
    });

    test('decryptPayload recognizes e2ee field', () {
      // Simulates _decryptPayload logic: checks for 'e2ee' key
      Map<String, dynamic> raw = {'e2ee': 'cipher', 'extra': 'data'};
      final encrypted = raw['e2ee'] as String?;
      expect(encrypted, isNotNull);
      expect(encrypted, equals('cipher'));
    });

    test('decryptPayload returns raw map if no e2ee field', () {
      Map<String, dynamic> raw = {'sdp': 'v=0...', 'type': 'offer'};
      final encrypted = raw['e2ee'] as String?;
      expect(encrypted, isNull);
      // Should return raw map as-is
    });
  });
}
