package sfu

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"sort"
	"sync"
	"sync/atomic"
	"time"

	"github.com/pion/rtcp"
	"github.com/pion/rtp"
	"github.com/pion/webrtc/v4"
)

// SimulcastLayer holds one spatial/temporal layer of a simulcast track.
type SimulcastLayer struct {
	RID       string
	Remote    *webrtc.TrackRemote
	LocalSink *webrtc.TrackLocalStaticRTP
	Bitrate   int // target bps
}

// Track represents a published media track in a room.
type Track struct {
	ID        string
	Owner     string // pubkey of publisher
	Kind      string // "audio" | "video" | "screen" | "data"
	Codec     string
	Remote    *webrtc.TrackRemote
	LocalSink *webrtc.TrackLocalStaticRTP
	Muted     bool

	// Simulcast layers (populated when RID is present)
	Simulcast bool
	Layers    map[string]*SimulcastLayer // "f"/"h"/"q"

	// Audio level from RTP header extension (RFC 6464).
	// Value is -dBov: 0=loudest, 127=silence. Updated per-packet for audio tracks.
	AudioLevel atomic.Int32
}

// Participant represents a user in a room.
type Participant struct {
	Pubkey         string
	PC             *webrtc.PeerConnection
	PublishedTracks map[string]*Track          // trackID → Track (tracks this participant publishes)
	Subscriptions  map[string]*webrtc.RTPSender // trackID → sender (tracks this participant receives)
	SubLayers      map[string]string            // trackID → current simulcast layer ("f"/"h"/"q"/"")
	VideoSubs      map[string]bool              // trackID → currently subscribed for video?
	SendMessage    func([]byte) error          // callback to send JSON to client
	SendBinary     func([]byte) error          // callback to send binary frames
	JoinedAt       time.Time
	mu             sync.Mutex

	// Bandwidth estimation (Phase 4)
	EstimatedBW  atomic.Int64 // bps, from REMB
	LastBWUpdate atomic.Int64 // unix ms
}

// Room represents an SFU media room.
type Room struct {
	mu           sync.RWMutex
	ID           string
	Name         string
	Creator      string // pubkey
	Token        string // access token
	E2EE         bool
	MaxSize      int
	Participants map[string]*Participant // pubkey → Participant
	Tracks       map[string]*Track       // trackID → Track
	CreatedAt    time.Time

	// Room lifecycle
	closeCh chan struct{} // closed when room shuts down

	// Speaker detection
	speakerMu  sync.Mutex
	speakers   []string // pubkeys currently speaking
	dominant   string   // pubkey of dominant speaker

	// Last-N: only forward top N video tracks based on speaker activity
	lastNCount int                 // from MediaConfig.LastNVideo (0 = disabled)
	lastNSet   map[string]struct{} // pubkeys whose video is currently forwarded
	lastNGen   uint64              // bumped on each update

	// Simulcast
	simulcast bool // true if server-side simulcast is enabled

	api        *webrtc.API
	onEmpty    func(roomID string) // called when room becomes empty
}

// NewRoom creates a new SFU room.
func NewRoom(id, creator, name string, maxSize int, e2ee bool, lastNCount int, simulcast bool, api *webrtc.API, onEmpty func(string)) *Room {
	token := generateToken()
	return &Room{
		ID:           id,
		Name:         name,
		Creator:      creator,
		Token:        token,
		E2EE:         e2ee,
		MaxSize:      maxSize,
		Participants: make(map[string]*Participant),
		Tracks:       make(map[string]*Track),
		CreatedAt:    time.Now(),
		closeCh:      make(chan struct{}),
		lastNCount:   lastNCount,
		lastNSet:     make(map[string]struct{}),
		simulcast:    simulcast,
		api:          api,
		onEmpty:      onEmpty,
	}
}

func generateToken() string {
	b := make([]byte, 16)
	rand.Read(b)
	return hex.EncodeToString(b)
}

func generateTrackID() string {
	b := make([]byte, 8)
	rand.Read(b)
	return "t" + hex.EncodeToString(b)
}

