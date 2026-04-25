import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Shared state for TURN-over-WebSocket.
/// When the Pulse WS is connected, TURN data flows through binary frame 0x30
/// instead of creating a separate TLS connection (censorship resistance).
class _TurnWSBridge {
  static WebSocketChannel? channel;
  static final _clients = <int, Socket>{};
  static int _nextId = 0;
  /// Register a local TCP client to receive 0x30 responses from the WS.
  static int register(Socket client) {
    final id = _nextId++;
    _clients[id] = client;
    return id;
  }

  static void unregister(int id) {
    _clients.remove(id);
  }

  /// Hard-drop every local TCP client currently bridged through the WS.
  /// Called between SFU calls so a stale, leaked socket from the prior
  /// libwebrtc TURN allocation can't keep eating fanout from the new
  /// session — that's the bug that made call #2 silently lose its
  /// outbound audio after a fast hangup→call cycle.
  ///
  /// Iterate a snapshot — `client.destroy()` synchronously fires the
  /// socket's onDone, which calls back into `unregister()` and
  /// mutates `_clients`, blowing up live iteration with
  /// ConcurrentModificationError.
  static void dropAllClients() {
    final snapshot = List<Socket>.of(_clients.values);
    _clients.clear();
    for (final c in snapshot) {
      try { c.destroy(); } catch (_) {}
    }
  }

  /// Send STUN data to server via WS binary frame: 0x30 + payload.
  static void sendTurnData(List<int> data) {
    final ch = channel;
    if (ch == null) {
      debugPrint('[TurnWS] DROP ${data.length}B — no WS channel');
      return;
    }
    final frame = Uint8List(1 + data.length);
    frame[0] = 0x30;
    frame.setRange(1, frame.length, data);
    try {
      ch.sink.add(frame);
      debugPrint('[TurnWS] → WS ${data.length}B (clients=${_clients.length})');
    } catch (e) {
      debugPrint('[TurnWS] WS send failed: $e');
    }
  }

  /// Called by PulseInboxReader when a 0x30 binary frame arrives.
  /// Strips prefix and forwards STUN data to ALL registered local clients
  /// (TURN uses a single TCP connection per allocation, so typically just one).
  static void onTurnData(List<int> data) {
    if (data.isEmpty) return;
    final stunData = data; // prefix already stripped by caller
    debugPrint('[TurnWS] ← WS ${data.length}B → ${_clients.length} clients');
    for (final client in _clients.values) {
      try {
        client.add(stunData);
      } catch (_) {}
    }
  }
}

/// Local TCP proxy for Pulse TURN.
///
/// Two modes:
///   1. **WebSocket mode** (preferred): TURN data tunneled through existing
///      Pulse WebSocket as binary frame 0x30. No extra TLS connection.
///   2. **TLS mode** (fallback): Direct TLS to TURN server (original behavior).
///
/// Mode is chosen automatically: if Pulse WS is connected, use WS mode.
class PulseTurnProxy {
  static final instance = PulseTurnProxy._();
  PulseTurnProxy._();

  static const _localPort = 34430;
  static const _maxConcurrentTls = 2;

  ServerSocket? _server;
  StreamSubscription<Socket>? _sub;
  String _remoteHost = '';
  int _remotePort = 443;
  String _localIp = '127.0.0.1';
  int _pendingTls = 0;
  bool _useWebSocket = false;

  bool get isRunning => _server != null;

  /// The TURN URL for ICE config — plain TCP to local proxy.
  String get localTurnUrl {
    // Android (emulator, Waydroid): use loopback — no separate LAN plane.
    // Linux + Windows desktop: use real interface IP. libwebrtc on these
    // platforms silently drops `turn:127.0.0.1:...?transport=tcp` (ICE
    // gathering completes in <100ms with zero candidates emitted); using
    // a real address matches what the OS treats as "this machine" and
    // libwebrtc actually opens the TCP connection to the proxy.
    final ip = Platform.isAndroid ? '127.0.0.1' : _localIp;
    return 'turn:$ip:$_localPort?transport=tcp';
  }

