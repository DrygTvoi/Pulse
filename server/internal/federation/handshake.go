package federation

import (
	"crypto/ed25519"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/gorilla/websocket"
)

const (
	handshakeTimeout  = 10 * time.Second
	handshakeVersion  = "pulse-fed-v1"
	handshakeVersion2 = "pulse-fed-v2"
)

// HandshakeMessage is exchanged during server-to-server mutual auth (v1).
type HandshakeMessage struct {
	Version   string `json:"version"`
	Pubkey    string `json:"pubkey"`
	Timestamp int64  `json:"timestamp"`
	Signature string `json:"signature"`
}

// HandshakeMessageV2 is the v2 federation hello with server info.
type HandshakeMessageV2 struct {
	Type      string           `json:"type"`
	Version   int              `json:"v"`
	Pubkey    string           `json:"pubkey"`
	Timestamp int64            `json:"ts"`
	Signature string           `json:"sig"`
	Server    *FedServerInfo   `json:"server,omitempty"`
}

// FedServerInfo describes a federation peer's capabilities.
type FedServerInfo struct {
	Name     string   `json:"name"`
	Version  string   `json:"version"`
	Features []string `json:"features"`
	Users    int      `json:"users"`
}

// FederatedEnvelopeV2 is the v2 federation message with hop limiting.
type FederatedEnvelopeV2 struct {
	Type string `json:"type"` // "fed_envelope"
	ID   string `json:"id"`
	From string `json:"from"`
	To   string `json:"to"`
	Kind string `json:"kind"` // "message" | "signal" | "media"
	Body string `json:"body"`
	Ts   int64  `json:"ts"`
	TTL  int64  `json:"ttl"`
	Hops int    `json:"hops"`
}

// FederationAuth holds the server's Ed25519 keypair for federation.
type FederationAuth struct {
	PrivateKey ed25519.PrivateKey
	PublicKey  ed25519.PublicKey
}

// NewFederationAuth creates a FederationAuth from an existing private key.
// If privKey is nil, a new keypair is generated.
func NewFederationAuth(privKey ed25519.PrivateKey) (*FederationAuth, error) {
	if privKey == nil {
		pub, priv, err := ed25519.GenerateKey(rand.Reader)
		if err != nil {
			return nil, fmt.Errorf("failed to generate federation keypair: %w", err)
		}
		return &FederationAuth{PrivateKey: priv, PublicKey: pub}, nil
	}
	return &FederationAuth{
		PrivateKey: privKey,
		PublicKey:  privKey.Public().(ed25519.PublicKey),
	}, nil
}

// PubkeyHex returns the hex-encoded public key.
func (fa *FederationAuth) PubkeyHex() string {
	return hex.EncodeToString(fa.PublicKey)
}

// PrivkeyHex returns the hex-encoded private key (for storage).
func (fa *FederationAuth) PrivkeyHex() string {
	return hex.EncodeToString(fa.PrivateKey)
}

// PerformHandshake performs mutual authentication on an outgoing WS connection.
// Returns the remote server's pubkey on success.
func (fa *FederationAuth) PerformHandshake(conn *websocket.Conn) (string, error) {
	conn.SetReadDeadline(time.Now().Add(handshakeTimeout))
	conn.SetWriteDeadline(time.Now().Add(handshakeTimeout))

	// Step 1: Send our handshake
	ts := time.Now().Unix()
	msg := fa.signHandshake(ts)

	data, err := json.Marshal(msg)
	if err != nil {
		return "", fmt.Errorf("failed to marshal handshake: %w", err)
	}
	if err := conn.WriteMessage(websocket.TextMessage, data); err != nil {
		return "", fmt.Errorf("failed to send handshake: %w", err)
	}

	// Step 2: Read peer's handshake
	_, peerData, err := conn.ReadMessage()
	if err != nil {
		return "", fmt.Errorf("failed to read peer handshake: %w", err)
	}

	var peerMsg HandshakeMessage
	if err := json.Unmarshal(peerData, &peerMsg); err != nil {
		return "", fmt.Errorf("failed to parse peer handshake: %w", err)
	}

	// Step 3: Verify peer's handshake
	if err := verifyHandshake(&peerMsg); err != nil {
		return "", fmt.Errorf("peer handshake verification failed: %w", err)
	}

	log.Printf("[federation] handshake completed with peer %s", peerMsg.Pubkey)
	return peerMsg.Pubkey, nil
}

// AcceptHandshake handles an incoming federation connection handshake.
// Returns the remote server's pubkey on success.
func (fa *FederationAuth) AcceptHandshake(conn *websocket.Conn) (string, error) {
	conn.SetReadDeadline(time.Now().Add(handshakeTimeout))
	conn.SetWriteDeadline(time.Now().Add(handshakeTimeout))

	// Step 1: Read peer's handshake
	_, peerData, err := conn.ReadMessage()
	if err != nil {
		return "", fmt.Errorf("failed to read peer handshake: %w", err)
	}

	var peerMsg HandshakeMessage
	if err := json.Unmarshal(peerData, &peerMsg); err != nil {
		return "", fmt.Errorf("failed to parse peer handshake: %w", err)
	}

	// Step 2: Verify peer's handshake
	if err := verifyHandshake(&peerMsg); err != nil {
		return "", fmt.Errorf("peer handshake verification failed: %w", err)
	}

	// Step 3: Send our handshake reply
	ts := time.Now().Unix()
	msg := fa.signHandshake(ts)

	data, err := json.Marshal(msg)
	if err != nil {
		return "", fmt.Errorf("failed to marshal handshake reply: %w", err)
	}
	if err := conn.WriteMessage(websocket.TextMessage, data); err != nil {
		return "", fmt.Errorf("failed to send handshake reply: %w", err)
	}

	// Clear deadlines for normal operation
	conn.SetReadDeadline(time.Time{})
	conn.SetWriteDeadline(time.Time{})

	log.Printf("[federation] accepted handshake from peer %s", peerMsg.Pubkey)
	return peerMsg.Pubkey, nil
}