// AddParticipant adds a new participant to the room.
func (r *Room) AddParticipant(pubkey string, sendMsg func([]byte) error, sendBin func([]byte) error) (*Participant, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	if len(r.Participants) >= r.MaxSize {
		return nil, fmt.Errorf("room is full (%d/%d)", len(r.Participants), r.MaxSize)
	}

	if _, exists := r.Participants[pubkey]; exists {
		return nil, fmt.Errorf("already in room")
	}

	p := &Participant{
		Pubkey:          pubkey,
		PublishedTracks: make(map[string]*Track),
		Subscriptions:   make(map[string]*webrtc.RTPSender),
		SubLayers:       make(map[string]string),
		VideoSubs:       make(map[string]bool),
		SendMessage:     sendMsg,
		SendBinary:      sendBin,
		JoinedAt:        time.Now(),
	}

	r.Participants[pubkey] = p
	return p, nil
}

// RemoveParticipant removes a participant and cleans up their tracks.
func (r *Room) RemoveParticipant(pubkey string) {
	r.mu.Lock()
	p, ok := r.Participants[pubkey]
	if !ok {
		r.mu.Unlock()
		return
	}

	// Clean up published tracks
	for trackID, track := range p.PublishedTracks {
		delete(r.Tracks, trackID)
		_ = track // track resources cleaned up when PC closes

		// Notify other participants that track is gone
		r.broadcastExcept(pubkey, trackRemovedJSON(r.ID, pubkey, trackID))
	}

	// Close PeerConnection
	if p.PC != nil {
		p.PC.Close()
	}

	delete(r.Participants, pubkey)
	empty := len(r.Participants) == 0
	r.mu.Unlock()

	// Notify others about departure
	r.broadcastExcept(pubkey, roomLeftJSON(r.ID, pubkey))

	if empty && r.onEmpty != nil {
		r.onEmpty(r.ID)
	}
}

// CreatePeerConnection creates a new PeerConnection for a participant.
func (r *Room) CreatePeerConnection(pubkey string, config webrtc.Configuration) (*webrtc.PeerConnection, error) {
	r.mu.Lock()
	p, ok := r.Participants[pubkey]
	r.mu.Unlock()
	if !ok {
		return nil, fmt.Errorf("not in room")
	}

	pc, err := r.api.NewPeerConnection(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create PeerConnection: %w", err)
	}

	p.mu.Lock()
	p.PC = pc
	p.mu.Unlock()

	// Handle incoming tracks from this participant
	pc.OnTrack(func(remote *webrtc.TrackRemote, receiver *webrtc.RTPReceiver) {
		r.handleIncomingTrack(pubkey, remote)
	})

	pc.OnICEConnectionStateChange(func(state webrtc.ICEConnectionState) {
		log.Printf("[sfu] room %s participant %s ICE state: %s", r.ID, pubkey[:8], state)
		if state == webrtc.ICEConnectionStateFailed || state == webrtc.ICEConnectionStateDisconnected {
			// Give time for recovery, then remove
			go func() {
				timer := time.NewTimer(10 * time.Second)
				defer timer.Stop()
				select {
				case <-timer.C:
					r.mu.RLock()
					p, ok := r.Participants[pubkey]
					r.mu.RUnlock()
					if ok && p.PC == pc {
						currentState := pc.ICEConnectionState()
						if currentState == webrtc.ICEConnectionStateFailed || currentState == webrtc.ICEConnectionStateDisconnected {
							r.RemoveParticipant(pubkey)
						}
					}
				case <-r.closeCh:
					// Room closing — no cleanup needed
				}
			}()
		}
	})

	return pc, nil
}

// handleIncomingTrack handles a new track published by a participant.
func (r *Room) handleIncomingTrack(pubkey string, remote *webrtc.TrackRemote) {
	kind := remote.Kind().String()
	codec := remote.Codec().MimeType
	rid := remote.RID()

	// Simulcast: if RID is present, this is one layer of a simulcast track
	if rid != "" && r.simulcast {
		r.handleSimulcastLayer(pubkey, remote, kind, codec, rid)
		return
	}

	trackID := generateTrackID()

	// Create a local track that will be used to fan-out to subscribers
	localTrack, err := webrtc.NewTrackLocalStaticRTP(
		remote.Codec().RTPCodecCapability,
		trackID,
		fmt.Sprintf("sfu_%s_%s", pubkey[:8], kind),
	)
	if err != nil {
		log.Printf("[sfu] failed to create local track: %v", err)
		return
	}

	track := &Track{
		ID:        trackID,
		Owner:     pubkey,
		Kind:      kind,
		Codec:     codec,
		Remote:    remote,
		LocalSink: localTrack,
		Layers:    make(map[string]*SimulcastLayer),
	}
	track.AudioLevel.Store(127) // default: silence

	r.mu.Lock()
	p, ok := r.Participants[pubkey]
	if ok {
		p.PublishedTracks[trackID] = track
	}
	r.Tracks[trackID] = track
	r.mu.Unlock()

	// Notify publisher of track ID
	if ok {
		p.SendMessage(trackPublishedJSON(r.ID, trackID))
	}

	// Notify all other participants that a new track is available
	r.broadcastExcept(pubkey, trackAvailableJSON(r.ID, pubkey, trackID, kind))

	// Start forwarding RTP packets from remote to local track
	go r.forwardRTP(remote, localTrack, track)
}

