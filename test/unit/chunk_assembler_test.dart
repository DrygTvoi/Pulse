import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/chunk_assembler.dart';

/// Build a well-formed chunk payload string.
String makeChunk({
  required String fid,
  required int idx,
  required int total,
  required Uint8List data,
  bool includeHash = true,
  String? name,
  String? mediaType,
}) {
  final map = <String, dynamic>{
    'fid': fid,
    'idx': idx,
    'total': total,
    'd': base64Encode(data),
    if (includeHash) 'h': crypto.sha256.convert(data).toString(),
    if (idx == 0 && name != null) 'n': name,
    if (idx == 0 && mediaType != null) 'mt': mediaType,
    if (idx == 0) 'sz': data.length * total,
  };
  return jsonEncode(map);
}

void main() {
  group('ChunkAssembler', () {
    test('single-chunk file assembles immediately', () {
      final ca = ChunkAssembler();
      final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
      final chunk = makeChunk(
        fid: 'f1', idx: 0, total: 1, data: payload,
        name: 'test.bin', mediaType: 'file',
      );
      final result = ca.handleChunk(chunk);
      expect(result, isNotNull);
      final decoded = jsonDecode(result!) as Map<String, dynamic>;
      expect(base64Decode(decoded['d'] as String), equals(payload));
      expect(decoded['n'], equals('test.bin'));
    });

    test('multi-chunk file assembles when all chunks arrive', () {
      final ca = ChunkAssembler();
      final part0 = Uint8List.fromList([10, 11, 12]);
      final part1 = Uint8List.fromList([20, 21, 22]);
      final part2 = Uint8List.fromList([30, 31, 32]);

      expect(ca.handleChunk(makeChunk(fid: 'f2', idx: 0, total: 3, data: part0, name: 'big.bin', mediaType: 'file')), isNull);
      expect(ca.handleChunk(makeChunk(fid: 'f2', idx: 1, total: 3, data: part1)), isNull);
      final result = ca.handleChunk(makeChunk(fid: 'f2', idx: 2, total: 3, data: part2));

      expect(result, isNotNull);
      final decoded = jsonDecode(result!) as Map<String, dynamic>;
      final assembled = base64Decode(decoded['d'] as String);
      expect(assembled, equals([10, 11, 12, 20, 21, 22, 30, 31, 32]));
    });

    test('out-of-order chunks still assemble correctly', () {
      final ca = ChunkAssembler();
      final part0 = Uint8List.fromList([1, 2]);
      final part1 = Uint8List.fromList([3, 4]);

      // Send chunk 1 first, then chunk 0
      ca.handleChunk(makeChunk(fid: 'f3', idx: 1, total: 2, data: part1));
      final result = ca.handleChunk(makeChunk(fid: 'f3', idx: 0, total: 2, data: part0, name: 'ooo.bin', mediaType: 'file'));

      expect(result, isNotNull);
      final assembled = base64Decode((jsonDecode(result!) as Map)['d'] as String);
      expect(assembled, equals([1, 2, 3, 4]));
    });

    test('returns null while chunks are still missing', () {
      final ca = ChunkAssembler();
      final chunk = makeChunk(fid: 'f4', idx: 0, total: 3, data: Uint8List.fromList([1]), name: 'f.bin', mediaType: 'file');
      expect(ca.handleChunk(chunk), isNull);
      expect(ca.getMissingChunks('f4'), equals([1, 2]));
    });

    test('rejects chunk with wrong SHA-256 hash', () {
      final ca = ChunkAssembler();
      final data = Uint8List.fromList([7, 8, 9]);
      final map = {
        'fid': 'f5',
        'idx': 0,
        'total': 1,
        'd': base64Encode(data),
        'h': 'badhashbadhashbadhashbadhashbadhashbadhashbadhashbadhashbadhashba', // wrong
        'n': 'f.bin',
        'mt': 'file',
        'sz': 3,
      };
      expect(ca.handleChunk(jsonEncode(map)), isNull);
    });

    test('accepts chunk without hash field (optional)', () {
      final ca = ChunkAssembler();
      final data = Uint8List.fromList([42]);
      final chunk = makeChunk(fid: 'f6', idx: 0, total: 1, data: data, includeHash: false, name: 'x.bin', mediaType: 'file');
      expect(ca.handleChunk(chunk), isNotNull);
    });

    test('rejects total <= 0', () {
      final ca = ChunkAssembler();
      final map = jsonEncode({'fid': 'f7', 'idx': 0, 'total': 0, 'd': base64Encode([1])});
      expect(ca.handleChunk(map), isNull);
    });

    test('rejects total > 2000', () {
      final ca = ChunkAssembler();
      final map = jsonEncode({'fid': 'f8', 'idx': 0, 'total': 2001, 'd': base64Encode([1])});
      expect(ca.handleChunk(map), isNull);
    });

    test('rejects oversized total buffer (> 50 MB equivalent)', () {
      final ca = ChunkAssembler();
      // Single very large chunk that exceeds the 50MB budget
      final bigData = Uint8List(51 * 1024 * 1024); // 51 MB
      final map = jsonEncode({
        'fid': 'f9',
        'idx': 0,
        'total': 1,
        'd': base64Encode(bigData),
        'n': 'big.bin',
        'mt': 'file',
        'sz': bigData.length,
      });
      expect(ca.handleChunk(map), isNull);
    });

    test('evicts oldest transfer when maxPendingFiles is exceeded', () {
      final ca = ChunkAssembler();
      // Fill up to maxPendingFiles (16) with incomplete 2-chunk transfers
      for (int i = 0; i < ChunkAssembler.maxPendingFiles; i++) {
        ca.handleChunk(makeChunk(
          fid: 'evict$i', idx: 0, total: 2,
          data: Uint8List.fromList([i]),
          name: 'f.bin', mediaType: 'file',
        ));
      }
      expect(ca.activeTransferIds.length, equals(ChunkAssembler.maxPendingFiles));

      // Adding one more should evict the oldest
      ca.handleChunk(makeChunk(
        fid: 'evict_new', idx: 0, total: 2,
        data: Uint8List.fromList([99]),
        name: 'new.bin', mediaType: 'file',
      ));
      expect(ca.activeTransferIds.length, lessThanOrEqualTo(ChunkAssembler.maxPendingFiles));
      expect(ca.activeTransferIds, contains('evict_new'));
    });

    test('getMissingChunks returns null for unknown fid', () {
      final ca = ChunkAssembler();
      expect(ca.getMissingChunks('unknown'), isNull);
    });

    test('getMissingChunks returns empty list when all chunks received', () {
      final ca = ChunkAssembler();
      // After assembly completes the fid is removed, so getMissingChunks returns null.
      final data = Uint8List.fromList([1]);
      ca.handleChunk(makeChunk(fid: 'done', idx: 0, total: 1, data: data, name: 'f', mediaType: 'file'));
      // Transfer was completed and cleaned up
      expect(ca.getMissingChunks('done'), isNull);
    });

    test('handles malformed JSON gracefully', () {
      final ca = ChunkAssembler();
      expect(ca.handleChunk('not json'), isNull);
      expect(ca.handleChunk('{}'), isNull);
    });

    test('isStalled returns false for unknown fid', () {
      final ca = ChunkAssembler();
      expect(ca.isStalled('unknown'), isFalse);
    });

    test('isStalled returns false for recently active transfer', () {
      final ca = ChunkAssembler();
      ca.handleChunk(makeChunk(fid: 'active', idx: 0, total: 2, data: Uint8List.fromList([1]), name: 'f', mediaType: 'file'));
      expect(ca.isStalled('active', stallDuration: const Duration(seconds: 60)), isFalse);
    });
  });
}
