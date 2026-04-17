# Pulse

End-to-end encrypted, decentralized messenger. No central servers. No data collection. No backdoors.

You bring your own transport — Nostr, Firebase, Oxen/Session, self-hosted Pulse relay, or LAN — and messages are encrypted with the **Signal Protocol** plus a **Kyber-1024 post-quantum hybrid layer** before they ever leave your device.

---

## How it works

```
Alice                                       Transport                         Bob
─────                                       ─────────                         ───
plaintext
  → MessageEnvelope wrap (_from field)
  → Signal encrypt  (Double Ratchet)        Nostr WebSocket    ─────────→   Gift Wrap unwrap
  → NIP-44 v2 encrypt (XChaCha20)           Firebase SSE                     → NIP-44 decrypt
  → NIP-59 Gift Wrap (ephemeral key)        Oxen HTTP                        → Signal decrypt
  → Kyber-1024 wrap (PQC2||ct||n||aes)      Pulse WebSocket                  → PQC unwrap
  → send                                                                     → MessageEnvelope unwrap
                                            LAN UDP/TCP                      → plaintext
```

**Three encryption layers:**

1. **Signal Protocol** (X3DH + Double Ratchet) — classical E2EE with forward secrecy and break-in recovery
2. **NIP-44 v2 + Gift Wrap** (XChaCha20 + HMAC-SHA256, ephemeral sender, ±2h timestamp jitter) — metadata privacy on Nostr
3. **Kyber-1024 KEM** (NIST FIPS 203 / ML-KEM) — post-quantum outer wrap; protects against harvest-now/decrypt-later attacks

Every message is also wrapped in a `MessageEnvelope` carrying the sender's canonical address inside the E2EE payload, enabling transparent cross-adapter federation (Nostr ↔ Firebase ↔ Oxen ↔ Pulse).

---

## Features

**Messaging**
- Signal Protocol E2EE (Double Ratchet + X3DH key exchange)
- Kyber-1024 post-quantum hybrid — harvest-now/decrypt-later resistant
- NIP-44 v2 encryption + NIP-59 Gift Wrap (metadata privacy)
- Cross-adapter federation — Nostr ↔ Firebase ↔ Oxen ↔ Pulse ↔ LAN transparently
- Per-transport address routing with priority-based failover
- Group chats (mesh broadcast to all members)
- Channel feeds (Telegram-style read-only broadcast channels)
- Media sharing — images (compressed, max 1280px), files (up to 100 MB, chunked), Blossom P2P storage
- Voice messages (up to 5 min, record + playback)
- Disappearing messages (TTL) with cross-device sync
- Scheduled messages — long-press Send to pick a date/time
- Message reactions (8 emoji) and inline editing (shows "(edited)" tag)
- Delivery status: sending → sent → delivered → read (double-check icons)
- Auto-retry on failure with retry button on failed messages

**Calls**
- 1-on-1 audio/video calls via WebRTC
- Screen sharing with quality controls (resolution + frame rate)
- Group calls: WebRTC mesh for ≤4 participants, SFU for larger groups
- Redundant Tor backup audio — secondary RTCPeerConnection via Tor relay; instant failover on ICE failure
- Automatic fallback to relay-only mode (TURN TLS/443) when direct P2P fails

**Transports (5)**
- **Nostr** — WebSocket; pseudonymous, decentralized relay network; NIP-44/NIP-59
- **Firebase** — HTTP SSE receive + REST send; works anywhere Google is accessible
- **Oxen/Session** — HTTP JSON-RPC polling; onion-routed storage network
- **Pulse** — self-hosted WebSocket relay with Ed25519 auth + federation + built-in TURN
- **LAN** — UDP/TCP local broadcast; works with zero internet (offline mesh)

**Censorship resistance**
- Bundled Tor with pluggable transports: obfs4 → WebTunnel → Snowflake → plain (auto-cascade)
- Bundled Psiphon VPN with SOCKS5 proxy + TURN tunneling
- uTLS proxy with TLS fingerprint rotation (Chrome/Firefox/Edge/Safari) + ECH (Encrypted Client Hello)
- DoH (DNS-over-HTTPS) via Cloudflare 1.1.1.1 — bypasses DNS poisoning
- CF-aware relay routing: direct TCP-to-IP via DoH-resolved addresses
- Adaptive relay racing: probes Cloudflare relays via WS, fastest wins (15min TTL)
- Autonomous relay discovery: nostr.watch, nostr.band APIs + NIP-65 peer relay exchange
- 5-phase connectivity probe: direct → DoH → Tor bootstrap → Tor probe → done
- Dynamic bridge fetching from bridges.torproject.org via MOAT API (24h cache + embedded fallbacks)
- I2P SOCKS5 proxy support for all transports
- TURN server auto-discovery + custom TURN (Settings → Calls)

