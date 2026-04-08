import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// Local TLS-terminating TCP proxy for Pulse TURNS.
///
/// Accepts plain TCP from libwebrtc, connects TLS to the Pulse TURN server
/// via Dart's SecureSocket (which uses the OS cert store).
///
/// Needed on:
///   Linux  — BoringSSL lacks ISRG Root X1 (Let's Encrypt)
///   Android/Waydroid — native WebRTC TLS TURN allocation broken in container
///
/// Linux uses LAN IP (libwebrtc filters loopback). Android uses 127.0.0.1.
class PulseTurnProxy {
  static final instance = PulseTurnProxy._();
  PulseTurnProxy._();

  static const _localPort = 34430;
  /// Max concurrent TLS handshakes — prevents event loop starvation from
  /// 6+ simultaneous SecureSocket.connect calls. Queued clients wait instead
  /// of being rejected, so all TURN allocations eventually succeed.
  static const _maxConcurrentTls = 2;

  ServerSocket? _server;
  StreamSubscription<Socket>? _sub;
  String _remoteHost = '';
  int _remotePort = 443;
  String _localIp = '127.0.0.1';
  int _activeBridges = 0;
  int _pendingTls = 0;
  final _tlsGate = Completer<void>(); // never completes; _waitTlsSlot uses fresh ones

  bool get isRunning => _server != null;

  /// The TURN URL for ICE config — plain TCP.
  /// Linux: LAN IP (libwebrtc filters loopback). Android: 127.0.0.1.
  String get localTurnUrl {
    final ip = Platform.isAndroid ? '127.0.0.1' : _localIp;
    return 'turn:$ip:$_localPort?transport=tcp';
  }

