package sfu

import (
	"encoding/binary"
	"fmt"
	"log"
)

// MediaBinaryHeaderSize is the header for ws-relay media frames.
const MediaBinaryHeaderSize = 27

// MediaFrame represents a parsed ws-relay binary media frame.
type MediaFrame struct {
	Type       byte   // 0x10-0x15
	RoomID     []byte // 16 bytes
	TrackIndex byte
	Sequence   uint32
	Timestamp  uint32
	Flags      byte
	Payload    []byte
}

// ParseMediaFrame parses a binary ws-relay frame.
func ParseMediaFrame(data []byte) (*MediaFrame, error) {
	if len(data) < MediaBinaryHeaderSize {
		return nil, fmt.Errorf("frame too short: %d bytes", len(data))
	}

	return &MediaFrame{
		Type:       data[0],
		RoomID:     data[1:17],
		TrackIndex: data[17],
		Sequence:   binary.BigEndian.Uint32(data[18:22]),
		Timestamp:  binary.BigEndian.Uint32(data[22:26]),
		Flags:      data[26],
		Payload:    data[MediaBinaryHeaderSize:],
	}, nil
}

// BuildMediaFrame builds a binary ws-relay frame.
func BuildMediaFrame(frameType byte, roomID []byte, trackIdx byte, seq, ts uint32, flags byte, payload []byte) []byte {
	frame := make([]byte, MediaBinaryHeaderSize+len(payload))
	frame[0] = frameType
	copy(frame[1:17], roomID[:16])
	frame[17] = trackIdx
	binary.BigEndian.PutUint32(frame[18:22], seq)
	binary.BigEndian.PutUint32(frame[22:26], ts)
	frame[26] = flags
	copy(frame[MediaBinaryHeaderSize:], payload)
	return frame
}

// HandleWSRelayFrame processes a ws-relay binary media frame and forwards to subscribers.
func (m *Manager) HandleWSRelayFrame(senderPubkey string, data []byte) {
	frame, err := ParseMediaFrame(data)
	if err != nil {
		log.Printf("[sfu] invalid media frame from %s: %v", senderPubkey[:8], err)
		return
	}

	roomIDHex := fmt.Sprintf("%x", frame.RoomID)

	room := m.GetRoom(roomIDHex)
	if room == nil {
		return
	}

	room.mu.RLock()
	defer room.mu.RUnlock()

	// Verify sender is in the room
	if _, ok := room.Participants[senderPubkey]; !ok {
		return
	}

	// For video frames (0x11-0x14), check Last-N filtering
	isVideo := frame.Type >= 0x11 && frame.Type <= 0x14
	if isVideo && !room.IsInLastN(senderPubkey) {
		return // sender not in Last-N active set — skip video forwarding
	}

	// Forward to all other participants
	for pk, p := range room.Participants {
		if pk != senderPubkey {
			if p.SendBinary != nil {
				p.SendBinary(data)
			}
		}
	}
}
