import 'package:flutter_test/flutter_test.dart';

// ── Pure logic extracted from VoiceService ────────────────────────────────────
//
// VoiceService._resample() is a private static method. We mirror it here
// exactly so its logic can be tested without touching the microphone, the
// file system, or path_provider (all of which are not available in unit tests).
//
// The implementation is identical to lib/services/voice_service.dart's
// _resample() — if the production function changes, update this mirror too.

/// Resample [src] to [targetLen] values using linear interpolation.
/// When [src] is empty, returns a list of [targetLen] × 0.1 (silence placeholders).
List<double> resample(List<double> src, int targetLen) {
  if (src.isEmpty) return List.filled(targetLen, 0.1);
  if (src.length == targetLen) return List<double>.from(src);
  final out = <double>[];
  for (int i = 0; i < targetLen; i++) {
    final pos = i * (src.length - 1) / (targetLen - 1);
    final lo = pos.floor().clamp(0, src.length - 1);
    final hi = pos.ceil().clamp(0, src.length - 1);
    final frac = pos - lo;
    out.add(src[lo] * (1 - frac) + src[hi] * frac);
  }
  return out;
}

// ── Amplitude normalisation (mirrors the timer callback in startRecording) ──
//
// dBFS → [0, 1]:  norm = ((current + 60) / 60).clamp(0, 1)
double normaliseDbfs(double dbfs) => ((dbfs + 60.0) / 60.0).clamp(0.0, 1.0);

