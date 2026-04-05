# Pulse Protocol v2 — Specification

> Status: DRAFT
> Date: 2026-04-04
> Author: Pulse Team

---

## 1. Design Goals

1. **Zero limitations** — no message size cap, no event size cap, binary-native
2. **Built-in media relay** — SFU for 1:1 and group calls, any quality up to hardware/bandwidth limit
3. **Censorship resistant by architecture** — single TLS port, probe resistance, indistinguishable from HTTPS
4. **Domain-free operation** — works on bare IP with certificate pinning
5. **Cloudflare-compatible** — works behind CF reverse proxy with ECH
6. **Configurable federation** — open mesh, closed private, or whitelist
7. **Self-hosted first** — one binary, one config file, one port

### Non-goals

- Not a public standard (no NIPs/RFCs) — protocol serves Pulse clients
- Not blockchain/PoW — server operator controls access
- Not a CDN — large file hosting is out of scope (use Blossom/S3)

---

## 2. Architecture Overview

```
                        ┌──────────────────────────────┐
                        │       Pulse Server           │
                        │       (single binary)        │
 :443 TLS ─────────────►│                              │
                        │  ┌────────┐  ┌────────────┐ │
  HTTP GET / ──────────►│  │ Decoy  │  │  Auth      │ │
  (probe resistance)    │  │ Web    │  │  Engine    │ │
                        │  └────────┘  └────────────┘ │
  WS /v2 ──────────────►│  ┌────────────────────────┐ │
  (messaging+signaling) │  │   Message Router       │ │
                        │  │   ├─ local delivery     │ │
                        │  │   ├─ offline store      │ │
                        │  │   └─ federation fwd     │ │
                        │  └────────────────────────┘ │
  ICE-TCP (muxed) ─────►│  ┌────────────────────────┐ │
  (media relay)         │  │   SFU Engine (Pion)    │ │
                        │  │   ├─ rooms              │ │
                        │  │   ├─ track forwarding   │ │
                        │  │   ├─ simulcast select   │ │
                        │  │   └─ bandwidth adapt    │ │
                        │  └────────────────────────┘ │
  WS /federation ──────►│  ┌────────────────────────┐ │
  (server-to-server)    │  │   Federation Router    │ │
                        │  └────────────────────────┘ │
                        └──────────────────────────────┘
```

### Single-port multiplexing

Everything on **one TLS port** (default 443). After TLS handshake, the server reads the first decrypted bytes:

| First bytes | Protocol | Handler |
|---|---|---|
| `GET`, `POST`, `HEAD` ... | HTTP | Web server (decoy site, WS upgrade, REST API) |
| `0x00` or `0x01` (STUN binding) | ICE-TCP | Pion SFU media transport |

DPI sees only a TLS connection to port 443 — identical to any HTTPS website.

---

## 3. Transport Layer

### 3.1 TLS Modes

