# Pulse Next-Generation Media Protocol — Full Technical Specification

**Version:** 0.1-draft
**Status:** Research specification
**Date:** 2026-04-04
**Scope:** Four modalities — voice, parametric video, smart screen sharing, traffic obfuscation

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Modality 1: Ultra-Low Bitrate Voice](#2-modality-1-ultra-low-bitrate-voice)
3. [Modality 2: Parametric Video](#3-modality-2-parametric-video)
4. [Modality 3: Smart Screen Sharing](#4-modality-3-smart-screen-sharing)
5. [Modality 4: Traffic Obfuscation](#5-modality-4-traffic-obfuscation)
6. [Unified Multiplexing Layer](#6-unified-multiplexing-layer)
7. [Capability Negotiation](#7-capability-negotiation)
8. [Quality Metrics & Mode Switching](#8-quality-metrics--mode-switching)
9. [Hardware Requirements Matrix](#9-hardware-requirements-matrix)
10. [Implementation Roadmap](#10-implementation-roadmap)
11. [Open Problems & Research Directions](#11-open-problems--research-directions)

---

## 1. Design Principles

1. **Bandwidth minimality** — every bit must justify its existence
2. **Perceptual quality over mathematical quality** — optimize for human perception, not PSNR
3. **Graceful degradation** — every modality has a fallback chain, never a cliff
4. **E2EE first** — all processing happens on-device, server sees only encrypted opaque blobs
5. **Heterogeneous devices** — negotiate capabilities, never assume hardware
6. **Stealth** — traffic indistinguishable from HTTPS browsing to any observer

---

## 2. Modality 1: Ultra-Low Bitrate Voice

### 2.1 Codec Selection & Configuration

**Primary codec: Opus (RFC 6716)**

| Parameter | Value | Rationale |
|---|---|---|
| Sample rate | 16000 Hz (wideband) | Sufficient for speech intelligibility; 48 kHz adds 30% bitrate for inaudible improvement in voice |
| Frame size | 20 ms | Balance of latency (low) and compression efficiency (high). 10ms saves 10ms latency but costs ~15% more bitrate |
| Channels | 1 (mono) | Stereo adds 50-80% bitrate; spatial audio unnecessary for voice calls |
| Application mode | `OPUS_APPLICATION_VOIP` | Enables built-in VAD, optimized for speech |
| Bitrate | Adaptive 6-24 kbps (see §2.3) | |
| Complexity | 5 (mobile) / 10 (desktop) | Higher = better quality per bit, but more CPU |
| DTX (Discontinuous Transmission) | Enabled | Transmits comfort noise (CN) during silence at ~1-2 kbps instead of encoding silence |
| FEC (Forward Error Correction) | Enabled, `useinbandfec=1` | Embeds redundancy of previous frame in current packet. Adds ~10-20% overhead but survives 10-20% packet loss without PLC |
| FEC packet loss threshold | 5% | FEC enabled when measured loss > 5%; below this, overhead not justified |
| VBR | Constrained VBR | `OPUS_SET_VBR(1)` + `OPUS_SET_VBR_CONSTRAINT(1)`. Allows bitrate variation per frame but within bounds |
| Packet loss percentage hint | Dynamic | `OPUS_SET_PACKET_LOSS_PERC(measured_loss)`. Tells encoder current loss rate so it can adjust FEC depth |
| Signal type | `OPUS_SIGNAL_VOICE` | Disables music optimization paths |
| Max bandwidth | `OPUS_BANDWIDTH_WIDEBAND` | 16 kHz ceiling. Prevents upsampling to superwideband (24 kHz) which wastes bits |

**Secondary codec: Lyra v2 (Google)**

For ultra-constrained links (< 6 kbps usable bandwidth):

| Parameter | Value |
|---|---|
| Bitrate | 3.2 kbps fixed |
| Frame size | 20 ms |
| Sample rate | 16000 Hz |
| Architecture | Autoregressive generative model (WaveGRU) |
| Quality | MOS 3.5-3.8 at 3.2 kbps (comparable to Opus at 9-10 kbps) |

Lyra requires ML inference on-device (~5ms on Snapdragon 855+, ~15ms on older SoCs).

**Tertiary codec: Codec2 (open source)**

For absolute minimum bitrate (emergency/disaster scenarios):

| Parameter | Value |
|---|---|
| Bitrate | 700 bps - 3200 bps |
| Frame size | 40 ms (700/1200) or 20 ms (3200) |
| Quality | MOS 2.5-3.2 (intelligible but robotic) |
| Use case | Satellite, HF radio, extreme bandwidth constraints |

### 2.2 Packet Loss Concealment (PLC)

**Three-tier PLC strategy:**

**Tier 1: Opus FEC recovery (0-20% loss)**
- In-band FEC: decoder reconstructs lost frame from redundancy in next packet
- One-packet latency cost (20ms additional delay for FEC recovery)
- Effective up to ~20% random loss

**Tier 2: Enhanced PLC via interpolation (20-40% loss)**
- When FEC data unavailable (consecutive losses), use Opus internal PLC:
  - Pitch period extrapolation from last decoded frame
  - Spectral envelope fade-to-noise over 5 frames (100ms)
  - Energy decay: -6 dB per lost frame
- Supplemented by:
  - WebRTC NetEq jitter buffer with adaptive depth (20-200ms)
  - Packet reordering tolerance: accept out-of-order packets within jitter buffer window

**Tier 3: Generative PLC via neural model (40%+ loss)**
- Use LPCNet-based PLC (from WebRTC M96+):
  - Trained on speech corpora to predict next 20ms from previous context
  - Runs on CPU, ~2ms per frame on ARM Cortex-A76
  - Quality: extends intelligible audio for up to 120ms of consecutive loss
- Fallback: mute with visual "connection issues" indicator after 200ms consecutive loss

### 2.3 Adaptive Bitrate (ABR)

**Control signal: RTCP Receiver Reports + Transport-Wide Congestion Control (TWCC)**

```
Measured parameters:
  - RTT (round-trip time) from RTCP SR/RR
  - Packet loss % from RTCP RR
  - Jitter from RTCP RR
  - Available bandwidth estimate from TWCC (RFC 8888)

Bitrate ladder:
  Quality    Bitrate    Trigger conditions
  ────────────────────────────────────────────────────────
  Excellent  24 kbps    loss < 2%, RTT < 150ms, BW > 50 kbps
  Good       16 kbps    loss < 5%, RTT < 300ms, BW > 30 kbps
  Fair       10 kbps    loss < 15%, RTT < 500ms, BW > 15 kbps
  Low         6 kbps    loss < 25%, RTT < 1000ms, BW > 8 kbps
  Lyra      3.2 kbps    loss > 25% OR BW < 8 kbps (if Lyra supported)
  Codec2    1.2 kbps    BW < 4 kbps (emergency mode)
  Muted        0        BW < 2 kbps or loss > 50%
```

**ABR algorithm: Modified GCC (Google Congestion Control)**

```
every 200ms:
  bw_estimate = TWCC.estimatedBandwidth()
  loss = RTCP_RR.fractionLost()
  rtt = RTCP_RR.roundTripTime()

  // Hysteresis: go down fast, come up slow
  if loss > current_tier.max_loss OR rtt > current_tier.max_rtt:
    decrease_tier()          // immediate
    decrease_cooldown = 3s   // prevent oscillation
  else if loss < lower_tier.max_loss AND rtt < lower_tier.max_rtt:
    if time_since_last_decrease > decrease_cooldown:
      increase_tier()        // gradual: increase by 1 tier per 2 seconds

  opus_encoder.setBitrate(current_tier.bitrate)
  opus_encoder.setPacketLossPerc(loss)
  if loss > 5%:
    opus_encoder.setFEC(true)
  else:
    opus_encoder.setFEC(false)
```

### 2.4 Wire Format

```
Audio RTP packet (inside SRTP → inside TLS):

  0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |V=2|P|X|  CC   |M|     PT      |       Sequence Number         |  RTP header
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+  (12 bytes)
 |                           Timestamp                           |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                             SSRC                              |
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |      0xBE     |      0xDE     | Extension length=1            |  RTP ext hdr
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+  (RFC 6464)
 | ID=1  | L=0   |V|   Level     |     padding (2 bytes)         |  Audio level
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
 |                     Opus payload (variable)                   |  6-60 bytes
 |                          ...                                  |  @ 6-24 kbps
 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Total per-packet overhead:
  RTP header:        12 bytes
  RTP extension:      4 bytes (audio level)
  SRTP auth tag:     10 bytes
  DTLS record:       13 bytes
  ─────────────────────────
  Overhead:          39 bytes
  Payload @ 10 kbps: 25 bytes (10000/8/50 = 25 bytes per 20ms frame)
  Total:             64 bytes per packet → 50 pps → 25.6 kbps on wire

For ws-relay mode (binary WS frames instead of RTP/DTLS):
  WS binary header:   2-6 bytes
  Frame type (0x10):  1 byte
  Room ID:           16 bytes
  Track index:        1 byte
  Sequence:           4 bytes
  Timestamp:          4 bytes
  Flags:              1 byte
  ─────────────────────────
  Overhead:          29-33 bytes
  Payload:           25 bytes
  Total:             ~57 bytes → 22.8 kbps on wire (11% saving vs RTP)
```

### 2.5 Latency Budget

```
Capture (microphone buffer):        10 ms
Opus encode (20ms frame):           2-5 ms (complexity 5-10)
Packetization + encryption:         < 1 ms
Network (one-way):                  20-150 ms (variable)
Jitter buffer:                      20-60 ms (adaptive)
Decryption + depacketization:       < 1 ms
Opus decode:                        0.5-2 ms
Playback buffer:                    10 ms
────────────────────────────────────────────
Total one-way:                      64-239 ms
Target:                             < 200 ms (ITU-T G.114: "good" quality)
Hard limit:                         < 400 ms (beyond this, conversation breaks down)
```

### 2.6 Quality Metrics

| Metric | Method | Target |
|---|---|---|
| MOS (Mean Opinion Score) | ViSQOL v3 (Google, objective estimation) | ≥ 3.5 at 10 kbps, ≥ 4.0 at 16 kbps |
| PESQ (ITU-T P.862) | Reference-based: compare original vs decoded | ≥ 3.0 at 6 kbps |
| POLQA (ITU-T P.863) | Next-gen PESQ, better for wideband | ≥ 3.2 at 10 kbps |
| E-model R-factor | ITU-T G.107: combined codec+delay+loss | R ≥ 70 (acceptable), target R ≥ 80 |
| End-to-end latency | RTP timestamps + NTP sync | < 200ms p50, < 350ms p95 |
| Audio level accuracy | RFC 6464 vs local VAD | ≤ 3 dB deviation |

### 2.7 Libraries & Implementation

| Component | Library | Version | Platform | Notes |
|---|---|---|---|---|
| Opus encode/decode | libopus | 1.5.2+ | All (native) | Via flutter_webrtc (bundled in libwebrtc) |
| Lyra encode/decode | google/lyra | 1.3.2 | Android/Linux (native C++) | Platform channel from Dart; requires TFLite runtime |
| Codec2 | drowe67/codec2 | 1.2.0 | All (C, portable) | FFI from Dart; 700bps-3200bps modes |
| Jitter buffer | libwebrtc NetEq | M120+ | All (bundled) | Adaptive depth, packet reordering |
| TWCC | libwebrtc | M120+ | All (bundled) | Transport-wide congestion control |
| Neural PLC | libwebrtc | M96+ | All (bundled) | LPCNet-based, enabled by default |
| Quality measurement | visqol | 3.3.3 | Linux/macOS (offline) | For development testing only |
| ABR control | Custom | — | Dart | Implement GCC-like controller in signaling_service.dart |

---

## 3. Modality 2: Parametric Video

### 3.1 Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        SENDER PIPELINE                          │
│                                                                  │
│  Camera → [Face Detection] → [Landmarks Extraction] → [Params   │
│            MediaPipe         MediaPipe Face Mesh       Encoding] │
│            BlazeFace         468 landmarks + iris      ↓         │
│                              + head pose              Delta      │
│                              + expression coeffs      Compress   │
│                                                       ↓         │
│                              [Fallback Check]         [Wire]    │
│                              Face visible? Hands?     15-25     │
│                              Confidence > 0.7?        kbps      │
│                              ↓ NO                               │
│                              [AV1/H265 Encode]        80-300    │
│                              Adaptive bitrate         kbps      │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                       RECEIVER PIPELINE                          │
│                                                                  │
│  [Wire] → [Delta Decompress] → [3D Model Render] → [Composite] │
│  15-25     Reconstruct full     FLAME/custom mesh    Blend face  │
│  kbps      landmark set         + neural texture     with bg     │
│            468 xyz + params     + hair/accessory     ↓           │
│                                 inference            Display     │
│                                                                  │
│  OR                                                              │
│                                                                  │
│  [Wire] → [AV1/H265 Decode] → Display                          │
│  80-300    Standard decode                                       │
│  kbps                                                            │
└────────���─────────────────────────────────────────────────────────┘
```

### 3.2 Enrollment Phase

Before parametric video can work, each user needs a personalized face model.

**Enrollment protocol:**

```
1. User triggers enrollment (Settings → "Create Video Avatar")
2. App captures 5-7 photos at different angles:
   - Front face (neutral expression)
   - Left 30° and Right 30° turn
   - Up 15° and Down 15° tilt
   - Smile expression
   - Open mouth expression
3. On-device processing:
   a. Run MediaPipe Face Mesh on all frames → 468 landmarks each
   b. Run FLAME model fitting → shape parameters β (300 components)
   c. Extract texture map from frontal image → 256×256 UV texture
   d. Optional: hair segmentation mask + color histogram
4. Output: PersonalFaceModel {
     flame_shape: float32[300]         // ~1.2 KB
     flame_expression_neutral: float32[100]  // 400 bytes
     texture_uv: uint8[256×256×3]      // 192 KB (JPEG: ~15-30 KB)
     hair_mask: uint8[128×128]         // 16 KB (PNG: ~3 KB)
     hair_color: float32[3]            // 12 bytes
     iris_color: float32[3]            // 12 bytes
     skin_tone: float32[3]             // 12 bytes
   }
   Total: ~20-50 KB compressed
5. Model transmitted to peer during call setup (one-time, via data channel)
6. Model cached locally keyed by peer pubkey SHA-256
```

**Enrollment latency budget:**
- Photo capture: ~5 seconds (user interaction)
- FLAME fitting: ~3-8 seconds on Snapdragon 8 Gen 2 / ~15-30s on mid-range
- Texture extraction: ~500ms
- Total: ~10-40 seconds (one-time per user)

### 3.3 Real-Time Parameter Extraction (Sender)

**Stage 1: Face detection — BlazeFace (MediaPipe)**
- Input: camera frame 640×480 @ 30fps
- Output: face bounding box + 6 keypoints
- Latency: 1-3ms on GPU, 5-8ms on CPU
- Confidence threshold: 0.7 (below → fallback to video codec)

**Stage 2: Face mesh — MediaPipe Face Mesh**
- Input: cropped face ROI
- Output: 468 3D landmarks (x, y, z normalized to [0,1])
- Latency: 3-8ms on GPU, 15-25ms on CPU
- Also outputs: iris landmarks (10 points), face oval contour

**Stage 3: FLAME parameter regression**
- Input: 468 landmarks
- Output: FLAME parameters per frame:

```
FrameParams {
  expression: float16[50]      // expression coefficients (FLAME ψ)
  jaw_pose: float16[3]         // jaw rotation (axis-angle)
  head_pose: float16[6]        // rotation (3) + translation (3)
  eye_gaze: float16[4]         // left/right eye yaw + pitch
  blink: float16[2]            // left/right eyelid closure [0,1]
}

Raw size per frame: 130 bytes
At 30 fps: 3900 bytes/sec = 31.2 kbps (before compression)
```

**Stage 4: Delta compression**

```
Temporal compression scheme:

Keyframe (every 2 seconds = every 60th frame):
  - Full FrameParams: 130 bytes
  - Quantization: float16 (already minimal)

Delta frame (59 out of 60):
  - Difference from previous frame
  - Most expression params change < 0.01 per frame → quantize to int8
  - Delta FrameParams:
    expression_delta: int8[50]     // 50 bytes (±127 steps, resolution 1/127)
    jaw_delta: int8[3]             // 3 bytes
    head_pose_delta: int8[6]       // 6 bytes
    eye_gaze_delta: int8[4]        // 4 bytes
    blink_delta: int8[2]           // 2 bytes
  - Raw delta: 65 bytes
  - Run-length encoding (many deltas = 0): ~20-40 bytes typical

Average: (130 + 59×30) / 60 = ~31.5 bytes/frame
At 30 fps: ~945 bytes/sec = 7.6 kbps

With zstd compression on delta stream: ~5-8 kbps
Keyframe overhead: ~2 kbps average
Total: ~8-12 kbps for face parameters
```

**Stage 5: Background and accessories**

```
Non-face elements transmitted separately:

Background:
  - Segmented via MediaPipe Selfie Segmentation
  - Transmitted as low-res (160×120) JPEG keyframe every 5 seconds: ~3-5 KB
  - Average: ~5-8 kbps during motion, ~0.5 kbps static

Hair/accessories:
  - Hair segmentation mask: binary 64×64, delta-coded
  - ~200 bytes/sec = 1.6 kbps

Total parametric stream: 12-22 kbps
  Face params:     8-12 kbps
  Background:      3-8 kbps
  Hair/accessories: 1-2 kbps
```

### 3.4 Real-Time Rendering (Receiver)

**Rendering pipeline (per frame):**

```
1. Decompress delta → reconstruct full FrameParams (< 0.1ms)
2. Apply FLAME model:
   - Shape: β coefficients → 5023 vertices (from enrollment model)
   - Expression: ψ coefficients → vertex offsets
   - Pose: head rotation + jaw → model transform
   - GPU operation: vertex shader, ~0.5-1ms
3. Apply texture:
   - UV-mapped texture from enrollment (256×256)
   - Expression-dependent texture warping (mouth, eyes)
   - GPU fragment shader, ~0.5-1ms
4. Render eyes and gaze:
   - Iris position from gaze parameters
   - Eyelid position from blink parameters
   - ~0.2ms
5. Render hair:
   - From segmentation mask + color
   - Simple billboard or mesh depending on hardware
   - ~0.5-1ms
6. Composite with background:
   - Alpha blend face render over background
   - ~0.2ms
7. Post-processing:
   - Temporal smoothing (EMA filter, α=0.3)
   - Anti-aliasing (FXAA)
   - ~0.5ms

Total render latency: 2-5ms on mobile GPU, 1-2ms on desktop GPU
```

**Rendering quality tiers:**

| Tier | Mesh resolution | Texture size | Hair model | Target device |
|---|---|---|---|---|
| Ultra | 5023 vertices (full FLAME) | 512×512 | Strand-based | Desktop GPU, iPhone 14+ |
| High | 2000 vertices (decimated) | 256×256 | Mesh-based | Snapdragon 8xx, iPhone 12+ |
| Medium | 500 vertices | 128×128 | Billboard | Snapdragon 6xx, iPhone 11 |
| Low | 200 vertices | 64×64 | None (silhouette) | Low-end Android |

### 3.5 Temporal Consistency

**Problem:** Frame-to-frame jitter in landmarks causes visual "jittering" of the rendered face.

**Solution: Multi-level temporal smoothing**

```
Level 1 — Landmark smoothing (sender side):
  OneEuro filter per landmark coordinate (3×468 = 1404 filters)
  Parameters: min_cutoff=1.0, beta=0.5, d_cutoff=1.0
  Latency impact: 0ms (causal filter, no lookahead)
  Effect: removes high-frequency noise from landmark detection

Level 2 — Parameter smoothing (sender side):
  Exponential moving average on FLAME parameters
  α = 0.7 (fast response) for expression, α = 0.9 (smooth) for head pose
  Effect: prevents sudden jumps between frames

Level 3 — Render smoothing (receiver side):
  Interpolation between consecutive received frames
  If frame drops occur, interpolate using velocity extrapolation:
    param[t] = param[t-1] + velocity[t-1] × dt
  Effect: masks packet loss up to ~100ms (3 frames at 30fps)

Level 4 — Motion blur:
  Apply per-vertex motion blur based on inter-frame velocity
  Only for fast head movements (angular velocity > 30°/s)
  Effect: masks temporal aliasing during fast motion
```

### 3.6 Edge Case Handling

| Case | Detection method | Response |
|---|---|---|
| **Hand over face** | MediaPipe landmark confidence < 0.5 for occluded region | Freeze last known params for occluded region; extrapolate head pose from non-occluded landmarks; if >50% occluded for >500ms → switch to fallback video |
| **Side profile (>60° yaw)** | Head pose yaw estimate | FLAME model supports ±90°; quality degrades past 75°; at >80° → automatic fallback to video |
| **Multiple faces** | BlazeFace returns >1 detection | Track primary face by bounding box overlap with previous frame (IoU > 0.3); ignore secondary |
| **Poor lighting** | Landmark confidence variance > threshold | Increase face mesh model sensitivity; add gamma correction pre-processing; if confidence stays < 0.5 for 1s → fallback |
| **Unusual hair/headwear** | Hair segmentation fails (IoU with expected region < 0.3) | Disable hair rendering; use neutral background for head region |
| **Glasses/sunglasses** | Occlude eye region landmarks | Use last known iris position; disable blink tracking for occluded eyes |
| **Beard/facial hair** | Jaw region landmarks shift | FLAME shape params encode jaw shape; texture handles appearance; minor geometric artifacts acceptable |
| **Fast motion** | Inter-frame landmark displacement > threshold | Increase temporal filter responsiveness (decrease α); add motion blur; if displacement too large → skip frame |
| **Camera switch** | New camera parameters detected | Re-run face detection; reset temporal filters; brief freeze (1-2 frames) acceptable |

### 3.7 Fallback Strategy

**Decision tree for fallback to classical video codec:**

```
every frame:
  face_detected = BlazeFace.confidence > 0.7
  landmarks_valid = FaceMesh.confidence > 0.5
  face_visible_area > 30% of frame  // not too far away
  head_yaw < 80°

  parametric_ok = face_detected AND landmarks_valid AND face_visible AND head_yaw < 80°

  if parametric_ok:
    if was_fallback:
      // Transition back to parametric
      // Gradual blend over 500ms to avoid jarring switch
      blend_factor = min(1.0, (time_since_parametric_ok) / 500ms)
      output = blend(video_decoded, parametric_rendered, blend_factor)
    else:
      output = parametric_rendered
  else:
    activate_fallback_codec()
    // Ramp up video bitrate over 200ms (avoid I-frame burst on poor link)
```

**Fallback codec configuration:**

| Parameter | Value | Notes |
|---|---|---|
| Codec priority | AV1 > VP9 > H.265 > H.264 | AV1 best quality-per-bit; H.264 widest support |
| Resolution | 320×240 @ 15fps (default) | Minimal for recognizable face at fallback bitrate |
| Bitrate | 80-300 kbps (adaptive) | GCC-controlled |
| Keyframe interval | 3 seconds | Balance: longer = better compression, shorter = faster recovery |
| Latency mode | Ultra-low latency | `realtime` tuning, no B-frames, 1 reference frame |
| ROI encoding | Face region at 2× QP quality vs background | Perceptually optimal allocation |

### 3.8 Wire Format

```
Parametric video packet:

  Byte 0:      Frame type
                0x00 = Keyframe (full params + texture update)
                0x01 = Delta frame (compressed deltas)
                0x02 = Background update
                0x03 = Model update (enrollment data chunk)
                0x04 = Fallback switch signal
  Bytes 1-2:   Sequence number (uint16, big-endian)
  Byte 3:      Timestamp delta from previous frame (uint8, in ms, max 255ms)
  Bytes 4-5:   Payload length (uint16, big-endian)
  Bytes 6+:    Payload (type-dependent)

Keyframe payload:
  expression: float16[50]         // 100 bytes
  jaw_pose: float16[3]            // 6 bytes
  head_pose: float16[6]           // 12 bytes
  eye_gaze: float16[4]            // 8 bytes
  blink: float16[2]               // 4 bytes
  landmark_confidence: uint8      // 1 byte
  flags: uint8                    // 1 byte (bit 0: hair updated, bit 1: bg updated)
  Total keyframe: 6 + 132 = 138 bytes

Delta payload:
  bitmask: uint8[8]               // 64 bits: which of 65 params changed
  changed_deltas: int8[N]         // only changed params (typically 20-40)
  Total delta: 6 + 8 + N = ~34-54 bytes

Background update payload:
  format: uint8                   // 0=JPEG, 1=WebP, 2=raw
  width: uint16
  height: uint16
  data: bytes                     // 160×120 JPEG: ~2-5 KB
```

### 3.9 Libraries & Implementation

| Component | Library | Version | Platform | Notes |
|---|---|---|---|---|
| Face detection | MediaPipe BlazeFace | 0.10.14+ | Android/iOS native, Linux via C++ | Platform channel from Dart |
| Face mesh | MediaPipe Face Mesh | 0.10.14+ | Same | 468 landmarks + confidence |
| FLAME model fitting | DECA (PyTorch → ONNX → TFLite) | Custom | All via TFLite | Convert DECA to TFLite for mobile; ~20MB model |
| FLAME model runtime | Custom FLAME in GLSL | — | All (GPU) | Vertex shader: β → vertices |
| 3D rendering | flutter_gl / raw OpenGL ES | 0.5+ | All | Render FLAME mesh with texture |
| Neural texture | Custom (optional) | — | Desktop/high-end mobile | Neural radiance field for photorealistic skin |
| Selfie segmentation | MediaPipe Selfie Segmentation | 0.10.14+ | Android/iOS native | Background separation |
| One Euro filter | Custom Dart implementation | — | All | ~50 lines, real-time temporal smoothing |
| Delta compression | zstd (via FFI) | 1.5.5+ | All | 2-5× compression on param deltas |
| Fallback video | libwebrtc (AV1/VP9/H264) | M120+ | All (bundled) | Standard WebRTC video pipeline |

### 3.10 Hardware Requirements

**Sender (parametric mode):**
- CPU: 4× ARM Cortex-A76 or equivalent (2× for landmarks, 1× for FLAME, 1× for encoding)
- GPU: Adreno 640+ / Mali-G78+ / Apple A14+ (for face mesh GPU inference)
- RAM: 200 MB additional (MediaPipe models + buffers)
- Camera: 640×480 minimum, 1280×720 recommended
- Minimum viable: Snapdragon 730G / Dimensity 800 / iPhone 11 / any x86-64 desktop

**Receiver (parametric mode):**
- CPU: 2× ARM Cortex-A76 (decompress + control)
- GPU: Any GPU with OpenGL ES 3.0+ (render FLAME mesh)
- RAM: 100 MB (model + textures + render buffers)
- Minimum viable: Snapdragon 665 / iPhone XR / any x86-64 desktop

---

## 4. Modality 3: Smart Screen Sharing

### 4.1 Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                       SENDER PIPELINE                                │
│                                                                      │
│  Screen capture → [Content Classifier] → ┬─ Text regions → OCR     │
│  (OS API)          Per-tile analysis      │   extract + structured   │
│                    640 tiles (40×16)       │                         │
│                                           ├─ UI regions → Vector    │
│                                           │   edge detect + quant   │
│                                           │                         │
│                                           ├─ Static regions → Delta │
│                                           │   keyframe + diff       │
│                                           │                         │
│                                           └─ Motion regions → AV1  │
│                                               adaptive encode       │
│                                                                      │
│  All streams → [Multiplexer] → [Encryption] → Wire                 │
���──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                       RECEIVER PIPELINE                              │
│                                                                      │
│  Wire → [Demux] → ┬─ Text data → [Text Renderer]    ─┐            │
│                    ├─ Vector data → [Vector Renderer] ─┤            │
│                    ├─ Delta tiles → [Tile Compositor]  ─┤→ Display  │
│                    └─ Video stream → [AV1 Decode]     ─┘            │
└──────────────────────────────────────────────────────────────────────┘
```

### 4.2 Content Classification

**Tile-based analysis:**

```
Screen divided into tiles:
  Tile size: 48×48 pixels (at native resolution)
  For 1920×1080: 40×23 = 920 tiles
  For 2560×1440: 54×30 = 1620 tiles

Per-tile classification (every frame):
  1. Motion score: SAD (Sum of Absolute Differences) vs previous frame
     - static: SAD < 50 (per-pixel average < 0.2)
     - low_motion: SAD 50-500
     - high_motion: SAD > 500

  2. Content type (for non-static tiles):
     a. Edge density: Sobel filter → count pixels > threshold
        - high edge density (>30%) → likely text or UI
        - low edge density (<10%) → likely photo/video
     b. Color variance: compute per-tile color histogram entropy
        - low entropy → solid color / UI element
        - high entropy → photo/video/gradient
     c. Temporal pattern: motion vector analysis over 5 frames
        - consistent MV direction → scrolling text / panning
        - random MVs → video content

  Classification output per tile:
    enum TileType { STATIC, TEXT, UI, PHOTO, VIDEO, SCROLL }

Per-tile classification cost:
  SAD: ~0.1ms per tile (SIMD optimized)
  Sobel: ~0.2ms per tile
  Histogram: ~0.1ms per tile
  Total: ~0.4ms × 920 tiles = ~370ms sequential
  Parallelized (8 threads): ~50ms
  GPU compute shader: ~5ms
```

### 4.3 Text Region Encoding

**When tile classified as TEXT:**

```
Text encoding pipeline:

1. OCR pass (selective, not every frame):
   - Trigger: new text tile appears OR text tile content changes
   - Engine: Tesseract 5.x (native) or ML Kit (Android/iOS)
   - ROI: only changed text tiles, not full screen
   - Typical ROI: 200×50 pixels (one text tile cluster)
   - Latency: 15-50ms per ROI on mobile, 5-15ms on desktop

2. OCR result encoding:
   TextBlock {
     tile_x: uint8          // tile column
     tile_y: uint8          // tile row
     tile_w: uint8          // width in tiles (for multi-tile text blocks)
     tile_h: uint8          // height in tiles
     font_size: uint8       // estimated font size (points)
     font_weight: uint8     // 0=normal, 1=bold
     fg_color: uint8[3]     // foreground RGB
     bg_color: uint8[3]     // background RGB
     text_utf8: bytes       // UTF-8 encoded text
   }

   Size: ~20 bytes overhead + text length
   Typical text tile (80 chars): ~100 bytes
   vs. pixel data: 48×48×3 = 6912 bytes → JPEG ~500 bytes
   Savings: 5× (and perfectly sharp at any zoom level)

3. Fallback for OCR failure:
   - If OCR confidence < 60%, fall back to high-quality PNG tile
   - PNG of text tile: ~200-400 bytes (text compresses well)
   - Still 2-3× better than video codec for text

4. Delta encoding:
   - Only send TextBlock when text actually changes
   - For scrolling: detect scroll vector, send "scroll(dx, dy)" command
     ScrollCommand { tile_x, tile_y, tile_w, tile_h, dx: int16, dy: int16 }
     Size: 10 bytes (vs. re-encoding entire text area)
```

**When OCR is too slow (>50ms) or unavailable:**
- Fall back to lossless PNG per-tile for text regions
- PNG of text content: 48×48 pixels, 1-4 KB (text = high spatial frequency = poor JPEG but good PNG)
- Still much better than video codec which blurs text

### 4.4 UI Region Encoding

**When tile classified as UI (solid colors, clean edges):**

```
UI encoding pipeline:

1. Color quantization:
   - Reduce tile to ≤ 8 distinct colors (median cut algorithm)
   - Most UI tiles have 2-4 colors
   - Encode as indexed color with palette

2. Run-length encoding:
   UITile {
     palette_size: uint8        // 2-8
     palette: uint8[3][N]       // N×RGB
     scanlines: bytes           // RLE-encoded palette indices
   }

   Typical UI tile: 20-80 bytes (vs 6912 raw, vs ~300 JPEG)
   Savings: 4-15× vs JPEG

3. Vector detection (optional, compute-intensive):
   - Detect rectangles, rounded rectangles, circles via Hough transform
   - Encode as drawing commands:
     DrawRect { x, y, w, h, fill_color, border_color, border_width, radius }
   - ~20 bytes per shape vs ~200 bytes rasterized
   - Only beneficial for large UI areas (>4 tiles)
   - Skip on low-power devices

4. Delta for UI:
   - UI elements rarely change between frames
   - Hash each tile (xxHash, ~0.01ms per tile)
   - Only re-encode when hash changes
   - Typical UI: 90% tiles static → transmit only 10% per frame
```

### 4.5 Static Region Handling

**When tile classified as STATIC (no change):**

```
Static strategy:

1. Initial keyframe:
   - Full screen captured as JPEG tiles or WebP tiles
   - Quality: 90% (high, since transmitted rarely)
   - At 1920×1080: ~150-300 KB for full screen
   - Transmitted once on screen share start

2. Delta detection:
   - Per-tile hash comparison (xxHash64)
   - Changed tiles: re-encode and transmit
   - Unchanged tiles: skip entirely (0 bytes)

3. Periodic keyframe refresh:
   - Every 10 seconds: full keyframe to handle drift
   - Progressive: send 10% of tiles per second (round-robin)
   - Total keyframe bandwidth: ~30-50 KB / 10s = ~3-5 kbps

4. Static screen (e.g. paused document):
   - After 2 seconds of no changes → reduce to 1 fps polling
   - Only hash comparison, no encoding
   - Bandwidth: ~0.1 kbps (tile hashes only)
```

### 4.6 Video Region Encoding

**When tile classified as VIDEO (high motion, high entropy):**

```
Video region strategy:

1. Region detection:
   - Cluster adjacent VIDEO tiles into rectangular regions
   - Minimum region: 4 tiles (192×96 pixels)
   - Maximum region: full screen (if entire screen is video)

2. Separate encode stream:
   - AV1 (libaom/SVT-AV1) or VP9 encoder for video region only
   - Resolution: native resolution of detected region
   - Bitrate: adaptive, 100-500 kbps depending on region size
   - Frame rate: match source (detect via motion analysis: 24/25/30/60fps)
   - Latency preset: `speed 8` (real-time, lower quality but fast)

3. Compositing on receiver:
   - Video region decoded separately
   - Composited into tile grid at correct position
   - No re-encoding of non-video areas

4. Optimization: browser detection
   - If video fills >70% of screen → switch to full-screen video mode
   - Drop tile analysis overhead
   - Use standard AV1/VP9 full-frame codec
   - Bitrate: 300-500 kbps at 720p

5. Video region tracking:
   - Video regions may move (user scrolls page)
   - Track region by motion vector consensus
   - On region move: send position update (4 bytes) instead of re-encoding
```

### 4.7 Scroll Detection & Optimization

```
Scroll detection:

1. Compute optical flow on changed tile regions (block matching, 16×16 blocks)
2. If >70% of motion vectors point same direction with similar magnitude:
   → scroll detected

3. Scroll encoding:
   ScrollEvent {
     region: { x, y, w, h } in tiles      // 4 bytes
     dx: int16, dy: int16                   // 4 bytes (pixel displacement)
   }
   Total: 8 bytes per scroll event

4. Receiver:
   - Shift existing tile buffer by (dx, dy)
   - Request only newly revealed tiles (at scroll edge)
   - Bandwidth during scroll:
     Revealed edge width × tile_height × tile_bytes
     Typical: scrolling 100px down → 2 tile rows × 40 cols × ~200 bytes = ~16 KB/frame
     At 60fps scroll: ~960 KB/s = ~7.7 Mbps ← too much

5. Scroll optimization:
   - Cap scroll update rate to 10 fps (every 100ms)
   - Batch scroll displacement: report cumulative (dx, dy) per 100ms
   - Revealed tiles sent as low-quality first (JPEG q=50), refined over next 500ms
   - Bandwidth during fast scroll: ~100-200 kbps
   - Bandwidth after scroll stops: ~20-50 kbps (tile refinement)
```

### 4.8 Bitrate Summary by Content Type

```
Content type     Encoding method            Kbps (typical)     Notes
─────────────────────────────────────────────────────────────────────
Pure static      Keyframe + tile hash       0.1-5              Document viewing, paused app
Slow UI change   UI tiles + delta           5-30               Typing, menu navigation
Text scrolling   Scroll + revealed tiles    20-80              Scrolling document
Mixed UI+text    OCR + UI + delta           15-50              IDE, browser with text
Video in window  AV1 sub-stream             100-300            YouTube in browser
Full-screen vid  AV1 full-frame             300-500            Movie playback
Fast animation   AV1 adaptive              150-400            Gaming, complex UI transitions
```

### 4.9 Wire Format

```
Screen share frame:

  Byte 0:      Frame type
                0x10 = Keyframe (full screen)
                0x11 = Delta (changed tiles only)
                0x12 = Scroll event
                0x13 = Text block update
                0x14 = UI tile update
                0x15 = Video region keyframe
                0x16 = Video region delta
                0x17 = Cursor update
                0x18 = Resolution change
  Bytes 1-2:   Sequence number (uint16)
  Byte 3:      Timestamp delta (uint8, ms)
  Bytes 4-5:   Tile count / payload length
  Bytes 6+:    Payload

Delta payload:
  For each changed tile:
    tile_x: uint8
    tile_y: uint8
    tile_type: uint8 (0=jpeg, 1=png, 2=text, 3=ui_rle, 4=video_ref)
    data_len: uint16
    data: bytes

Cursor update:
  x: uint16, y: uint16           // cursor position
  cursor_type: uint8              // 0=arrow, 1=hand, 2=text, 3=custom
  // Custom cursor image only sent on change: ~200 bytes PNG
```

### 4.10 Libraries & Implementation

| Component | Library | Version | Platform | Notes |
|---|---|---|---|---|
| Screen capture | flutter_webrtc `getDisplayMedia` / platform API | 0.11+ | All | OS-level screen capture |
| Tile hashing | xxHash (via FFI) | 0.8.2 | All | ~1 GB/s throughput |
| OCR | Tesseract 5 (native FFI) | 5.3.4 | Linux/Android | Platform channel; ~15-50ms per ROI |
| OCR (mobile) | ML Kit Text Recognition | 16.0+ | Android/iOS | Google ML Kit via plugin |
| Color quantization | Custom Dart + SIMD | — | All | Median cut, ~1ms per tile |
| AV1 encode | SVT-AV1 (native FFI) | 2.0+ | Linux/desktop | Real-time preset; too heavy for mobile |
| AV1 encode (mobile) | MediaCodec AV1 / VideoToolbox | OS-provided | Android 14+ / iOS 17+ | Hardware AV1 on recent SoCs |
| VP9 encode (fallback) | libvpx (via libwebrtc) | bundled | All | Software VP9, realtime preset |
| Image compression | libjpeg-turbo, libpng | system | All | Tile compression |
| Delta compression | zstd | 1.5.5+ | All | Batch tile delta streams |
| Optical flow | Custom block matching | — | All (SIMD) | 16×16 blocks, SAD-based |

### 4.11 Hardware Requirements

**Sender:**
- CPU: 4-core ARM A76+ or x86-64 (tile analysis + OCR + encoding)
- GPU: Optional (compute shaders accelerate tile classification 10×)
- RAM: 300 MB (frame buffers + tile cache + OCR model)
- Special: screen capture permission (Android: MediaProjection, iOS: ReplayKit)
- **Mobile-specific limitations:**
  - OCR too slow on <2020 SoCs → fall back to PNG tiles for text
  - AV1 software encode impractical → use VP9 or hardware AV1 (Android 14+)
  - Tile analysis in GPU compute: requires Vulkan compute support

**Receiver:**
- CPU: 2-core (decode + composite)
- GPU: Any (tile compositing trivial)
- RAM: 150 MB (tile buffer + decoded frame)
- Significantly lighter than sender

---

## 5. Modality 4: Traffic Obfuscation

### 5.1 Architecture

```
Application data (voice/video/screen/messages)
        │
        ▼
┌─────────────────────┐
│ Modality Multiplexer │ → single byte stream
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Padding Normalizer  │ → fixed-size buckets
└─────────┬───────────┘
          │
          ���
┌─────────────────────┐
│  Jitter Injector     │ → randomized timing
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  TLS 1.3 Record      │ → standard TLS framing
│  (with uTLS fp)      │
└─────────┬──���────────┘
          │
          ▼
       TCP :443          → indistinguishable from HTTPS
```

### 5.2 TLS 1.3 Masquerade

**Goal:** Traffic on the wire must be indistinguishable from standard HTTPS/TLS 1.3 browsing.

```
Layer 1 — TLS fingerprint (ClientHello):
  - Use uTLS library to mimic specific browser fingerprints
  - Rotate between: Chrome 120, Firefox 121, Safari 17, Edge 120
  - Include realistic: cipher suites, extensions, ALPN (h2, http/1.1)
  - ECH (Encrypted Client Hello) when available
  - Fingerprint selected based on OS: Android → Chrome, iOS → Safari

Layer 2 — ALPN negotiation:
  - Negotiate HTTP/2 (h2) as application protocol
  - Frame all WebSocket data inside HTTP/2 frames
  - This makes the connection look like a standard HTTP/2 session

Layer 3 — Application data records:
  - TLS 1.3 record format: type(1) + version(2) + length(2) + encrypted_data
  - All records appear as TLS ApplicationData (type 0x17)
  - Record sizes match typical HTTPS patterns (see §5.3)

Layer 4 — Connection behavior:
  - Initial handshake matches HTTPS: TCP SYN → TLS ClientHello → ...
  - Connection idle behavior: periodic TLS records (mimics HTTP/2 PING)
  - Connection lifetime: 5-30 minutes (matches typical API long-poll)
  - Reconnect pattern: exponential backoff matching browser retry
```

### 5.3 Packet Size Normalization

**Goal:** Packet sizes should not reveal content type (voice vs video vs message).

```
Bucket sizes (matching common HTTPS response patterns):

  Bucket    Size range    Padded to    Usage
  ──────────────────────────────────────────────────
  TINY      0-128         128 bytes    Control messages, acks
  SMALL     129-256       256 bytes    Audio frames, text messages
  MEDIUM    257-512       512 bytes    Multiple audio, small delta
  LARGE     513-1024      1024 bytes   Video params, UI tiles
  XLARGE    1025-1400     1400 bytes   Near MTU, video/file chunks
  MTU       1401-1460     1460 bytes   Maximum: TCP MSS (1500-40)

Padding strategy:
  1. Compute target bucket for payload size
  2. Append random bytes to reach bucket boundary
  3. Padding format: payload_length(2 bytes) + payload + random_padding
  4. Receiver reads payload_length, ignores padding

Example: 25-byte Opus frame
  → bucket = SMALL (256 bytes)
  → wire: [0x00 0x19] [25 bytes opus] [229 bytes random] = 256 bytes
  → inside TLS record: 256 + 5 (header) + 16 (AEAD tag) = 277 bytes

Bandwidth overhead for audio stream:
  Without padding: 25 bytes × 50 pps = 10 kbps
  With SMALL bucket: 256 bytes × 50 pps = 102 kbps
  Overhead: 10.2× ← too much!

Optimization: batch multiple frames per bucket:
  Collect up to 100ms of audio (5 frames × 25 bytes = 125 bytes)
  → bucket = SMALL (256 bytes) at 10 pps = 20.5 kbps
  Overhead: 2× (acceptable for paranoid mode)
  Latency impact: +100ms (acceptable in paranoid privacy preset)
```

**Adaptive padding based on privacy preset:**

```
Standard:   No padding. Raw sizes on wire.
Private:    256-byte bucket minimum. Burst padding during idle.
Paranoid:   MTU-normalized (all packets = 1460 bytes) + CBR + chaff.
Custom:     User-selected bucket size + padding mode.
```

### 5.4 Timing Obfuscation (Jitter Injection)

**Goal:** Packet timing should not reveal content type. Voice has regular 20ms intervals; video has bursty keyframes.

```
Strategy 1 — Jitter injection (Private mode):
  For each outgoing packet:
    actual_send_time = scheduled_time + random_uniform(-jitter_max, +jitter_max)

  jitter_max by preset:
    Private:  ±20ms (masks voice periodicity without breaking real-time)
    Paranoid: ±100ms (significant masking, higher latency)

  Reorder protection:
    Receiver uses sequence numbers to reorder
    Jitter buffer absorbs timing variance (already needed for network jitter)

Strategy 2 — Constant-rate transmission (Paranoid mode):
  Transmit exactly 1 packet every T milliseconds, regardless of actual data
  T = 20ms → 50 pps (matches audio frame rate — most efficient)

  If real data available: send real data (padded to MTU)
  If no data: send padding frame (0xFF + random, padded to MTU)

  Bandwidth: 1460 bytes × 50 pps = 584 kbps constant
  This is: ~70 KB/s in each direction, regardless of activity

  Optimization: reduce to 10 pps (100ms interval) when no call active
  → 116.8 kbps idle (message-only session)

Strategy 3 — Traffic shaping to match HTTP/2 profile:
  Analyze typical HTTP/2 session patterns:
    - Bursty (page load): 50-100 packets in 200ms, then silence
    - Streaming (video): regular 30fps-ish packet train
    - API polling: 1 request/response every 5-30 seconds

  Shape our traffic to match "streaming video" profile:
    - Target: 30 records/second with ±30% jitter
    - Burst on "keyframe": every 3s, send 5-10 records in 100ms
    - Matches Netflix/YouTube HLS chunk pattern
```

### 5.5 DPI Countermeasures

```
Countermeasure 1 — Record size distribution:
  DPI systems fingerprint protocols by TLS record size distributions
  Our distribution should match HTTPS:
  - Median record size: 1200-1400 bytes (matches typical HTTP/2 DATA frames)
  - Small records (50-200 bytes): 10-15% (matches HTTP/2 HEADERS, SETTINGS)
  - Inject occasional small records (PING/PONG mimicry) during data transfer

Countermeasure 2 — Initial handshake behavior:
  After TLS handshake, mimic HTTP/2 connection preface:
  - Client sends: HTTP/2 magic + SETTINGS frame (inside TLS record)
  - Server responds: SETTINGS + SETTINGS ACK
  - Then: WebSocket upgrade request as HTTP/2 stream
  - DPI sees standard HTTP/2 negotiation

Countermeasure 3 — Connection multiplexing:
  Use HTTP/2 stream IDs for different modalities:
    Stream 1: Control channel (text messages, signaling)
    Stream 3: Audio
    Stream 5: Video / parametric
    Stream 7: Screen share
  DPI sees normal HTTP/2 multiplexing behavior

Countermeasure 4 — Server response patterns:
  Server should also pad responses to match HTTPS patterns
  Include fake HTTP headers in initial handshake:
    "Server: nginx/1.24.0" (probe resistance — already implemented)
    "Content-Type: application/octet-stream"
    "X-Request-ID: <uuid>"

Countermeasure 5 — SNI fronting / ECH:
  When connecting through censored networks:
  - ECH: encrypt SNI in ClientHello (TLS 1.3 extension)
  - If ECH unavailable: domain fronting via CDN (Cloudflare, etc.)
  - uTLS proxy already handles this (tools/utls-proxy/)

Countermeasure 6 — Active probing resistance:
  Server already implements probe resistance (DecoyHandler):
  - Non-authenticated requests → nginx default page
  - curl/wget → standard 200/404 HTML
  - Port scan → looks like standard HTTPS server

  Additional: respond to HTTP/2 PING with standard PONG timing
  Additional: support real HTTP GET for decoy pages (serve actual static files)
```

### 5.6 Chaff & Dummy Traffic

```
Chaff message injection (existing implementation, enhanced):

Current:
  - Random interval (±50% of configured interval)
  - Fixed bucket sizes (256/1024/4096)
  - Marked with "_chaff": true for client discard

Enhanced:
  - Chaff timing correlated with real traffic patterns
    (more chaff during active sessions, less during idle)
  - Chaff sizes match distribution of real messages for that session
  - Bidirectional: server→client AND client→server chaff
  - Chaff indistinguishable from encrypted real messages:
    - Same TLS record wrapper
    - Same padding
    - No "_chaff" field (E2EE means server can't add fields)
    - Instead: chaff indicated by reserved byte in encrypted header
      (only sender/receiver know the encryption key to detect chaff)

Chaff budget:
  Standard: 0 (no chaff)
  Private:  1 chaff per 10 real messages (10% overhead)
  Paranoid: 1:1 ratio (100% overhead, doubles bandwidth)

  With CBR mode: chaff is implicit (padding frames fill silence)
```

### 5.7 Libraries & Implementation

| Component | Library | Version | Platform | Notes |
|---|---|---|---|---|
| uTLS | refraction-networking/utls | 1.6+ | Go proxy | Chrome/Firefox/Safari fingerprints |
| TLS 1.3 | Go crypto/tls + uTLS | Go 1.22+ | Go proxy | ECH support in utls 1.6+ |
| HTTP/2 framing | golang.org/x/net/http2 | 0.24+ | Go server | Native HTTP/2 support |
| Padding | Custom (already implemented) | — | Go server | NormalizeBucketSize + CBR/burst |
| Jitter | Custom (already implemented) | — | Go server | ApplyJitter + delivery delay |
| Chaff | Custom (already implemented) | — | Go server | PaddingService.chaffLoop |
| Probe resistance | Custom (already implemented) | — | Go server | DecoyHandler |
| Client TLS pinning | Dart IOHttpClient | — | Dart | badCertificateCallback for cert_fp |

---

## 6. Unified Multiplexing Layer

### 6.1 Binary Frame Format

All modalities share a single binary frame format within the TLS stream:

```
Pulse Multiplexed Frame:

  Byte 0:       Modality (upper 4 bits) + Flags (lower 4 bits)
                Modality:
                  0x0_ = Control (text JSON messages, signaling)
                  0x1_ = Audio
                  0x2_ = Parametric Video
                  0x3_ = Fallback Video (AV1/VP9)
                  0x4_ = Screen Share
                  0x5_ = File Transfer
                  0x6_ = Tunnel
                  0xF_ = Padding/Chaff
                Flags (lower 4 bits):
                  bit 0: Keyframe
                  bit 1: FEC data included
                  bit 2: Priority (1=high, 0=normal)
                  bit 3: Reserved

  Bytes 1-2:    Payload length (uint16, big-endian, max 65535)
  Bytes 3-4:    Sequence number (uint16, per-modality)
  Byte 5:       Timestamp delta (uint8, ms since last frame of same modality)
  Bytes 6+:     Encrypted payload (E2EE, opaque to server)

Total header overhead: 6 bytes per frame
```

### 6.2 Priority & Scheduling

```
Priority queue for outgoing frames:

  Priority 0 (highest): Audio frames (real-time, small)
  Priority 1:           Parametric video keyframes
  Priority 2:           Control messages (signaling, acks)
  Priority 3:           Parametric video deltas
  Priority 4:           Screen share deltas
  Priority 5:           Fallback video
  Priority 6 (lowest):  File transfer chunks, padding

Scheduling algorithm:
  - Strict priority for audio (always goes first if available)
  - Weighted fair queue for video/screen (70/30 split)
  - File transfer: only when audio+video budget has headroom
  - Padding: fills remaining bandwidth in CBR mode

Bandwidth allocation example (100 kbps total available):
  Audio (10 kbps):          guaranteed, always sent
  Parametric video (15 kbps): guaranteed if in parametric mode
  Screen share (30 kbps):   best-effort, shares with video
  File transfer:            remainder (45 kbps)
  Padding:                  fills to CBR target if enabled
```

---

## 7. Capability Negotiation

### 7.1 Protocol

During call setup, peers exchange capabilities via signaling:

```json
{
  "type": "media_caps",
  "audio": {
    "codecs": ["opus", "lyra_v2", "codec2"],
    "opus_max_bitrate": 24000,
    "opus_dtx": true,
    "opus_fec": true,
    "lyra_supported": true,
    "codec2_modes": [3200, 1200]
  },
  "video": {
    "parametric": {
      "supported": true,
      "face_mesh_version": "0.10.14",
      "flame_supported": true,
      "render_tier": "high",
      "max_render_fps": 30,
      "enrollment_model_hash": "sha256:abcdef..."
    },
    "fallback_codecs": ["AV1", "VP9", "H264"],
    "max_bitrate": 300000,
    "max_resolution": "640x480",
    "max_fps": 30
  },
  "screen": {
    "tile_analysis": true,
    "ocr_available": true,
    "ocr_engine": "tesseract_5",
    "av1_hw_encode": false,
    "vp9_encode": true,
    "max_capture_fps": 30,
    "max_resolution": "2560x1440"
  },
  "obfuscation": {
    "padding_modes": ["none", "bucket", "cbr"],
    "max_cbr_kbps": 500,
    "jitter_tolerance_ms": 100,
    "chaff_supported": true
  },
  "device": {
    "cpu_cores": 8,
    "gpu": "Adreno 730",
    "ram_mb": 8192,
    "os": "Android 14",
    "battery_pct": 72,
    "network_type": "wifi"
  }
}
```

### 7.2 Negotiation Rules

```
Agreed mode = intersection of both peers' capabilities:

Audio codec:
  Both have Opus → Opus (always)
  Low bandwidth detected → try Lyra if both support
  Emergency → Codec2 if both support

Video mode:
  Both support parametric AND both have enrollment models → parametric
  One side doesn't support parametric → fallback video codec
  Fallback codec = highest priority in both lists (AV1 > VP9 > H264)

Screen share:
  Both support tile analysis → smart tiles
  One side doesn't → standard AV1/VP9 full-frame
  OCR: only if sender supports it (receiver doesn't need OCR)

Obfuscation:
  Use strictest preset between both peers
  If peer A = "paranoid" and peer B = "standard" → use "paranoid"
  (privacy is only as strong as the most cautious participant)
```

---

## 8. Quality Metrics & Mode Switching

### 8.1 Real-Time Quality Monitoring

```
Metrics collected continuously (every 500ms):

Network metrics:
  - RTT (from RTCP SR/RR or WS ping)
  - Packet loss % (from RTCP RR or sequence gap analysis)
  - Jitter (from RTCP RR)
  - Available bandwidth estimate (from TWCC or send-side BWE)

Audio quality:
  - Local: VAD state (speaking/silent), audio level
  - Remote: playout delay, concealed frames %, jitter buffer delay
  - Derived: estimated MOS (E-model from R-factor)

Video quality (parametric):
  - Landmark confidence (per-frame, from MediaPipe)
  - Face detection confidence
  - Rendering FPS vs target FPS
  - Parameter delta magnitude (large = fast motion)

Video quality (fallback):
  - Encode time vs frame interval (>80% = overloaded)
  - Quantizer value (higher = worse quality)
  - Decoded FPS vs target FPS
  - Estimated VMAF/SSIM from QP (offline calibration table)

Screen share quality:
  - Tile classification time vs budget (>80% = overloaded)
  - OCR confidence average
  - Pending tile queue depth
  - Encode queue latency
```

### 8.2 Mode Switching Thresholds

```
Audio:
  Opus 24k → 16k:   loss > 5% OR bw < 30 kbps
  Opus 16k → 10k:   loss > 10% OR bw < 15 kbps
  Opus 10k → 6k:    loss > 20% OR bw < 10 kbps
  Opus → Lyra:       loss > 30% OR bw < 6 kbps (AND Lyra supported)
  Lyra → Codec2:     bw < 4 kbps (AND Codec2 supported)
  Any → mute:        loss > 50% OR bw < 2 kbps (for > 5 seconds)
  Hysteresis:         upgrade after 5 seconds of improved conditions

Video:
  Parametric → fallback:  face_confidence < 0.5 for > 500ms
  Fallback → parametric:  face_confidence > 0.7 for > 1s
  Fallback bitrate:       GCC-controlled, 80-300 kbps
  Fallback freeze:        if encode_time > 50ms → reduce fps
  Any → off:              bw < 20 kbps → audio only

Screen:
  Smart → simple VP9:     tile_analysis_time > 50ms consistently
  High detail → low:      pending_tiles > 100 → reduce to JPEG quality 60
  Any → off:              bw < 30 kbps → pause screen share
```

---

## 9. Hardware Requirements Matrix

### 9.1 Minimum Requirements by Feature

| Feature | CPU | GPU | RAM | SoC example |
|---|---|---|---|---|
| Voice only (Opus) | 1× A55 | None | 50 MB | Any 2018+ phone |
| Voice (Lyra) | 2× A76 | None | 100 MB | Snapdragon 730 |
| Parametric video (send) | 4× A76 | Adreno 618+ | 300 MB | Snapdragon 765G |
| Parametric video (recv) | 2× A76 | ES 3.0 GPU | 150 MB | Snapdragon 665 |
| Smart screen share (send) | 4× A76 + GPU compute | Adreno 640+ | 400 MB | Snapdragon 855 |
| Smart screen share (recv) | 2× A55 | Any | 100 MB | Any 2019+ phone |
| Full system (all features) | 4× A78 + GPU | Adreno 660+ | 500 MB | Snapdragon 888 |
| Desktop (all features) | 4C/8T x86-64 | Any | 512 MB | Intel i5-8250U |

### 9.2 Battery Impact

```
Estimated additional power draw (screen-off, audio call):

Voice only (Opus 16 kbps):        ~150 mW → ~8 hours on 4000 mAh
Voice (Lyra 3.2 kbps):            ~300 mW → ~5 hours (ML inference)
Parametric video (send):          ~1200 mW → ~2 hours
Parametric video (recv):          ~500 mW → ~4 hours
Fallback video (send, 300 kbps):  ~800 mW → ~3 hours
Smart screen (send):              ~1500 mW → ~1.5 hours
CBR padding (100 kbps idle):      ~100 mW → negligible additional
```

---

## 10. Implementation Roadmap

### Phase A: Foundation (Weeks 1-4)
- [ ] Adaptive Opus bitrate controller (ABR) in signaling_service.dart
- [ ] Lyra v2 integration via platform channel (Android first)
- [ ] Enhanced padding with bucket normalization (already partially done)
- [ ] Jitter injection with configurable presets
- [ ] Capability negotiation protocol (media_caps exchange)

### Phase B: Smart Screen Share (Weeks 5-12)
- [ ] Tile-based content classification engine (native C++, platform channel)
- [ ] Delta tile encoding with xxHash change detection
- [ ] Scroll detection via block matching optical flow
- [ ] Separate AV1 sub-stream for video regions
- [ ] OCR integration (Tesseract native + ML Kit)
- [ ] Tile compositor on receiver side

### Phase C: Parametric Video (Weeks 13-24)
- [ ] MediaPipe Face Mesh integration (platform channel)
- [ ] FLAME model fitting (DECA → TFLite conversion + integration)
- [ ] One Euro filter temporal smoothing
- [ ] Delta compression for face parameters
- [ ] Enrollment pipeline (photo capture → model fitting → transmission)
- [ ] OpenGL ES renderer for FLAME mesh on receiver
- [ ] Texture rendering with UV mapping
- [ ] Fallback switching logic with blend transitions
- [ ] Edge case handling (occlusion, profile, lighting)

### Phase D: Traffic Obfuscation Hardening (Weeks 25-28)
- [ ] HTTP/2 framing layer
- [ ] CBR mode with traffic shaping to match HTTP/2 patterns
- [ ] Enhanced chaff (encrypted, indistinguishable from real traffic)
- [ ] DPI resistance testing against known classifiers
- [ ] Record size distribution normalization

### Phase E: Integration & Testing (Weeks 29-32)
- [ ] End-to-end integration testing all modalities simultaneously
- [ ] Quality regression testing (MOS, VMAF benchmarks)
- [ ] Battery/thermal profiling per device class
- [ ] DPI evasion testing (China GFW simulator, Iran DPI simulator)
- [ ] Cross-platform capability negotiation testing

---

## 11. Open Problems & Research Directions

### 11.1 Parametric Video

1. **Photorealistic neural rendering on mobile:** Current SOTA (NeRF, 3D Gaussian Splatting) requires desktop GPU. No viable path to real-time on mobile until dedicated NPU hardware or major algorithmic breakthrough.
   - *Research direction:* MobileNeRF, BakedSDF — pre-bake neural representations to texture + mesh for mobile GPU
   - *Estimated timeline:* 2-3 years for mobile-viable quality

2. **Hair rendering from 2D observations:** Strand-level hair reconstruction from monocular video is unsolved in real-time. Current best: billboard + alpha mask.
   - *Research direction:* NeuralHDHair, HairStep — but inference too slow for real-time
   - *Workaround:* Stylized hair (pre-modeled hairstyles mapped to segmentation)

3. **Expression space gaps:** FLAME's 50 expression coefficients don't capture all human expressions (e.g., tongue protrusion, nostril flare, asymmetric expressions).
   - *Research direction:* EMOCA, SPECTRE — expanded expression spaces
   - *Workaround:* Additional blendshapes for common missing expressions

4. **Uncanny valley:** Even perfect landmark tracking produces subtly wrong motion. Human visual system detects micro-expression timing errors at ~10ms resolution.
   - *No known solution.* This may be fundamentally limiting for parametric video. Stylized (non-photorealistic) rendering sidesteps this.

### 11.2 Smart Screen Sharing

5. **Real-time OCR accuracy:** Tesseract achieves ~95% accuracy on clean text, but drops to 70-80% on anti-aliased screen text, colored backgrounds, or non-Latin scripts.
   - *Research direction:* PaddleOCR, EasyOCR — better accuracy but heavier models
   - *Workaround:* Only use OCR for high-confidence detections; fall back to PNG tiles otherwise

6. **Content classifier robustness:** Tile-based classification struggles with mixed content (e.g., code editor with syntax highlighting = text + color = ambiguous).
   - *Research direction:* Lightweight CNN tile classifier (~500 KB model, ~1ms inference)
   - *Workaround:* Conservative classification — when uncertain, use JPEG tile (safe default)

7. **Sub-pixel scroll detection:** Block matching gives integer-pixel precision. Sub-pixel scrolling (common on macOS with trackpad) causes blurry tiles at scroll boundaries.
   - *Workaround:* Round to nearest integer; accept 1-pixel blur during scroll

### 11.3 Traffic Obfuscation

8. **Statistical traffic analysis:** Even with CBR padding, an adversary can analyze traffic patterns over minutes to distinguish voice call from messaging (different session duration distributions).
   - *Research direction:* Differentially private traffic generation
   - *Partial mitigation:* Keep CBR active for random duration after call ends

9. **Active probing by censors:** China's GFW actively probes suspected circumvention servers by replaying ClientHello or sending malformed requests.
   - *Current mitigation:* DecoyHandler serves real nginx pages
   - *Enhanced:* Implement full HTTP/2 server that serves real web content alongside relay

10. **Timing side channels in E2EE:** Processing time for message decryption varies with message size, potentially leaking information.
    - *Mitigation:* Constant-time processing (pad to bucket boundary before decryption)
    - *Open:* GPU-accelerated crypto has timing leaks via power analysis

### 11.4 Cross-Cutting

11. **Multi-modal bandwidth contention:** When voice + video + screen share active simultaneously, fair scheduling between modalities is non-trivial. Audio must be prioritized but screen share text legibility requires sustained bitrate.
    - *Approach:* Strict priority for audio, preemptive scheduling for video, best-effort for screen
    - *Open:* Optimal allocation function depends on content type (presentation vs conversation)

12. **Heterogeneous peer capabilities:** If sender has Snapdragon 8 Gen 3 (full parametric) but receiver has budget phone (can't render FLAME), the sender does expensive processing for nothing.
    - *Solution:* Capability negotiation (§7) prevents this
    - *Open:* What if capabilities change mid-call (battery saving mode kicks in)?

---

*End of specification.*
