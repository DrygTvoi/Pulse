package relay

import "encoding/json"

// Envelope is the generic wire-protocol wrapper.
// Every message sent over WebSocket is an Envelope with a Type and a JSON Payload.
type Envelope struct {
	Type    string          `json:"type"`
	Payload json.RawMessage `json:"payload"`
}

// --- Client → Server message types ---

// AuthResponse is sent by the client in response to an auth_challenge.
type AuthResponse struct {
	Pubkey    string `json:"pubkey"`
	Signature string `json:"signature"`
	Nonce     string `json:"nonce"`
	Timestamp int64  `json:"timestamp"`
	Invite    string `json:"invite,omitempty"`
	PoWSeed   string `json:"pow_seed,omitempty"`
	PoWNonce  uint64 `json:"pow_nonce,omitempty"`
}

// SendMessage is sent by the client to deliver a message to another user.
type SendMessage struct {
	ID      string          `json:"id"`
	To      string          `json:"to"`
	Payload json.RawMessage `json:"payload"`
	TTL     int64           `json:"ttl,omitempty"` // seconds until expiry, 0 = use server default
}

// Signal is sent by the client for signaling (WebRTC, key exchange, etc).
type Signal struct {
	To      string          `json:"to"`
	Payload json.RawMessage `json:"payload"`
}

// Fetch requests stored messages.
type Fetch struct {
	Since int64 `json:"since"` // unix timestamp
	Limit int   `json:"limit"`
}

// Ack acknowledges receipt of a message.
type Ack struct {
	ID string `json:"id"`
}

// KeysPut uploads the user's key bundle.
type KeysPut struct {
	Bundle json.RawMessage `json:"bundle"`
}

// KeysGet requests another user's key bundle.
type KeysGet struct {
	Pubkey string `json:"pubkey"`
}

// Ping is a keepalive.
type Ping struct{}

// BackupPut uploads an encrypted backup.
type BackupPut struct {
	Data     []byte `json:"data"`
	Checksum string `json:"checksum"`
}

// BackupGet requests the user's backup.
type BackupGet struct{}

// --- Server → Client message types ---

// AuthChallenge is sent to the client upon connection.
type AuthChallenge struct {
	Nonce     string `json:"nonce"`
	Timestamp int64  `json:"timestamp"`
}

// AuthOK confirms successful authentication.
type AuthOK struct {
	Pubkey string `json:"pubkey"`
}

// IncomingMessage is a message delivered to the client.
type IncomingMessage struct {
	ID      string          `json:"id"`
	From    string          `json:"from"`
	Payload json.RawMessage `json:"payload"`
	Created int64           `json:"created"`
}

// IncomingSignal is a signal delivered to the client.
type IncomingSignal struct {
	From    string          `json:"from"`
	Payload json.RawMessage `json:"payload"`
}

// Stored confirms a message was stored for offline delivery.
type Stored struct {
	ID string `json:"id"`
}

// KeysResponse contains a requested key bundle.
type KeysResponse struct {
	Pubkey string          `json:"pubkey"`
	Bundle json.RawMessage `json:"bundle"`
}

// AckResponse confirms message acknowledgement.
type AckResponse struct {
	ID string `json:"id"`
}

// ErrorResponse reports an error.
type ErrorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// BackupResponse contains a user's backup.
type BackupResponse struct {
	Data     []byte `json:"data"`
	Checksum string `json:"checksum"`
}

// PongResponse is a keepalive reply.
type PongResponse struct{}

