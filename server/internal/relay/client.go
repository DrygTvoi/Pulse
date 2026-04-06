package relay

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/auth"
	"github.com/nicholasgasior/pulse-server/internal/metrics"
	"github.com/nicholasgasior/pulse-server/internal/store"
)

// Client states.
const (
	StateConnected      = "connected"
	StateAuthenticating = "authenticating"
	StateAuthenticated  = "authenticated"
)

// WebSocket parameters.
const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingInterval   = (pongWait * 9) / 10
	maxMessageSize = 1 << 20 // 1 MB
)

// Client represents a single WebSocket connection.
type Client struct {
	hub       *Hub
	conn      *websocket.Conn
	pubkey    string
	state     string
	challenge *auth.Challenge
	cfg       *config.Config
	users     *store.UserStore
	invites   *store.InviteStore
	messages  *store.MessageStore

	certFP       string // TLS certificate SHA-256 fingerprint
	remoteIP     string // client IP for optional storage
	powChallenge *metrics.PoWChallenge

	send       chan []byte
	sendBinary chan []byte
	closeOnce  sync.Once
	done       chan struct{}
}

// NewClient creates a new Client for the given WebSocket connection.
func NewClient(hub *Hub, conn *websocket.Conn, cfg *config.Config, users *store.UserStore, invites *store.InviteStore, messages *store.MessageStore, certFP string) *Client {
	return &Client{
		hub:        hub,
		conn:       conn,
		state:      StateConnected,
		cfg:        cfg,
		users:      users,
		invites:    invites,
		messages:   messages,
		certFP:     certFP,
		send:       make(chan []byte, 256),
		sendBinary: make(chan []byte, 64),
		done:       make(chan struct{}),
	}
}

// SetRemoteIP sets the client's remote IP address for optional storage.
func (c *Client) SetRemoteIP(ip string) {
	c.remoteIP = ip
}

// Start begins the client's read and write pumps and sends the auth challenge.
func (c *Client) Start() {
	// Generate and send auth challenge
	challenge, err := auth.GenerateChallenge()
	if err != nil {
		log.Printf("[client] failed to generate challenge: %v", err)
		c.conn.Close()
		return
	}
	c.challenge = challenge
	c.state = StateAuthenticating

	ch := &AuthChallenge{
		Type:      TypeAuthChallenge,
		Nonce:     challenge.Nonce,
		Timestamp: challenge.Timestamp,
		Version:   2,
	}
	// Include PoW challenge when auth mode is "open" to prevent abuse
	if c.cfg.Auth.Mode == "open" && c.cfg.Limits.PoWDifficulty > 0 {
		pow := metrics.GeneratePoWChallenge(c.cfg.Limits.PoWDifficulty)
		c.powChallenge = pow
		ch.PoWSeed = pow.Seed
		ch.PoWDifficulty = pow.Difficulty
		ch.PoWExpires = pow.Expires
	}
	data, err := json.Marshal(ch)
	if err != nil {
		log.Printf("[client] failed to marshal challenge: %v", err)
		c.conn.Close()
		return
	}
	select {
	case c.send <- data:
	default:
		log.Printf("[client] send buffer full on challenge")
		c.conn.Close()
		return
	}

	log.Printf("[client] starting pumps for %s", c.remoteIP)
	go c.writePump()
	go c.readPump()
}

// Close cleanly shuts down the client connection.
func (c *Client) Close() {
	c.closeOnce.Do(func() {
		close(c.done)
		c.conn.Close()
	})
}

// SendEnvelope marshals and queues a flat JSON message for sending.
// It adds "type" to the marshaled struct.
func (c *Client) SendEnvelope(msgType string, payload interface{}) error {
	return c.sendFlat(msgType, payload)
}

// sendFlat sends a flat JSON message with "type" injected into the marshaled payload.
func (c *Client) sendFlat(msgType string, payload interface{}) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	// Merge "type" into the JSON object
	var m map[string]interface{}
	if err := json.Unmarshal(data, &m); err != nil {
		return fmt.Errorf("failed to unmarshal payload for type injection: %w", err)
	}
	m["type"] = msgType
	flat, err := json.Marshal(m)
	if err != nil {
		return fmt.Errorf("failed to marshal flat message: %w", err)
	}

	select {
	case c.send <- flat:
		return nil
	case <-c.done:
		return fmt.Errorf("client is closed")
	default:
		return fmt.Errorf("send buffer full")
	}
}

