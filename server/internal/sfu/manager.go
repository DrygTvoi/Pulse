package sfu

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	"github.com/pion/ice/v4"
	"github.com/pion/interceptor"
	"github.com/pion/logging"
	"github.com/pion/webrtc/v4"

	"github.com/nicholasgasior/pulse-server/config"
)

// Manager manages all SFU rooms.
type Manager struct {
	mu     sync.RWMutex
	rooms  map[string]*Room // roomID → Room
	cfg    *config.MediaConfig
	api    *webrtc.API
	tcpMux ice.TCPMux

	// MaxRooms is an authoritative cap enforced inside CreateRoom under
	// m.mu. External gates (e.g. hub.go's admission check on RoomCount)
	// may lose a race between two concurrent creators; this cap is the
	// TOCTOU-safe backstop. 0 means "no cap".
	MaxRooms int

	// Speaker detection
	stopCh chan struct{}

	// speakerLoopOnce is used to emit a single informational log line the
	// first time speakerDetectionLoop actually has work to do, so we can
	// see in production whether the loop is spinning on empty rooms.
	speakerLoopStarted sync.Once
}

// NewManager creates a new SFU manager.
func NewManager(cfg *config.MediaConfig, tcpListener net.Listener) *Manager {
	m := &Manager{
		rooms:  make(map[string]*Room),
		cfg:    cfg,
		stopCh: make(chan struct{}),
	}

	// Configure Pion WebRTC API
	settingEngine := webrtc.SettingEngine{}

	// If stealth mode — use ICE-TCP mux on the shared TLS listener
	if tcpListener != nil && (cfg.Mode == "stealth" || cfg.Mode == "all") {
		loggerFactory := logging.NewDefaultLoggerFactory()
		mux := ice.NewTCPMuxDefault(ice.TCPMuxParams{
			Listener: tcpListener,
			Logger:   loggerFactory.NewLogger("ice-tcp"),
		})
		m.tcpMux = mux
		settingEngine.SetICETCPMux(mux)
		log.Printf("[sfu] ICE-TCP mux enabled on shared listener")
	}

	// TCP-only candidate gathering is ONLY safe when we actually have an
	// ICE-TCP mux to receive incoming connections on. Without the mux
	// (e.g. server is behind nginx and was started without a shared TLS
	// listener), TCP-only would gather candidates that nothing can
	// connect to — every ICE check times out and clients see "checking
	// → failed" while the server side reports the same.
	//
	// So: if we got a tcpListener AND we're in stealth mode, lock to TCP
	// (real GFW-safe behaviour). Otherwise fall back to default
	// (UDP+TCP) gathering so calls work via TURNS-relayed UDP through
	// the bundled coturn — slightly less stealthy but the alternative
	// is no calls at all behind a reverse proxy.
	if cfg.Mode == "stealth" && tcpListener != nil {
		settingEngine.SetNetworkTypes([]webrtc.NetworkType{
			webrtc.NetworkTypeTCP4,
			webrtc.NetworkTypeTCP6,
		})
		log.Printf("[sfu] stealth mode — gathering TCP-only ICE candidates")
	} else if cfg.Mode == "stealth" {
		log.Printf("[sfu] stealth mode but no TCP mux listener — keeping " +
			"default UDP+TCP gathering so calls reach clients via TURN")
	}

	// Allow detached data channels for performance
	settingEngine.DetachDataChannels()

	// Create media engine with default codecs
	mediaEngine := &webrtc.MediaEngine{}
	if err := mediaEngine.RegisterDefaultCodecs(); err != nil {
		log.Printf("[sfu] warning: failed to register default codecs: %v", err)
	}

	// Create interceptor registry
	ir := &interceptor.Registry{}
	if err := webrtc.RegisterDefaultInterceptors(mediaEngine, ir); err != nil {
		log.Printf("[sfu] warning: failed to register interceptors: %v", err)
	}

	// Create the API with our settings
	m.api = webrtc.NewAPI(
		webrtc.WithSettingEngine(settingEngine),
		webrtc.WithMediaEngine(mediaEngine),
		webrtc.WithInterceptorRegistry(ir),
	)

	// Start speaker detection ticker if enabled
	if cfg.SpeakerDetect {
		go m.speakerDetectionLoop()
	}

	// Start BWE adjustment loop if simulcast is enabled
	if cfg.Simulcast {
		go m.bweLoop()
	}

	// Start room cleanup ticker
	go m.cleanupLoop()

	return m
}

