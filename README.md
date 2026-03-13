# Pulse

End-to-end encrypted, decentralized messenger. No central servers. No data collection. No backdoors.

You bring your own transport — Firebase, Nostr, Oxen/Session, or Waku — and messages are encrypted with the Signal Protocol **plus a Kyber-1024 post-quantum hybrid layer** before they ever leave your device.

---

## How it works

```
Alice                                    Transport                    Bob
─────                                    ─────────                    ───
plaintext
  → MessageEnvelope wrap (_from field)
  → Signal encrypt  (Double Ratchet)     Firebase SSE   ─────────→  PQC2 unwrap
  → Kyber-1024 wrap (PQC2||ct||n||aes)  Nostr WebSocket              → Signal decrypt
  → send                                Oxen HTTP                    → plaintext
                                        Waku REST
```

**Two encryption layers:**

1. **Signal Protocol** (X3DH + Double Ratchet) — classical E2EE with forward secrecy and break-in recovery
2. **Kyber-1024 KEM** (NIST FIPS 203 / ML-KEM) — post-quantum outer wrap; protects against "harvest-now/decrypt-later" attacks by future quantum computers

An attacker recording traffic today cannot decrypt it with a quantum computer — they'd need to break **both** Curve25519 and Kyber-1024 simultaneously. This is the NIST-recommended hybrid approach.

Every message is also wrapped in a `MessageEnvelope` carrying the sender's canonical address inside the E2EE payload, enabling transparent cross-adapter federation (Firebase ↔ Nostr ↔ Oxen).

---

## Features

**Messaging**
- Signal Protocol E2EE (Double Ratchet + X3DH key exchange)
- Kyber-1024 post-quantum hybrid layer — harvest-now/decrypt-later resistant
- Cross-adapter federation — Firebase ↔ Nostr ↔ Oxen transparently
- Group chats (mesh broadcast to all members)
- Media sharing — images (compressed, max 1280px) and files (up to 100 MB, chunked)
- Disappearing messages (TTL) with cross-device sync
- Scheduled messages — long-press Send to pick a date/time
- Message reactions (8 emoji, long-press → React)
- Message editing — long-press → Edit (shows "(edited)" tag)
- Message delivery status: sending → sent → read
- Auto-retry on failure (once, after 30 seconds)

**Calls**
- 1-on-1 audio/video calls via WebRTC
- Screen sharing (toggle camera ↔ screen)
- Group calls: WebRTC mesh for ≤4 participants, Jitsi fallback for ≥5
- Automatic fallback to relay-only mode (TURN TLS/443) when direct P2P fails
- Call duration timer, ICE connection state display

**Transports**
- **Firebase** — HTTP SSE receive + REST send; works anywhere Google is accessible
- **Nostr** — WebSocket; pseudonymous, decentralized relay network
- **Oxen/Session** — HTTP JSON-RPC polling; onion-routed storage network; works in censored regions
- **Waku v2** — HTTP REST polling against a local nwaku node; privacy-preserving p2p

**Censorship resistance**
- Background connectivity probe: finds reachable Nostr relays and Oxen nodes on startup
- Tor bootstrap: if direct probes fail, starts system `tor` to discover reachable relays, then stops
- Probe-discovered servers are cached 24 h and used automatically by adapters
- TURN server auto-discovery: probes community TURN candidates, saves reachable ones for calls
- Tor and I2P SOCKS5 proxy support for all transport connections
- Auto-detect call failure → retry via TURN TLS/443 (the only reliable path through GFW)

**Security**
- Signal fingerprints for contact verification (TOFU)
- Key change warnings when a contact's identity key rotates
- PreKey persistence across restarts — published bundles stay valid
- Automatic bundle republish when a PreKey is consumed
- PQC badge in chat header — green "+ Kyber" indicator once Kyber key is established

**UX**
- First-launch onboarding (4 slides, skippable)
- Quick Start and Anonymous Account creation (both register Nostr + Oxen automatically)
- Typing indicators (debounced, 4-second auto-clear)
- Full-text message search within a chat
- Date separators and message grouping
- Infinite scroll with paginated history (SQLite-backed)
- Desktop notifications (local, no server)
- Pinch-to-zoom image viewer with save-to-disk
- App lock with password + panic key

---

## Security stack

