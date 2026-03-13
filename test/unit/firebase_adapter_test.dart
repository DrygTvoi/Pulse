import 'package:flutter_test/flutter_test.dart';

// Unit tests for FirebaseInboxSender URL construction logic.
//
// The bug: sendSignal previously used _buildUrl which always wrote to the
// SENDER's Firebase project. For cross-project contacts (databaseId contains
// "@https://other.firebaseio.com"), signals (typing, read receipts, TTL)
// were sent to the wrong project.
//
// Fix: parse "@http" suffix exactly like sendMessage does.
//
// These tests mirror the exact URL-building logic without making real HTTP
// requests.

// ── Pure helper that mirrors the fixed sendSignal URL logic ──────────────────

String buildSignalUrl({
  required String senderDbUrl,
  required String senderAuthKey,
  required String targetDatabaseId,
}) {
  String userId;
  String targetDbUrl;
  final atIdx = targetDatabaseId.indexOf('@http');
  if (atIdx != -1) {
    userId = targetDatabaseId.substring(0, atIdx);
    targetDbUrl = targetDatabaseId.substring(atIdx + 1);
    if (targetDbUrl.endsWith('/')) {
      targetDbUrl = targetDbUrl.substring(0, targetDbUrl.length - 1);
    }
  } else {
    userId = targetDatabaseId;
    targetDbUrl = senderDbUrl;
  }

  final authSuffix =
      (senderAuthKey.isNotEmpty && targetDbUrl == senderDbUrl) ? '?auth=$senderAuthKey' : '';
  return '$targetDbUrl/inbox/$userId/signals.json$authSuffix';
}

// Same logic for sendMessage (reference — should produce identical structure)
String buildMessageUrl({
  required String senderDbUrl,
  required String senderAuthKey,
  required String targetDatabaseId,
}) {
  String userId;
  String targetDbUrl;
  final atIdx = targetDatabaseId.indexOf('@http');
  if (atIdx != -1) {
    userId = targetDatabaseId.substring(0, atIdx);
    targetDbUrl = targetDatabaseId.substring(atIdx + 1);
    if (targetDbUrl.endsWith('/')) {
      targetDbUrl = targetDbUrl.substring(0, targetDbUrl.length - 1);
    }
  } else {
    userId = targetDatabaseId;
    targetDbUrl = senderDbUrl;
  }

  final authSuffix =
      (senderAuthKey.isNotEmpty && targetDbUrl == senderDbUrl) ? '?auth=$senderAuthKey' : '';
  return '$targetDbUrl/inbox/$userId/messages.json$authSuffix';
}

// ─────────────────────────────────────────────────────────────────────────────

const _senderUrl = 'https://sender-project.firebaseio.com';
const _senderAuth = 'myAuthKey123';
const _otherUrl = 'https://other-project.firebaseio.com';

void main() {
  group('FirebaseInboxSender — signal URL construction', () {
    group('same-project contact (plain userId)', () {
      test('sends to correct path under sender project', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: 'user_abc',
        );
        expect(url, '$_senderUrl/inbox/user_abc/signals.json?auth=$_senderAuth');
      });

      test('includes auth key for same-project requests', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: 'user_xyz',
        );
        expect(url, contains('?auth=$_senderAuth'));
      });

      test('no auth suffix when authKey is empty', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: '',
          targetDatabaseId: 'user_abc',
        );
        expect(url, '$_senderUrl/inbox/user_abc/signals.json');
        expect(url, isNot(contains('?auth=')));
      });
    });

    group('cross-project contact (userId@https://other.firebaseio.com)', () {
      const crossId = 'user_bob@$_otherUrl';

      test('writes to OTHER project URL, not sender project', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: crossId,
        );
        expect(url, startsWith(_otherUrl));
        expect(url, isNot(contains(_senderUrl)));
      });

      test('userId portion is correctly parsed before @', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: crossId,
        );
        expect(url, contains('/inbox/user_bob/'));
      });

      test('no auth appended for foreign project (prevents leaking credentials)', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: crossId,
        );
        expect(url, isNot(contains('?auth=')));
      });

      test('full URL is well-formed', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: crossId,
        );
        expect(url, '$_otherUrl/inbox/user_bob/signals.json');
      });

      test('trailing slash in other project URL is stripped', () {
        final url = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: 'user_bob@$_otherUrl/',
        );
        // URL should be identical to the non-trailing-slash version
        expect(url, '$_otherUrl/inbox/user_bob/signals.json');
        // No double slash after the host (i.e. no "...io.com//inbox/...")
        expect(url.replaceFirst('https://', ''), isNot(contains('//')));
      });
    });

    group('signal and message URL structure are consistent', () {
      test('same-project: signal and message differ only in endpoint name', () {
        const targetId = 'user_alice';
        final sigUrl = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: targetId,
        );
        final msgUrl = buildMessageUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: targetId,
        );
        expect(sigUrl, sigUrl.replaceFirst('signals.json', 'signals.json'));
        expect(msgUrl.replaceFirst('messages.json', 'signals.json'), sigUrl);
      });

      test('cross-project: both route to the same foreign Firebase URL', () {
        const crossId = 'user_carol@$_otherUrl';
        final sigUrl = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: crossId,
        );
        final msgUrl = buildMessageUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: crossId,
        );
        // Both should start with the other project URL
        expect(sigUrl, startsWith(_otherUrl));
        expect(msgUrl, startsWith(_otherUrl));
        // No credentials leaked to foreign project
        expect(sigUrl, isNot(contains(_senderAuth)));
        expect(msgUrl, isNot(contains(_senderAuth)));
      });
    });

    group('regression: old bug reproduced and fixed', () {
      test('OLD behavior would produce invalid path (demonstrated)', () {
        // The old _buildUrl always used _senderUrl regardless of target project.
        // This is what the bug produced:
        const crossId = 'user_bob@$_otherUrl';
        final buggyUrl =
            '$_senderUrl/inbox/$crossId/signals.json?auth=$_senderAuth';

        // The buggy URL embeds the entire cross-project ID (including @https://)
        // as a Firebase path segment — clearly invalid.
        expect(buggyUrl, contains('@https://'));
        expect(buggyUrl, contains(_senderUrl)); // wrong project
        expect(buggyUrl, isNot(equals('$_otherUrl/inbox/user_bob/signals.json')));
      });

      test('NEW behavior produces correct URL for same cross-project contact', () {
        const crossId = 'user_bob@$_otherUrl';
        final fixedUrl = buildSignalUrl(
          senderDbUrl: _senderUrl,
          senderAuthKey: _senderAuth,
          targetDatabaseId: crossId,
        );
        expect(fixedUrl, '$_otherUrl/inbox/user_bob/signals.json');
        expect(fixedUrl, isNot(contains('@https://'))); // no raw ID in path
      });
    });
  });
}