// handleSimulcastLayer adds a simulcast layer to an existing (or new) track.
func (r *Room) handleSimulcastLayer(pubkey string, remote *webrtc.TrackRemote, kind, codec, rid string) {
	r.mu.Lock()

	// Find existing track for this owner+kind that has simulcast
	var track *Track
	p, pOk := r.Participants[pubkey]
	if pOk {
		for _, t := range p.PublishedTracks {
			if t.Kind == kind && t.Simulcast {
				track = t
				break
			}
		}
	}

	if track == nil {
		// First layer — create the parent track
		trackID := generateTrackID()

		// The "main" local sink uses the first layer's codec
		localTrack, err := webrtc.NewTrackLocalStaticRTP(
			remote.Codec().RTPCodecCapability,
			trackID,
			fmt.Sprintf("sfu_%s_%s", pubkey[:8], kind),
		)
		if err != nil {
			r.mu.Unlock()
			log.Printf("[sfu] failed to create simulcast local track: %v", err)
			return
		}

		track = &Track{
			ID:        trackID,
			Owner:     pubkey,
			Kind:      kind,
			Codec:     codec,
			Remote:    remote,
			LocalSink: localTrack,
			Simulcast: true,
			Layers:    make(map[string]*SimulcastLayer),
		}
		track.AudioLevel.Store(127)

		if pOk {
			p.PublishedTracks[trackID] = track
		}
		r.Tracks[trackID] = track
		r.mu.Unlock()

		if pOk {
			p.SendMessage(trackPublishedJSON(r.ID, trackID))
		}
		r.broadcastExcept(pubkey, trackAvailableJSON(r.ID, pubkey, trackID, kind))
	} else {
		r.mu.Unlock()
	}

	// Create local sink for this layer
	layerLocalTrack, err := webrtc.NewTrackLocalStaticRTP(
		remote.Codec().RTPCodecCapability,
		track.ID+"_"+rid,
		fmt.Sprintf("sfu_%s_%s_%s", pubkey[:8], kind, rid),
	)
	if err != nil {
		log.Printf("[sfu] failed to create simulcast layer track %s: %v", rid, err)
		return
	}

	bitrate := 150000 // default quarter
	switch rid {
	case "f":
		bitrate = 2500000
	case "h":
		bitrate = 600000
	case "q":
		bitrate = 150000
	}

	layer := &SimulcastLayer{
		RID:       rid,
		Remote:    remote,
		LocalSink: layerLocalTrack,
		Bitrate:   bitrate,
	}

	r.mu.Lock()
	track.Layers[rid] = layer
	// If this is the "h" (half) layer, use it as the default local sink
	if rid == "h" {
		track.LocalSink = layerLocalTrack
	}
	r.mu.Unlock()

	log.Printf("[sfu] simulcast layer %s added to track %s (owner: %s)", rid, track.ID, pubkey[:8])

	// Forward RTP for this layer
	go r.forwardRTP(remote, layerLocalTrack, track)
}

