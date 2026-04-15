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
- SmartRouter: auto-failover across multiple transport addresses per contact
- Group chats (mesh broadcast to all members)
- Media sharing — images (compressed, max 1280px) and files (up to 100 MB, chunked)
- Voice messages (up to 5 min, record + playback)
- Disappearing messages (TTL) with cross-device sync
- Scheduled messages — long-press Send to pick a date/time
- Message reactions (8 emoji, long-press → React)
- Message editing — long-press → Edit (shows "(edited)" tag)
- Delivery status: sending → sent → delivered → read (double-check icons)
- Auto-retry on failure with retry button on failed messages

**Calls**
- 1-on-1 audio/video calls via WebRTC
- Screen sharing (toggle camera ↔ screen)
- Group calls: WebRTC mesh for ≤4 participants, Jitsi fallback for ≥5
- Redundant Tor backup audio — secondary RTCPeerConnection via Tor relay; instant failover on ICE failure
- Automatic fallback to relay-only mode (TURN TLS/443) when direct P2P fails
- Call duration timer, ICE connection state display

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
- CF-aware relay routing: direct TCP-to-IP via DoH-resolved addresses (bypasses poisoned DNS)
- Adaptive relay racing: probes Cloudflare relays via WS, fastest wins (15min TTL)
- Autonomous relay discovery: nostr.watch, nostr.band APIs + NIP-65 peer relay exchange — zero developer infrastructure
- 5-phase connectivity probe: direct → DoH → Tor bootstrap → Tor probe → done
- Dynamic bridge fetching from bridges.torproject.org via MOAT API (24h cache + embedded fallbacks)
- I2P SOCKS5 proxy support for all transports
- TURN server auto-discovery + custom TURN (Settings → Calls)
- Auto-retry calls via TURN TLS/443 (the only reliable WebRTC path through GFW)

**Security**
- Signal fingerprints for contact verification (TOFU)
- NIP-04 Encrypt-then-MAC (HMAC-SHA256) with full PKCS#7 validation
- ECDH HMAC-SHA256 signal signing on critical signals (addr_update, sys_keys, relay_exchange, profile_update)
- Signed prekey rotation every 7 days with 2-rotation grace period
- SQLCipher full-DB encryption with annual key rotation
- Key zeroization on app exit (Nostr, Signal, PQC keys)
- WS connection pool (persistent per-relay, 5min TTL) — reduces DPI fingerprint
- Dedup sliding window (10K entries) — prevents replay
- Chunk assembler with resource limits (16 pending, 50MB total, 5min stale eviction)
- Rate limiter (token bucket: 30 msg/2s, 20 sig/3s per sender)
- Circuit breaker on repeated transport failures
- Password-derived keys (Argon2id m=64MiB t=3 p=1) — brain-wallet account restore
- Password variety enforcement (min 16 chars, 3 of 4 char classes, entropy indicator)
- PQC badge in chat header — green "+ Kyber" indicator once Kyber key is established
- Prekey exhaustion monitoring (>3 in 24h → warning)

**UX**
- First-launch onboarding (4 slides, skippable)
- Anonymous account creation from recovery password (brain-wallet, no random keys)
- Account restore: same password → same Nostr pubkey → same address on any device
- Device transfer: encrypted export/import of Signal + Kyber keys
- Statuses/Stories: broadcast ephemeral updates to contacts
- Avatar upload (256px JPEG, broadcast via profile_update signal)
- Contact profiles with bio
- Typing indicators (debounced, 4-second auto-clear)
- Full-text message search within a chat
- Date separators and message grouping
- Infinite scroll with paginated history (SQLite-backed)
- Desktop notifications (local, no server)
- Pinch-to-zoom image viewer with save-to-disk
- App lock with password + panic key (alert on wrong password)
- Background service on Android (keeps WebSocket alive when minimized)
- Deep links: `pulse://add?cfg=<base64>` with multi-address support
- Offline banner when disconnected ("messages will queue")
- Localization: English, Russian (~90 strings; ~400 remaining)

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
| Key derivation | Argon2id (64 MiB, 3 iterations) | RFC 9106 | Brute-force resistant password hashing |
| Transport (optional) | Tor / Psiphon / I2P / uTLS | — | IP-level anonymity + DPI evasion |

The wire format is versioned (`PQC2||...`) so future algorithms (e.g. ML-DSA signatures) can be added without breaking existing sessions.

---

## Threat model