// SendBinaryChunk sends a binary chunk frame to the client.
func (c *Client) SendBinaryChunk(transferID []byte, chunkIdx, totalChunks uint32, data []byte) error {
	frame := make([]byte, BinaryHeaderSize+len(data))
	frame[0] = BinaryTypeChunk
	copy(frame[1:17], transferID[:16])
	binary.BigEndian.PutUint32(frame[17:21], chunkIdx)
	binary.BigEndian.PutUint32(frame[21:25], totalChunks)
	copy(frame[25:], data)

	select {
	case c.sendBinary <- frame:
		return nil
	case <-c.done:
		return fmt.Errorf("client is closed")
	default:
		return fmt.Errorf("binary send buffer full")
	}
}

// SendDirect sends a pre-marshaled JSON message.
func (c *Client) SendDirect(data []byte) error {
	select {
	case c.send <- data:
		return nil
	case <-c.done:
		return fmt.Errorf("client is closed")
	default:
		return fmt.Errorf("send buffer full")
	}
}

// SendError sends a flat error message.
func (c *Client) SendError(code, message string) {
	data, _ := json.Marshal(&FlatError{
		Type:    TypeError,
		Code:    code,
		Message: message,
	})
	c.SendDirect(data)
}

// readPump reads messages from the WebSocket connection.
func (c *Client) readPump() {
	defer func() {
		if c.state == StateAuthenticated {
			c.hub.Unregister(c)
		}
		c.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		msgType, message, err := c.conn.ReadMessage()
		if err != nil {
			log.Printf("[client] read exit for %s (ip=%s, state=%s): %v", c.pubkey, c.remoteIP, c.state, err)
			return
		}

		// Handle binary frames (file transfer chunks, media, tunnels)
		if msgType == websocket.BinaryMessage {
			if c.state != StateAuthenticated {
				continue
			}
			c.handleBinaryFrame(message)
			continue
		}

		c.handleTextFrame(message)
	}
}

// handleTextFrame processes a flat JSON text frame.
func (c *Client) handleTextFrame(message []byte) {
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(message, &raw); err != nil {
		c.SendError("invalid_json", "failed to parse message")
		return
	}

	var mt string
	if t, ok := raw["type"]; ok {
		json.Unmarshal(t, &mt)
	}
	if mt == "" {
		c.SendError("invalid_json", "missing type field")
		return
	}

	switch c.state {
	case StateAuthenticating:
		c.handleAuth(mt, message)
	case StateAuthenticated:
		env := c.toEnvelope(mt, message)
		if env != nil {
			c.hub.HandleMessage(c, env)
		}
	default:
		c.SendError("unexpected_state", "connection in unexpected state")
	}
}

// toEnvelope converts a flat JSON message to an internal Envelope for Hub dispatch.
func (c *Client) toEnvelope(msgType string, raw []byte) *Envelope {
	switch msgType {
	case TypeSend:
		var msg FlatSendMessage
		if err := json.Unmarshal(raw, &msg); err != nil {
			c.SendError("invalid_payload", "failed to parse send message")
			return nil
		}
		payload, _ := json.Marshal(&SendMessage{
			ID:      msg.ID,
			To:      msg.To,
			Payload: json.RawMessage(fmt.Sprintf("%q", msg.Body)),
			TTL:     msg.TTL,
		})
		return &Envelope{Type: TypeSend, Payload: payload}

	case TypeSignal:
		var sig FlatSignal
		if err := json.Unmarshal(raw, &sig); err != nil {
			c.SendError("invalid_payload", "failed to parse signal")
			return nil
		}
		payload, _ := json.Marshal(&Signal{
			To:      sig.To,
			Payload: json.RawMessage(fmt.Sprintf("%q", sig.Payload)),
		})
		return &Envelope{Type: TypeSignal, Payload: payload}

	case TypeUploadStart, TypeUploadResume, TypeDownloadReq,
		TypeRoomCreate, TypeRoomJoin, TypeRoomLeave,
		TypeMediaOffer, TypeMediaCandidate,
		TypeTrackPublish, TypeTrackSubscribe, TypeTrackPause, TypeTrackResume,
		TypeQualityPrefer,
		TypeTunnelOpen, TypeTunnelClose:
		// Pass raw JSON as payload for hub to handle
		return &Envelope{Type: msgType, Payload: json.RawMessage(raw)}

	default:
		// For other types (fetch, ack, keys_put, keys_get, ping, backup_put, backup_get),
		// the flat format has the same fields — just wrap them
		return &Envelope{Type: msgType, Payload: json.RawMessage(raw)}
	}
}