// forwardRTP copies RTP packets from the remote track to the local track.
// For audio tracks, it also extracts the audio level from RFC 6464 header extensions.
func (r *Room) forwardRTP(remote *webrtc.TrackRemote, local *webrtc.TrackLocalStaticRTP, track *Track) {
	buf := make([]byte, 1500)
	isAudio := track.Kind == "audio"
	for {
		n, _, err := remote.Read(buf)
		if err != nil {
			return
		}

		// Parse audio level from RTP header extension (RFC 6464)
		if isAudio {
			var pkt rtp.Packet
			if parseErr := pkt.Unmarshal(buf[:n]); parseErr == nil {
				// Try extension IDs 1-3 (common SDP extmap IDs for audio level)
				for id := uint8(1); id <= 3; id++ {
					if ext := pkt.GetExtension(id); len(ext) >= 1 {
						// RFC 6464: V (1 bit) + level (7 bits), -dBov
						level := ext[0] & 0x7F
						track.AudioLevel.Store(int32(level))
						break
					}
				}
			}
		}

		if _, err := local.Write(buf[:n]); err != nil {
			return
		}
	}
}

// SubscribeTrack adds a subscription so a participant receives a track.
func (r *Room) SubscribeTrack(pubkey, trackID string) error {
	return r.SubscribeTrackWithLayer(pubkey, trackID, "")
}

// UnsubscribeTrack removes a track subscription.
func (r *Room) UnsubscribeTrack(pubkey, trackID string) error {
	r.mu.RLock()
	p, ok := r.Participants[pubkey]
	r.mu.RUnlock()
	if !ok {
		return fmt.Errorf("not in room")
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	sender, ok := p.Subscriptions[trackID]
	if !ok {
		return nil
	}

	if p.PC != nil {
		p.PC.RemoveTrack(sender)
	}
	delete(p.Subscriptions, trackID)
	return nil
}

// GetParticipantInfo returns the list of participants and their tracks.
func (r *Room) GetParticipantInfo() []ParticipantInfo {
	r.mu.RLock()
	defer r.mu.RUnlock()

	result := make([]ParticipantInfo, 0, len(r.Participants))
	for pubkey, p := range r.Participants {
		tracks := make([]TrackInfo, 0, len(p.PublishedTracks))
		for _, t := range p.PublishedTracks {
			tracks = append(tracks, TrackInfo{ID: t.ID, Kind: t.Kind})
		}
		result = append(result, ParticipantInfo{Pubkey: pubkey, Tracks: tracks})
	}
	return result
}

// ParticipantInfo is a serializable participant descriptor.
type ParticipantInfo struct {
	Pubkey string      `json:"pubkey"`
	Tracks []TrackInfo `json:"tracks"`
}

// TrackInfo is a serializable track descriptor.
type TrackInfo struct {
	ID   string `json:"id"`
	Kind string `json:"kind"`
}

// ParticipantCount returns the number of participants.
func (r *Room) ParticipantCount() int {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return len(r.Participants)
}

// broadcastExcept sends a message to all participants except the given pubkey.
func (r *Room) broadcastExcept(excludePubkey string, msg []byte) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	for pk, p := range r.Participants {
		if pk != excludePubkey {
			p.SendMessage(msg)
		}
	}
}

// Broadcast sends a message to all participants.
func (r *Room) Broadcast(msg []byte) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	for _, p := range r.Participants {
		p.SendMessage(msg)
	}
}

// Close removes all participants and closes the room.
func (r *Room) Close() {
	// Signal all goroutines tied to this room to stop
	select {
	case <-r.closeCh:
	default:
		close(r.closeCh)
	}

	r.mu.Lock()
	pubkeys := make([]string, 0, len(r.Participants))
	for pk := range r.Participants {
		pubkeys = append(pubkeys, pk)
	}
	r.mu.Unlock()

	for _, pk := range pubkeys {
		r.RemoveParticipant(pk)
	}
}