| Threat | Protected? | How |
|---|---|---|
| Passive eavesdropper (today) | ✅ | Signal E2EE + NIP-44 |
| Passive eavesdropper with future quantum computer | ✅ | Kyber-1024 hybrid |
| Active MITM with classical computer | ✅ | Signal identity keys + fingerprint verification |
| Transport operator reading message content | ✅ | Triple-encrypted before leaving device |
| Transport operator observing metadata (who/when) | ⚠️ Partial | Gift Wrap hides sender on Nostr; Tor/I2P/Psiphon hides IP; contact graph still visible to relay |
| DPI / traffic analysis | ⚠️ Partial | uTLS fingerprint spoofing + obfs4/WebTunnel/Snowflake PTs |
| DNS poisoning / hijacking | ✅ | DoH via 1.1.1.1 + CF-direct TCP-to-IP routing |
| Compromised device | ❌ | No solution at application layer |
| Active MITM with large-scale quantum computer | ❌ | Requires ML-DSA bundle signatures (roadmap) |

---

## Transports

| | Nostr | Firebase | Oxen/Session | Pulse | LAN |
|---|---|---|---|---|---|
| Protocol | WebSocket | HTTP SSE + REST | HTTP JSON-RPC | WebSocket | UDP/TCP |
| Identity | `pubkey@wss://relay` | `userId@https://fb.url` | 66-char hex (`05…`) | `ed25519@https://server` | local IP |
| Works in CN/IR | ⚠️ (with Tor/PT) | ❌ | ✅ | ✅ (self-hosted) | ✅ (no internet) |
| Requires server | Public Nostr relay | Firebase project | Oxen seed nodes | Self-hosted | None |
| Metadata privacy | Gift Wrap | Minimal | Onion routing | Server-only | Broadcast |

Adding a new transport means implementing two interfaces: `InboxReader` and `MessageSender`.

---

## Architecture