func generateRoomID() string {
	b := make([]byte, 16)
	rand.Read(b)
	return hex.EncodeToString(b)
}

// CreateRoom creates a new SFU room.
func (m *Manager) CreateRoom(creator string, maxSize int, name string, e2ee bool) (*Room, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	// TOCTOU-safe cap: check and insert under the same lock. External
	// callers may have already checked RoomCount(), but nothing prevents
	// two admissions from slipping through simultaneously; this is the
	// authoritative gate.
	if m.MaxRooms > 0 && len(m.rooms) >= m.MaxRooms {
		return nil, fmt.Errorf("room cap reached (%d)", m.MaxRooms)
	}

	if m.cfg.MaxRoomSize > 0 && maxSize > m.cfg.MaxRoomSize {
		maxSize = m.cfg.MaxRoomSize
	}
	if maxSize <= 0 {
		maxSize = m.cfg.MaxRoomSize
	}

	roomID := generateRoomID()
	room := NewRoom(roomID, creator, name, maxSize, e2ee, m.cfg.LastNVideo, m.cfg.Simulcast, m.api, m.onRoomEmpty)
	m.rooms[roomID] = room

	log.Printf("[sfu] room %s created by %s (max: %d)", roomID, creator[:8], maxSize)
	return room, nil
}

// GetRoom returns a room by ID. Returns nil when the room no longer
// exists OR has been marked closed — callers that might race with
// `onRoomEmpty` (e.g. handling a mediaOffer while the last participant
// leaves) shouldn't operate on a dead room.
func (m *Manager) GetRoom(roomID string) *Room {
	m.mu.RLock()
	r := m.rooms[roomID]
	m.mu.RUnlock()
	if r == nil || r.closed.Load() {
		return nil
	}
	return r
}

// RoomCount returns the number of active rooms.
func (m *Manager) RoomCount() int {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return len(m.rooms)
}

func (m *Manager) onRoomEmpty(roomID string) {
	m.mu.Lock()
	r := m.rooms[roomID]
	delete(m.rooms, roomID)
	m.mu.Unlock()
	if r != nil {
		r.closed.Store(true)
	}
	log.Printf("[sfu] room %s removed (empty)", roomID)
}

// JoinRoom adds a participant to a room.
func (m *Manager) JoinRoom(roomID, token, pubkey string, sendMsg func([]byte) error, sendBin func([]byte) error) (*Room, *Participant, error) {
	room := m.GetRoom(roomID)
	if room == nil {
		return nil, nil, fmt.Errorf("room not found")
	}
	if room.Token != token {
		return nil, nil, fmt.Errorf("invalid room token")
	}

	p, err := room.AddParticipant(pubkey, sendMsg, sendBin)
	if err != nil {
		return nil, nil, err
	}

	return room, p, nil
}

// HandleMediaOffer processes an SDP offer from a participant and returns an answer.
func (m *Manager) HandleMediaOffer(roomID, pubkey, sdpOffer string) (string, error) {
	room := m.GetRoom(roomID)
	if room == nil {
		return "", fmt.Errorf("room not found")
	}

	// Build ICE configuration based on media mode
	iceConfig := m.buildICEConfig()

	pc, err := room.CreatePeerConnection(pubkey, iceConfig)
	if err != nil {
		return "", err
	}

	offer := webrtc.SessionDescription{
		Type: webrtc.SDPTypeOffer,
		SDP:  sdpOffer,
	}

	if err := pc.SetRemoteDescription(offer); err != nil {
		return "", fmt.Errorf("failed to set remote description: %w", err)
	}

	answer, err := pc.CreateAnswer(nil)
	if err != nil {
		return "", fmt.Errorf("failed to create answer: %w", err)
	}

	if err := pc.SetLocalDescription(answer); err != nil {
		return "", fmt.Errorf("failed to set local description: %w", err)
	}

	// Wait for ICE gathering to complete
	gatherComplete := webrtc.GatheringCompletePromise(pc)
	<-gatherComplete

	return pc.LocalDescription().SDP, nil
}