| Layer | Algorithm | Standard | What it protects |
|---|---|---|---|
| Classical E2EE | X3DH + Double Ratchet (Curve25519, AES-256-CBC, HMAC-SHA256) | Signal Protocol | Forward secrecy, break-in recovery |
| Post-quantum KEM | Kyber-1024 / ML-KEM | NIST FIPS 203 | Harvest-now/decrypt-later |
| Hybrid KDF | HKDF-SHA256 over `Signal_SK ‖ Kyber_SS` | RFC 5869 | Security holds if either primitive survives |
| Authenticated encryption | AES-256-GCM | NIST SP 800-38D | Integrity + confidentiality of PQC outer layer |
| Transport (optional) | Tor / I2P SOCKS5 | — | IP-level anonymity |

The wire format is versioned (`PQC2||...`) so future algorithms (e.g. ML-DSA signatures) can be added without breaking existing sessions.

---

## Threat model

| Threat | Protected? | How |
|---|---|---|
| Passive eavesdropper (today) | ✅ | Signal E2EE |
| Passive eavesdropper with future quantum computer | ✅ | Kyber-1024 hybrid |
| Active MITM with classical computer | ✅ | Signal identity keys + fingerprint verification |
| Transport operator reading message content | ✅ | Double-encrypted before leaving device |
| Transport operator observing metadata (who/when) | ⚠️ Partial | Tor/I2P hides IP; contact graph still visible to relay |
| Compromised device | ❌ | No solution at application layer |
| Active MITM with large-scale quantum computer | ❌ | Requires ML-DSA bundle signatures (roadmap) |

---

## Transports

| | Firebase | Nostr | Oxen/Session | Waku v2 |
|---|---|---|---|---|
| Protocol | HTTP SSE + REST | WebSocket | HTTP JSON-RPC | HTTP REST |
| Identity | `userId@https://project.firebaseio.com` | `pubkey@wss://relay.url` | Session ID (66-char hex) | — |
| Works in CN/IR | ❌ | ⚠️ | ✅ | local only |
| Requires server | Firebase project | Nostr relay | Oxen seed nodes (public) | local nwaku |

Adding a new transport means implementing two interfaces: `InboxReader` and `MessageSender`.

---

## Architecture

```
lib/
├── adapters/
│   ├── inbox_manager.dart           InboxReader / MessageSender interfaces + router
│   ├── firebase_adapter.dart        Firebase SSE reader + REST sender
│   ├── nostr_adapter.dart           Nostr WebSocket reader + sender (secp256k1, BIP-340)
│   ├── oxen_adapter.dart            Oxen/Session HTTP JSON-RPC reader + sender
│   └── waku_adapter.dart            Waku v2 HTTP REST reader + sender
├── controllers/
│   └── chat_controller.dart         Singleton ChangeNotifier — coordinates everything
├── models/
│   ├── message.dart
│   ├── message_envelope.dart        Federation wrapper: {_v, _from, body}
│   ├── contact.dart
│   ├── chat_room.dart
│   └── identity.dart
├── services/
│   ├── signal_service.dart          Signal Protocol (Double Ratchet, PreKey store)
│   ├── pqc_service.dart             Kyber-1024 keypair management (FIPS 203)
│   ├── crypto_layer.dart            PQC wrap/unwrap: HKDF-SHA256 + AES-256-GCM
│   ├── local_storage_service.dart   SQLite via sqflite_ffi — message persistence
│   ├── signaling_service.dart       WebRTC 1-on-1
│   ├── group_signaling_service.dart WebRTC mesh for group calls
│   ├── call_transport.dart          ICE profile abstraction (Auto / Restricted)
│   ├── ice_server_config.dart       STUN/TURN server management + probe integration
│   ├── connectivity_probe_service.dart  Background relay/node/TURN discovery
│   ├── tor_service.dart             Tor process management + SOCKS5 bridge
│   ├── media_service.dart           File/image pick, compress, base64, chunking
│   └── notification_service.dart    Desktop notifications via local_notifier
├── screens/
│   ├── onboarding_screen.dart       First-launch 4-slide onboarding
│   └── ...                          One file per screen
└── widgets/
    └── message_bubble.dart          Delivery status, reactions, media rendering
```

### Data flow (outgoing message)

```
plaintext
  → MessageEnvelope.wrap()          add {_v, _from, body}
  → SignalService.encrypt()         Double Ratchet → Signal ciphertext
  → CryptoLayer.wrap()              Kyber-1024 encapsulate + AES-256-GCM
      PQC2 || <kyber_ct> || <nonce> || <aes_gcm_ct>
  → InboxManager.sendMessage()      Firebase / Nostr / Oxen / Waku
```

### Data flow (incoming message)

