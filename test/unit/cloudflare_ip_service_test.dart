import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_messenger/services/cloudflare_ip_service.dart';

void main() {
  // ── ipToInt ──────────────────────────────────────────────────────────────────

  group('ipToInt', () {
    test('converts 0.0.0.0 to 0', () {
      expect(CloudflareIpService.ipToInt('0.0.0.0'), equals(0));
    });

    test('converts 255.255.255.255 to 0xFFFFFFFF', () {
      expect(CloudflareIpService.ipToInt('255.255.255.255'), equals(0xFFFFFFFF));
    });

    test('converts 1.2.3.4 correctly', () {
      // 1*2^24 + 2*2^16 + 3*2^8 + 4
      expect(CloudflareIpService.ipToInt('1.2.3.4'),
          equals((1 << 24) | (2 << 16) | (3 << 8) | 4));
    });

    test('converts 10.0.0.1', () {
      expect(CloudflareIpService.ipToInt('10.0.0.1'),
          equals((10 << 24) | 1));
    });

    test('converts 192.168.1.1', () {
      expect(CloudflareIpService.ipToInt('192.168.1.1'),
          equals((192 << 24) | (168 << 16) | (1 << 8) | 1));
    });

    test('returns null for too few octets', () {
      expect(CloudflareIpService.ipToInt('1.2.3'), isNull);
    });

    test('returns null for too many octets', () {
      expect(CloudflareIpService.ipToInt('1.2.3.4.5'), isNull);
    });

    test('returns null for empty string', () {
      expect(CloudflareIpService.ipToInt(''), isNull);
    });

    test('returns null for non-numeric octets', () {
      expect(CloudflareIpService.ipToInt('a.b.c.d'), isNull);
    });

    test('returns null for negative octet', () {
      // _ipToInt throws FormatException for n < 0 and returns null via catch.
      expect(CloudflareIpService.ipToInt('1.2.3.-1'), isNull);
    });
  });

  // ── isValidIpv4 ──────────────────────────────────────────────────────────────

  group('isValidIpv4', () {
    test('accepts 0.0.0.0', () {
      expect(CloudflareIpService.isValidIpv4('0.0.0.0'), isTrue);
    });

    test('accepts 255.255.255.255', () {
      expect(CloudflareIpService.isValidIpv4('255.255.255.255'), isTrue);
    });

    test('accepts typical IP', () {
      expect(CloudflareIpService.isValidIpv4('192.168.1.1'), isTrue);
    });

    test('rejects octet > 255', () {
      expect(CloudflareIpService.isValidIpv4('256.0.0.1'), isFalse);
    });

    test('rejects negative octet', () {
      expect(CloudflareIpService.isValidIpv4('1.2.3.-1'), isFalse);
    });

    test('rejects too few octets', () {
      expect(CloudflareIpService.isValidIpv4('1.2.3'), isFalse);
    });

    test('rejects too many octets', () {
      expect(CloudflareIpService.isValidIpv4('1.2.3.4.5'), isFalse);
    });

    test('rejects empty string', () {
      expect(CloudflareIpService.isValidIpv4(''), isFalse);
    });

    test('rejects alphabetic', () {
      expect(CloudflareIpService.isValidIpv4('a.b.c.d'), isFalse);
    });

    test('rejects IPv6', () {
      expect(CloudflareIpService.isValidIpv4('::1'), isFalse);
    });
  });

  // ── isPublicIp ───────────────────────────────────────────────────────────────

  group('isPublicIp', () {
    test('rejects 10.x.x.x (RFC 1918)', () {
      expect(CloudflareIpService.isPublicIp('10.0.0.1'), isFalse);
      expect(CloudflareIpService.isPublicIp('10.255.255.255'), isFalse);
    });

    test('rejects 172.16-31.x.x (RFC 1918)', () {
      expect(CloudflareIpService.isPublicIp('172.16.0.1'), isFalse);
      expect(CloudflareIpService.isPublicIp('172.31.255.255'), isFalse);
    });

    test('accepts 172.15.x.x (just outside RFC 1918 range)', () {
      expect(CloudflareIpService.isPublicIp('172.15.255.255'), isTrue);
    });

    test('accepts 172.32.0.0 (just outside RFC 1918 range)', () {
      expect(CloudflareIpService.isPublicIp('172.32.0.0'), isTrue);
    });

    test('rejects 192.168.x.x (RFC 1918)', () {
      expect(CloudflareIpService.isPublicIp('192.168.0.1'), isFalse);
      expect(CloudflareIpService.isPublicIp('192.168.255.255'), isFalse);
    });

    test('rejects 127.x.x.x (loopback)', () {
      expect(CloudflareIpService.isPublicIp('127.0.0.1'), isFalse);
      expect(CloudflareIpService.isPublicIp('127.255.255.255'), isFalse);
    });

    test('rejects 169.254.x.x (link-local)', () {
      expect(CloudflareIpService.isPublicIp('169.254.0.1'), isFalse);
      expect(CloudflareIpService.isPublicIp('169.254.255.255'), isFalse);
    });

    test('accepts public IP 8.8.8.8', () {
      expect(CloudflareIpService.isPublicIp('8.8.8.8'), isTrue);
    });

    test('accepts public IP 1.1.1.1', () {
      expect(CloudflareIpService.isPublicIp('1.1.1.1'), isTrue);
    });

    test('accepts 104.16.0.1 (Cloudflare)', () {
      expect(CloudflareIpService.isPublicIp('104.16.0.1'), isTrue);
    });

    test('returns false for invalid IP', () {
      expect(CloudflareIpService.isPublicIp('not.an.ip.addr'), isFalse);
    });
  });

  // ── isLoopbackHost ───────────────────────────────────────────────────────────

  group('isLoopbackHost', () {
    test('detects localhost', () {
      expect(CloudflareIpService.isLoopbackHost('localhost'), isTrue);
    });

    test('detects ::1 (IPv6 loopback)', () {
      expect(CloudflareIpService.isLoopbackHost('::1'), isTrue);
    });

    test('detects 127.0.0.1', () {
      expect(CloudflareIpService.isLoopbackHost('127.0.0.1'), isTrue);
    });

    test('detects 127.255.255.255 (entire 127/8 block)', () {
      expect(CloudflareIpService.isLoopbackHost('127.255.255.255'), isTrue);
    });

    test('rejects 128.0.0.1', () {
      expect(CloudflareIpService.isLoopbackHost('128.0.0.1'), isFalse);
    });

    test('rejects normal hostname', () {
      expect(CloudflareIpService.isLoopbackHost('relay.damus.io'), isFalse);
    });

    test('rejects public IP', () {
      expect(CloudflareIpService.isLoopbackHost('8.8.8.8'), isFalse);
    });
  });

  // ── isValidHostname ──────────────────────────────────────────────────────────

  group('isValidHostname', () {
    test('accepts simple hostname', () {
      expect(CloudflareIpService.isValidHostname('example.com'), isTrue);
    });

    test('accepts subdomain', () {
      expect(CloudflareIpService.isValidHostname('relay.damus.io'), isTrue);
    });

    test('accepts hostname with hyphens', () {
      expect(CloudflareIpService.isValidHostname('my-relay.example.com'), isTrue);
    });

    test('accepts numeric hostname', () {
      expect(CloudflareIpService.isValidHostname('8.8.8.8'), isTrue);
    });

    test('rejects empty string', () {
      expect(CloudflareIpService.isValidHostname(''), isFalse);
    });

    test('rejects hostname with parentheses', () {
      expect(CloudflareIpService.isValidHostname('relay.primal.net)'), isFalse);
    });

    test('rejects hostname with spaces', () {
      expect(CloudflareIpService.isValidHostname('relay .com'), isFalse);
    });

    test('rejects hostname starting with hyphen', () {
      expect(CloudflareIpService.isValidHostname('-relay.com'), isFalse);
    });

    test('rejects hostname starting with dot', () {
      expect(CloudflareIpService.isValidHostname('.relay.com'), isFalse);
    });

    test('rejects hostname longer than 253 chars', () {
      final long = 'a' * 254;
      expect(CloudflareIpService.isValidHostname(long), isFalse);
    });

    test('accepts hostname exactly 253 chars with dot', () {
      // 253-char hostname must contain a dot to be a real internet hostname.
      final exact = 'a' * 251 + '.b';  // 253 chars, has dot
      expect(CloudflareIpService.isValidHostname(exact), isTrue);
    });

    test('rejects single-label hostnames (no dot)', () {
      // Real internet hostnames always have a TLD — no dot means it's not
      // a real hostname. This prevents scheme names (wss, https) from passing.
      expect(CloudflareIpService.isValidHostname('wss'), isFalse);
      expect(CloudflareIpService.isValidHostname('localhost'), isFalse);
      expect(CloudflareIpService.isValidHostname('relay'), isFalse);
    });
  });

  // ── parseCidr + CidrBlock.contains ───────────────────────────────────────────

  group('parseCidr', () {
    test('parses valid /24 CIDR', () {
      final block = CloudflareIpService.parseCidr('192.168.1.0/24');
      expect(block, isNotNull);
      expect(block!.network,
          equals(CloudflareIpService.ipToInt('192.168.1.0')));
      // /24 mask = 0xFFFFFF00
      expect(block.mask, equals(0xFFFFFF00));
    });

    test('parses valid /32 CIDR (single host)', () {
      final block = CloudflareIpService.parseCidr('10.0.0.1/32');
      expect(block, isNotNull);
      expect(block!.mask, equals(0xFFFFFFFF));
    });

    test('parses valid /0 CIDR (match all)', () {
      final block = CloudflareIpService.parseCidr('0.0.0.0/0');
      expect(block, isNotNull);
      expect(block!.mask, equals(0));
    });

    test('parses /13 CIDR (Cloudflare 104.16.0.0/13)', () {
      final block = CloudflareIpService.parseCidr('104.16.0.0/13');
      expect(block, isNotNull);
      // /13 mask = 0xFFF80000
      expect(block!.mask, equals(0xFFF80000));
    });

    test('returns null for missing prefix length', () {
      expect(CloudflareIpService.parseCidr('192.168.1.0'), isNull);
    });

    test('returns null for invalid IP in CIDR', () {
      expect(CloudflareIpService.parseCidr('bad.ip/24'), isNull);
    });

    test('returns null for prefix > 32', () {
      expect(CloudflareIpService.parseCidr('10.0.0.0/33'), isNull);
    });

    test('returns null for negative prefix', () {
      expect(CloudflareIpService.parseCidr('10.0.0.0/-1'), isNull);
    });

    test('returns null for empty string', () {
      expect(CloudflareIpService.parseCidr(''), isNull);
    });

    test('returns null for non-numeric prefix', () {
      expect(CloudflareIpService.parseCidr('10.0.0.0/abc'), isNull);
    });
  });

  group('CidrBlock.contains', () {
    test('IP inside /24 range is contained', () {
      final block = CloudflareIpService.parseCidr('192.168.1.0/24')!;
      final ip = CloudflareIpService.ipToInt('192.168.1.42')!;
      expect(block.contains(ip), isTrue);
    });

    test('IP outside /24 range is not contained', () {
      final block = CloudflareIpService.parseCidr('192.168.1.0/24')!;
      final ip = CloudflareIpService.ipToInt('192.168.2.1')!;
      expect(block.contains(ip), isFalse);
    });

    test('network address itself is contained', () {
      final block = CloudflareIpService.parseCidr('10.0.0.0/8')!;
      final ip = CloudflareIpService.ipToInt('10.0.0.0')!;
      expect(block.contains(ip), isTrue);
    });

    test('broadcast address is contained', () {
      final block = CloudflareIpService.parseCidr('10.0.0.0/8')!;
      final ip = CloudflareIpService.ipToInt('10.255.255.255')!;
      expect(block.contains(ip), isTrue);
    });

    test('Cloudflare range 104.16.0.0/13 contains 104.16.0.1', () {
      final block = CloudflareIpService.parseCidr('104.16.0.0/13')!;
      final ip = CloudflareIpService.ipToInt('104.16.0.1')!;
      expect(block.contains(ip), isTrue);
    });

    test('Cloudflare range 104.16.0.0/13 contains 104.23.255.255', () {
      final block = CloudflareIpService.parseCidr('104.16.0.0/13')!;
      final ip = CloudflareIpService.ipToInt('104.23.255.255')!;
      expect(block.contains(ip), isTrue);
    });

    test('Cloudflare range 104.16.0.0/13 does not contain 104.24.0.0', () {
      // 104.24.0.0/14 is a separate block
      final block = CloudflareIpService.parseCidr('104.16.0.0/13')!;
      final ip = CloudflareIpService.ipToInt('104.24.0.0')!;
      expect(block.contains(ip), isFalse);
    });

    test('/32 contains only exact IP', () {
      final block = CloudflareIpService.parseCidr('1.2.3.4/32')!;
      expect(block.contains(CloudflareIpService.ipToInt('1.2.3.4')!), isTrue);
      expect(block.contains(CloudflareIpService.ipToInt('1.2.3.5')!), isFalse);
    });

    test('/0 contains any IP', () {
      final block = CloudflareIpService.parseCidr('0.0.0.0/0')!;
      expect(block.contains(CloudflareIpService.ipToInt('1.2.3.4')!), isTrue);
      expect(block.contains(CloudflareIpService.ipToInt('255.255.255.255')!), isTrue);
    });
  });

  // ── Integration: all fallback ranges parse successfully ──────────────────────

  group('fallback ranges', () {
    // The hardcoded _fallbackRanges should all be parseable.
    // We verify by checking a known Cloudflare IP.
    test('known Cloudflare IP 104.16.0.1 is in fallback ranges', () {
      // Parse all fallback ranges manually (they are public const)
      final ranges = [
        '173.245.48.0/20',
        '103.21.244.0/22',
        '103.22.200.0/22',
        '103.31.4.0/22',
        '141.101.64.0/18',
        '108.162.192.0/18',
        '190.93.240.0/20',
        '188.114.96.0/20',
        '197.234.240.0/22',
        '198.41.128.0/17',
        '162.158.0.0/15',
        '104.16.0.0/13',
        '104.24.0.0/14',
        '172.64.0.0/13',
        '131.0.72.0/22',
      ];
      final blocks = ranges
          .map(CloudflareIpService.parseCidr)
          .where((b) => b != null)
          .toList();

      // All 15 should parse successfully
      expect(blocks.length, equals(15));

      final testIp = CloudflareIpService.ipToInt('104.16.0.1')!;
      final match = blocks.any((b) => b!.contains(testIp));
      expect(match, isTrue);
    });

    test('non-Cloudflare IP 8.8.8.8 is NOT in fallback ranges', () {
      final ranges = [
        '173.245.48.0/20', '103.21.244.0/22', '103.22.200.0/22',
        '103.31.4.0/22', '141.101.64.0/18', '108.162.192.0/18',
        '190.93.240.0/20', '188.114.96.0/20', '197.234.240.0/22',
        '198.41.128.0/17', '162.158.0.0/15', '104.16.0.0/13',
        '104.24.0.0/14', '172.64.0.0/13', '131.0.72.0/22',
      ];
      final blocks = ranges
          .map(CloudflareIpService.parseCidr)
          .where((b) => b != null)
          .toList();

      final testIp = CloudflareIpService.ipToInt('8.8.8.8')!;
      final match = blocks.any((b) => b!.contains(testIp));
      expect(match, isFalse);
    });
  });
}