// handleAuth processes an auth_response during authentication.
func (c *Client) handleAuth(msgType string, raw []byte) {
	log.Printf("[auth] handleAuth called: type=%s ip=%s raw=%s", msgType, c.remoteIP, string(raw))

	if msgType != TypeAuthResponse {
		log.Printf("[auth] REJECT: expected auth_response, got %s", msgType)
		c.SendError("auth_required", "expected auth_response")
		return
	}

	var resp AuthResponse
	if err := json.Unmarshal(raw, &resp); err != nil {
		log.Printf("[auth] REJECT: unmarshal failed: %v", err)
		c.SendError("invalid_payload", "failed to parse auth_response")
		return
	}

	log.Printf("[auth] parsed: pubkey=%s nonce=%s ts=%d", resp.Pubkey[:16], resp.Nonce[:16], resp.Timestamp)

	if c.challenge == nil {
		log.Printf("[auth] REJECT: no challenge issued")
		c.SendError("auth_failed", "no challenge issued")
		c.Close()
		return
	}

	log.Printf("[auth] challenge: nonce=%s ts=%d", c.challenge.Nonce[:16], c.challenge.Timestamp)

	if resp.Nonce != c.challenge.Nonce || resp.Timestamp != c.challenge.Timestamp {
		log.Printf("[auth] REJECT: challenge mismatch (nonce_match=%v ts_match=%v)", resp.Nonce == c.challenge.Nonce, resp.Timestamp == c.challenge.Timestamp)
		c.SendError("auth_failed", "challenge mismatch")
		c.Close()
		return
	}

	if !auth.VerifyResponse(resp.Pubkey, resp.Signature, resp.Nonce, resp.Timestamp) {
		log.Printf("[auth] REJECT: invalid signature for pubkey=%s", resp.Pubkey[:16])
		c.SendError("auth_failed", "invalid signature")
		c.Close()
		return
	}

	log.Printf("[auth] OK: signature verified for %s", resp.Pubkey[:16])

	// Verify PoW solution if challenge was issued
	if c.powChallenge != nil {
		log.Printf("[auth] PoW check for %s", resp.Pubkey[:16])
		sol := &metrics.PoWSolution{Seed: resp.PoWSeed, Nonce: resp.PoWNonce}
		if !metrics.VerifyPoW(c.powChallenge, sol) {
			log.Printf("[auth] REJECT: PoW failed for %s", resp.Pubkey[:16])
			c.SendError("pow_failed", "invalid proof-of-work solution")
			c.Close()
			return
		}
		c.powChallenge = nil // consumed
		log.Printf("[auth] PoW OK for %s", resp.Pubkey[:16])
	}

	log.Printf("[auth] processRegistration for %s", resp.Pubkey[:16])
	// Common registration + ban check logic
	if !c.processRegistration(&resp) {
		log.Printf("[auth] REJECT: processRegistration failed for %s", resp.Pubkey[:16])
		return
	}

	log.Printf("[auth] registration OK for %s, setting state", resp.Pubkey[:16])
	// Authentication successful
	c.pubkey = resp.Pubkey
	c.state = StateAuthenticated
	c.challenge = nil
	if c.cfg.Privacy.StoreClientIP && c.remoteIP != "" {
		c.users.UpdateLastSeenIP(c.pubkey, c.remoteIP)
	} else {
		c.users.UpdateLastSeen(c.pubkey)
	}

	if c.hub.MaxConnectionsReached() {
		log.Printf("[auth] REJECT: server full for %s", resp.Pubkey[:16])
		c.SendError("server_full", "server has reached maximum connections")
		c.Close()
		return
	}

	log.Printf("[auth] registering with hub for %s", resp.Pubkey[:16])
	c.hub.Register(c)

	// Build auth_ok with server info
	ok := &AuthOK{
		Type:   TypeAuthOK,
		Pubkey: c.pubkey,
		CertFP: c.certFP,
	}

	// Include TURN credentials if available
	if c.hub.turnServer != nil {
		creds, err := c.hub.turnServer.GenerateCredentials(c.pubkey)
		if err == nil {
			ok.Turn = &TurnCredentials{
				URLs:       creds.URIs,
				Username:   creds.Username,
				Credential: creds.Password,
				TTL:        creds.TTL,
			}
		}
	}

	// Include pending message count
	if c.messages != nil {
		if count, err := c.messages.CountPendingForUser(c.pubkey); err == nil {
			ok.PendingCount = count
		}
	}

	// Advertise active privacy features so client can match upstream CBR
	ps := c.hub.PrivacySettings()
	if ps.Padding || ps.Chaff {
		ok.Privacy = &PrivacyInfo{
			Chaff: ps.Chaff,
		}
		if ps.Padding {
			ok.Privacy.Padding = ps.PaddingMode
			ok.Privacy.RateKbps = ps.PaddingRateKbps
		}
	}

	data, _ := json.Marshal(ok)
	c.SendDirect(data)
}