```
Transport event
  → _handleIncomingMessages()
      1. CryptoLayer.unwrap()        detect PQC2 prefix → Kyber decapsulate + AES-GCM decrypt
      2. Signal decrypt              fast path: senderId match; fallback: try all contacts
      3. MessageEnvelope.tryUnwrap() extract canonical sender (_from) + body
      4. Contact match               by envelope._from (adapter-agnostic federation)
      5. Group routing               detect {_group: id} → route to group room
      6. Chunk assembly              buffer chunked file transfers until complete
      7. Persist to SQLite
      8. Notify UI + desktop notification
```

---

## Getting started

### Prerequisites

- Flutter 3.x (desktop Linux target)
- One of: Firebase project, public Nostr relay, or Oxen seed nodes (public, no setup needed)

### Run

```bash
flutter pub get
flutter run -d linux
```

### First launch

An onboarding wizard walks you through the key concepts on first launch. Then:

- **Quick Start** — enter a name, get Nostr + Oxen addresses automatically
- **Anonymous Account** — optional name, maximum anonymity, also gets Nostr + Oxen

The app probes for reachable relays in the background on first launch and caches results for 24 hours.

### Adding a contact

Contacts screen → **+** → paste their address. Supported formats:
- Firebase: `userId@https://project.firebaseio.com`
- Nostr: `pubkey@wss://relay.url`
- Oxen/Session: 66-character hex string starting with `05`

The app fetches their Signal + Kyber public key bundle on first message and establishes an E2EE + PQC session automatically.

---

## Censorship resistance

Pulse is designed to work in restrictive network environments:

| Feature | How it helps |
|---|---|
| Oxen transport | HTTP polling to public seed nodes; used in HK/IR protests |
| ConnectivityProbeService | Finds reachable relays on startup; Tor bootstrap if needed |
| Auto-retry calls with TURN TLS/443 | Only reliable WebRTC path through GFW |
| TURN server auto-discovery | Probes community TURN candidates, uses reachable ones |
| Tor / I2P proxy support | Route all traffic through anonymizing proxy |

For maximum reliability in censored regions: Settings → **Censorship Resistance** → configure Tor or I2P proxy. The app also accepts a custom TURN server (Settings → **Calls & TURN**) for reliable calls.

---

## Security notes

**What the transport sees**

| Data | Firebase | Nostr relay | Oxen node |
|---|---|---|---|
| Sender identity | Firebase user ID | Nostr pubkey (may be throwaway) | Session ID |
| Recipient identity | Firebase path | `#p` tag (pubkey) | Session ID |
| Message content | PQC2 ciphertext | PQC2 ciphertext | PQC2 ciphertext |

**What is NOT protected**
- Metadata: who talks to whom, when, and how often — visible to the transport (use Tor/I2P to hide IP)
- Group membership: member list is local; group messages are sent as individual DMs
- Active quantum MITM at the moment of key exchange (theoretical; ML-DSA signatures are on the roadmap)

---

## Tests

```bash
flutter test
flutter test test/unit/
flutter test --reporter expanded
```

| File | Covers |
|---|---|
| `unit/message_envelope_test.dart` | Federation envelope wrap/unwrap |
| `unit/message_test.dart` | Message JSON serialization |
| `unit/media_service_test.dart` | Media payload parsing, size labels |
| `unit/nostr_crypto_test.dart` | secp256k1 pubkey derivation |
| `unit/local_storage_service_test.dart` | SQLite CRUD, pagination, room isolation |
| `unit/fingerprint_format_test.dart` | Signal fingerprint formatting |
| `unit/firebase_adapter_test.dart` | Firebase URL construction, cross-project routing |
| `integration/signal_protocol_test.dart` | Full Signal session (PreKey, Double Ratchet, bidirectional) |

---

## Roadmap

- **Snowflake/obfs4 bundled** — bundle Tor + PT binaries; zero-install censorship circumvention
- **uTLS fingerprint spoofing** — make TLS traffic look like Chrome; defeats DPI fingerprinting
- **ML-DSA (Dilithium) bundle signatures** — post-quantum identity authentication
- **Multi-device / linked devices** — share identity across machines
- **Key backup / export** — encrypted backup of Signal + Kyber keypairs
- **Android / iOS** — transport and crypto layers are platform-agnostic; UI needs responsive layout

---

## Known limitations

- **Calls in censored regions**: unreliable without a dedicated TURN server in Asia; configure one in Settings → Calls & TURN
- **No key backup**: losing the device means losing all Signal sessions; contacts will need to re-establish
- **Group calls ≥5**: Jitsi fallback requires a browser on the system
- **No account recovery**: identity lives in local secure storage only
- **Scheduled messages**: timers are process-local; fires only while app is running