// ── Integer encoding (mirrors stopRecording's amp encoding step) ─────────────
//
// Converts a normalised amplitude value to an integer percentage 0-100.
int encodeAmpInt(double norm) => (norm * 100).round();

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── _resample: output length ─────────────────────────────────────────────

  group('resample: output length', () {
    test('always produces exactly targetLen values', () {
      expect(resample([0.1, 0.5, 0.9], 30).length, 30);
      expect(resample(List.filled(100, 0.5), 30).length, 30);
      expect(resample([0.3], 30).length, 30);
      expect(resample([], 30).length, 30);
    });

    test('no-op when src.length == targetLen', () {
      final src = [0.1, 0.4, 0.7, 0.9];
      expect(resample(src, 4), equals(src));
    });

    test('targetLen of 1 with single-element src returns that element', () {
      // Production guards: if src.length == targetLen, returns src directly.
      // So resample([0.75], 1) takes the identity path, no division occurs.
      final result = resample([0.75], 1);
      expect(result.length, 1);
      expect(result.first, closeTo(0.75, 1e-10));
    });
  });

  // ── _resample: empty input ───────────────────────────────────────────────

  group('resample: empty input', () {
    test('empty src yields silence placeholders (0.1)', () {
      final result = resample([], 30);
      expect(result.length, 30);
      expect(result.every((v) => v == 0.1), isTrue);
    });

    test('empty src with targetLen=1 yields [0.1]', () {
      expect(resample([], 1), [0.1]);
    });
  });

  // ── _resample: endpoints ─────────────────────────────────────────────────

  group('resample: boundary interpolation', () {
    test('first output value equals first src value (no extrapolation)', () {
      final src = [0.2, 0.5, 0.8];
      expect(resample(src, 10).first, closeTo(src.first, 1e-10));
    });

    test('last output value equals last src value (no extrapolation)', () {
      final src = [0.2, 0.5, 0.8];
      expect(resample(src, 10).last, closeTo(src.last, 1e-10));
    });

    test('single-sample src fills every output with that value', () {
      final result = resample([0.75], 30);
      expect(result.every((v) => (v - 0.75).abs() < 1e-10), isTrue,
          reason: 'single input should replicate to all outputs');
    });
  });

  // ── _resample: interpolation quality ────────────────────────────────────

  group('resample: linear interpolation correctness', () {
    test('midpoint of two-value src gives their average (upsample 2→3)', () {
      // With src=[0.0, 1.0] and targetLen=3:
      //   i=0 → pos=0.0, out=0.0
      //   i=1 → pos=0.5, out=0.5
      //   i=2 → pos=1.0, out=1.0
      final result = resample([0.0, 1.0], 3);
      expect(result[0], closeTo(0.0, 1e-10));
      expect(result[1], closeTo(0.5, 1e-10));
      expect(result[2], closeTo(1.0, 1e-10));
    });

    test('upsample preserves monotonicity for monotone src', () {
      final src = [0.1, 0.3, 0.6, 0.9];
      final result = resample(src, 20);
      for (int i = 1; i < result.length; i++) {
        expect(result[i], greaterThanOrEqualTo(result[i - 1]),
            reason: 'upsampled monotone signal should stay monotone at index $i');
      }
    });

    test('downsample 30→5 keeps first and last values', () {
      final src = List.generate(30, (i) => i / 29.0);
      final result = resample(src, 5);
      expect(result.first, closeTo(0.0, 1e-10));
      expect(result.last, closeTo(1.0, 1e-10));
    });

    test('all-zeros src yields all-zeros output', () {
      final result = resample(List.filled(20, 0.0), 30);
      expect(result.every((v) => v == 0.0), isTrue);
    });

    test('all-ones src yields all-ones output', () {
      final result = resample(List.filled(15, 1.0), 30);
      expect(result.every((v) => (v - 1.0).abs() < 1e-10), isTrue);
    });

    test('output values are always in [0.0, 1.0] for normalised input', () {
      // Verify no extrapolation produces out-of-range values.
      final src = [0.0, 0.5, 1.0, 0.3, 0.8];
      final result = resample(src, 30);
      for (final v in result) {
        expect(v, inInclusiveRange(0.0, 1.0),
            reason: 'interpolated value $v should stay in [0, 1]');
      }
    });

    test('upsample 2→30 produces 30 strictly increasing values for ramp', () {
      final result = resample([0.0, 1.0], 30);
      for (int i = 1; i < result.length; i++) {
        expect(result[i], greaterThan(result[i - 1]),
            reason: 'ramp upsampled at index $i should still increase');
      }
    });
  });

  // ── _resample: round-trip identity ──────────────────────────────────────

  group('resample: same-length identity', () {
    test('resample to same length is exact copy', () {
      final src = [0.1, 0.4, 0.9, 0.2, 0.7];
      expect(resample(src, src.length), equals(src));
    });

    test('resample works with targetLen larger than 256', () {
      final src = List.generate(5, (i) => i * 0.25);
      final result = resample(src, 300);
      expect(result.length, 300);
      expect(result.first, closeTo(src.first, 1e-10));
      expect(result.last, closeTo(src.last, 1e-10));
    });
  });

  // ── Amplitude normalisation: dBFS → [0, 1] ──────────────────────────────

  group('normaliseDbfs', () {
    test('silence floor (-60 dBFS) normalises to 0.0', () {
      expect(normaliseDbfs(-60.0), closeTo(0.0, 1e-10));
    });

    test('full scale (0 dBFS) normalises to 1.0', () {
      expect(normaliseDbfs(0.0), closeTo(1.0, 1e-10));
    });

    test('mid-range (-30 dBFS) normalises to 0.5', () {
      expect(normaliseDbfs(-30.0), closeTo(0.5, 1e-10));
    });

    test('below floor (< -60 dBFS) clamps to 0.0', () {
      expect(normaliseDbfs(-80.0), closeTo(0.0, 1e-10));
      expect(normaliseDbfs(-100.0), closeTo(0.0, 1e-10));
    });

    test('above full scale (> 0 dBFS) clamps to 1.0', () {
      expect(normaliseDbfs(3.0), closeTo(1.0, 1e-10));
      expect(normaliseDbfs(10.0), closeTo(1.0, 1e-10));
    });

    test('normalised value is always in [0.0, 1.0] for any dBFS', () {
      for (final dbfs in [-120.0, -60.0, -30.0, -10.0, 0.0, 6.0]) {
        final v = normaliseDbfs(dbfs);
        expect(v, inInclusiveRange(0.0, 1.0),
            reason: 'normaliseDbfs($dbfs) = $v outside [0,1]');
      }
    });
  });

  // ── Integer encoding: norm → int percentage ──────────────────────────────

  group('encodeAmpInt', () {
    test('0.0 encodes to 0', () {
      expect(encodeAmpInt(0.0), 0);
    });

    test('1.0 encodes to 100', () {
      expect(encodeAmpInt(1.0), 100);
    });

    test('0.5 encodes to 50', () {
      expect(encodeAmpInt(0.5), 50);
    });

    test('values are rounded, not truncated', () {
      // 0.456 * 100 = 45.6 → rounds to 46
      expect(encodeAmpInt(0.456), 46);
      // 0.454 * 100 = 45.4 → rounds to 45
      expect(encodeAmpInt(0.454), 45);
    });

    test('full pipeline: dBFS → norm → int stays in [0, 100]', () {
      for (final dbfs in [-120.0, -60.0, -45.0, -30.0, -10.0, 0.0, 6.0]) {
        final norm = normaliseDbfs(dbfs);
        final encoded = encodeAmpInt(norm);
        expect(encoded, inInclusiveRange(0, 100),
            reason: 'encoded value $encoded for dBFS=$dbfs is out of [0,100]');
      }
    });
  });

  // ── Integration: resample + encode pipeline ──────────────────────────────

  group('waveform pipeline integration', () {
    test('30-bar waveform from raw amplitude samples has correct shape', () {
      // Simulate a recording with 45 amplitude samples at varying levels.
      final rawSamples = <double>[];
      for (int i = 0; i < 45; i++) {
        rawSamples.add(i / 44.0); // ramp 0→1
      }

      final bars = resample(rawSamples, 30);
      final encoded = bars.map(encodeAmpInt).toList();

      expect(encoded.length, 30);
      // Ramp: first bar near 0, last bar near 100
      expect(encoded.first, lessThan(10));
      expect(encoded.last, greaterThan(90));
      // All values in valid JSON-safe range
      expect(encoded.every((v) => v >= 0 && v <= 100), isTrue);
    });

    test('silence recording produces near-zero waveform', () {
      final rawSamples = List.filled(20, 0.0); // silence
      final bars = resample(rawSamples, 30);
      final encoded = bars.map(encodeAmpInt).toList();
      expect(encoded.every((v) => v == 0), isTrue);
    });

    test('empty recording produces silence-placeholder waveform', () {
      // No samples collected (recording cancelled immediately).
      final bars = resample([], 30);
      final encoded = bars.map(encodeAmpInt).toList();
      // 0.1 * 100 = 10
      expect(encoded.every((v) => v == 10), isTrue);
    });

    test('clipping is prevented end-to-end', () {
      // Simulate clipping above 0 dBFS — normalise first, then resample.
      final rawDbfs = [-80.0, -20.0, 0.0, 3.0, -10.0];
      final normalised = rawDbfs.map(normaliseDbfs).toList();
      final bars = resample(normalised, 30);
      expect(bars.every((v) => v >= 0.0 && v <= 1.0), isTrue,
          reason: 'no bar should exceed 1.0 after clamp');
    });
  });
}