// UpdateLastN recalculates the Last-N active speaker set and subscribes/unsubscribes
// video tracks accordingly. Called from speaker detection loop.
func (r *Room) UpdateLastN(speakers []string, dominant string) {
	if r.lastNCount <= 0 {
		return // Last-N disabled
	}

	r.mu.RLock()
	if len(r.Participants) <= r.lastNCount {
		r.mu.RUnlock()
		return // fewer participants than N — everyone gets video
	}
	r.mu.RUnlock()

	// Build new set: dominant always included + top N-1 by most recent speaking
	newSet := make(map[string]struct{})
	if dominant != "" {
		newSet[dominant] = struct{}{}
	}

	// Sort speakers by audio level (lower = louder), take top N-1
	type speakerLevel struct {
		pubkey string
		level  int32
	}
	var sl []speakerLevel
	r.mu.RLock()
	for _, pk := range speakers {
		if pk == dominant {
			continue // already in set
		}
		p, ok := r.Participants[pk]
		if !ok {
			continue
		}
		var minLevel int32 = 127
		for _, t := range p.PublishedTracks {
			if t.Kind == "audio" {
				lvl := t.AudioLevel.Load()
				if lvl < minLevel {
					minLevel = lvl
				}
			}
		}
		sl = append(sl, speakerLevel{pk, minLevel})
	}
	r.mu.RUnlock()

	sort.Slice(sl, func(i, j int) bool { return sl[i].level < sl[j].level })
	remaining := r.lastNCount - len(newSet)
	for i := 0; i < remaining && i < len(sl); i++ {
		newSet[sl[i].pubkey] = struct{}{}
	}

	// Compare with current set
	r.mu.Lock()
	changed := false
	if len(newSet) != len(r.lastNSet) {
		changed = true
	} else {
		for pk := range newSet {
			if _, ok := r.lastNSet[pk]; !ok {
				changed = true
				break
			}
		}
	}

	if !changed {
		r.mu.Unlock()
		return
	}

	// Determine who left and who joined the active set
	leaving := make(map[string]struct{})
	entering := make(map[string]struct{})
	for pk := range r.lastNSet {
		if _, ok := newSet[pk]; !ok {
			leaving[pk] = struct{}{}
		}
	}
	for pk := range newSet {
		if _, ok := r.lastNSet[pk]; !ok {
			entering[pk] = struct{}{}
		}
	}

	r.lastNSet = newSet
	r.lastNGen++
	r.mu.Unlock()

	// Unsubscribe video tracks of participants leaving the active set
	for pk := range leaving {
		r.mu.RLock()
		p, ok := r.Participants[pk]
		if ok {
			for trackID, t := range p.PublishedTracks {
				if t.Kind == "video" || t.Kind == "screen" {
					// Unsub from all other participants
					for subPk, sub := range r.Participants {
						if subPk != pk {
							sub.mu.Lock()
							sub.VideoSubs[trackID] = false
							sub.mu.Unlock()
						}
					}
					_ = trackID
				}
			}
		}
		r.mu.RUnlock()
	}

	// Subscribe video tracks of participants entering the active set
	for pk := range entering {
		r.mu.RLock()
		p, ok := r.Participants[pk]
		if ok {
			for trackID, t := range p.PublishedTracks {
				if t.Kind == "video" || t.Kind == "screen" {
					for subPk, sub := range r.Participants {
						if subPk != pk {
							sub.mu.Lock()
							sub.VideoSubs[trackID] = true
							sub.mu.Unlock()
						}
					}
				}
			}
		}
		r.mu.RUnlock()
	}

	// Build active set list for broadcast
	activeList := make([]string, 0, len(newSet))
	for pk := range newSet {
		activeList = append(activeList, pk)
	}

	r.Broadcast(lastNUpdateJSON(r.ID, activeList, dominant))
}

// IsInLastN returns true if the given pubkey is in the Last-N active set.
// If Last-N is disabled (count=0) or there are fewer participants than N, returns true.
func (r *Room) IsInLastN(pubkey string) bool {
	if r.lastNCount <= 0 {
		return true
	}
	r.mu.RLock()
	defer r.mu.RUnlock()
	if len(r.Participants) <= r.lastNCount {
		return true
	}
	_, ok := r.lastNSet[pubkey]
	return ok
}