**Security**
- Random recovery key (`XXXX-XXXX-XXXX-XXXX-XXXX-XXXX`, ~124 bits) — replaces user-chosen passwords
- Unlock password for daily use (PBKDF2 200k iterations, 10-attempt wipe)
- Recovery key → Argon2id (64 MiB, 3 iterations) → deterministic Nostr + Oxen + Pulse keys
- Signal fingerprints for contact verification (TOFU)
- ECDH HMAC-SHA256 signal signing on critical signals
- Signed prekey rotation every 7 days with 2-rotation grace period
- SQLCipher full-DB encryption with annual key rotation
- Key zeroization on app exit (Nostr, Signal, PQC keys)
- Dedup sliding window (10K entries) — prevents replay
- Rate limiter (token bucket: 30 msg/2s, 20 sig/3s per sender)
- Circuit breaker on repeated transport failures
- Panic key — triggers data wipe on duress
- PQC badge in chat header — green "+ Kyber" indicator once Kyber key is established

**UX**
- First-launch onboarding with language picker
- 4-step account creation: name → recovery key → verify key → set password
- Account restore: recovery key → same keys on any device
- Device transfer: encrypted export/import of Signal + Kyber keys
- Statuses/Stories: broadcast ephemeral updates to contacts
- Avatar upload (256px JPEG, broadcast via profile_update signal)
- Contact profiles with bio and multi-address QR/deep links
- Typing indicators (debounced, 4-second auto-clear)
- Full-text message search within a chat
- Date separators and message grouping
- Infinite scroll with paginated history (SQLite-backed)
- Desktop notifications (local, no server)
- Pinch-to-zoom image viewer with save-to-disk
- Background service on Android (keeps WebSocket alive when minimized)
- Deep links: `pulse://add?cfg=<base64>` with multi-address support
- Theme engine with 5 presets (Ocean, Jade, Cobalt, Midnight, Light) + full color customization
- Localized in 51 languages

**Platforms**
- Linux desktop (primary)
- Android (APK)
- macOS, iOS, Windows, Web (configured, not yet tested in production)

---

## Security stack

| Layer | Algorithm | Standard | What it protects |
|---|---|---|---|
| Classical E2EE | X3DH + Double Ratchet (Curve25519, AES-256-CBC, HMAC-SHA256) | Signal Protocol | Forward secrecy, break-in recovery |
| Nostr encryption | NIP-44 v2 (XChaCha20 + HMAC-SHA256, HKDF) | NIP-44 | Content confidentiality on Nostr |
| Metadata privacy | NIP-59 Gift Wrap (ephemeral key, ±2h jitter) | NIP-59 | Hides sender/timestamp on Nostr |
| Post-quantum KEM | Kyber-1024 / ML-KEM | NIST FIPS 203 | Harvest-now/decrypt-later |
| Hybrid KDF | HKDF-SHA256 over `Signal_SK ‖ Kyber_SS` | RFC 5869 | Security holds if either primitive survives |
| Authenticated encryption | AES-256-GCM | NIST SP 800-38D | Integrity + confidentiality of PQC outer layer |
| DB encryption | SQLCipher (AES-256-CBC) | — | At-rest message encryption |
| Key derivation | Argon2id (64 MiB, 3 iterations) | RFC 9106 | Brute-force resistant key derivation |
| Password hashing | PBKDF2-SHA256 (200k iterations) | RFC 2898 | Daily unlock authentication |
| Transport (optional) | Tor / Psiphon / I2P / uTLS | — | IP-level anonymity + DPI evasion |

The wire format is versioned (`PQC2||...`) so future algorithms (e.g. ML-DSA signatures) can be added without breaking existing sessions.

---

## Threat model

