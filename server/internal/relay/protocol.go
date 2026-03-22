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
	TypeStored        = "stored"
	TypeKeys          = "keys"
	TypeAckResp       = "ack"
	TypeError         = "error"
	TypeBackup        = "backup"
	TypePong          = "pong"
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