// Message type constants.
const (
	// Client → Server
	TypeAuthResponse = "auth_response"
	TypeSend         = "send"
	TypeSignal       = "signal"
	TypeFetch        = "fetch"
	TypeAck          = "ack"
	TypeKeysPut      = "keys_put"
	TypeKeysGet      = "keys_get"
	TypePing         = "ping"
	TypeBackupPut    = "backup_put"
	TypeBackupGet    = "backup_get"

	// Server → Client
	TypeAuthChallenge = "auth_challenge"
	TypeAuthOK        = "auth_ok"
	TypeMessage       = "message"
	TypeInSignal      = "signal"
	TypeSignalFail    = "signal_fail"
	TypeStored        = "stored"
	TypeKeys          = "keys"
	TypeAckResp       = "ack"
	TypeError         = "error"
	TypeBackup        = "backup"
	TypePong          = "pong"

	// File transfer (v2)
	TypeUploadStart    = "upload_start"
	TypeUploadAck      = "upload_ack"
	TypeUploadComplete = "upload_complete"
	TypeUploadResume   = "upload_resume"
	TypeDownloadReq    = "download_req"

	// SFU Media (Phase 2+3)
	TypeRoomCreate      = "room_create"
	TypeRoomCreated     = "room_created"
	TypeRoomJoin        = "room_join"
	TypeRoomInfo        = "room_info"
	TypeRoomLeave       = "room_leave"
	TypeRoomLeft        = "room_left"
	TypeMediaOffer      = "media_offer"
	TypeMediaAnswer     = "media_answer"
	TypeMediaCandidate  = "media_candidate"
	TypeTrackPublish    = "track_publish"
	TypeTrackPublished  = "track_published"
	TypeTrackAvailable  = "track_available"
	TypeTrackSubscribe  = "track_subscribe"
	TypeTrackSubscribed = "track_subscribed"
	TypeTrackPause      = "track_pause"
	TypeTrackResume     = "track_resume"
	TypeQualityPrefer   = "quality_prefer"
	TypeSpeakerUpdate   = "speaker_update"
	TypeLastNUpdate     = "last_n_update"

	// Tunnel (Phase 5)
	TypeTunnelOpen   = "tunnel_open"
	TypeTunnelOpened = "tunnel_opened"
	TypeTunnelClose  = "tunnel_close"
	TypeTunnelError  = "tunnel_error"

	// Sealed sender (Phase 6)
	TypeSealedSend = "sealed_send"
)

// MakeEnvelope creates an Envelope from a type and payload.
func MakeEnvelope(msgType string, payload interface{}) (*Envelope, error) {
	data, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}
	return &Envelope{
		Type:    msgType,
		Payload: json.RawMessage(data),
	}, nil
}

// --- V2 flat wire structs (no nested "payload" wrapper) ---

// V2AuthChallenge is the v2 auth challenge (flat).
type V2AuthChallenge struct {
	Type          string `json:"type"`
	Nonce         string `json:"nonce"`
	Timestamp     int64  `json:"ts"`
	Version       int    `json:"v"`
	PoWSeed       string `json:"pow_seed,omitempty"`
	PoWDifficulty int    `json:"pow_difficulty,omitempty"`
	PoWExpires    int64  `json:"pow_expires,omitempty"`
}

// V2PrivacyInfo describes the server's active privacy/obfuscation features.
type V2PrivacyInfo struct {
	Padding  string `json:"padding,omitempty"`  // "cbr" | "burst" | ""
	RateKbps int    `json:"rate_kbps,omitempty"`
	Chaff    bool   `json:"chaff,omitempty"`
}

// V2AuthOK is the v2 auth success response (flat).
type V2AuthOK struct {
	Type         string           `json:"type"`
	Pubkey       string           `json:"pubkey"`
	Server       string           `json:"server,omitempty"`
	Turn         *TurnCredentials `json:"turn,omitempty"`
	CertFP       string           `json:"cert_fp,omitempty"`
	PendingCount int              `json:"pending_count"`
	Privacy      *V2PrivacyInfo   `json:"privacy,omitempty"`
}

// TurnCredentials holds TURN server connection info.
type TurnCredentials struct {
	URLs       []string `json:"urls"`
	Username   string   `json:"username"`
	Credential string   `json:"credential"`
	TTL        int      `json:"ttl"`
}

// V2SendMessage is a v2 send message (flat).
type V2SendMessage struct {
	Type     string `json:"type"`
	ID       string `json:"id"`
	To       string `json:"to"`
	Body     string `json:"body"`
	TTL      int64  `json:"ttl,omitempty"`
	Priority int    `json:"priority,omitempty"`
}

// V2IncomingMessage is a v2 incoming message (flat).
type V2IncomingMessage struct {
	Type     string `json:"type"`
	ID       string `json:"id"`
	From     string `json:"from"`
	Body     string `json:"body"`
	Ts       int64  `json:"ts"`
	ServerTs int64  `json:"server_ts"`
}

// V2Signal is a v2 signal (flat).
type V2Signal struct {
	Type    string `json:"type"`
	To      string `json:"to"`
	Payload string `json:"payload"`
}

// V2Error is a v2 error response (flat).
type V2Error struct {
	Type    string `json:"type"`
	Code    string `json:"code"`
	Message string `json:"message"`
}