| Threat | Protected? | How |
|---|---|---|
| Passive eavesdropper (today) | Yes | Signal E2EE + NIP-44 |
| Passive eavesdropper with future quantum computer | Yes | Kyber-1024 hybrid |
| Active MITM with classical computer | Yes | Signal identity keys + fingerprint verification |
| Transport operator reading message content | Yes | Triple-encrypted before leaving device |
| Transport operator observing metadata (who/when) | Partial | Gift Wrap hides sender on Nostr; Tor/I2P/Psiphon hides IP; contact graph still visible to relay |
| DPI / traffic analysis | Partial | uTLS fingerprint spoofing + obfs4/WebTunnel/Snowflake PTs |
| DNS poisoning / hijacking | Yes | DoH via 1.1.1.1 + CF-direct TCP-to-IP routing |
| Compromised device | No | No solution at application layer |
| Active MITM with large-scale quantum computer | No | Requires ML-DSA bundle signatures (roadmap) |

---

## Transports

| | Nostr | Firebase | Oxen/Session | Pulse | LAN |
|---|---|---|---|---|---|
| Protocol | WebSocket | HTTP SSE + REST | HTTP JSON-RPC | WebSocket | UDP/TCP |
| Identity | `pubkey@wss://relay` | `userId@https://fb.url` | 66-char hex (`05…`) | `ed25519@https://server` | local IP |
| Works in CN/IR | With Tor/PT | No | Yes | Yes (self-hosted) | Yes (no internet) |
| Requires server | Public Nostr relay | Firebase project | Oxen seed nodes | Self-hosted | None |
| Metadata privacy | Gift Wrap | Minimal | Onion routing | Server-only | Broadcast |

Adding a new transport means implementing two interfaces: `InboxReader` and `MessageSender`.

---

## Architecture

```
lib/
├── adapters/                           6 files
│   ├── inbox_manager.dart              InboxReader / MessageSender interfaces + router
│   ├── nostr_adapter.dart              Nostr WebSocket (NIP-04/44/59, Gift Wrap, adaptive relay)
│   ├── firebase_adapter.dart           Firebase SSE reader + REST sender
│   ├── oxen_adapter.dart               Oxen/Session HTTP JSON-RPC reader + sender
│   ├── pulse_adapter.dart              Self-hosted Pulse relay (Ed25519 auth, shared WS)
│   └── lan_adapter.dart                LAN UDP/TCP broadcast (offline mesh)
├── controllers/
│   └── chat_controller.dart            Singleton ChangeNotifier — coordinates everything
├── models/                             9 files
│   ├── message.dart                    Message with delivery status, reactions, edits
│   ├── message_envelope.dart           Federation wrapper: {_v, _from, body}
│   ├── contact.dart                    Per-transport address map + priority routing
│   ├── channel.dart                    Broadcast channel model
│   ├── channel_post.dart               Channel post + reactions
│   ├── chat_room.dart                  Derived from Contact; unread count, last message
│   ├── identity.dart                   Local identity + adapter config
│   ├── user_status.dart                Status/story model
│   └── contact_repository.dart         Abstract contact store interface
├── services/                           58 files
│   ├── signal_service.dart             Signal Protocol (Double Ratchet, PreKey store)
│   ├── pqc_service.dart                Kyber-1024 keypair management (FIPS 203)
│   ├── nip44_service.dart              NIP-44 v2 (XChaCha20 + HMAC-SHA256)
│   ├── gift_wrap_service.dart          NIP-59 triple-layer encryption
│   ├── crypto_layer.dart               PQC wrap/unwrap: HKDF-SHA256 + AES-256-GCM
│   ├── key_manager.dart                Signal + PQC key lifecycle facade
│   ├── key_derivation_service.dart     Argon2id key derivation from recovery key
│   ├── recovery_key_service.dart       Generate/validate/format recovery keys
│   ├── password_hasher.dart            PBKDF2 PIN/password hashing
│   ├── signal_broadcaster.dart         Broadcast signals (addr, profile, relay exchange)
│   ├── signal_dispatcher.dart          Dispatch + verify incoming signals
│   ├── local_storage_service.dart      SQLCipher message persistence
│   ├── channel_service.dart            Channel feed (HTTP + WebSocket live updates)
│   ├── blossom_service.dart            Blossom P2P media storage
│   ├── signaling_service.dart          WebRTC 1-on-1 + Tor backup audio
│   ├── group_signaling_service.dart    WebRTC mesh for group calls
│   ├── tor_service.dart                Bundled Tor + PT cascade (obfs4/WT/SF/plain)
│   ├── psiphon_service.dart            Bundled Psiphon VPN
│   ├── utls_service.dart               uTLS proxy (ECH, fingerprint rotation)
│   ├── yggdrasil_service.dart          Yggdrasil overlay network
│   ├── connectivity_probe_service.dart 5-phase relay/node/TURN discovery
│   ├── relay_directory_service.dart    Community relay APIs (nostr.watch, nostr.band)
│   ├── nip65_discovery_service.dart    NIP-65 peer relay discovery
│   ├── ice_server_config.dart          STUN/TURN management
│   ├── media_service.dart              File/image pick, compress, base64, chunking
│   ├── notification_service.dart       Desktop + mobile notifications; per-chat mute
│   ├── background_service.dart         Android foreground task (keeps WS alive)
│   ├── rate_limiter.dart               Token bucket per sender
│   ├── chunk_assembler.dart            Multi-part file reassembly
│   ├── circuit_breaker_service.dart    Failure tracking + auto-stop retries
│   └── ...
├── screens/                            39 screens
├── widgets/                            27 reusable components
├── theme/                              Design tokens, app theme, theme manager (5 presets)
└── l10n/                               51 locales (ARB + generated Dart)

server/                                 Self-hosted Pulse relay (Go)
├── internal/
│   ├── relay/                          WebSocket hub, message routing, rate limiting
│   ├── store/                          SQLite persistence (users, messages, invites, keys)
│   ├── auth/                           Ed25519 challenge-response authentication
│   ├── federation/                     Peer-to-peer inter-server routing
│   ├── transport/                      TLS listener
│   └── turn/                           Built-in TURN server (pion)
├── cmd/                                CLI commands (serve, invite, user, federation, status)
├── Dockerfile + docker-compose.yml     Container deployment
└── config.example.toml                 Configuration template
```