// signHandshake creates a signed handshake message.
func (fa *FederationAuth) signHandshake(ts int64) *HandshakeMessage {
	payload := handshakePayload(fa.PubkeyHex(), ts)
	sig := ed25519.Sign(fa.PrivateKey, []byte(payload))
	return &HandshakeMessage{
		Version:   handshakeVersion,
		Pubkey:    fa.PubkeyHex(),
		Timestamp: ts,
		Signature: hex.EncodeToString(sig),
	}
}

// verifyHandshake validates a peer's handshake message.
func verifyHandshake(msg *HandshakeMessage) error {
	if msg.Version != handshakeVersion {
		return fmt.Errorf("unsupported version: %s", msg.Version)
	}

	// Check timestamp freshness (allow 60 second skew)
	age := time.Now().Unix() - msg.Timestamp
	if age < -60 || age > 60 {
		return fmt.Errorf("handshake timestamp too old or in the future: %ds", age)
	}

	pubBytes, err := hex.DecodeString(msg.Pubkey)
	if err != nil || len(pubBytes) != ed25519.PublicKeySize {
		return fmt.Errorf("invalid pubkey")
	}

	sigBytes, err := hex.DecodeString(msg.Signature)
	if err != nil || len(sigBytes) != ed25519.SignatureSize {
		return fmt.Errorf("invalid signature encoding")
	}

	payload := handshakePayload(msg.Pubkey, msg.Timestamp)
	if !ed25519.Verify(ed25519.PublicKey(pubBytes), []byte(payload), sigBytes) {
		return fmt.Errorf("signature verification failed")
	}

	return nil
}

// handshakePayload constructs the message that is signed during handshake.
func handshakePayload(pubkey string, ts int64) string {
	return fmt.Sprintf("%s:%s:%d", handshakeVersion, pubkey, ts)
}

// --- Federation v2 handshake ---

// signHandshakeV2 creates a v2 federation hello with server info.
func (fa *FederationAuth) signHandshakeV2(ts int64, info *FedServerInfo) *HandshakeMessageV2 {
	payload := fmt.Sprintf("%s:%s:%d", handshakeVersion2, fa.PubkeyHex(), ts)
	sig := ed25519.Sign(fa.PrivateKey, []byte(payload))
	return &HandshakeMessageV2{
		Type:      "fed_hello",
		Version:   2,
		Pubkey:    fa.PubkeyHex(),
		Timestamp: ts,
		Signature: hex.EncodeToString(sig),
		Server:    info,
	}
}

// PerformHandshakeV2 does mutual auth with v2 server info exchange.
func (fa *FederationAuth) PerformHandshakeV2(conn *websocket.Conn, info *FedServerInfo) (string, *FedServerInfo, error) {
	conn.SetReadDeadline(time.Now().Add(handshakeTimeout))
	conn.SetWriteDeadline(time.Now().Add(handshakeTimeout))

	ts := time.Now().Unix()
	msg := fa.signHandshakeV2(ts, info)
	data, err := json.Marshal(msg)
	if err != nil {
		return "", nil, fmt.Errorf("failed to marshal v2 handshake: %w", err)
	}
	if err := conn.WriteMessage(websocket.TextMessage, data); err != nil {
		return "", nil, fmt.Errorf("failed to send v2 handshake: %w", err)
	}

	_, peerData, err := conn.ReadMessage()
	if err != nil {
		return "", nil, fmt.Errorf("failed to read peer v2 handshake: %w", err)
	}

	var peerMsg HandshakeMessageV2
	if err := json.Unmarshal(peerData, &peerMsg); err != nil {
		// Try v1 fallback
		var v1Msg HandshakeMessage
		if err2 := json.Unmarshal(peerData, &v1Msg); err2 == nil {
			if err3 := verifyHandshake(&v1Msg); err3 == nil {
				return v1Msg.Pubkey, nil, nil
			}
		}
		return "", nil, fmt.Errorf("failed to parse peer v2 handshake: %w", err)
	}

	if err := verifyHandshakeV2(&peerMsg); err != nil {
		return "", nil, fmt.Errorf("v2 handshake verification failed: %w", err)
	}

	conn.SetReadDeadline(time.Time{})
	conn.SetWriteDeadline(time.Time{})

	return peerMsg.Pubkey, peerMsg.Server, nil
}

// verifyHandshakeV2 validates a v2 federation handshake.
func verifyHandshakeV2(msg *HandshakeMessageV2) error {
	if msg.Version != 2 {
		return fmt.Errorf("expected v2, got v%d", msg.Version)
	}

	age := time.Now().Unix() - msg.Timestamp
	if age < -60 || age > 60 {
		return fmt.Errorf("timestamp out of range: %ds", age)
	}

	pubBytes, err := hex.DecodeString(msg.Pubkey)
	if err != nil || len(pubBytes) != ed25519.PublicKeySize {
		return fmt.Errorf("invalid pubkey")
	}

	sigBytes, err := hex.DecodeString(msg.Signature)
	if err != nil || len(sigBytes) != ed25519.SignatureSize {
		return fmt.Errorf("invalid signature")
	}

	payload := fmt.Sprintf("%s:%s:%d", handshakeVersion2, msg.Pubkey, msg.Timestamp)
	if !ed25519.Verify(ed25519.PublicKey(pubBytes), []byte(payload), sigBytes) {
		return fmt.Errorf("signature verification failed")
	}

	return nil
}