// SendBinaryDirect sends raw binary data to the client.
func (c *Client) SendBinaryDirect(data []byte) error {
	select {
	case c.sendBinary <- data:
		return nil
	case <-c.done:
		return fmt.Errorf("client is closed")
	default:
		return fmt.Errorf("binary send buffer full")
	}
}

// handleBinaryFrame processes an incoming binary WebSocket frame.
func (c *Client) handleBinaryFrame(data []byte) {
	if len(data) < 1 {
		return
	}

	frameType := data[0]

	switch {
	case frameType == BinaryTypeUpload || frameType == BinaryTypeChunk:
		// File transfer chunk
		if len(data) < BinaryHeaderSize {
			c.SendError("invalid_binary", "binary frame too short")
			return
		}
		transferID := fmt.Sprintf("%x", data[1:17])
		chunkIdx := binary.BigEndian.Uint32(data[17:21])
		totalChunks := binary.BigEndian.Uint32(data[21:25])
		chunkData := data[BinaryHeaderSize:]
		c.hub.HandleUploadChunk(c, transferID, int(chunkIdx), int(totalChunks), chunkData)

	case frameType >= BinaryTypeAudio && frameType <= BinaryTypeDataChannel:
		// WS-relay media frames (0x10-0x15) → SFU
		c.hub.HandleWSRelayMedia(c, data)

	case frameType == BinaryTypeTunnelUp:
		// Tunnel data from client (0x20)
		c.hub.HandleTunnelData(c, data)

	case frameType == BinaryTypePadding:
		// Padding frame (0xFF) — silently discard
		return

	default:
		c.SendError("invalid_binary", fmt.Sprintf("unknown binary frame type: 0x%02x", frameType))
	}
}

// writePump writes messages to the WebSocket connection.
func (c *Client) writePump() {
	ticker := time.NewTicker(pingInterval)
	defer func() {
		ticker.Stop()
		c.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Printf("[client] write error for %s: %v", c.pubkey, err)
				return
			}

		case binMsg, ok := <-c.sendBinary:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				return
			}
			if err := c.conn.WriteMessage(websocket.BinaryMessage, binMsg); err != nil {
				log.Printf("[client] binary write error for %s: %v", c.pubkey, err)
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}

		case <-c.done:
			return
		}
	}
}

// processRegistration checks user existence, handles registration, and checks ban status.
// Returns true if registration succeeded and user is not banned.
func (c *Client) processRegistration(resp *AuthResponse) bool {
	exists, err := c.users.UserExists(resp.Pubkey)
	if err != nil {
		c.SendError("internal_error", "failed to check user")
		c.Close()
		return false
	}

	if !exists {
		switch c.cfg.Auth.Mode {
		case "open":
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				c.SendError("internal_error", "failed to create user")
				c.Close()
				return false
			}

		case "invite":
			if resp.Invite == "" {
				c.SendError("invite_required", "invite code required for registration")
				c.Close()
				return false
			}
			if _, err := c.invites.ValidateInvite(resp.Invite); err != nil {
				c.SendError("invite_invalid", err.Error())
				c.Close()
				return false
			}
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				c.SendError("internal_error", "failed to create user")
				c.Close()
				return false
			}
			if err := c.invites.UseInvite(resp.Invite, resp.Pubkey); err != nil {
				log.Printf("[client] failed to mark invite used: %v", err)
			}

		case "closed":
			c.SendError("registration_closed", "server is not accepting new registrations")
			c.Close()
			return false

		default:
			c.SendError("internal_error", "unknown auth mode")
			c.Close()
			return false
		}
	}

	user, err := c.users.GetUser(resp.Pubkey)
	if err != nil {
		c.SendError("internal_error", "failed to get user")
		c.Close()
		return false
	}
	if user != nil && user.Banned {
		c.SendError("banned", "user is banned")
		c.Close()
		return false
	}

	return true
}