// HandleRenegotiateAnswer routes a client's answer to a server-initiated
// renegotiation offer back to the participant's PeerConnection.
func (m *Manager) HandleRenegotiateAnswer(roomID, pubkey, sdp string) error {
	room := m.GetRoom(roomID)
	if room == nil {
		return fmt.Errorf("room not found")
	}
	return room.HandleRenegotiateAnswer(pubkey, sdp)
}

// HandleICECandidate adds an ICE candidate to a participant's PeerConnection.
func (m *Manager) HandleICECandidate(roomID, pubkey string, candidate webrtc.ICECandidateInit) error {
	room := m.GetRoom(roomID)
	if room == nil {
		return fmt.Errorf("room not found")
	}

	room.mu.RLock()
	p, ok := room.Participants[pubkey]
	room.mu.RUnlock()
	if !ok || p.PC == nil {
		return fmt.Errorf("participant not found or no PeerConnection")
	}

	return p.PC.AddICECandidate(candidate)
}

// LeaveRoom removes a participant from a room.
func (m *Manager) LeaveRoom(roomID, pubkey string) {
	room := m.GetRoom(roomID)
	if room == nil {
		return
	}
	room.RemoveParticipant(pubkey)
}

// RemoveParticipantFromAll removes a participant from all rooms.
func (m *Manager) RemoveParticipantFromAll(pubkey string) {
	m.mu.RLock()
	rooms := make([]*Room, 0)
	for _, r := range m.rooms {
		r.mu.RLock()
		if _, ok := r.Participants[pubkey]; ok {
			rooms = append(rooms, r)
		}
		r.mu.RUnlock()
	}
	m.mu.RUnlock()

	for _, r := range rooms {
		r.RemoveParticipant(pubkey)
	}
}

func (m *Manager) buildICEConfig() webrtc.Configuration {
	// ICETransportPolicy applies to LOCAL candidate gathering. The server
	// has no TURN client so ICETransportPolicyRelay would leave it with
	// zero candidates and ICE failure — gathering scope is controlled
	// instead via SettingEngine.SetNetworkTypes (TCP-only in stealth mode).
	// Always advertise All so paired remote (TURNS-relay) candidates are
	// considered.
	return webrtc.Configuration{
		ICETransportPolicy: webrtc.ICETransportPolicyAll,
	}
}

// speakerDetectionLoop periodically checks audio levels and sends speaker updates.
func (m *Manager) speakerDetectionLoop() {
	ticker := time.NewTicker(500 * time.Millisecond)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			m.detectSpeakers()
		case <-m.stopCh:
			return
		}
	}
}