```
lib/
├── adapters/
│   ├── inbox_manager.dart           InboxReader / MessageSender interfaces + router
│   ├── nostr_adapter.dart           Nostr WebSocket (NIP-04/44/59, Gift Wrap, adaptive relay)
│   ├── firebase_adapter.dart        Firebase SSE reader + REST sender
│   ├── oxen_adapter.dart            Oxen/Session HTTP JSON-RPC reader + sender
│   ├── pulse_adapter.dart           Self-hosted Pulse relay (Ed25519 auth, federation)
│   └── lan_adapter.dart             LAN UDP/TCP broadcast (offline mesh)
├── controllers/
│   └── chat_controller.dart         Singleton ChangeNotifier — coordinates everything
├── models/
│   ├── message.dart                 Message with delivery status, reactions, edits
│   ├── message_envelope.dart        Federation wrapper: {_v, _from, body}
│   ├── contact.dart                 Contact with alternateAddresses for SmartRouter
│   ├── chat_room.dart               Derived from Contact; unread count, last message
│   ├── identity.dart                Local identity + adapter config
│   ├── user_status.dart             Status/story model
│   └── contact_repository.dart      Abstract contact store interface
├── services/
│   ├── signal_service.dart          Signal Protocol (Double Ratchet, PreKey store)
│   ├── pqc_service.dart             Kyber-1024 keypair management (FIPS 203)
│   ├── nip44_service.dart           NIP-44 v2 (XChaCha20 + HMAC-SHA256)
│   ├── gift_wrap_service.dart       NIP-59 triple-layer encryption
│   ├── nostr_event_builder.dart     Nostr event construction + Schnorr signing
│   ├── crypto_layer.dart            PQC wrap/unwrap: HKDF-SHA256 + AES-256-GCM
│   ├── key_manager.dart             Signal + PQC key lifecycle facade
│   ├── key_derivation_service.dart  Argon2id brain-wallet key derivation
│   ├── signal_broadcaster.dart      Broadcast signals (addr, profile, relay exchange)
│   ├── signal_dispatcher.dart       Dispatch + verify incoming signals
│   ├── local_storage_service.dart   SQLCipher message persistence
│   ├── message_repository.dart      Paginated history + dedup + caching
│   ├── signaling_service.dart       WebRTC 1-on-1 + Tor backup audio
│   ├── group_signaling_service.dart WebRTC mesh for group calls
│   ├── tor_service.dart             Bundled Tor + PT cascade (obfs4/WT/SF/plain)
│   ├── psiphon_service.dart         Bundled Psiphon VPN
│   ├── utls_service.dart            uTLS proxy (ECH, fingerprint rotation)
│   ├── connectivity_probe_service.dart  5-phase relay/node/TURN discovery
│   ├── relay_directory_service.dart Community relay APIs (nostr.watch, nostr.band)
│   ├── nip65_discovery_service.dart NIP-65 peer relay discovery
│   ├── adaptive_relay_service.dart  CF relay racing (fastest wins)
│   ├── cloudflare_ip_service.dart   DoH + CIDR lookup (bypass DNS poisoning)
│   ├── bridge_fetch_service.dart    Dynamic PT bridge fetching (MOAT API)
│   ├── ice_server_config.dart       STUN/TURN management + probe integration
│   ├── media_service.dart           File/image pick, compress, base64, chunking
│   ├── voice_service.dart           Voice message record/playback
│   ├── notification_service.dart    Desktop + mobile notifications; per-chat mute
│   ├── status_service.dart          Status/story broadcast + delivery
│   ├── background_service.dart      Android foreground task (keeps WS alive)
│   ├── rate_limiter.dart            Token bucket per sender
│   ├── chunk_assembler.dart         Multi-part file reassembly
│   ├── circuit_breaker_service.dart Failure tracking + auto-stop retries
│   └── ...
├── screens/                         33 screens (home, chat, call, settings, onboarding, ...)
├── widgets/                         22 reusable components
├── theme/                           Design tokens, app theme, theme manager
└── l10n/                            i18n: English + Russian

server/                              Self-hosted Pulse relay (Go)
├── internal/
│   ├── relay/                       WebSocket hub, message routing, rate limiting
│   ├── store/                       SQLite persistence (users, messages, invites, keys)
│   ├── auth/                        Ed25519 challenge-response authentication
│   ├── federation/                  Peer-to-peer inter-server routing
│   ├── transport/                   TLS listener
│   └── turn/                        Built-in TURN server (pion)
├── cmd/                             CLI commands (serve, invite, user, federation, status)
├── Dockerfile + docker-compose.yml  Container deployment
└── config.example.toml              Configuration template
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

- Flutter 3.x (Linux desktop + Android targets)
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

An onboarding wizard walks you through the key concepts. Then:

- **Anonymous Account** — enter a recovery password (min 16 chars), get deterministic Nostr + Oxen addresses automatically (brain-wallet)
- Same password on another device → same identity (account restore)

The app probes for reachable relays in the background on first launch and caches results for 24 hours.

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
| Autonomous relay discovery | nostr.watch + nostr.band + NIP-65 + P2P relay exchange — zero dev infrastructure |
| Adaptive relay racing | Probes CF relays via WS; fastest wins; 15min TTL |
| Oxen transport | HTTP to public seed nodes; onion-routed |
| LAN adapter | Works with zero internet (local mesh) |
| TURN TLS/443 auto-fallback | Only reliable WebRTC path through GFW |
| Configurable bootstrap timeout | 15–120s slider in Settings → Proxy & Tunnels |

For maximum reliability in censored regions: Settings → **Proxy & Tunnels** → enable Tor (pick transport before connecting) or Psiphon. The app also accepts a custom TURN server in Settings → **Calls & TURN**.

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

**221+ passing tests** across 3 categories:

| Category | Count | Examples |
|---|---|---|
| Unit tests | 75+ files | Signal Protocol, NIP-44, Gift Wrap, Kyber, relay discovery, Tor service, rate limiter, chunk assembler, password entropy, deep links, adapters |
| Widget tests | 45+ files | All major screens + components (home, chat, call, settings, onboarding, contacts, etc.) |
| Integration tests | 2 files | Full Signal session (PreKey + Double Ratchet bidirectional), E2E message flow |

CI runs on every push: analyze → test → build APK (`.github/workflows/ci.yml`).

---

## Roadmap

- **ML-DSA (Dilithium) bundle signatures** — post-quantum identity authentication
- **Multi-device / linked devices** — share identity across machines
- **iOS build** — transport and crypto layers are platform-agnostic; UI is responsive
- **Full i18n** — ~400 strings remaining beyond the current 90
- **Group E2EE** — Sender Keys or MLS for efficient group encryption

---

## Known limitations

- **Calls in censored regions**: unreliable without Tor or a dedicated TURN server; configure in Settings → Calls & TURN
- **Group calls ≥5**: Jitsi fallback requires a browser; shows "not E2EE" warning
- **Scheduled messages**: timers are process-local; fires only while app is running
- **Wire protocol labels**: crypto layer still uses `Aegis_PQC_v1` from pre-rename era (kept for backward compatibility)

---

## License

See [LICENSE](LICENSE).