// UploadStart initiates a chunked file upload.
type UploadStart struct {
	Type       string `json:"type"`
	TransferID string `json:"transfer_id"`
	SHA256     string `json:"sha256"`
	TotalSize  int64  `json:"total_size"`
	ChunkSize  int    `json:"chunk_size"`
	ChunkCount int    `json:"chunk_count"`
}

// UploadAckResp acknowledges an upload start or resume.
type UploadAckResp struct {
	Type       string `json:"type"`
	TransferID string `json:"transfer_id"`
	NextChunk  int    `json:"next_chunk"`
}

// UploadCompleteResp confirms a completed upload.
type UploadCompleteResp struct {
	Type       string `json:"type"`
	TransferID string `json:"transfer_id"`
	FileID     string `json:"file_id"`
	Size       int64  `json:"size"`
}

// DownloadReq requests a file download.
type DownloadReq struct {
	Type       string `json:"type"`
	TransferID string `json:"transfer_id"`
}

// --- SFU Room structs (Phase 2+3) ---

// RoomCreate — Client → Server
type RoomCreate struct {
	Type  string `json:"type"`
	Max   int    `json:"max,omitempty"`
	Name  string `json:"name,omitempty"`
	E2EE  bool   `json:"e2ee,omitempty"`
}

// RoomCreated — Server → Client
type RoomCreated struct {
	Type   string `json:"type"`
	RoomID string `json:"room_id"`
	Token  string `json:"token"`
}

// RoomJoin — Client → Server
type RoomJoin struct {
	Type   string `json:"type"`
	RoomID string `json:"room_id"`
	Token  string `json:"token"`
}

// RoomParticipantInfo describes one participant in a room.
type RoomParticipantInfo struct {
	Pubkey string           `json:"pubkey"`
	Tracks []TrackShortInfo `json:"tracks"`
}

// TrackShortInfo is a brief track descriptor.
type TrackShortInfo struct {
	ID   string `json:"id"`
	Kind string `json:"kind"`
}

// RoomInfo — Server → Client
type RoomInfo struct {
	Type         string                `json:"type"`
	RoomID       string                `json:"room_id"`
	Participants []RoomParticipantInfo `json:"participants"`
}

// RoomLeave — Client → Server
type RoomLeave struct {
	Type   string `json:"type"`
	RoomID string `json:"room_id"`
}

// RoomLeft — Server → Client (also sent as notification when another user leaves)
type RoomLeft struct {
	Type   string `json:"type"`
	RoomID string `json:"room_id"`
	Pubkey string `json:"pubkey,omitempty"`
}

// MediaOffer — Client → Server (SDP offer)
type MediaOffer struct {
	Type   string `json:"type"`
	RoomID string `json:"room_id"`
	SDP    string `json:"sdp"`
}

// MediaAnswer — Server → Client (SDP answer)
type MediaAnswer struct {
	Type   string `json:"type"`
	RoomID string `json:"room_id"`
	SDP    string `json:"sdp"`
}

// MediaCandidate — bidirectional ICE candidate
type MediaCandidate struct {
	Type          string `json:"type"`
	RoomID        string `json:"room_id"`
	Candidate     string `json:"candidate"`
	SDPMid        string `json:"sdp_mid,omitempty"`
	SDPMLineIndex int    `json:"sdp_mline_index,omitempty"`
}

// SimulcastLayerInfo describes one simulcast layer.
type SimulcastLayerInfo struct {
	RID        string `json:"rid"`
	Width      int    `json:"width"`
	Height     int    `json:"height"`
	MaxBitrate int    `json:"maxBitrate"`
	MaxFPS     int    `json:"maxFps,omitempty"`
}

// TrackPublish — Client → Server
type TrackPublish struct {
	Type      string               `json:"type"`
	RoomID    string               `json:"room_id"`
	Kind      string               `json:"kind"` // "audio" | "video" | "screen" | "data"
	Codec     string               `json:"codec,omitempty"`
	Simulcast bool                 `json:"simulcast,omitempty"`
	Layers    []SimulcastLayerInfo `json:"layers,omitempty"`
}

// TrackPublished — Server → Client
type TrackPublished struct {
	Type    string `json:"type"`
	RoomID  string `json:"room_id"`
	TrackID string `json:"track_id"`
}