// SubscribeTrackWithLayer adds a subscription with optional simulcast layer preference.
func (r *Room) SubscribeTrackWithLayer(pubkey, trackID, layer string) error {
	r.mu.RLock()
	p, ok := r.Participants[pubkey]
	track, trackOk := r.Tracks[trackID]
	r.mu.RUnlock()

	if !ok {
		return fmt.Errorf("not in room")
	}
	if !trackOk {
		return fmt.Errorf("track not found")
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	if p.PC == nil {
		return fmt.Errorf("no PeerConnection")
	}

	// Choose which local track to add
	var localTrack *webrtc.TrackLocalStaticRTP
	if track.Simulcast && layer != "" {
		if l, ok := track.Layers[layer]; ok {
			localTrack = l.LocalSink
		}
	}
	if localTrack == nil {
		localTrack = track.LocalSink
	}

	sender, err := p.PC.AddTrack(localTrack)
	if err != nil {
		return fmt.Errorf("failed to add track: %w", err)
	}

	p.Subscriptions[trackID] = sender
	p.SubLayers[trackID] = layer
	if track.Kind == "video" || track.Kind == "screen" {
		p.VideoSubs[trackID] = true
	}

	// Parse RTCP — extract REMB for BWE (Phase 4)
	go func() {
		buf := make([]byte, 1500)
		for {
			n, _, err := sender.Read(buf)
			if err != nil {
				return
			}
			pkts, _ := rtcp.Unmarshal(buf[:n])
			for _, pkt := range pkts {
				if remb, ok := pkt.(*rtcp.ReceiverEstimatedMaximumBitrate); ok {
					p.EstimatedBW.Store(int64(remb.Bitrate))
					p.LastBWUpdate.Store(time.Now().UnixMilli())
				}
			}
		}
	}()

	return nil
}

// SwitchLayer switches a subscriber's simulcast layer for a given track.
func (r *Room) SwitchLayer(subscriberPubkey, trackID, newLayer string) error {
	r.mu.RLock()
	p, ok := r.Participants[subscriberPubkey]
	track, trackOk := r.Tracks[trackID]
	r.mu.RUnlock()

	if !ok {
		return fmt.Errorf("not in room")
	}
	if !trackOk || !track.Simulcast {
		return fmt.Errorf("track not found or not simulcast")
	}

	newLayerInfo, ok := track.Layers[newLayer]
	if !ok {
		return fmt.Errorf("layer %s not available", newLayer)
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	// Remove current sender
	if sender, exists := p.Subscriptions[trackID]; exists && p.PC != nil {
		p.PC.RemoveTrack(sender)
	}

	if p.PC == nil {
		return fmt.Errorf("no PeerConnection")
	}

	// Add new layer
	sender, err := p.PC.AddTrack(newLayerInfo.LocalSink)
	if err != nil {
		return fmt.Errorf("failed to switch layer: %w", err)
	}
	p.Subscriptions[trackID] = sender
	p.SubLayers[trackID] = newLayer

	// RTCP reader for new sender
	go func() {
		buf := make([]byte, 1500)
		for {
			n, _, err := sender.Read(buf)
			if err != nil {
				return
			}
			pkts, _ := rtcp.Unmarshal(buf[:n])
			for _, pkt := range pkts {
				if remb, ok := pkt.(*rtcp.ReceiverEstimatedMaximumBitrate); ok {
					p.EstimatedBW.Store(int64(remb.Bitrate))
					p.LastBWUpdate.Store(time.Now().UnixMilli())
				}
			}
		}
	}()

	return nil
}

// layerBitrate returns the target bitrate for a simulcast layer.
func layerBitrate(layer string) int64 {
	switch layer {
	case "f":
		return 2500000
	case "h":
		return 600000
	case "q":
		return 150000
	default:
		return 600000 // non-simulcast default
	}
}

// layerDown returns the next lower quality layer, or "" if already at lowest.
func layerDown(layer string) string {
	switch layer {
	case "f":
		return "h"
	case "h":
		return "q"
	default:
		return ""
	}
}

// layerUp returns the next higher quality layer, or "" if already at highest.
func layerUp(layer string) string {
	switch layer {
	case "q":
		return "h"
	case "h":
		return "f"
	default:
		return ""
	}
}

// AdjustBWE checks a participant's estimated bandwidth and switches simulcast layers.
// Returns number of adjustments made.
func (r *Room) AdjustBWE(pubkey string, dominant string, speakers map[string]struct{}) int {
	r.mu.RLock()
	p, ok := r.Participants[pubkey]
	r.mu.RUnlock()
	if !ok {
		return 0
	}

	bw := p.EstimatedBW.Load()
	if bw <= 0 {
		return 0 // no REMB data yet
	}
	lastUpdate := p.LastBWUpdate.Load()
	if time.Now().UnixMilli()-lastUpdate > 10000 {
		return 0 // stale REMB (>10s old)
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	// Sum current subscription bitrates (video only)
	var totalBps int64
	type subInfo struct {
		trackID string
		layer   string
		bps     int64
	}
	var videoSubs []subInfo

	for trackID, layer := range p.SubLayers {
		r.mu.RLock()
		track, tOk := r.Tracks[trackID]
		r.mu.RUnlock()
		if !tOk || !track.Simulcast {
			continue
		}
		if track.Kind != "video" && track.Kind != "screen" {
			continue
		}
		bps := layerBitrate(layer)
		totalBps += bps
		videoSubs = append(videoSubs, subInfo{trackID, layer, bps})
	}

	if len(videoSubs) == 0 {
		return 0
	}

	adjustments := 0

	if bw < totalBps*80/100 {
		// Bandwidth constrained — downgrade lowest priority track
		// Priority: dominant > speaker > other. Downgrade "other" first.
		var target *subInfo
		for i := range videoSubs {
			s := &videoSubs[i]
			if layerDown(s.layer) == "" {
				continue // already at lowest
			}
			r.mu.RLock()
			track := r.Tracks[s.trackID]
			r.mu.RUnlock()
			if track == nil {
				continue
			}
			owner := track.Owner
			if owner == dominant {
				continue // never downgrade dominant
			}
			if _, isSpeaker := speakers[owner]; !isSpeaker {
				target = s
				break // prefer non-speaker
			}
			if target == nil {
				target = s // fallback: downgrade a speaker (but not dominant)
			}
		}
		if target != nil {
			newLayer := layerDown(target.layer)
			// SwitchLayer needs lock released — use a deferred call
			trackID := target.trackID
			p.mu.Unlock()
			if err := r.SwitchLayer(pubkey, trackID, newLayer); err == nil {
				adjustments++
				log.Printf("[sfu/bwe] %s: downgrade %s %s→%s (bw=%dkbps, sum=%dkbps)",
					pubkey[:8], trackID, target.layer, newLayer, bw/1000, totalBps/1000)
			}
			p.mu.Lock()
		}
	} else if bw > totalBps*120/100 {
		// Bandwidth available — upgrade highest priority track
		var target *subInfo
		for i := range videoSubs {
			s := &videoSubs[i]
			if layerUp(s.layer) == "" {
				continue // already at highest
			}
			r.mu.RLock()
			track := r.Tracks[s.trackID]
			r.mu.RUnlock()
			if track == nil {
				continue
			}
			owner := track.Owner
			if owner == dominant {
				target = s
				break // prioritize dominant
			}
			if _, isSpeaker := speakers[owner]; isSpeaker && target == nil {
				target = s
			}
			if target == nil {
				target = s
			}
		}
		if target != nil {
			newLayer := layerUp(target.layer)
			trackID := target.trackID
			p.mu.Unlock()
			if err := r.SwitchLayer(pubkey, trackID, newLayer); err == nil {
				adjustments++
				log.Printf("[sfu/bwe] %s: upgrade %s %s→%s (bw=%dkbps, sum=%dkbps)",
					pubkey[:8], trackID, target.layer, newLayer, bw/1000, totalBps/1000)
			}
			p.mu.Lock()
		}
	}

	return adjustments
}

// --- JSON helpers ---

func trackPublishedJSON(roomID, trackID string) []byte {
	return []byte(fmt.Sprintf(`{"type":"track_published","room_id":"%s","track_id":"%s"}`, roomID, trackID))
}

func trackAvailableJSON(roomID, pubkey, trackID, kind string) []byte {
	return []byte(fmt.Sprintf(`{"type":"track_available","room_id":"%s","pubkey":"%s","track_id":"%s","kind":"%s"}`, roomID, pubkey, trackID, kind))
}

func trackRemovedJSON(roomID, pubkey, trackID string) []byte {
	return []byte(fmt.Sprintf(`{"type":"track_removed","room_id":"%s","pubkey":"%s","track_id":"%s"}`, roomID, pubkey, trackID))
}

func roomLeftJSON(roomID, pubkey string) []byte {
	return []byte(fmt.Sprintf(`{"type":"room_left","room_id":"%s","pubkey":"%s"}`, roomID, pubkey))
}

func lastNUpdateJSON(roomID string, activeSet []string, dominant string) []byte {
	s := "["
	for i, pk := range activeSet {
		if i > 0 {
			s += ","
		}
		s += `"` + pk + `"`
	}
	s += "]"
	dom := ""
	if dominant != "" {
		dom = `,"dominant":"` + dominant + `"`
	}
	return []byte(fmt.Sprintf(`{"type":"last_n_update","room_id":"%s","active_set":%s%s}`, roomID, s, dom))
}
