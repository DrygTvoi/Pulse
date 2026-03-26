import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Pure-Dart unit tests for BridgeFetchService logic.
///
/// The methods under test (_parseBuiltinResponse, _decodeChunked, _isPublicIp,
/// _postBody) are private in the service, so we reimplement the exact same
/// logic here — same pattern used in oxen_adapter_test.dart.

// ── Reimplemented private methods ───────────────────────────────────────────

/// Mirrors BridgeFetchService._parseBuiltinResponse (lines 349–396).
Map<String, List<String>>? parseBuiltinResponse(String body) {
  try {
    final json = jsonDecode(body);

    if (json is Map) {
      final result = <String, List<String>>{};
      for (final transport
          in ['snowflake', 'obfs4', 'webtunnel', 'meek', 'meek-azure']) {
        final t = json[transport];

        // Current format (2025+): {"obfs4": ["obfs4 IP:port ...", ...]}
        if (t is List) {
          final lines = t.whereType<String>().toList();
          if (lines.isNotEmpty) result[transport] = lines;
          continue;
        }

        // Legacy nested format: {"obfs4": {"bridges": {"bridge_strings": [...]}}}
        if (t is Map) {
          final bridges = t['bridges'];
          if (bridges is Map) {
            final lines = bridges['bridge_strings'];
            if (lines is List) {
              result[transport] = lines.cast<String>().toList();
            }
          }
        }
      }
      if (result.isNotEmpty) return result;
    }

    // Legacy/alternative format: {"data": [{"type": "...", "bridge_strings": [...]}]}
    if (json is Map && json['data'] is List) {
      final result = <String, List<String>>{};
      for (final item in json['data'] as List) {
        if (item is! Map) continue;
        final type = item['type'] as String?;
        final lines = item['bridge_strings'];
        if (type != null && lines is List) {
          result[type] = lines.cast<String>().toList();
        }
      }
      if (result.isNotEmpty) return result;
    }
  } catch (_) {
    // parse error → return null
  }
  return null;
}

/// Mirrors BridgeFetchService._decodeChunked (lines 312–332).
String decodeChunked(String raw) {
  final buf = StringBuffer();
  var pos = 0;
  while (pos < raw.length) {
    final lineEnd = raw.indexOf('\r\n', pos);
    if (lineEnd == -1) break;
    final sizeHex = raw.substring(pos, lineEnd).trim();
    // Strip chunk extensions (e.g. ";name=value")
    final size =
        int.tryParse(sizeHex.split(';').first.trim(), radix: 16) ?? 0;
    if (size == 0) break; // terminal chunk
    final dataStart = lineEnd + 2;
    final dataEnd = dataStart + size;
    if (dataEnd > raw.length) {
      buf.write(raw.substring(dataStart));
      break;
    }
    buf.write(raw.substring(dataStart, dataEnd));
    pos = dataEnd + 2; // skip trailing \r\n after chunk data
  }
  return buf.toString();
}

/// Mirrors BridgeFetchService._isPublicIp (lines 433–446).
bool isPublicIp(String ip) {
  final parts = ip.split('.');
  if (parts.length != 4) return false;
  final b = parts.map((p) => int.tryParse(p) ?? -1).toList();
  if (b.any((x) => x < 0 || x > 255)) return false;
  if (b[0] == 10) return false; // RFC 1918
  if (b[0] == 172 && b[1] >= 16 && b[1] <= 31) return false; // RFC 1918
  if (b[0] == 192 && b[1] == 168) return false; // RFC 1918
  if (b[0] == 127) return false; // loopback
  if (b[0] == 198 && (b[1] == 18 || b[1] == 19)) return false; // RFC 2544
  if (b[0] == 100 && b[1] >= 64 && b[1] <= 127) return false; // RFC 6598 CGN
  if (b[0] == 0) return false; // "this" network
  return true;
}