// TrackAvailable — Server → Client (notification: remote track published)
type TrackAvailable struct {
	Type    string `json:"type"`
	RoomID  string `json:"room_id"`
	Pubkey  string `json:"pubkey"`
	TrackID string `json:"track_id"`
	Kind    string `json:"kind"`
}

// TrackSubscribe — Client → Server
type TrackSubscribe struct {
	Type    string `json:"type"`
	RoomID  string `json:"room_id"`
	TrackID string `json:"track_id"`
	Layer   string `json:"layer,omitempty"` // simulcast layer preference
}

// TrackSubscribed — Server → Client
type TrackSubscribed struct {
	Type    string `json:"type"`
	RoomID  string `json:"room_id"`
	TrackID string `json:"track_id"`
}

// TrackPause — Client → Server
type TrackPause struct {
	Type    string `json:"type"`
	RoomID  string `json:"room_id"`
	TrackID string `json:"track_id"`
}

// TrackResume — Client → Server
type TrackResume struct {
	Type    string `json:"type"`
	RoomID  string `json:"room_id"`
	TrackID string `json:"track_id"`
}

// QualityPrefer — Client → Server
type QualityPrefer struct {
	Type       string `json:"type"`
	RoomID     string `json:"room_id"`
	TrackID    string `json:"track_id"`
	Layer      string `json:"layer,omitempty"`
	MaxBitrate int    `json:"max_bitrate,omitempty"`
}

// SpeakerUpdate — Server → Client
type SpeakerUpdate struct {
	Type     string   `json:"type"`
	RoomID   string   `json:"room_id"`
	Speakers []string `json:"speakers"`
	Dominant string   `json:"dominant,omitempty"`
}

// LastNUpdate — Server → Client (notifies which participants have active video)
type LastNUpdate struct {
	Type      string   `json:"type"`
	RoomID    string   `json:"room_id"`
	ActiveSet []string `json:"active_set"`
	Dominant  string   `json:"dominant,omitempty"`
}

// --- Tunnel structs (Phase 5) ---

// TunnelOpen — Client → Server
type TunnelOpen struct {
	Type     string `json:"type"`
	TunnelID string `json:"tunnel_id"`
	Host     string `json:"host"`
	Port     int    `json:"port"`
}

// TunnelOpened — Server → Client
type TunnelOpened struct {
	Type     string `json:"type"`
	TunnelID string `json:"tunnel_id"`
	RemoteIP string `json:"remote_ip"`
}

// TunnelClose — bidirectional
type TunnelClose struct {
	Type     string `json:"type"`
	TunnelID string `json:"tunnel_id"`
}

// TunnelError — Server → Client
type TunnelError struct {
	Type     string `json:"type"`
	TunnelID string `json:"tunnel_id"`
	Reason   string `json:"reason"`
}

// --- Sealed sender (Phase 6) ---

// SealedSend — Client → Server (via /v2/sealed)
type SealedSend struct {
	Type string `json:"type"`
	Cert string `json:"cert"`
	To   string `json:"to"`
	Body string `json:"body"`
}

// DeliveryCert is a single-use delivery token for sealed sender.
type DeliveryCert struct {
	Token   string `json:"token"`
	Expires int64  `json:"expires"`
}

// --- Binary frame header constants ---
const (
	BinaryTypeUpload byte = 0x01
	BinaryTypeChunk  byte = 0x02
	BinaryHeaderSize      = 25 // 1 type + 16 transferID + 4 chunkIdx + 4 totalChunks

	// Media ws-relay binary types (Phase 3)
	BinaryTypeAudio        byte = 0x10
	BinaryTypeVideoKey     byte = 0x11
	BinaryTypeVideoDelta   byte = 0x12
	BinaryTypeScreenKey    byte = 0x13
	BinaryTypeScreenDelta  byte = 0x14
	BinaryTypeDataChannel  byte = 0x15
	MediaBinaryHeaderSize       = 27 // 1 type + 16 roomID + 1 trackIdx + 4 seq + 4 ts + 1 flags

	// Tunnel binary types (Phase 5)
	BinaryTypeTunnelUp   byte = 0x20 // client → server
	BinaryTypeTunnelDown byte = 0x21 // server → client
	TunnelBinaryHeader        = 17   // 1 type + 16 tunnelID

	// Padding (Phase 6)
	BinaryTypePadding byte = 0xFF
)