  Future<bool> start(String host, int port) async {
    if (_server != null && _remoteHost == host && _remotePort == port) {
      return true; // already running for this target
    }
    await stop();
    _remoteHost = host;
    _remotePort = port;

    // Find a non-loopback IPv4 address (libwebrtc filters 127.0.0.1)
    _localIp = await _findLanIp();

    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, _localPort);
      _sub = _server!.listen(
        _handleClient,
        onError: (e) => print('[TurnProxy] listen error: $e'),
        onDone: () { _server = null; _sub = null; },
      );
      print('[TurnProxy] listening :$_localPort → $host:$port (TLS), ip=$_localIp');
      // Warm up TLS session cache — first connection caches the TLS session,
      // making subsequent handshakes during calls use abbreviated/PSK resumption
      // (~50ms instead of ~500ms each). Fire-and-forget.
      _warmupTls();
      return true;
    } catch (e) {
      print('[TurnProxy] bind failed: $e');
      _server = null;
      return false;
    }
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _server?.close();
    _server = null;
  }

  final List<Completer<void>> _tlsWaiters = [];

  /// Releases one TLS slot and wakes the next waiter (if any).
  void _releaseTlsSlot() {
    _pendingTls--;
    if (_tlsWaiters.isNotEmpty) {
      _tlsWaiters.removeAt(0).complete();
    }
  }

  /// Waits for a TLS slot (max [_maxConcurrentTls] simultaneous handshakes).
  Future<void> _acquireTlsSlot() async {
    _pendingTls++;
    if (_pendingTls <= _maxConcurrentTls) return;
    final c = Completer<void>();
    _tlsWaiters.add(c);
    await c.future;
  }

  void _handleClient(Socket client) {
    _activeBridges++;
    _bridge(client).whenComplete(() {
      _activeBridges--;
    }).catchError((Object e) {
      print('[TurnProxy] bridge error: $e');
      try { client.destroy(); } catch (_) {}
    });
  }

  Future<void> _bridge(Socket client) async {
    client.setOption(SocketOption.tcpNoDelay, true);

    // Throttle concurrent TLS handshakes to avoid freezing the UI
    await _acquireTlsSlot();
    SecureSocket remote;
    try {
      remote = await SecureSocket.connect(
        _remoteHost, _remotePort,
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      _releaseTlsSlot();
      rethrow;
    }
    _releaseTlsSlot();
    remote.setOption(SocketOption.tcpNoDelay, true);

    // Catch async write errors (broken pipe) — add() doesn't throw sync,
    // the error surfaces on socket.done. Without this → [FATAL] Unhandled.
    client.done.catchError((_) {});
    remote.done.catchError((_) {});

    bool closed = false;
    void cleanup() {
      if (closed) return;
      closed = true;
      try { client.destroy(); } catch (_) {}
      try { remote.destroy(); } catch (_) {}
    }

    remote.listen(
      (data) { try { client.add(data); } catch (_) {} },
      onDone: cleanup,
      onError: (_) => cleanup(),
      cancelOnError: true,
    );
    client.listen(
      (data) { try { remote.add(data); } catch (_) {} },
      onDone: cleanup,
      onError: (_) => cleanup(),
      cancelOnError: true,
    );
  }

  /// Parse and log a STUN/TURN message for diagnostics.
  static void _logStunMessage(List<int> data, int msgNum) {
    if (data.length < 20) {
      print('[TurnProxy] server msg#$msgNum: too short (${data.length} bytes)');
      return;
    }
    try {
      final bytes = Uint8List.fromList(data);
      final bd = ByteData.sublistView(bytes);
      final type = bd.getUint16(0);
      final len = bd.getUint16(2);

      // Decode STUN message type
      final isError = (type & 0x0110) == 0x0110;
      final isSuccess = (type & 0x0100) == 0x0100 && !isError;
      final method = type & 0x000F | ((type & 0x00E0) >> 1) |
          ((type & 0x3E00) >> 2);
      String methodName;
      switch (method) {
        case 0x001: methodName = 'Binding'; break;
        case 0x003: methodName = 'Allocate'; break;
        case 0x004: methodName = 'Refresh'; break;
        case 0x006: methodName = 'Send'; break;
        case 0x007: methodName = 'Data'; break;
        case 0x008: methodName = 'CreatePermission'; break;
        case 0x009: methodName = 'ChannelBind'; break;
        default: methodName = '0x${method.toRadixString(16)}'; break;
      }
      final cls = isError ? 'Error' : isSuccess ? 'Success' : 'Request';
      String info = '$methodName $cls (0x${type.toRadixString(16)}) len=$len';

      // Parse attributes to find ERROR-CODE, REALM, NONCE, XOR-RELAYED-ADDRESS
      int pos = 20;
      while (pos + 4 <= data.length) {
        final attrType = bd.getUint16(pos);
        final attrLen = bd.getUint16(pos + 2);
        final attrEnd = pos + 4 + attrLen;
        if (attrEnd > data.length) break;

        if (attrType == 0x0009 && attrLen >= 4) {
          // ERROR-CODE
          final errClass = data[pos + 6] & 0x07;
          final errNumber = data[pos + 7];
          final errCode = errClass * 100 + errNumber;
          String reason = '';
          if (attrLen > 4) {
            reason = String.fromCharCodes(data.sublist(pos + 8, attrEnd));
          }
          info += ' ERROR=$errCode($reason)';
        } else if (attrType == 0x0014) {
          // REALM
          info += ' realm=${String.fromCharCodes(data.sublist(pos + 4, attrEnd))}';
        } else if (attrType == 0x0015) {
          // NONCE
          final nonce = String.fromCharCodes(data.sublist(pos + 4, attrEnd));
          info += ' nonce=${nonce.length > 16 ? '${nonce.substring(0, 16)}...' : nonce}';
        } else if (attrType == 0x0016) {
          // XOR-RELAYED-ADDRESS
          info += ' (has relay addr)';
        } else if (attrType == 0x0020) {
          // XOR-MAPPED-ADDRESS
          info += ' (has mapped addr)';
        }

        pos += 4 + ((attrLen + 3) & ~3); // padded to 4-byte boundary
      }

      print('[TurnProxy] server msg#$msgNum: $info (${data.length} bytes)');
    } catch (e) {
      // Hex dump first 40 bytes on parse failure
      final hex = data.take(40).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      print('[TurnProxy] server msg#$msgNum: parse error ($e) hex=$hex');
    }
  }

  /// Pre-warm the TLS session cache so call-time handshakes use resumption.
  void _warmupTls() {
    SecureSocket.connect(_remoteHost, _remotePort,
        timeout: const Duration(seconds: 10))
    .then((s) {
      print('[TurnProxy] TLS session warmed');
      s.destroy();
    })
    .catchError((e) {
      print('[TurnProxy] TLS warmup failed (non-fatal): $e');
    });
  }

  static Future<String> _findLanIp() async {
    try {
      // Prefer 192.168.x.x
      for (final iface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }
      // Any non-loopback IPv4
      for (final iface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }
}