### Data flow (outgoing message)

```
plaintext
  → MessageEnvelope.wrap()          add {_v, _from, body}
  → SignalService.encrypt()         Double Ratchet → Signal ciphertext
  → NIP44Service.encrypt()          XChaCha20 + HMAC-SHA256 (Nostr)
  → GiftWrapService.wrap()          ephemeral key + ±2h jitter (Nostr)
  → CryptoLayer.wrap()              Kyber-1024 encapsulate + AES-256-GCM
      PQC2 || <kyber_ct> || <nonce> || <aes_gcm_ct>
  → InboxManager.sendMessage()      Nostr / Firebase / Oxen / Pulse / LAN
```

### Data flow (incoming message)

```
Transport event
  → _handleIncomingMessages()
      1. Gift Wrap unwrap             detect kind:1059 → decrypt with privkey
      2. NIP-44 decrypt               detect version byte 0x02 → XChaCha20
      3. CryptoLayer.unwrap()         detect PQC2 prefix → Kyber decapsulate + AES-GCM
      4. Signal decrypt               fast path: senderId match; fallback: try all contacts
      5. MessageEnvelope.tryUnwrap()   extract canonical sender (_from) + body
      6. Contact match                by envelope._from (adapter-agnostic federation)
      7. Group routing                detect {_group: id} → route to group room
      8. Chunk assembly               buffer chunked file transfers until complete
      9. Persist to SQLite (SQLCipher)
     10. Notify UI + notification
```

---

## Self-hosted Pulse relay

The `server/` directory contains a Go relay server for the Pulse transport.

**Features:**
- Ed25519 challenge-response authentication
- WebSocket message relay with rate limiting
- SQLite persistence (users, messages, invites, keys, backups)
- Built-in TURN server (pion) for WebRTC calls
- Federation: peer-to-peer inter-server routing
- Invite code system for controlled registration
- Docker deployment ready

**Quick start:**

```bash
cd server
cp config.example.toml config.toml   # edit with your settings
go build -o pulse-server .
./pulse-server serve
```

Or with Docker:

```bash
cd server
docker compose up -d
```

**CLI commands:**

```bash
./pulse-server serve                  # Start the relay
./pulse-server invite create          # Generate invite code
./pulse-server user list              # List registered users
./pulse-server federation add <url>   # Add federation peer
./pulse-server status                 # Server status
```

---

## Getting started

### Prerequisites

- Flutter 3.x
- One of: public Nostr relay, Firebase project, Oxen seed nodes (public), self-hosted Pulse server, or LAN

### Run

```bash
flutter pub get
flutter run -d linux
```

### Android build

```bash
ANDROID_HOME=/path/to/android-sdk flutter build apk --debug
```