func (m *Manager) detectSpeakers() {
	m.mu.RLock()
	rooms := make([]*Room, 0, len(m.rooms))
	for _, r := range m.rooms {
		rooms = append(rooms, r)
	}
	m.mu.RUnlock()

	// SpeakerThreshold is in -dBov (e.g., -40 means level < 40 in dBov = louder than -40 dBFS)
	// AudioLevel from RTP: 0=loudest, 127=silence. Convert: dBFS = -level
	// So threshold -40 means: accept if level <= 40
	thresholdDBov := int32(-m.cfg.SpeakerThreshold) // e.g., -(-40) = 40

	scanned := 0
	for _, room := range rooms {
		// Fast path: skip rooms with no audio tracks ever published.
		// hasAudio is a one-way flag flipped when the first audio track
		// is added; rooms that only carry video/screen/data never enter
		// the per-participant scan below.
		if !room.hasAudio.Load() {
			continue
		}

		room.mu.RLock()
		// Speaker detection is meaningless with <2 participants: there's
		// no one to notify, and no "dominance" comparison to make.
		if len(room.Participants) < 2 {
			room.mu.RUnlock()
			continue
		}

		speakers := make([]string, 0)
		var dominant string
		var minLevel int32 = 127 // lowest dBov = loudest

		for pubkey, p := range room.Participants {
			for _, track := range p.PublishedTracks {
				if track.Kind == "audio" && !track.Muted {
					level := track.AudioLevel.Load() // 0=loud, 127=silent
					if level < thresholdDBov {
						speakers = append(speakers, pubkey)
						if level < minLevel {
							minLevel = level
							dominant = pubkey
						}
					}
				}
			}
		}
		room.mu.RUnlock()
		scanned++

		if len(speakers) > 0 {
			room.speakerMu.Lock()
			changed := !strSliceEqual(room.speakers, speakers) || room.dominant != dominant
			room.speakers = speakers
			room.dominant = dominant
			room.speakerMu.Unlock()

			if changed {
				msg := speakerUpdateJSON(room.ID, speakers, dominant)
				room.Broadcast(msg)

				// Update Last-N active set based on new speaker info
				room.UpdateLastN(speakers, dominant)
			}
		}
	}

	// First time we actually scanned at least one room with audio +
	// 2+ participants, log it. This answers the question "is the 500ms
	// loop ever doing anything, or just waking up and exiting?" without
	// spamming the logs on every tick.
	if scanned > 0 {
		m.speakerLoopStarted.Do(func() {
			log.Printf("[sfu] speaker detection loop: first scan with audio+participants (rooms=%d)", scanned)
		})
	}
}

func strSliceEqual(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	set := make(map[string]struct{}, len(a))
	for _, s := range a {
		set[s] = struct{}{}
	}
	for _, s := range b {
		if _, ok := set[s]; !ok {
			return false
		}
	}
	return true
}

// bweLoop periodically adjusts simulcast layers based on REMB bandwidth estimates.
func (m *Manager) bweLoop() {
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			m.adjustAllBWE()
		case <-m.stopCh:
			return
		}
	}
}

func (m *Manager) adjustAllBWE() {
	m.mu.RLock()
	rooms := make([]*Room, 0, len(m.rooms))
	for _, r := range m.rooms {
		rooms = append(rooms, r)
	}
	m.mu.RUnlock()

	for _, room := range rooms {
		room.mu.RLock()
		if len(room.Participants) < 2 {
			room.mu.RUnlock()
			continue
		}

		// Collect current speakers
		room.speakerMu.Lock()
		dominant := room.dominant
		speakerSet := make(map[string]struct{}, len(room.speakers))
		for _, s := range room.speakers {
			speakerSet[s] = struct{}{}
		}
		room.speakerMu.Unlock()

		pubkeys := make([]string, 0, len(room.Participants))
		for pk := range room.Participants {
			pubkeys = append(pubkeys, pk)
		}
		room.mu.RUnlock()

		for _, pk := range pubkeys {
			room.AdjustBWE(pk, dominant, speakerSet)
		}
	}
}

// cleanupLoop removes stale empty rooms.
func (m *Manager) cleanupLoop() {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			m.mu.Lock()
			for id, room := range m.rooms {
				if room.ParticipantCount() == 0 && time.Since(room.CreatedAt) > 5*time.Minute {
					delete(m.rooms, id)
					log.Printf("[sfu] stale room %s removed", id)
				}
			}
			m.mu.Unlock()
		case <-m.stopCh:
			return
		}
	}
}

// Stop shuts down the SFU manager.
func (m *Manager) Stop() {
	close(m.stopCh)

	m.mu.Lock()
	for _, room := range m.rooms {
		room.Close()
	}
	m.rooms = make(map[string]*Room)
	m.mu.Unlock()

	if m.tcpMux != nil {
		m.tcpMux.Close()
	}
}

func speakerUpdateJSON(roomID string, speakers []string, dominant string) []byte {
	s := "["
	for i, sp := range speakers {
		if i > 0 {
			s += ","
		}
		s += `"` + sp + `"`
	}
	s += "]"
	return []byte(fmt.Sprintf(`{"type":"speaker_update","room_id":"%s","speakers":%s,"dominant":"%s"}`, roomID, s, dominant))
}