| Mode | Use case | Config |
|---|---|---|
| `self-signed` | Bare IP, no domain. Client pins cert fingerprint. | Default |
| `manual` | Own domain, own certs (Let's Encrypt etc.) | `tls_cert`, `tls_key` paths |
| `cloudflare` | Behind CF proxy. Server runs plain HTTP, CF terminates TLS. | `tls_mode = "none"` |
| `acme` | Auto Let's Encrypt via ACME challenge | `tls_mode = "acme"`, `domain = "..."` |

### 3.2 Certificate Pinning (domain-free mode)

When the server starts in `self-signed` mode:

1. Generates Ed25519 TLS certificate (or ECDSA P-256 for browser compat)
2. Prints SHA-256 fingerprint to stdout: `CERT_FP <hex>`
3. Client stores fingerprint on first connect (TOFU) or receives it out-of-band
4. Client verifies fingerprint on every reconnect — rejects mismatches

Address format for pinned mode:
```
<pubkey>@https://<ip>:<port>#<cert_fingerprint>
```

Example:
```
a1b2c3...@https://185.22.153.7:8443#e3b0c44298fc1c149afbf4c8996fb924
```

### 3.3 Cloudflare Mode

When behind Cloudflare:
- Server listens plain HTTP (CF terminates TLS)
- CF provides: ECH, DDoS protection, IP hiding, WebSocket proxying
- Client connects to CF domain — GFW sees traffic to Cloudflare IP
- Address format: `<pubkey>@https://pulse.example.com`

ECH is automatic with CF (no server-side work needed).

### 3.4 Probe Resistance

Any non-authenticated HTTP request returns a **convincing decoy website**:

```
GET / HTTP/1.1 → 200 OK, text/html (configurable: nginx default, blog, corporate page)
GET /favicon.ico → 200 OK, image/x-icon
GET /robots.txt → 200 OK, "User-agent: * Disallow: /"
GET /anything-else → 404 Not Found (mimics nginx/Apache)
```

Server response headers mimic the configured web server (`nginx/1.24.0`, `Apache/2.4.58`, etc.).

The WebSocket endpoint `/v2` only upgrades if the client sends the correct `Sec-WebSocket-Protocol` header:

```
Sec-WebSocket-Protocol: pulse.v2.<auth_token>
```

Without this header, `/v2` returns a normal 404. A GFW probe scanning for WebSocket endpoints finds nothing.

### 3.5 Connection Parameters

| Parameter | Value | Notes |
|---|---|---|
| Max WS text frame | 16 MB | For large encrypted payloads |
| Max WS binary frame | 64 MB | For chunked file transfer |
| Ping interval | 30s | Keepalive |
| Pong timeout | 10s | Disconnect if no pong |
| Auth timeout | 10s | Must auth within 10s of connect |
| Idle timeout | 5 min | No messages → server may disconnect |

---

## 4. Authentication

### 4.1 Handshake

```
Client                              Server
  │                                    │
  │──── WS Connect /v2 ──────────────►│
  │                                    │
  │◄─── auth_challenge ───────────────│
  │     {nonce, timestamp, version}    │
  │                                    │
  │──── auth_response ────────────────►│
  │     {pubkey, signature, nonce,     │
  │      timestamp, client_info}       │
  │                                    │
  │◄─── auth_ok ──────────────────────│
  │     {pubkey, server_info,          │
  │      turn_credentials,             │
  │      cert_fingerprint}             │
  │                                    │
```

**Challenge:**
```json
{
  "type": "auth_challenge",
  "nonce": "<32-byte hex>",
  "ts": 1712234567,
  "v": 2
}
```

**Response:**
```json
{
  "type": "auth_response",
  "pubkey": "<ed25519 pubkey hex, 64 chars>",
  "sig": "<ed25519 signature hex, 128 chars>",
  "nonce": "<echo nonce>",
  "ts": 1712234567,
  "client": {
    "name": "Pulse",
    "version": "1.0.0",
    "platform": "linux"
  }
}
```

Signature over: `pulse-v2-auth:<nonce>:<timestamp>`

**auth_ok:**
```json
{
  "type": "auth_ok",
  "pubkey": "<confirmed pubkey>",
  "server": {
    "name": "Pulse Relay",
    "version": "2.0.0",
    "features": ["sfu", "federation", "backup"],
    "max_upload": 67108864,
    "message_ttl": 604800
  },
  "turn": {
    "urls": ["turn:185.22.153.7:443?transport=tcp"],
    "username": "1712320967:a1b2c3...",
    "credential": "base64password",
    "ttl": 86400
  },
  "cert_fp": "e3b0c44..."
}
```

### 4.2 Registration Modes

| Mode | Behavior |
|---|---|
| `open` | Any valid Ed25519 pubkey can connect |
| `invite` | Must include `"invite": "<code>"` in auth_response |
| `closed` | Only pre-registered pubkeys allowed |

### 4.3 Multi-device

One pubkey = one active connection. New connection with same pubkey **closes the old one** (server sends `replaced` error to old connection before closing). Future: multi-device via derived sub-keys.

---

## 5. Messaging Protocol

All messages are JSON text frames over WebSocket, with one exception: binary payloads use binary frames with a reference ID.

### 5.1 Envelope Format

Every message is a JSON object with `type` field:

```json
{
  "type": "<message_type>",
  ...fields specific to type
}
```

No nested `payload` wrapper — flat structure for efficiency.

### 5.2 Message Types

#### send — Client → Server

```json
{
  "type": "send",
  "id": "<unique uuid>",
  "to": "<recipient pubkey>",
  "body": "<encrypted payload, any size>",
  "ttl": 0,
  "priority": "normal"
}
```

- `id`: client-generated UUID, used for dedup and ack
- `body`: encrypted blob (Signal protocol encrypted, base64 or raw UTF-8)
- `ttl`: seconds until expiry. 0 = server default (7 days). -1 = no store (online-only).
- `priority`: `"normal"` | `"high"` (high = push notification hint)

**No size limit** on `body`. Server config `max_message_bytes` is the only cap (default 512 MB).

For binary payloads larger than ~1 MB, use chunked upload (§5.4).

#### message — Server → Client

```json
{
  "type": "message",
  "id": "<message id>",
  "from": "<sender pubkey>",
  "body": "<encrypted payload>",
  "ts": 1712234567,
  "server_ts": 1712234568
}
```

- `ts`: sender's timestamp (untrusted, informational)
- `server_ts`: server's receive timestamp (trusted for ordering)

#### ack — Bidirectional

```json
{
  "type": "ack",
  "id": "<message id>"
}
```

Server sends `ack` when message is stored/delivered.
Client sends `ack` when message is processed (server deletes from offline queue).

#### fetch — Client → Server

```json
{
  "type": "fetch",
  "since": 1712230000,
  "limit": 200
}
```

Response: `stored` with array of messages.

#### stored — Server → Client

```json
{
  "type": "stored",
  "messages": [
    {"id": "...", "from": "...", "body": "...", "ts": ..., "server_ts": ...},
    ...
  ],
  "has_more": true
}
```

Paginated. Client fetches again with `since` = last `server_ts` if `has_more`.

### 5.3 Delivery Guarantees & Offline Queue

Pulse guarantees **at-least-once delivery** for messages. If a recipient is offline, messages are stored on the server and delivered when they reconnect.

#### Delivery matrix

| Data type | Recipient online | Recipient offline | TTL |
|---|---|---|---|
| **Message** (`send`) | Deliver immediately + store | Store in offline queue | Configurable (default 7 days) |
| **Signal** (`signal`) | Deliver immediately | `signal_fail` error | None (real-time only) |
| **File** (chunked) | Deliver immediately | Store encrypted blob | Same as message TTL |
| **Call invite** | Deliver as signal | Store as **missed call message** | 7 days |
| **Tunnel data** | Relay immediately | N/A (requires both ends) | None |

#### Offline queue lifecycle

```
Sender                          Server                        Recipient
  │                                │                              │
  │── send {id, to, body} ───────►│                              │ (offline)
  │                                │── store in DB ──►            │
  │◄── ack {id} ─────────────────│  (with expiry ts)            │
  │                                │                              │
  │         ... hours/days pass ...                               │
  │                                │                              │
  │                                │◄── WS connect + auth ───────│ (back online)
  │                                │                              │
  │                                │── auth_ok ──────────────────►│
  │                                │   {pending_count: 3}         │
  │                                │                              │
  │                                │◄── fetch {since: 0} ────────│
  │                                │                              │
  │                                │── stored {messages: [...]} ─►│
  │                                │                              │
  │                                │◄── ack {id: msg1} ──────────│
  │                                │◄── ack {id: msg2} ──────────│
  │                                │◄── ack {id: msg3} ──────────│
  │                                │                              │
  │                                │── delete acked from DB       │
```

#### Key behaviors

1. **`auth_ok` includes `pending_count`** — client knows how many offline messages are waiting before fetching
2. **Auto-fetch on connect** — client sends `fetch` immediately after `auth_ok`
3. **Paginated fetch** — `limit: 200` per batch, `has_more: true` triggers next fetch
4. **Ack-based deletion** — server keeps message until client explicitly acks (prevents loss on crash)
5. **TTL expiry** — server runs hourly cleanup, deletes messages past their `expires` timestamp
6. **Deduplication** — server rejects `send` with duplicate `id` (idempotent retries safe)
7. **Ordering** — messages delivered in `server_ts` order (server's receive timestamp, monotonic)

#### Missed calls

When a `call_invite` signal fails (recipient offline), server auto-creates a synthetic offline message:

```json
{
  "id": "<auto-generated>",
  "from": "<caller pubkey>",
  "body": "{\"t\":\"missed_call\",\"ts\":1712234567}",
  "ts": 1712234567,
  "server_ts": 1712234567
}
```

Recipient sees "Missed call" when they come back online.

#### Federation + offline

When Server1 sends `fed_envelope` to Server2, and the recipient on Server2 is offline:
- Server2 stores the message in its own offline queue
- Server2 sends `fed_ack` back to Server1 (meaning "accepted for delivery", not "delivered to user")
- Server1 can delete its copy — Server2 is now responsible

If Server2 is unreachable:
- Server1 queues the `fed_envelope` for retry (exponential backoff, max 24h)
- After 24h of failures, Server1 notifies sender: `delivery_failed`

### 5.4 Signals (Real-time, Ephemeral)

```json
{
  "type": "signal",
  "to": "<recipient pubkey>",
  "kind": "<signal_kind>",
  "body": "<signal payload>"
}
```

Signal kinds: `webrtc_offer`, `webrtc_answer`, `webrtc_candidate`, `webrtc_hangup`, `webrtc_reoffer`, `webrtc_reanswer`, `typing`, `presence`, `key_exchange`, `relay_exchange`, `call_invite`, `call_reject`, `call_busy`, etc.

Signals are **never stored** — recipient must be online. If offline, server responds:

```json
{
  "type": "signal_fail",
  "to": "<pubkey>",
  "kind": "<kind>",
  "reason": "offline"
}
```

### 5.5 File Transfer

Files are **always encrypted client-side** before upload. Server stores opaque blobs — cannot see contents.

#### Size tiers

| Size | Transport | Storage | E2EE |
|---|---|---|---|
| < 8 KB | Inline in `send.body` | With message | Signal Protocol (automatic) |
| 8 KB — 100 MB | Chunked upload → server blob store | Server disk, TTL-based | AES-256-GCM, key in `send.body` |
| 100+ MB | P2P DataChannel via SFU room | Not stored on server | AES-256-GCM, key via signal |

#### Chunked binary frame format

```
┌──────────────────────────────────────────────────┐
│ Byte 0:      Type (0x01=upload, 0x02=download)   │
│ Bytes 1-16:  Transfer ID (UUID, 16 bytes)        │
│ Bytes 17-20: Chunk index (uint32 BE)             │
│ Bytes 21-24: Total chunks (uint32 BE, 0=unknown) │
│ Bytes 25+:   Chunk data (up to 1 MB)             │
└──────────────────────────────────────────────────┘
```

#### Upload flow (8 KB — 100 MB)

```
Sender                          Server                       Recipient
  │                                │                             │
  │  1. Generate AES-256-GCM key  │                             │
  │  2. Encrypt file with key      │                             │
  │                                │                             │
  │── upload_start ───────────────►│                             │
  │   {id, size, sha256}           │                             │
  │◄── upload_ack ────────────────│                             │
  │   {max_chunk: 1048576}         │                             │
  │                                │                             │
  │── [0x01 chunk 0] ────────────►│                             │
  │── [0x01 chunk 1] ────────────►│                             │
  │── [0x01 chunk N] ────────────►│                             │
  │                                │── verify sha256             │
  │◄── upload_complete ──────────│                             │
  │   {file_id: "f1"}             │                             │
  │                                │                             │
  │── send ───────────────────────►│── message ─────────────────►│
  │   {to, body: {                 │   {from, body: same}        │
  │     "t": "file",              │                             │
  │     "file_id": "f1",          │                             │
  │     "key": "<AES key b64>",   │                             │ (or offline → stored)
  │     "iv": "<IV b64>",         │                             │
  │     "name": "photo.jpg",      │                             │
  │     "size": 5242880,          │                             │
  │     "mime": "image/jpeg",     │                             │
  │     "sha256": "<hash>"        │                             │
  │   }}                           │                             │
  │                                │                             │
  │                                │◄── download_req ────────────│
  │                                │   {file_id: "f1"}           │
  │                                │── [0x02 chunk 0] ──────────►│
  │                                │── [0x02 chunk N] ──────────►│
  │                                │                             │
  │                                │             3. Decrypt with │
  │                                │                AES key      │
```

**Key point**: the AES key is sent inside the `send.body` which is encrypted with Signal Protocol. Server stores the encrypted file blob but never has the decryption key.

#### Offline file delivery

Files persist on server until TTL expires (same as message TTL, default 7 days). When recipient comes online:
1. `fetch` returns the message with `file_id` + decryption key
2. Client sends `download_req` with `file_id`
3. Server streams chunks
4. Client decrypts and saves

#### Resumable transfers

If upload/download is interrupted:
```json
{"type": "upload_resume", "id": "<transfer_id>", "from_chunk": 15}
{"type": "download_req", "file_id": "f1", "from_chunk": 42}
```

Server skips already-received/sent chunks. SHA-256 verification at end ensures integrity.

#### Server storage config

```toml
[storage]
max_file_bytes = 104857600       # 100 MB per file
max_storage_per_user = 1073741824  # 1 GB total per user
file_ttl = "7d"                  # auto-delete after 7 days
```

### 5.6 Key Management

```json
{"type": "keys_put", "bundle": {/* Signal key bundle */}}
{"type": "keys_get", "pubkey": "<target>"}
{"type": "keys", "pubkey": "<target>", "bundle": {/* ... */}}
```

Unchanged from v1 — Signal Protocol key distribution.

### 5.7 Backup

```json
{"type": "backup_put", "data": "<base64>", "checksum": "<sha256>"}
{"type": "backup_get"}
{"type": "backup", "data": "<base64>", "checksum": "<sha256>"}
```

Max size: server-configured (`max_backup_bytes`, default 50 MB).

---

## 6. Media Relay — SFU Architecture

The core of Pulse v2: built-in Selective Forwarding Unit for voice/video calls.

### 6.1 Why SFU, Not MCU

| | SFU | MCU |
|---|---|---|
| CPU load (server) | Low — just forwarding | High — decode + re-encode |
| Latency | Low | Higher (transcoding) |
| Quality | Original per-sender | Single mix quality |
| Scalability | Linear | Quadratic |
| E2EE possible | Yes (SFrame) | No (server must decode) |
| Complexity | Medium | Very high |

SFU is the standard for modern video conferencing (Zoom, Meet, Teams all use SFU).

### 6.2 Media Transport

**Two modes, configured per-server:**

#### Mode A: ICE-TCP on :443 (Stealth — Default)

```
Client                                    Server :443
  │                                          │
  │── TLS Handshake ────────────────────────►│
  │                                          │ ← Detects STUN after TLS
  │── STUN Binding Request ────────────────►│ ← Routes to Pion ICE
  │◄── STUN Binding Response ───────────────│
  │                                          │
  │══ DTLS Handshake (inside TLS) ═════════►│
  │◄═══════════════════════════════════════ │
  │                                          │
  │── SRTP (audio/video RTP) ──────────────►│ ← Pion SFU forwards
  │◄── SRTP (audio/video RTP) ──────────────│
```

- **Same TLS connection** as the website / WebSocket — DPI cannot distinguish
- Server multiplexes: HTTP bytes → web handler, STUN bytes → Pion ICE handler
- Pion's `ice.TCPMux` handles ICE-TCP on the shared listener
- WebRTC PeerConnection uses `iceTransportPolicy: "relay"` with TURN-TCP credentials pointing to self

Performance: ~5-10% overhead vs UDP. Perfectly adequate for audio and video up to 1080p. Usable for 4K on fast links.

#### Mode B: UDP (Performance)

```
Client                        Server
  │                              │
  │── UDP :443 (STUN) ─────────►│ :443/udp
  │◄── UDP :443 (STUN) ─────────│
  │                              │
  │══ DTLS (UDP) ══════════════►│
  │◄═══════════════════════════ │
  │                              │
  │── SRTP/UDP ────────────────►│
  │◄── SRTP/UDP ────────────────│
```

- Standard WebRTC over UDP
- Lowest latency, best for 4K/8K
- UDP on :443 resembles QUIC/HTTP3 — increasingly common
- Server binds both TCP and UDP on :443

#### Mode C: WebSocket Relay (Maximum Stealth)

For environments where even ICE-TCP patterns are detected. All media as binary WebSocket frames on the same `/v2` connection:

```
Client A          Server          Client B
  │                  │                │
  │──[binary]──────►│──[binary]────►│
  │  media frame     │  forwarded    │
  │◄──[binary]──────│◄──[binary]────│
```

Binary media frame format (§6.7). No Pion needed — pure Go forwarding.

Trade-off: higher overhead, no jitter buffer (TCP), but **completely invisible** to DPI.

**Server config:**
```toml
[media]
mode = "stealth"  # "stealth" (ICE-TCP) | "performance" (UDP) | "ws-relay" | "all"
```

`"all"` enables all three — client negotiates best available.

### 6.3 Room Model

```
Room
 ├── id: UUID
 ├── creator: pubkey
 ├── participants: [pubkey]
 ├── max_participants: int (default 25)
 ├── tracks: [Track]
 ├── created_at: timestamp
 └── permissions: {pubkey → role}

Track
 ├── id: string
 ├── owner: pubkey
 ├── kind: "audio" | "video" | "screen" | "data"
 ├── codec: "opus" | "vp8" | "vp9" | "h264" | "av1"
 ├── simulcast_layers: [SimulcastLayer]
 └── muted: bool

SimulcastLayer
 ├── rid: "f" | "h" | "q"  (full, half, quarter)
 ├── width: int
 ├── height: int
 ├── max_bitrate: int
 └── max_fps: int
```

### 6.4 Room Lifecycle

```
Client                                  Server
  │                                        │
  │── room_create ────────────────────────►│
  │   {max: 25}                            │
  │◄── room_created ──────────────────────│
  │   {room_id, turn_credentials}          │
  │                                        │
  │── room_join ──────────────────────────►│
  │   {room_id}                            │
  │◄── room_info ─────────────────────────│
  │   {participants, tracks}               │
  │                                        │
  │── media_offer ────────────────────────►│
  │   {room_id, sdp}                       │  ← Client offers PeerConnection
  │◄── media_answer ──────────────────────│
  │   {sdp}                                │  ← Server answers with Pion PC
  │                                        │
  │══ WebRTC Media Established ═══════════│
  │                                        │
  │── track_publish ──────────────────────►│
  │   {kind: "audio", codec: "opus"}       │
  │◄── track_published ───────────────────│
  │   {track_id: "t1"}                     │
  │                                        │
  │◄── track_available ───────────────────│  ← Notification: other participant published
  │   {pubkey, track_id, kind}             │
  │                                        │
  │── track_subscribe ────────────────────►│
  │   {track_id: "t2"}                     │  ← Subscribe to remote track
  │◄── track_subscribed ─────────────────│
  │                                        │
  │── room_leave ─────────────────────────►│
  │◄── room_left ─────────────────────────│
```

### 6.5 Signaling Messages for SFU

#### room_create — Client → Server

```json
{
  "type": "room_create",
  "max": 25,
  "name": "optional human name",
  "e2ee": true
}
```

#### room_created — Server → Client

```json
{
  "type": "room_created",
  "room_id": "<uuid>",
  "token": "<room access token>"
}
```

#### room_join — Client → Server

```json
{
  "type": "room_join",
  "room_id": "<uuid>",
  "token": "<room access token, received via signal from caller>"
}
```

The caller shares `room_id` + `token` with callees via a `call_invite` signal through the existing messaging channel (E2EE protected).

#### room_info — Server → Client

```json
{
  "type": "room_info",
  "room_id": "<uuid>",
  "participants": [
    {"pubkey": "...", "tracks": [{"id": "t1", "kind": "audio"}, {"id": "t2", "kind": "video"}]}
  ]
}
```

#### media_offer / media_answer — SDP Exchange

```json
{
  "type": "media_offer",
  "room_id": "<uuid>",
  "sdp": "<SDP string>"
}
```

```json
{
  "type": "media_answer",
  "room_id": "<uuid>",
  "sdp": "<SDP string>"
}
```

Standard WebRTC SDP offer/answer, but between client and **server** (not peer-to-peer). Server uses Pion to create its side of the PeerConnection.

#### media_candidate — ICE Candidate

```json
{
  "type": "media_candidate",
  "room_id": "<uuid>",
  "candidate": "<ICE candidate string>",
  "sdp_mid": "0",
  "sdp_mline_index": 0
}
```

#### track_publish / track_subscribe

```json
{"type": "track_publish", "room_id": "<uuid>", "kind": "video", "codec": "vp9",
 "simulcast": true, "layers": [
   {"rid": "f", "width": 1920, "height": 1080, "maxBitrate": 3000000},
   {"rid": "h", "width": 960,  "height": 540,  "maxBitrate": 1000000},
   {"rid": "q", "width": 480,  "height": 270,  "maxBitrate": 400000}
]}

{"type": "track_subscribe", "room_id": "<uuid>", "track_id": "t2", "layer": "h"}
```

#### quality_prefer — Bandwidth Adaptation

```json
{
  "type": "quality_prefer",
  "room_id": "<uuid>",
  "track_id": "t2",
  "layer": "f",
  "max_bitrate": 5000000
}
```

Client tells server which simulcast layer it wants. Server switches forwarding.

#### speaker_update — Server → Client

```json
{
  "type": "speaker_update",
  "room_id": "<uuid>",
  "speakers": ["pubkey_a", "pubkey_c"],
  "dominant": "pubkey_a"
}
```

Server detects active speakers via audio energy levels and notifies clients. Clients can use this to show active speaker UI and auto-subscribe to their video.

### 6.6 Call Flow (1:1)

```
Caller                        Server                       Callee
  │                              │                            │
  │── signal: call_invite ──────►│── signal: call_invite ────►│
  │   {room_id, token}           │   {room_id, token}         │
  │                              │                            │
  │                              │◄── signal: call_accept ────│
  │◄── signal: call_accept ──────│                            │
  │                              │                            │
  │── room_join ────────────────►│                            │
  │◄── room_info ───────────────│                            │
  │── media_offer ──────────────►│                            │
  │◄── media_answer ────────────│                            │
  │                              │                            │
  │                              │◄── room_join ──────────────│
  │                              │──► room_info ──────────────│
  │                              │◄── media_offer ────────────│
  │                              │──► media_answer ───────────│
  │                              │                            │
  │═══ Audio/Video via SFU ═════│═══ Audio/Video via SFU ════│
```

### 6.7 Call Flow (Group)

Same as 1:1, but caller shares `room_id` + `token` with multiple contacts via `call_invite` signal. Each joins independently. Server forwards tracks selectively.

**Last-N optimization**: In large rooms (>6 participants), server only forwards the top N video streams (based on dominant speaker + pinned). Audio always forwarded for all.

```toml
[media]
last_n_video = 6         # max simultaneous video streams forwarded
speaker_detect = true     # enable audio energy detection
speaker_threshold = -40   # dBFS threshold for "speaking"
```

### 6.8 WebSocket Media Frame (ws-relay mode only)

For `ws-relay` mode — binary frames on the `/v2` WebSocket:

```
Byte 0:       Frame type
                0x10 = audio
                0x11 = video keyframe
                0x12 = video delta
                0x13 = screen keyframe
                0x14 = screen delta
                0x15 = data channel
Bytes 1-16:   Room ID (UUID, 16 bytes)
Byte 17:      Track index (0-255)
Bytes 18-21:  Sequence (uint32 BE)
Bytes 22-25:  Timestamp (uint32 BE, 48kHz clock for audio, 90kHz for video)
Byte 26:      Flags
                bit 0: marker (end of frame)
                bit 1: has FEC
                bit 2: E2EE encrypted (SFrame)
Bytes 27+:    Payload (Opus/VP9/H264/AV1 encoded data)
```

27 bytes overhead. Server reads room_id + track_index, looks up subscribers, forwards the binary frame to each.

### 6.9 E2EE for Calls (Optional)

When `e2ee: true` in `room_create`:

- Participants derive shared room key via Diffie-Hellman key exchange (X25519)
- Media encrypted with SFrame (Secure Frame) before RTP packetization
- Server forwards encrypted SRTP — cannot decode media
- Key ratcheting: new key every 256 frames
- Insertable Streams API (WebRTC) or manual encrypt in ws-relay mode

Note: SFrame support depends on flutter_webrtc capabilities. If unavailable, DTLS-SRTP provides transport-level encryption (server can theoretically see media, but it's self-hosted).

### 6.10 Bandwidth Estimation & Adaptation

Server-side:
- REMB (Receiver Estimated Maximum Bitrate) processing from Pion
- TWCC (Transport-Wide Congestion Control) feedback
- Proactive layer switching when receiver bandwidth drops

Client-side:
- Reports `quality_prefer` when UI changes (e.g., grid → spotlight)
- Pauses tracks not visible in UI (`track_pause` / `track_resume`)

```json
{"type": "track_pause", "room_id": "...", "track_id": "t5"}
{"type": "track_resume", "room_id": "...", "track_id": "t5"}
```

---

## 7. Federation

### 7.1 Overview

Federation allows multiple Pulse servers to form a mesh. Users on Server A can message and call users on Server B.

### 7.2 Federation Modes

```toml
[federation]
mode = "disabled"    # "disabled" | "private" | "open"
```

| Mode | Behavior |
|---|---|
| `disabled` | No federation. Standalone server. |
| `private` | Whitelist only. Admin manually adds peers via CLI. |
| `open` | Any Pulse server can connect and federate. Uses challenge auth. |

### 7.3 Peer Authentication

Server-to-server auth via Ed25519 (same as v1, upgraded envelope):

```json
{
  "type": "fed_hello",
  "v": 2,
  "pubkey": "<server ed25519 pubkey>",
  "ts": 1712234567,
  "sig": "<signature over 'pulse-fed-v2:<pubkey>:<ts>'>",
  "server": {
    "name": "My Relay",
    "version": "2.0.0",
    "features": ["sfu", "media_proxy"],
    "users": 42
  }
}
```

In `private` mode, server rejects `fed_hello` from unknown pubkeys.
In `open` mode, server accepts any valid signature.

### 7.4 Message Routing

```
User A@Server1 → User B@Server2

1. A sends "send" to Server1
2. Server1: is B in local users? NO
3. Server1: do I have a federation route for B? Check peer connections.
4. Server1 → Server2: fed_envelope {from: A, to: B, body: ...}
5. Server2: is B local? YES → deliver
6. Server2 → Server1: fed_ack {id: ...}
```

**Enhanced routing (v2)**: servers maintain a lightweight **user directory hint table**:

```sql
CREATE TABLE fed_user_hints (
  pubkey TEXT,
  peer_pubkey TEXT,         -- which federation peer hosts this user
  last_seen INTEGER,        -- when we last saw traffic for this user on that peer
  PRIMARY KEY (pubkey, peer_pubkey)
);
```

When Server1 delivers to B@Server2 successfully, it records the hint. Next message to B goes directly to Server2 instead of broadcasting to all peers.

Hints expire after 7 days. If delivery fails, hint is cleared and server falls back to broadcast.

### 7.5 Federated Calls

For calls across servers, the SFU room is hosted on the **caller's server**. Callee's server proxies the WebRTC connection:

```
Callee ──WebRTC──► Server2 ──federation WS──► Server1 (SFU room)
```

Server2 acts as a media proxy: it terminates the callee's WebRTC connection and relays RTP packets to Server1 via the federation WebSocket (binary frames). This adds latency but avoids exposing Server1's IP to the callee.

Alternative: callee connects directly to Server1 (lower latency, but requires Server1 to be accessible).

```json
{
  "type": "fed_media_proxy",
  "room_id": "<uuid>",
  "from": "<callee pubkey>",
  "data": "<base64 RTP packet>"
}
```

### 7.6 Federation Envelope

```json
{
  "type": "fed_envelope",
  "id": "<message uuid>",
  "from": "<sender pubkey>",
  "to": "<recipient pubkey>",
  "kind": "message",
  "body": "<encrypted payload>",
  "ts": 1712234567,
  "ttl": 604800,
  "hops": 1
}
```

`hops` prevents infinite forwarding. Max hops: 2 (originator → peer → peer). Server increments on forward, drops if > max.

---

## 8. Tunnel / Proxy (Built-in VPN)

Pulse server doubles as a **selective proxy** — clients can route arbitrary TCP traffic through the server, disguised as normal HTTPS WebSocket traffic.

### 8.1 Architecture

```
┌─ Client Device ────────────────────────────┐
│                                             │
│  Browser / App (youtube.com)               │
│         ↓                                   │
│  ┌─ Proxy Modes ─────────────────────────┐ │
│  │ A) System SOCKS5 proxy (Linux)        │ │
│  │ B) Android VpnService + tun2socks     │ │
│  │ C) Per-app proxy (PAC / ProxyProvider)│ │
│  └───────────┬───────────────────────────┘ │
│              ↓                              │
│  Pulse client: tunnel_open via /v2 WS      │
│              ↓ TLS, looks like HTTPS        │
└──────────────┼──────────────────────────────┘
               ↓
┌─ Pulse Server (:443) ──────────────────────┐
│                                             │
│  Receives tunnel_open {host, port}         │
│  Opens TCP to target host                   │
│  Bidirectional byte relay ← binary frames  │
│                                             │
└─────────────┬───────────────────────────────┘
              ↓
         youtube.com / telegram.org / etc.
```

### 8.2 Tunnel Protocol

Tunnels reuse the authenticated `/v2` WebSocket connection. No extra connection needed.

#### tunnel_open — Client → Server

```json
{
  "type": "tunnel_open",
  "tunnel_id": "<uuid>",
  "host": "youtube.com",
  "port": 443
}
```

#### tunnel_opened — Server → Client

```json
{
  "type": "tunnel_opened",
  "tunnel_id": "<uuid>",
  "remote_ip": "142.250.185.46"
}
```

#### tunnel_error — Server → Client

```json
{
  "type": "tunnel_error",
  "tunnel_id": "<uuid>",
  "reason": "connection_refused"
}
```

Possible reasons: `connection_refused`, `dns_failed`, `timeout`, `blocked`, `rate_limited`, `tunnel_disabled`.

#### tunnel_close — Bidirectional

```json
{
  "type": "tunnel_close",
  "tunnel_id": "<uuid>"
}
```

#### Binary tunnel data

```
Byte 0:       0x20 (tunnel data, client→server)
              0x21 (tunnel data, server→client)
Bytes 1-16:   Tunnel ID (UUID, 16 bytes)
Bytes 17+:    Raw TCP payload
```

17 bytes overhead per frame. Server reads tunnel_id, forwards payload bytes to/from the corresponding TCP connection.

### 8.3 Client Proxy Modes

| Mode | What is proxied | Config key |
|---|---|---|
| `off` | Nothing — only messenger traffic | Default |
| `list` | Specific domains (user-configurable list) | `proxy_domains` |
| `geo` | Domains blocked in user's country (GeoIP + community lists) | `proxy_geo_country` |
| `all` | All device traffic (full VPN) | — |

Client-side domain list example (shared_preferences):
```json
{
  "proxy_mode": "list",
  "proxy_domains": [
    "*.telegram.org", "t.me",
    "youtube.com", "*.googlevideo.com", "*.ytimg.com",
    "twitter.com", "x.com", "*.twimg.com",
    "instagram.com", "*.cdninstagram.com",
    "*.wikipedia.org",
    "openai.com", "chat.openai.com"
  ]
}
```

### 8.4 Android VPN Integration

On Android, to capture **all** device traffic (mode `all`):

1. Pulse registers a `VpnService`
2. Creates TUN interface via `VpnService.Builder`
3. Runs `tun2socks` (Go library) — converts IP packets to SOCKS5 connections
4. SOCKS5 connects through the Pulse WS tunnel
5. Exclude Pulse's own server IP from VPN to prevent loop

For mode `list`: use `VpnService.Builder.addRoute()` with resolved IPs of target domains, or route everything and short-circuit non-listed domains locally.

### 8.5 Concurrent Tunnels

Multiple tunnels can be open simultaneously on the same WebSocket connection. Each has a unique `tunnel_id`. Server maintains a map:

```
tunnel_id → net.Conn (TCP connection to target)
```

Limits:
```toml
[tunnel]
enabled = true
max_tunnels_per_user = 32        # concurrent connections
bandwidth_limit_mbps = 100       # per-user bandwidth cap (0 = unlimited)
allowed_ports = [80, 443]        # restrict target ports (empty = all)
blocked_hosts = ["*.gov.cn"]     # block specific destinations
dns_provider = "doh"             # resolve targets via DoH (prevents DNS leak)
```

### 8.6 Security Considerations

- Server resolves DNS via DoH — no DNS leak to local ISP
- Server rejects connections to private IPs (10.x, 192.168.x, 127.x) — prevents SSRF
- Per-user bandwidth cap prevents abuse
- `allowed_ports = [80, 443]` by default — prevents port scanning via tunnel
- Server logs only byte counts, never URLs or payload content (when `access_log = false`)
- All tunnel traffic is inside TLS — ISP/GFW sees only encrypted WebSocket frames to a "website"

---

## 9. Metadata Protection

### 10.1 Threat Model — What Adversaries See

Without protection, an adversary (ISP, GFW, NSA, GCHQ) can learn:

| Layer | What leaks | Who sees it |
|---|---|---|
| **Network** | Client IP ↔ Server IP, connection times, data volume per second, packet sizes | ISP, backbone, nation-state |
| **TLS** | SNI (server name), cert fingerprint, timing of handshakes | Passive DPI |
| **Server (if compromised)** | Who sent to whom, timestamps, message sizes, online/offline patterns | Admin, law enforcement with server access |
| **Traffic analysis** | Correlation: "user A sent X bytes at 14:03:07, user B received X bytes at 14:03:07" → A talks to B | Nation-state with network visibility |

Even with TLS, a passive observer sees **timing and volume patterns**. This is enough to:
- Determine who talks to whom (correlation attacks)
- Detect when someone is active vs idle
- Estimate conversation frequency
- Identify call vs text vs file transfer by traffic shape

### 9.2 Network-Level Protections

#### 9.2.1 Constant-Rate Padding (Traffic Shaping)

The most powerful defense against traffic analysis. Client and server maintain a **constant bitrate** connection — real messages hidden in the stream.

```
Without padding:
  ──────┐  ┌──┐     ┌─────┐          ┌─┐──────
        │  │  │     │     │          │ │
  idle  msg idle    file   idle      msg idle

  → adversary sees: message at 14:03, file at 14:07, message at 14:22

With CBR padding:
  ████████████████████████████████████████████████
  constant stream, real messages buried inside

  → adversary sees: constant HTTPS traffic to a "website", nothing else
```

**Implementation:**

```toml
[privacy]
padding = true
padding_mode = "cbr"             # "cbr" (constant bitrate) | "burst" (random bursts)
padding_rate_kbps = 32           # constant 32 kbps both directions
padding_jitter_pct = 20          # ±20% random variation to avoid fingerprinting the constant rate itself
```

Client sends `0xFF` binary frames to fill bandwidth up to `padding_rate_kbps`. When a real message is sent, padding is reduced proportionally so total rate stays constant.

For calls: padding is unnecessary (continuous media stream already masks traffic shape).

**CBR overhead**: 32 kbps × 3600s = ~14 MB/hour. Acceptable for always-on messenger.

#### 9.2.2 Message Size Normalization

All messages padded to fixed size buckets to prevent size-based fingerprinting:

| Bucket | Padded to | Use case |
|---|---|---|
| Tiny | 256 bytes | ACKs, typing indicators, presence |
| Small | 1 KB | Short text messages |
| Medium | 4 KB | Long messages, small images |
| Large | 16 KB | Signals, key exchanges |
| XLarge | 64 KB | Chunked transfers use fixed chunk sizes |

Client adds random bytes (PKCS#7-style) before encryption. Recipient strips padding after decryption.

```json
{
  "type": "send",
  "id": "...",
  "to": "...",
  "body": "<encrypted + padded to bucket size>",
  "pad": 768
}
```

`pad` field tells recipient how many bytes to strip (encrypted inside `body`, not visible to server).

#### 9.2.3 Timing Obfuscation

Messages are not delivered instantly — server adds random delay:

```toml
[privacy]
delivery_jitter_ms = 500         # random delay 0-500ms on each message delivery
```

This breaks timing correlation: adversary can't match "A sent at T" with "B received at T+network_latency" because server adds random T+0..500ms.

For signals (WebRTC): jitter disabled (real-time requirement).

#### 9.2.4 IP Protection

| Scenario | Client IP hidden from | How |
|---|---|---|
| **Direct connection** | External observers (ISP sees server IP only) | TLS |
| **Behind Cloudflare** | Server itself | CF terminates TLS, forwards X-Real-IP (server can ignore) |
| **Through Tor** | Server and ISP | Tor exit node IP visible to server |
| **Through uTLS+Tor** | Server, ISP, and DPI | Chrome fingerprint + Tor IP |

Server config:
```toml
[privacy]
store_client_ip = false          # NEVER store connecting IPs
access_log = false               # no HTTP access logs
strip_forwarded_headers = true   # ignore X-Forwarded-For, X-Real-IP
```

### 9.3 Server-Side Metadata Minimization

Even if the server is seized or compromised, adversary should learn **minimum**.

#### 9.3.1 Zero-Knowledge Message Store

Offline messages stored as:

```sql
CREATE TABLE offline_messages (
  id TEXT PRIMARY KEY,              -- random UUID (not sequential)
  recipient TEXT NOT NULL,          -- pubkey of recipient (server MUST know for routing)
  blob BLOB NOT NULL,               -- encrypted payload (opaque to server)
  size INTEGER NOT NULL,            -- padded size (bucket-normalized)
  expires INTEGER NOT NULL,         -- auto-delete timestamp
  created INTEGER NOT NULL          -- receive timestamp (for ordering only)
);
-- NO sender column. NO metadata columns. NO indexes on content.
```

**What server knows**: someone sent `N` bytes to `recipient` at `time`.
**What server does NOT know**: who sent it (sealed sender), what it contains, message type.

#### 9.3.2 Sealed Sender

Inspired by Signal's sealed sender. Server knows the recipient but **not the sender**.

**How it works:**

1. On auth, server issues **delivery certificates** — signed single-use tokens:
```json
{
  "type": "auth_ok",
  "delivery_certs": [
    {"token": "<random_token_1>", "expires": 1712320967},
    {"token": "<random_token_2>", "expires": 1712320967},
    ...  // 50 tokens, each single-use
  ]
}
```

2. Each token is: `HMAC(server_secret, random_id || expires)` — server can verify without storing.

3. When sending, client uses a **separate sealed connection**:
```
Client A                              Server
  │                                      │
  │── WS /v2/sealed ───────────────────►│  ← no auth, anonymous connection
  │                                      │
  │── sealed_send ──────────────────────►│
  │   {                                  │
  │     "cert": "<delivery_token>",     │  ← proves "I'm a valid user" but not WHICH user
  │     "to": "<recipient pubkey>",     │
  │     "body": "<encrypted blob>"      │  ← sender identity inside, encrypted for recipient
  │   }                                  │
  │                                      │
  │◄── ack ─────────────────────────────│
```

4. Server verifies `cert` is valid HMAC → message is from a registered user. Delivers to `to`. **Server never learns sender identity.**

5. Recipient decrypts `body` with their key → finds sender pubkey inside (part of Signal Protocol envelope).

**Key detail**: the sealed connection must come from a **different IP/circuit** than the identity connection. Otherwise server correlates by IP. Solutions:
- Client sends sealed messages through **Tor** (different exit node)
- Or through **different Cloudflare edge** (CF randomizes)
- Or server enforces: `strip_forwarded_headers = true` + doesn't log IPs

For self-hosted: if you control the server, you can trust it won't correlate. Sealed sender still protects against **future compromise** (seized server logs show no sender info).

```toml
[privacy]
sealed_sender = true             # enable /v2/sealed endpoint
sealed_cert_count = 50           # certs issued per auth session
sealed_cert_ttl = "24h"          # cert validity period
```

#### 9.3.3 Ephemeral Routing State

Server forgets routing information as fast as possible:

| Data | Retention |
|---|---|
| Online user list | RAM only, lost on restart |
| Message routing (who→whom) | Not stored. Only `recipient` in offline DB. |
| IP addresses | Never stored (`store_client_ip = false`) |
| Signal delivery | RAM only, no logging |
| Room participants | RAM only, purged on room close |
| Federation hints | 7 days, then auto-purged |
| File blobs | TTL-based, auto-purged |
| Auth logs | Disabled by default |

#### 9.3.4 Plausible Deniability

Server can prove to law enforcement: "I literally cannot tell you who sent this message. My database has recipient + encrypted blob. No sender, no IPs, no logs."

Database after seizure reveals:
```
id:        a1b2c3d4-random-uuid
recipient: 7f8a9b0c...  (a pubkey — need to link to real person separately)
blob:      [encrypted bytes — AES-256-GCM, undecryptable without recipient's key]
size:      4096  (padded — actual message could be 1 byte or 4000 bytes)
expires:   1712838567  (auto-deletes in 7 days anyway)
created:   1712234567
```

No sender. No IPs. No message content. No metadata.

### 9.4 Anti-Correlation Measures

Even with all above, a **global passive adversary** (NSA with backbone taps) can try correlation attacks. Mitigations:

#### 9.4.1 Decoy Traffic (Chaff)

Client periodically sends **fake messages** to random pubkeys:

```toml
[privacy]
chaff = true
chaff_interval_sec = 300         # send a fake message every ~5 minutes
chaff_recipients = "random"      # "random" | "contacts" (send to own contacts, indistinguishable)
```

Fake messages are valid encrypted blobs. Recipient's client silently discards them (magic byte in decrypted payload). Server can't tell real from fake.

This means: even if adversary sees "user A sent a message", they can't know if it's real or chaff.

#### 9.4.2 Batched Delivery

Instead of delivering messages one-by-one (revealing timing), server batches:

```toml
[privacy]
batch_delivery = true
batch_interval_ms = 2000         # deliver all pending messages every 2 seconds
```

Every 2 seconds, server delivers ALL pending messages for ALL online users simultaneously. Adversary sees a burst of traffic to many users at the same time — can't correlate specific sender→recipient pairs.

#### 9.4.3 Connection Persistence

Client maintains **always-on** WebSocket connection. Never disconnects between messages. From the outside, it looks like a persistent HTTPS connection to a website (CDN long-poll, streaming API, etc.).

```
Bad:  connect → send message → disconnect → ... → connect → send message → disconnect
      (adversary learns: user active at specific times)

Good: connect ████████████████████████████████████████████████████████████
      (constant connection, CBR padding, adversary learns nothing)
```

### 9.5 Metadata Protection Summary

| Attack | Protection | Strength |
|---|---|---|
| Read message content | Signal Protocol E2EE | Proven, unbreakable |
| Identify sender | Sealed sender + delivery certs | Server can't link sender to message |
| Identify recipient | Not possible to fully hide (server must route) | Recipient pubkey visible to server |
| Timing correlation | CBR padding + delivery jitter + batching | Very strong against passive adversary |
| Volume analysis | Message size normalization (bucket padding) | Size reveals nothing |
| Activity detection | Always-on connection + CBR + chaff | User appears always active |
| Seized server forensics | No sender, no IPs, no logs, TTL auto-delete | Plausible deniability |
| Global passive adversary | CBR + chaff + batching + Tor | As strong as practically possible |

### 9.6 Protection Levels (User-configurable)

Not everyone needs NSA-level protection. Three presets:

| Preset | Padding | Sealed Sender | Chaff | Batching | Jitter | For whom |
|---|---|---|---|---|---|---|
| **Standard** | Off | Off | Off | Off | Off | Normal use, lowest overhead |
| **Private** | Burst | On | Off | Off | 200ms | Journalists, activists |
| **Paranoid** | CBR 32kbps | On | On | 2s batch | 500ms | Nation-state threat model |

```toml
[privacy]
preset = "standard"  # "standard" | "private" | "paranoid" | "custom"
```

Client UI: simple toggle in settings — "Privacy Level: Standard / Private / Maximum".

---

## 10. Censorship Resistance

### 10.1 Threat Model

| Threat | Mitigation |
|---|---|
| DPI identifies WebSocket | Probe resistance (decoy website), standard TLS |
| GFW blocks server IP | Cloudflare mode (IP hidden behind CDN) |
| DNS poisoning | DoH in client, or Cloudflare DNS |
| TLS fingerprinting | Client uses uTLS (Chrome fingerprint) |
| Active probing | Decoy website + auth-gated WS upgrade |
| Traffic analysis (flow shape) | Optional padding (§8.3) |
| Server takedown | Federation — data on multiple servers |
| Certificate blocking | Certificate pinning (domain-free mode) |
| SNI-based blocking | ECH via Cloudflare, or IP-only mode (no SNI) |

### 10.2 Connection Chain (Client-side)

Client tries connections in order:

```
1. uTLS + ECH (Chrome fingerprint, hide SNI)
   ↓ fail
2. Cloudflare Worker relay (domain fronting)
   ↓ fail
3. Custom SOCKS5 proxy
   ↓ fail
4. Psiphon tunnel
   ↓ fail
5. uTLS + Tor SOCKS5 (Chrome fingerprint + Tor IP)
   ↓ fail
6. Plain Tor SOCKS5
   ↓ fail
7. I2P SOCKS5
   ↓ fail
8. Direct connection (last resort)
```

Server doesn't need to know which transport the client used — it sees a normal TLS WebSocket connection.

### 10.3 Traffic Padding (Optional)

To prevent traffic analysis (GFW correlating message sends with network bursts):

```toml
[privacy]
padding = true
padding_interval_ms = 100    # send dummy frames every 100ms
padding_max_bytes = 256       # random-sized padding up to 256 bytes
```

Server sends random-sized binary frames (type `0xFF`) at fixed intervals. Client ignores them. This creates constant-rate traffic that masks real message timing.

### 10.4 Domain-free Stealth

For maximum stealth without a domain:

1. Server on VPS with IP `185.x.x.x`, port 443
2. Self-signed TLS cert, fingerprint shared via QR/link
3. Server decoy: looks like nginx default page
4. Client connects with uTLS Chrome fingerprint
5. GFW probe connects → sees nginx page → moves on
6. Client sends correct WS protocol header → gets authenticated → messaging works

No domain, no DNS, no SNI (`ServerName` = IP address or empty). TLS to bare IP is common (APIs, IoT, internal services) — not suspicious.

---

## 11. Configuration Reference

Complete `config.toml`:

```toml
[server]
listen = "0.0.0.0:443"          # bind address
data_dir = "./data"              # SQLite, certs, logs
tls_mode = "self-signed"         # self-signed | manual | acme | none
tls_cert = ""                    # path (manual mode)
tls_key = ""                     # path (manual mode)
domain = ""                      # for acme mode

[auth]
mode = "invite"                  # open | invite | closed

[storage]
message_ttl = "7d"               # duration: 7d, 24h, 30d, etc.
max_message_bytes = 536870912    # 512 MB
max_backup_bytes = 52428800      # 50 MB
delete_on_ack = true             # delete offline messages after client ack

[media]
enabled = true
mode = "stealth"                 # stealth (ICE-TCP) | performance (UDP) | ws-relay | all
max_room_size = 25               # max participants per room
last_n_video = 6                 # max video streams forwarded in large rooms
simulcast = true                 # enable simulcast
speaker_detect = true            # audio energy detection
recording = false                # server-side recording (future)

[federation]
mode = "disabled"                # disabled | private | open
max_hops = 2

[privacy]
preset = "standard"              # standard | private | paranoid | custom
access_log = false               # don't log IPs
store_client_ip = false          # never store connecting IPs
strip_forwarded_headers = true   # ignore X-Forwarded-For headers
delete_on_ack = true             # delete offline messages after client ack
# -- Custom privacy overrides (only when preset = "custom") --
padding = false                  # traffic padding
padding_mode = "cbr"             # cbr | burst
padding_rate_kbps = 32           # constant bitrate rate
padding_jitter_pct = 20          # ±% variation
sealed_sender = false            # enable /v2/sealed anonymous delivery
sealed_cert_count = 50           # delivery certs per auth session
sealed_cert_ttl = "24h"          # cert validity
delivery_jitter_ms = 0           # random delay on delivery (0 = off)
batch_delivery = false           # batch all deliveries
batch_interval_ms = 2000         # batch window
chaff = false                    # send decoy messages
chaff_interval_sec = 300         # chaff frequency

[limits]
messages_per_minute = 60
signals_per_minute = 120
max_connections = 1000
max_rooms = 100

[tunnel]
enabled = true
max_tunnels_per_user = 32        # concurrent TCP connections
bandwidth_limit_mbps = 100       # per-user cap (0 = unlimited)
allowed_ports = [80, 443]        # restrict target ports (empty = all)
blocked_hosts = []               # block specific destinations
dns_provider = "doh"             # resolve via DoH (prevents DNS leak)

[decoy]
server_header = "nginx/1.24.0"   # fake Server header
index_html = "decoy/index.html"  # path to decoy homepage
favicon = "decoy/favicon.ico"
```

---

## 12. Wire Format Summary

### Text frames (JSON)

| Direction | Type | Purpose |
|---|---|---|
| S→C | `auth_challenge` | Auth nonce |
| C→S | `auth_response` | Auth signature |
| S→C | `auth_ok` | Auth success + server info + TURN creds |
| C→S | `send` | Send message |
| S→C | `message` | Receive message |
| ↔ | `ack` | Acknowledge |
| C→S | `fetch` | Fetch offline messages |
| S→C | `stored` | Batch of offline messages |
| C→S | `signal` | Real-time signal (WebRTC, typing, etc.) |
| S→C | `signal` | Forward signal |
| S→C | `signal_fail` | Signal undeliverable |
| C→S | `keys_put` | Publish key bundle |
| C→S | `keys_get` | Request key bundle |
| S→C | `keys` | Key bundle response |
| C→S | `backup_put` | Upload backup |
| C→S | `backup_get` | Request backup |
| S→C | `backup` | Backup data |
| C→S | `room_create` | Create SFU room |
| S→C | `room_created` | Room created + token |
| C→S | `room_join` | Join SFU room |
| S→C | `room_info` | Room state |
| C→S | `room_leave` | Leave room |
| C→S | `media_offer` | SDP offer to server |
| S→C | `media_answer` | SDP answer from server |
| ↔ | `media_candidate` | ICE candidate |
| C→S | `track_publish` | Announce track |
| S→C | `track_published` | Track ID assigned |
| S→C | `track_available` | Remote track published |
| C→S | `track_subscribe` | Subscribe to track |
| S→C | `track_subscribed` | Subscription confirmed |
| C→S | `track_pause` | Pause track reception |
| C→S | `track_resume` | Resume track reception |
| C→S | `quality_prefer` | Request simulcast layer |
| S→C | `speaker_update` | Active speakers changed |
| C→S | `upload_start` | Begin file upload |
| S→C | `upload_ack` | Upload accepted |
| S→C | `upload_complete` | Upload finished |
| C→S | `upload_resume` | Resume interrupted upload |
| C→S | `download_req` | Request file download |
| C→S | `tunnel_open` | Open TCP tunnel |
| S→C | `tunnel_opened` | Tunnel established |
| ↔ | `tunnel_close` | Close tunnel |
| S→C | `tunnel_error` | Tunnel failed |
| C→S | `sealed_send` | Send message without revealing sender (via /v2/sealed) |
| ↔ | `ping` / `pong` | Keepalive |
| S→C | `error` | Error response |

### Binary frames

| Byte 0 | Purpose |
|---|---|
| `0x01` | Upload chunk |
| `0x02` | Download chunk |
| `0x10` | Audio media (ws-relay mode) |
| `0x11` | Video keyframe (ws-relay mode) |
| `0x12` | Video delta (ws-relay mode) |
| `0x13` | Screen keyframe (ws-relay mode) |
| `0x14` | Screen delta (ws-relay mode) |
| `0x15` | Data channel (ws-relay mode) |
| `0x20` | Tunnel data (client → server) |
| `0x21` | Tunnel data (server → client) |
| `0xFF` | Padding (traffic analysis resistance) |

---

## 13. Migration from v1

v2 is **backward-compatible** with v1 clients:

1. Server supports both `/ws` (v1) and `/v2` (v2) endpoints
2. v1 message types map directly to v2 (envelope format unchanged for messaging)
3. SFU features only available on `/v2`
4. Federation v1 peers connect on `/federation`, v2 peers on `/v2/federation`
5. Server auto-detects protocol version from endpoint

Migration path: upgrade server first, then clients. v1 clients continue working on `/ws` indefinitely.

---

## 14. Implementation Phases

### Phase 1: Core Protocol v2
- [ ] New `/v2` WebSocket endpoint with probe resistance
- [ ] Flat message envelope (no nested payload)
- [ ] Chunked binary transfer
- [ ] Certificate pinning (domain-free mode)
- [ ] Configurable decoy website

### Phase 2: SFU Media
- [ ] Pion WebRTC integration
- [ ] Room lifecycle (create/join/leave)
- [ ] Track publish/subscribe
- [ ] ICE-TCP mux on :443 (stealth mode)
- [ ] UDP mode (performance)
- [ ] Simulcast layer selection

### Phase 3: Advanced Media
- [ ] Speaker detection
- [ ] Last-N video optimization
- [ ] Bandwidth estimation (REMB/TWCC)
- [ ] ws-relay mode (maximum stealth)
- [ ] Screen sharing via SFU
- [ ] SFrame E2EE (if flutter_webrtc supports)

### Phase 4: Federation v2
- [ ] User directory hints
- [ ] Hop-limited forwarding
- [ ] Federated media proxy
- [ ] Open federation mode

### Phase 5: Tunnel / Proxy
- [ ] `tunnel_open` / `tunnel_close` / binary relay
- [ ] DoH resolution for tunnel targets
- [ ] Per-user bandwidth limiting
- [ ] Android VpnService integration
- [ ] Domain list / GeoIP selective proxy
- [ ] tun2socks for full VPN mode

### Phase 6: Metadata Protection
- [ ] Message size normalization (bucket padding)
- [ ] CBR traffic padding (constant-rate `0xFF` frames)
- [ ] Delivery jitter (random delay)
- [ ] Sealed sender (`/v2/sealed` + delivery certificates)
- [ ] Decoy traffic (chaff messages)
- [ ] Batched delivery
- [ ] Zero-knowledge offline store (no sender column)
- [ ] Privacy presets UI (Standard / Private / Paranoid)

### Phase 7: Hardening
- [ ] Traffic padding
- [ ] Rate limiting per-room
- [ ] Abuse detection (PoW for open mode)
- [ ] Admin dashboard
- [ ] Metrics / monitoring