### First launch

An onboarding screen lets you pick a language and either create a new account or restore an existing one.

**New account (4 steps):**
1. Choose a display name
2. App generates a random recovery key (`XXXX-XXXX-XXXX-XXXX-XXXX-XXXX`)
3. Verify the key by re-entering it
4. Set an unlock password for daily use

The recovery key deterministically derives your Nostr, Oxen, and Pulse identities. Same key on another device = same identity (account restore).

**Restore account:** enter your recovery key → set a new password → done.

### Adding a contact

Contacts screen → **+** → paste their address or deep link. Supported formats:
- Nostr: `pubkey@wss://relay.url`
- Firebase: `userId@https://project.firebaseio.com`
- Oxen/Session: 66-character hex string starting with `05`
- Pulse: `ed25519_pubkey@https://server:port`
- Deep link: `pulse://add?cfg=<base64>` with multi-address support

The app fetches their Signal + Kyber public key bundle on first message and establishes an E2EE + PQC session automatically.

---

## Censorship resistance

| Feature | How it helps |
|---|---|
| Bundled Tor + PT cascade | obfs4 → WebTunnel → Snowflake → plain; auto-selects best transport |
| Bundled Psiphon VPN | SOCKS5 proxy for all adapters + TURN tunneling for calls |
| uTLS fingerprint spoofing | Makes TLS look like Chrome/Firefox/Edge; defeats DPI |
| ECH (Encrypted Client Hello) | Hides SNI from network observers |
| DoH (1.1.1.1) | Bypasses DNS poisoning in CN/IR |
| CF-direct routing | TCP-to-IP via DoH-resolved addresses; bypasses poisoned DNS entirely |
| Autonomous relay discovery | nostr.watch + nostr.band + NIP-65 + P2P relay exchange |
| Adaptive relay racing | Probes CF relays via WS; fastest wins; 15min TTL |
| Oxen transport | HTTP to public seed nodes; onion-routed |
| LAN adapter | Works with zero internet (local mesh) |
| TURN TLS/443 auto-fallback | Only reliable WebRTC path through GFW |

For maximum reliability in censored regions: Settings → **Proxy & Tunnels** → enable Tor or Psiphon. Custom TURN server available in Settings → **Calls & TURN**.

---

## Security notes

**What the transport sees**

| Data | Nostr relay | Firebase | Oxen node | Pulse server |
|---|---|---|---|---|
| Sender identity | Ephemeral key (Gift Wrap) | Firebase user ID | Session ID | Ed25519 pubkey |
| Recipient identity | Ephemeral key (Gift Wrap) | Firebase path | Session ID | Server routing |
| Message content | PQC2 ciphertext | PQC2 ciphertext | PQC2 ciphertext | PQC2 ciphertext |
| Timing | ±2h jitter (Gift Wrap) | Real time | Polling interval | Real time |

**What is NOT protected**
- Active quantum MITM at the moment of key exchange (theoretical; ML-DSA signatures are on the roadmap)
- Compromised device — no solution at application layer
- Group membership: member list is local; group messages are sent as individual DMs

---

## Tests

```bash
flutter test                           # all tests
flutter test test/unit/                # unit only
flutter test test/widget/              # widget only
flutter test --reporter expanded       # verbose output
```

130+ test files across 3 categories:

| Category | Examples |
|---|---|
| Unit tests | Signal Protocol, NIP-44, Gift Wrap, Kyber, relay discovery, Tor service, rate limiter, chunk assembler, deep links, adapters |
| Widget tests | All major screens + components (home, chat, call, settings, onboarding, contacts) |
| Integration tests | Full Signal session (PreKey + Double Ratchet bidirectional), E2E message flow |

---

## Roadmap

- **ML-DSA (Dilithium) bundle signatures** — post-quantum identity authentication
- **Multi-device sync** — real-time linked devices (currently: one-time device transfer only)
- **SFU end-to-end testing** — server-side complete, client integration needs real-call testing

---

## Known limitations

- **Calls in censored regions**: unreliable without Tor or a dedicated TURN server; configure in Settings → Calls & TURN
- **Group calls ≥5**: SFU server-side ready, client integration not yet tested in production
- **Scheduled messages**: timers are process-local; fires only while app is running
- **Wire protocol labels**: crypto layer uses `Aegis_PQC_v1` from pre-rename era (kept for backward compatibility)

---

## License

See [LICENSE](LICENSE).
