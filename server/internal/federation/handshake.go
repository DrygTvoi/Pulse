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
	handshakeTimeout = 10 * time.Second
	handshakeVersion = "pulse-fed-v1"
)

// HandshakeMessage is exchanged during server-to-server mutual auth.
type HandshakeMessage struct {
	Version   string `json:"version"`
	Pubkey    string `json:"pubkey"`
	Timestamp int64  `json:"timestamp"`
	Signature string `json:"signature"`
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