  /// Set the shared Pulse WebSocket channel for TURN-over-WS mode.
  /// Call this when PulseInboxReader authenticates.
  static void setWebSocketChannel(WebSocketChannel? ch) {
    _TurnWSBridge.channel = ch;
  }

  /// Called by PulseInboxReader when a 0x30 binary frame arrives.
  static void onTurnBinaryFrame(List<int> data) {
    _TurnWSBridge.onTurnData(data);
  }

  Future<bool> start(String host, int port) async {
    if (_server != null && _remoteHost == host && _remotePort == port) {
      return true;
    }
    await stop();
    _remoteHost = host;
    _remotePort = port;
    _localIp = await _findLanIp();

    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, _localPort);
      _sub = _server!.listen(
        _handleClient,
        onError: (e) => debugPrint('[TurnProxy] listen error: $e'),
        onDone: () { _server = null; _sub = null; },
      );

      // Decide mode: prefer WS if available, fall back to TLS
      _useWebSocket = _TurnWSBridge.channel != null;
      final mode = _useWebSocket ? 'WS (single connection)' : 'TLS';
      debugPrint('[TurnProxy] listening :$_localPort → $host:$port ($mode), ip=$_localIp');

      if (!_useWebSocket) {
        _warmupTls();
      }
      return true;
    } catch (e) {
      debugPrint('[TurnProxy] bind failed: $e');
      _server = null;
      return false;
    }
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _server?.close();
    _server = null;
    _TurnWSBridge.dropAllClients();
  }

  /// Drop every leaked-or-active local TCP client without tearing down
  /// the listening proxy. Used between SFU calls so call #2's libwebrtc
  /// gets a fresh slot in the bridge and stale TURN allocations from
  /// call #1 can't intercept its RTP.
  void resetClients() {
    _TurnWSBridge.dropAllClients();
  }

  final List<Completer<void>> _tlsWaiters = [];

  void _releaseTlsSlot() {
    _pendingTls--;
    if (_tlsWaiters.isNotEmpty) {
      _tlsWaiters.removeAt(0).complete();
    }
  }

  Future<void> _acquireTlsSlot() async {
    _pendingTls++;
    if (_pendingTls <= _maxConcurrentTls) return;
    final c = Completer<void>();
    _tlsWaiters.add(c);
    await c.future;
  }

  void _handleClient(Socket client) {
    // Re-check WS availability for each new client
    final useWs = _TurnWSBridge.channel != null;
    final bridge = useWs ? _bridgeViaWebSocket(client) : _bridgeViaTls(client);
    bridge.catchError((Object e) {
      debugPrint('[TurnProxy] bridge error: $e');
      try { client.destroy(); } catch (_) {}
    });
  }

  /// Bridge via existing Pulse WebSocket (0x30 binary frames).
  /// No extra TLS connection — everything through one WS.
  Future<void> _bridgeViaWebSocket(Socket client) async {
    client.setOption(SocketOption.tcpNoDelay, true);
    final id = _TurnWSBridge.register(client);

    client.done.catchError((_) {});
    bool closed = false;
    void cleanup() {
      if (closed) return;
      closed = true;
      _TurnWSBridge.unregister(id);
      try { client.destroy(); } catch (_) {}
    }

    client.listen(
      (data) { _TurnWSBridge.sendTurnData(data); },
      onDone: cleanup,
      onError: (_) => cleanup(),
      cancelOnError: true,
    );
  }

  /// Bridge via direct TLS (fallback when WS not available).
  Future<void> _bridgeViaTls(Socket client) async {
    client.setOption(SocketOption.tcpNoDelay, true);

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

  void _warmupTls() {
    SecureSocket.connect(_remoteHost, _remotePort,
        timeout: const Duration(seconds: 10))
    .then((s) {
      debugPrint('[TurnProxy] TLS session warmed');
      s.destroy();
    })
    .catchError((e) {
      debugPrint('[TurnProxy] TLS warmup failed (non-fatal): $e');
    });
  }

  static Future<String> _findLanIp() async {
    try {
      for (final iface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }
      for (final iface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }
}