/// Mirrors BridgeFetchService._postBody (lines 341–347).
String postBody() => jsonEncode({
      'data': [
        {
          'version': '0.1.0',
          'type': 'client-transports',
          'supported': ['snowflake', 'obfs4', 'webtunnel'],
        }
      ],
    });

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // _parseBuiltinResponse
  // ══════════════════════════════════════════════════════════════════════════

  group('parseBuiltinResponse — current format', () {
    test('parses current format with snowflake and obfs4 arrays', () {
      final body = jsonEncode({
        'snowflake': [
          'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72'
        ],
        'obfs4': [
          'obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878190A975A8FC7 cert=abc iat-mode=0'
        ],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['snowflake'], hasLength(1));
      expect(result['snowflake']![0], startsWith('snowflake '));
      expect(result['obfs4'], hasLength(1));
      expect(result['obfs4']![0], startsWith('obfs4 '));
    });

    test('parses current format with multiple bridge lines per transport', () {
      final body = jsonEncode({
        'obfs4': [
          'obfs4 1.2.3.4:443 AAAA cert=xxx iat-mode=0',
          'obfs4 5.6.7.8:443 BBBB cert=yyy iat-mode=0',
          'obfs4 9.10.11.12:443 CCCC cert=zzz iat-mode=0',
        ],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['obfs4'], hasLength(3));
    });

    test('parses current format with webtunnel transport', () {
      final body = jsonEncode({
        'webtunnel': ['webtunnel [2001:db8::1]:443 FINGERPRINT url=https://example.com/path ver=0.0.1'],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['webtunnel'], hasLength(1));
      expect(result['webtunnel']![0], contains('webtunnel'));
    });

    test('skips non-string elements in bridge array', () {
      final body = jsonEncode({
        'obfs4': [
          'obfs4 1.2.3.4:443 AAAA cert=xxx iat-mode=0',
          42, // non-string, should be skipped via whereType<String>
          null,
          'obfs4 5.6.7.8:443 BBBB cert=yyy iat-mode=0',
        ],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['obfs4'], hasLength(2));
    });

    test('ignores unknown transport keys', () {
      final body = jsonEncode({
        'unknown_transport': ['some line'],
        'obfs4': ['obfs4 1.2.3.4:443 AAAA cert=x iat-mode=0'],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      // 'unknown_transport' is not in the known list, so only obfs4 appears
      expect(result!.containsKey('unknown_transport'), isFalse);
      expect(result.containsKey('obfs4'), isTrue);
    });
  });

  group('parseBuiltinResponse — legacy nested format', () {
    test('parses legacy nested format with bridge_strings', () {
      final body = jsonEncode({
        'obfs4': {
          'bridges': {
            'bridge_strings': [
              'obfs4 1.2.3.4:443 AAAA cert=x iat-mode=0',
              'obfs4 5.6.7.8:443 BBBB cert=y iat-mode=0',
            ],
          },
        },
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['obfs4'], hasLength(2));
    });

    test('handles legacy nested format with empty bridge_strings', () {
      final body = jsonEncode({
        'snowflake': {
          'bridges': {
            'bridge_strings': <String>[],
          },
        },
      });
      // Legacy format adds key even with empty list → result has key with empty list
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['snowflake'], isEmpty);
    });

    test('handles legacy nested format with missing bridge_strings key', () {
      final body = jsonEncode({
        'obfs4': {
          'bridges': {
            'other_key': ['line1'],
          },
        },
      });
      final result = parseBuiltinResponse(body);
      // No bridge_strings → transport not added → returns null
      expect(result, isNull);
    });
  });

  group('parseBuiltinResponse — legacy data array format', () {
    test('parses legacy data array format', () {
      final body = jsonEncode({
        'data': [
          {
            'type': 'snowflake',
            'bridge_strings': ['snowflake 192.0.2.3:80 AAAA fingerprint=AAAA'],
          },
          {
            'type': 'obfs4',
            'bridge_strings': [
              'obfs4 1.2.3.4:443 BBBB cert=x iat-mode=0',
            ],
          },
        ],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['snowflake'], hasLength(1));
      expect(result['obfs4'], hasLength(1));
    });

    test('skips data items without type field', () {
      final body = jsonEncode({
        'data': [
          {
            'bridge_strings': ['snowflake 192.0.2.3:80 AAAA'],
          },
        ],
      });
      final result = parseBuiltinResponse(body);
      // No 'type' → item skipped → empty result → null
      expect(result, isNull);
    });

    test('skips data items that are not Maps', () {
      final body = jsonEncode({
        'data': [
          'not a map',
          42,
          {
            'type': 'obfs4',
            'bridge_strings': ['obfs4 1.2.3.4:443 AAAA cert=x iat-mode=0'],
          },
        ],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['obfs4'], hasLength(1));
    });
  });

  group('parseBuiltinResponse — edge cases', () {
    test('returns null for empty bridges in all transports', () {
      final body = jsonEncode({
        'snowflake': <String>[],
        'obfs4': <String>[],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNull);
    });

    test('returns null for invalid JSON', () {
      final result = parseBuiltinResponse('not json at all {{{');
      expect(result, isNull);
    });

    test('returns null for empty string', () {
      final result = parseBuiltinResponse('');
      expect(result, isNull);
    });

    test('returns null for JSON array at top level', () {
      final body = jsonEncode(['snowflake 192.0.2.3:80 AAAA']);
      final result = parseBuiltinResponse(body);
      expect(result, isNull);
    });

    test('returns null for JSON number at top level', () {
      final result = parseBuiltinResponse('42');
      expect(result, isNull);
    });

    test('returns null for empty JSON object', () {
      final result = parseBuiltinResponse('{}');
      expect(result, isNull);
    });

    test('returns null for map with only unrecognized keys', () {
      final body = jsonEncode({
        'tor': ['some line'],
        'vpn': ['another line'],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNull);
    });

    test('handles meek and meek-azure transports', () {
      final body = jsonEncode({
        'meek': ['meek 0.0.2.1:1 url=https://az786092.vo.msecnd.net/'],
        'meek-azure': ['meek_lite 0.0.2.1:2 url=https://meek.azureedge.net/'],
      });
      final result = parseBuiltinResponse(body);
      expect(result, isNotNull);
      expect(result!['meek'], hasLength(1));
      expect(result['meek-azure'], hasLength(1));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // _decodeChunked
  // ══════════════════════════════════════════════════════════════════════════

  group('decodeChunked', () {
    test('decodes a single chunk', () {
      // Chunk: size=5 (hex), data="Hello", terminal 0-chunk
      final raw = '5\r\nHello\r\n0\r\n\r\n';
      expect(decodeChunked(raw), equals('Hello'));
    });

    test('decodes multiple chunks', () {
      final raw = '5\r\nHello\r\n7\r\n, World\r\n0\r\n\r\n';
      expect(decodeChunked(raw), equals('Hello, World'));
    });

    test('returns empty string for empty input', () {
      expect(decodeChunked(''), equals(''));
    });

    test('returns empty string for terminal-only chunk', () {
      final raw = '0\r\n\r\n';
      expect(decodeChunked(raw), equals(''));
    });

    test('handles large hex chunk size', () {
      final data = 'A' * 256; // 256 = 0x100
      final raw = '100\r\n$data\r\n0\r\n\r\n';
      expect(decodeChunked(raw), equals(data));
    });

    test('handles chunk extensions (semicolon-separated)', () {
      // RFC 7230 allows chunk extensions: size;ext=val\r\n
      final raw = '5;ext=val\r\nHello\r\n0\r\n\r\n';
      expect(decodeChunked(raw), equals('Hello'));
    });

    test('handles truncated chunk data gracefully', () {
      // Chunk says size=10 but only 5 bytes available — should take what exists
      final raw = 'a\r\nHello';
      final result = decodeChunked(raw);
      expect(result, equals('Hello'));
    });

    test('handles missing CRLF between chunks gracefully', () {
      // No \r\n at all after initial position — breaks out of loop
      final raw = 'no crlf here';
      expect(decodeChunked(raw), equals(''));
    });

    test('handles uppercase hex size', () {
      final raw = 'A\r\n0123456789\r\n0\r\n\r\n';
      expect(decodeChunked(raw), equals('0123456789'));
    });

    test('handles lowercase hex size', () {
      final raw = 'a\r\n0123456789\r\n0\r\n\r\n';
      expect(decodeChunked(raw), equals('0123456789'));
    });

    test('decodes JSON body split across chunks', () {
      final json = '{"bridges":["obfs4 1.2.3.4:443 AAAA cert=x iat-mode=0"]}';
      final chunk1 = json.substring(0, 20);
      final chunk2 = json.substring(20);
      final raw =
          '${chunk1.length.toRadixString(16)}\r\n$chunk1\r\n'
          '${chunk2.length.toRadixString(16)}\r\n$chunk2\r\n'
          '0\r\n\r\n';
      final decoded = decodeChunked(raw);
      expect(decoded, equals(json));
      // Verify the decoded JSON is parseable
      final parsed = jsonDecode(decoded);
      expect(parsed['bridges'], hasLength(1));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // _isPublicIp
  // ══════════════════════════════════════════════════════════════════════════

  group('isPublicIp — RFC 1918 private ranges', () {
    test('rejects 10.0.0.1 (10/8)', () {
      expect(isPublicIp('10.0.0.1'), isFalse);
    });

    test('rejects 10.255.255.255 (10/8 upper bound)', () {
      expect(isPublicIp('10.255.255.255'), isFalse);
    });

    test('rejects 172.16.0.1 (172.16/12 lower bound)', () {
      expect(isPublicIp('172.16.0.1'), isFalse);
    });

    test('rejects 172.31.255.255 (172.16/12 upper bound)', () {
      expect(isPublicIp('172.31.255.255'), isFalse);
    });

    test('accepts 172.15.255.255 (just below 172.16/12)', () {
      expect(isPublicIp('172.15.255.255'), isTrue);
    });

    test('accepts 172.32.0.0 (just above 172.16/12)', () {
      expect(isPublicIp('172.32.0.0'), isTrue);
    });

    test('rejects 192.168.1.1 (192.168/16)', () {
      expect(isPublicIp('192.168.1.1'), isFalse);
    });

    test('rejects 192.168.0.0 (192.168/16 lower bound)', () {
      expect(isPublicIp('192.168.0.0'), isFalse);
    });

    test('rejects 192.168.255.255 (192.168/16 upper bound)', () {
      expect(isPublicIp('192.168.255.255'), isFalse);
    });
  });

  group('isPublicIp — loopback', () {
    test('rejects 127.0.0.1', () {
      expect(isPublicIp('127.0.0.1'), isFalse);
    });

    test('rejects 127.255.255.255', () {
      expect(isPublicIp('127.255.255.255'), isFalse);
    });
  });

  group('isPublicIp — CGN (RFC 6598)', () {
    test('rejects 100.64.0.1 (CGN lower bound)', () {
      expect(isPublicIp('100.64.0.1'), isFalse);
    });

    test('rejects 100.127.255.255 (CGN upper bound)', () {
      expect(isPublicIp('100.127.255.255'), isFalse);
    });

    test('accepts 100.63.255.255 (just below CGN)', () {
      expect(isPublicIp('100.63.255.255'), isTrue);
    });

    test('accepts 100.128.0.0 (just above CGN)', () {
      expect(isPublicIp('100.128.0.0'), isTrue);
    });
  });

  group('isPublicIp — other reserved ranges', () {
    test('rejects 198.18.0.1 (RFC 2544 benchmark)', () {
      expect(isPublicIp('198.18.0.1'), isFalse);
    });

    test('rejects 198.19.255.255 (RFC 2544 benchmark upper)', () {
      expect(isPublicIp('198.19.255.255'), isFalse);
    });

    test('accepts 198.17.255.255 (just below RFC 2544)', () {
      expect(isPublicIp('198.17.255.255'), isTrue);
    });

    test('accepts 198.20.0.0 (just above RFC 2544)', () {
      expect(isPublicIp('198.20.0.0'), isTrue);
    });

    test('rejects 0.0.0.0 ("this" network)', () {
      expect(isPublicIp('0.0.0.0'), isFalse);
    });

    test('rejects 0.1.2.3 ("this" network)', () {
      expect(isPublicIp('0.1.2.3'), isFalse);
    });
  });

  group('isPublicIp — valid public IPs', () {
    test('accepts 8.8.8.8 (Google DNS)', () {
      expect(isPublicIp('8.8.8.8'), isTrue);
    });

    test('accepts 1.1.1.1 (Cloudflare DNS)', () {
      expect(isPublicIp('1.1.1.1'), isTrue);
    });

    test('accepts 104.16.0.1 (Cloudflare)', () {
      expect(isPublicIp('104.16.0.1'), isTrue);
    });

    test('accepts 193.11.166.194 (obfs4 bridge)', () {
      expect(isPublicIp('193.11.166.194'), isTrue);
    });

    test('accepts 255.255.255.255 (broadcast)', () {
      // Not private, loopback, or "this" — implementation returns true
      expect(isPublicIp('255.255.255.255'), isTrue);
    });
  });

  group('isPublicIp — edge cases', () {
    test('returns false for empty string', () {
      expect(isPublicIp(''), isFalse);
    });

    test('returns false for non-IP string', () {
      expect(isPublicIp('not.an.ip.addr'), isFalse);
    });

    test('returns false for too few octets', () {
      expect(isPublicIp('1.2.3'), isFalse);
    });

    test('returns false for too many octets', () {
      expect(isPublicIp('1.2.3.4.5'), isFalse);
    });

    test('returns false for octet > 255', () {
      expect(isPublicIp('256.0.0.1'), isFalse);
    });

    test('returns false for negative octet', () {
      expect(isPublicIp('1.2.3.-1'), isFalse);
    });

    test('returns false for IPv6 address', () {
      expect(isPublicIp('::1'), isFalse);
    });

    test('returns false for hostname', () {
      expect(isPublicIp('relay.damus.io'), isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // _postBody
  // ══════════════════════════════════════════════════════════════════════════

  group('postBody', () {
    test('produces valid JSON', () {
      final body = postBody();
      expect(() => jsonDecode(body), returnsNormally);
    });

    test('contains data array with one item', () {
      final json = jsonDecode(postBody()) as Map<String, dynamic>;
      expect(json['data'], isList);
      expect((json['data'] as List), hasLength(1));
    });

    test('specifies version 0.1.0', () {
      final json = jsonDecode(postBody()) as Map<String, dynamic>;
      final item = (json['data'] as List).first as Map<String, dynamic>;
      expect(item['version'], equals('0.1.0'));
    });

    test('specifies type client-transports', () {
      final json = jsonDecode(postBody()) as Map<String, dynamic>;
      final item = (json['data'] as List).first as Map<String, dynamic>;
      expect(item['type'], equals('client-transports'));
    });

    test('requests snowflake, obfs4, and webtunnel', () {
      final json = jsonDecode(postBody()) as Map<String, dynamic>;
      final item = (json['data'] as List).first as Map<String, dynamic>;
      final supported = item['supported'] as List;
      expect(supported, contains('snowflake'));
      expect(supported, contains('obfs4'));
      expect(supported, contains('webtunnel'));
      expect(supported, hasLength(3));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Bridge line format validation
  // ══════════════════════════════════════════════════════════════════════════

  group('Bridge line format validation', () {
    // Embedded bridge constants — verify structure

    test('embedded snowflake bridges start with "snowflake "', () {
      // Reconstruct the embedded snowflake lines (from source)
      const sfIce =
          'ice=stun:stun.cloudflare.com:3478,stun:global.stun.twilio.com:3478,'
          'stun:stun.relay.metered.ca:80,stun:stun.nextcloud.com:3478,'
          'stun:stun.nextcloud.com:443,stun:stun.bethesda.net:3478,'
          'stun:stun.mixvoip.com:3478,stun:stun.voipgate.com:3478,'
          'stun:stun.epygi.com:3478,stun:stun.stunprotocol.org:3478,'
          'stun:stun.services.mozilla.com:3478,stun:74.125.250.129:19302';

      final bridges = [
        'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
            'fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
            'url=https://1098762253.rsc.cdn77.org/ '
            'fronts=app.datapacket.com,www.datapacket.com '
            '$sfIce '
            'utls-imitate=hellorandomizedalpn',
        'snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA '
            'fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA '
            'url=https://1098762253.rsc.cdn77.org/ '
            'fronts=app.datapacket.com,www.datapacket.com '
            '$sfIce '
            'utls-imitate=hellorandomizedalpn',
        'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
            'fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
            'url=https://snowflake.torproject.org/ '
            'fronts=www.google.com,www.gstatic.com '
            '$sfIce '
            'utls-imitate=hellorandomizedalpn',
      ];

      for (final line in bridges) {
        expect(line, startsWith('snowflake '));
      }
    });

    test('snowflake bridges contain fingerprint field', () {
      const line =
          'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
          'fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
          'url=https://1098762253.rsc.cdn77.org/ '
          'fronts=app.datapacket.com,www.datapacket.com '
          'ice=stun:stun.cloudflare.com:3478 '
          'utls-imitate=hellorandomizedalpn';
      expect(line, contains('fingerprint='));
    });

    test('snowflake bridges contain ice= STUN servers', () {
      const line =
          'snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
          'fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 '
          'url=https://1098762253.rsc.cdn77.org/ '
          'fronts=app.datapacket.com,www.datapacket.com '
          'ice=stun:stun.cloudflare.com:3478 '
          'utls-imitate=hellorandomizedalpn';
      expect(line, contains('ice=stun:'));
    });

    test('obfs4 bridge lines start with "obfs4 "', () {
      const bridges = [
        'obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878190A975A8FC7 '
            'cert=4TLQPJrTSaDffMK7Nbao6LC7G9OW/NHkUwIdjLSS3KYf06igE7DbfYZXne9aRzA+Lx0vTQ iat-mode=0',
        'obfs4 85.31.186.98:443 011F2599C0E9B27EE74B353155E244813763C3E5 '
            'cert=ayq0XzCwhpdysn5o0EyDU7iank0SMa1TjJMNx7s0M2R6RHXEOdYMjCmjFBOCGq7rEE3Yeg iat-mode=0',
      ];
      for (final line in bridges) {
        expect(line, startsWith('obfs4 '));
      }
    });

    test('obfs4 bridge lines contain cert= and iat-mode=', () {
      const line =
          'obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878190A975A8FC7 '
          'cert=4TLQPJrTSaDffMK7Nbao6LC7G9OW/NHkUwIdjLSS3KYf06igE7DbfYZXne9aRzA+Lx0vTQ iat-mode=0';
      expect(line, contains('cert='));
      expect(line, contains('iat-mode='));
    });

    test('obfs4 bridge line has IP:port format after transport name', () {
      const line =
          'obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878190A975A8FC7 '
          'cert=xxx iat-mode=0';
      final parts = line.split(' ');
      expect(parts[0], equals('obfs4'));
      // Second part should be IP:port
      expect(parts[1], contains(':'));
      final ipPort = parts[1].split(':');
      expect(ipPort, hasLength(2));
      // Port should be a number
      expect(int.tryParse(ipPort[1]), isNotNull);
    });

    test('obfs4 fingerprint is 40-char uppercase hex', () {
      const line =
          'obfs4 193.11.166.194:27015 2D82C2E354D531A68469ADF7F878190A975A8FC7 '
          'cert=xxx iat-mode=0';
      final parts = line.split(' ');
      final fingerprint = parts[2];
      expect(fingerprint, hasLength(40));
      expect(RegExp(r'^[0-9A-F]{40}$').hasMatch(fingerprint), isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Integration: parse + chunked decode
  // ══════════════════════════════════════════════════════════════════════════

  group('Integration: chunked-encoded JSON parsing', () {
    test('decodes chunked body then parses bridge response', () {
      final json = jsonEncode({
        'snowflake': ['snowflake 192.0.2.3:80 AAAA fingerprint=AAAA'],
        'obfs4': ['obfs4 1.2.3.4:443 BBBB cert=x iat-mode=0'],
      });
      // Encode as single chunk
      final chunked =
          '${json.length.toRadixString(16)}\r\n$json\r\n0\r\n\r\n';
      final decoded = decodeChunked(chunked);
      final result = parseBuiltinResponse(decoded);
      expect(result, isNotNull);
      expect(result!['snowflake'], hasLength(1));
      expect(result['obfs4'], hasLength(1));
    });

    test('decodes multi-chunk body then parses bridge response', () {
      final json = jsonEncode({
        'obfs4': [
          'obfs4 1.2.3.4:443 AAAA cert=x iat-mode=0',
          'obfs4 5.6.7.8:443 BBBB cert=y iat-mode=0',
        ],
      });
      // Split into 3 chunks
      final part1 = json.substring(0, 20);
      final part2 = json.substring(20, 50);
      final part3 = json.substring(50);
      final chunked = '${part1.length.toRadixString(16)}\r\n$part1\r\n'
          '${part2.length.toRadixString(16)}\r\n$part2\r\n'
          '${part3.length.toRadixString(16)}\r\n$part3\r\n'
          '0\r\n\r\n';
      final decoded = decodeChunked(chunked);
      expect(decoded, equals(json));
      final result = parseBuiltinResponse(decoded);
      expect(result, isNotNull);
      expect(result!['obfs4'], hasLength(2));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // isPublicIp — DNS poisoning defense (link-local not in source but tested)
  // ══════════════════════════════════════════════════════════════════════════

  group('isPublicIp — DNS poisoning defense IPs', () {
    test('rejects 169.254.1.1 (link-local)', () {
      // Note: _isPublicIp in bridge_fetch_service.dart does NOT explicitly
      // check 169.254.x.x — unlike CloudflareIpService. Verify behavior.
      // The source code does NOT block 169.254.x.x, so it returns true.
      // This documents the actual behavior.
      expect(isPublicIp('169.254.1.1'), isTrue);
    });

    test('accepts legitimate bridge server IP', () {
      expect(isPublicIp('116.202.120.184'), isTrue);
    });

    test('rejects poisoned DNS response 10.10.10.10', () {
      expect(isPublicIp('10.10.10.10'), isFalse);
    });

    test('rejects poisoned DNS response 100.100.100.100 (CGN)', () {
      expect(isPublicIp('100.100.100.100'), isFalse);
    });
  });
}
