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

	protoVersion int    // 1 or 2
	certFP       string // TLS certificate SHA-256 fingerprint
	remoteIP     string // client IP for optional storage
	powChallenge *metrics.PoWChallenge

	send       chan []byte
	sendBinary chan []byte
	closeOnce  sync.Once
	done       chan struct{}
}

// NewClient creates a new Client for the given WebSocket connection.
func NewClient(hub *Hub, conn *websocket.Conn, cfg *config.Config, users *store.UserStore, invites *store.InviteStore) *Client {
	return &Client{
		hub:          hub,
		conn:         conn,
		state:        StateConnected,
		cfg:          cfg,
		users:        users,
		invites:      invites,
		protoVersion: 1,
		send:         make(chan []byte, 256),
		sendBinary:   make(chan []byte, 64),
		done:         make(chan struct{}),
	}
}

// NewClientV2 creates a v2 protocol Client.
func NewClientV2(hub *Hub, conn *websocket.Conn, cfg *config.Config, users *store.UserStore, invites *store.InviteStore, messages *store.MessageStore, certFP string) *Client {
	return &Client{
		hub:          hub,
		conn:         conn,
		state:        StateConnected,
		cfg:          cfg,
		users:        users,
		invites:      invites,
		messages:     messages,
		protoVersion: 2,
		certFP:       certFP,
		send:         make(chan []byte, 256),
		sendBinary:   make(chan []byte, 64),
		done:         make(chan struct{}),
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

	if c.protoVersion == 2 {
		// V2: flat JSON (no envelope wrapper)
		v2ch := &V2AuthChallenge{
			Type:      TypeAuthChallenge,
			Nonce:     challenge.Nonce,
			Timestamp: challenge.Timestamp,
			Version:   2,
		}
		// Include PoW challenge when auth mode is "open" to prevent abuse
		if c.cfg.Auth.Mode == "open" && c.cfg.Limits.PoWDifficulty > 0 {
			pow := metrics.GeneratePoWChallenge(c.cfg.Limits.PoWDifficulty)
			c.powChallenge = pow
			v2ch.PoWSeed = pow.Seed
			v2ch.PoWDifficulty = pow.Difficulty
			v2ch.PoWExpires = pow.Expires
		}
		data, err := json.Marshal(v2ch)
		if err != nil {
			log.Printf("[client] failed to marshal v2 challenge: %v", err)
			c.conn.Close()
			return
		}
		select {
		case c.send <- data:
		default:
			log.Printf("[client] send buffer full on v2 challenge")
			c.conn.Close()
			return
		}
	} else {
		if err := c.SendEnvelope(TypeAuthChallenge, &AuthChallenge{
			Nonce:     challenge.Nonce,
			Timestamp: challenge.Timestamp,
		}); err != nil {
			log.Printf("[client] failed to send challenge: %v", err)
			c.conn.Close()
			return
		}
	}

	log.Printf("[client] starting pumps for %s (v%d)", c.remoteIP, c.protoVersion)
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

// SendEnvelope marshals and queues an envelope for sending.
// For v1 clients, wraps in {"type":..., "payload":...}.
// For v2 clients, sends flat JSON with "type" field included in the payload struct.
func (c *Client) SendEnvelope(msgType string, payload interface{}) error {
	if c.protoVersion == 2 {
		return c.sendV2(msgType, payload)
	}

	env, err := MakeEnvelope(msgType, payload)
	if err != nil {
		return fmt.Errorf("failed to create envelope: %w", err)
	}
	data, err := json.Marshal(env)
	if err != nil {
		return fmt.Errorf("failed to marshal envelope: %w", err)
	}

	select {
	case c.send <- data:
		return nil
	case <-c.done:
		return fmt.Errorf("client is closed")
	default:
		return fmt.Errorf("send buffer full")
	}
}

// sendV2 sends a flat v2 JSON message. It adds "type" to the marshaled map.
func (c *Client) sendV2(msgType string, payload interface{}) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal v2 payload: %w", err)
	}

	// Merge "type" into the JSON object
	var m map[string]interface{}
	if err := json.Unmarshal(data, &m); err != nil {
		return fmt.Errorf("failed to unmarshal v2 payload for type injection: %w", err)
	}
	m["type"] = msgType
	flat, err := json.Marshal(m)
	if err != nil {
		return fmt.Errorf("failed to marshal v2 flat message: %w", err)
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

// SendV2Direct sends a pre-marshaled v2 JSON message.
func (c *Client) SendV2Direct(data []byte) error {
	select {
	case c.send <- data:
		return nil
	case <-c.done:
		return fmt.Errorf("client is closed")
	default:
		return fmt.Errorf("send buffer full")
	}
}

// SendV2Error sends a flat v2 error message.
func (c *Client) SendV2Error(code, message string) {
	data, _ := json.Marshal(&V2Error{
		Type:    TypeError,
		Code:    code,
		Message: message,
	})
	c.SendV2Direct(data)
}

// SendError sends an error envelope.
func (c *Client) SendError(code, message string) {
	c.SendEnvelope(TypeError, &ErrorResponse{
		Code:    code,
		Message: message,
	})
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

		// Handle binary frames (v2 file transfer chunks)
		if msgType == websocket.BinaryMessage {
			if c.state != StateAuthenticated {
				continue
			}
			c.handleBinaryFrame(message)
			continue
		}

		if c.protoVersion == 2 {
			c.handleV2TextFrame(message)
		} else {
			c.handleV1TextFrame(message)
		}
	}
}

// handleV1TextFrame processes a v1 text frame (envelope format).
func (c *Client) handleV1TextFrame(message []byte) {
	var env Envelope
	if err := json.Unmarshal(message, &env); err != nil {
		c.SendError("invalid_json", "failed to parse message")
		return
	}

	switch c.state {
	case StateAuthenticating:
		c.handleAuth(&env)
	case StateAuthenticated:
		c.hub.HandleMessage(c, &env)
	default:
		c.SendError("unexpected_state", "connection in unexpected state")
	}
}

// handleV2TextFrame processes a v2 flat JSON text frame.
func (c *Client) handleV2TextFrame(message []byte) {
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(message, &raw); err != nil {
		c.SendV2Error("invalid_json", "failed to parse message")
		return
	}

	var msgType string
	if t, ok := raw["type"]; ok {
		json.Unmarshal(t, &msgType)
	}
	if msgType == "" {
		c.SendV2Error("invalid_json", "missing type field")
		return
	}

	switch c.state {
	case StateAuthenticating:
		c.handleAuthV2(msgType, message)
	case StateAuthenticated:
		// Convert flat v2 to Envelope for Hub processing
		env := c.v2ToEnvelope(msgType, message)
		if env != nil {
			c.hub.HandleMessage(c, env)
		}
	default:
		c.SendV2Error("unexpected_state", "connection in unexpected state")
	}
}

// v2ToEnvelope converts a flat v2 JSON message to a v1 Envelope for Hub dispatch.
func (c *Client) v2ToEnvelope(msgType string, raw []byte) *Envelope {
	switch msgType {
	case TypeSend:
		// V2 send: {"type":"send","id":"...","to":"...","body":"...","ttl":N}
		var v2 V2SendMessage
		if err := json.Unmarshal(raw, &v2); err != nil {
			c.SendV2Error("invalid_payload", "failed to parse send message")
			return nil
		}
		payload, _ := json.Marshal(&SendMessage{
			ID:      v2.ID,
			To:      v2.To,
			Payload: json.RawMessage(fmt.Sprintf("%q", v2.Body)),
			TTL:     v2.TTL,
		})
		return &Envelope{Type: TypeSend, Payload: payload}

	case TypeSignal:
		var v2 V2Signal
		if err := json.Unmarshal(raw, &v2); err != nil {
			c.SendV2Error("invalid_payload", "failed to parse signal")
			return nil
		}
		payload, _ := json.Marshal(&Signal{
			To:      v2.To,
			Payload: json.RawMessage(fmt.Sprintf("%q", v2.Payload)),
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

// handleAuthV2 processes v2 auth_response during authentication.
func (c *Client) handleAuthV2(msgType string, raw []byte) {
	if msgType != TypeAuthResponse {
		c.SendV2Error("auth_required", "expected auth_response")
		return
	}

	var resp AuthResponse
	if err := json.Unmarshal(raw, &resp); err != nil {
		c.SendV2Error("invalid_payload", "failed to parse auth_response")
		return
	}

	if c.challenge == nil {
		c.SendV2Error("auth_failed", "no challenge issued")
		c.Close()
		return
	}

	if resp.Nonce != c.challenge.Nonce || resp.Timestamp != c.challenge.Timestamp {
		c.SendV2Error("auth_failed", "challenge mismatch")
		c.Close()
		return
	}

	// V2 uses pulse-v2-auth prefix
	if !auth.VerifyResponseV2(resp.Pubkey, resp.Signature, resp.Nonce, resp.Timestamp) {
		c.SendV2Error("auth_failed", "invalid signature")
		c.Close()
		return
	}

	// Verify PoW solution if challenge was issued
	if c.powChallenge != nil {
		sol := &metrics.PoWSolution{Seed: resp.PoWSeed, Nonce: resp.PoWNonce}
		if !metrics.VerifyPoW(c.powChallenge, sol) {
			c.SendV2Error("pow_failed", "invalid proof-of-work solution")
			c.Close()
			return
		}
		c.powChallenge = nil // consumed
	}

	// Common registration + ban check logic
	if !c.processRegistration(&resp) {
		return
	}

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
		c.SendV2Error("server_full", "server has reached maximum connections")
		c.Close()
		return
	}

	c.hub.Register(c)

	// Build v2 auth_ok with server info
	v2ok := &V2AuthOK{
		Type:   TypeAuthOK,
		Pubkey: c.pubkey,
		CertFP: c.certFP,
	}

	// Include TURN credentials if available
	if c.hub.turnServer != nil {
		creds, err := c.hub.turnServer.GenerateCredentials(c.pubkey)
		if err == nil {
			v2ok.Turn = &TurnCredentials{
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
			v2ok.PendingCount = count
		}
	}

	// Advertise active privacy features so client can match upstream CBR
	ps := c.hub.PrivacySettings()
	if ps.Padding || ps.Chaff {
		v2ok.Privacy = &V2PrivacyInfo{
			Chaff: ps.Chaff,
		}
		if ps.Padding {
			v2ok.Privacy.Padding = ps.PaddingMode
			v2ok.Privacy.RateKbps = ps.PaddingRateKbps
		}
	}

	data, _ := json.Marshal(v2ok)
	c.SendV2Direct(data)
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
	sendErr := func(code, message string) {
		if c.protoVersion == 2 {
			c.SendV2Error(code, message)
		} else {
			c.SendError(code, message)
		}
	}

	exists, err := c.users.UserExists(resp.Pubkey)
	if err != nil {
		sendErr("internal_error", "failed to check user")
		c.Close()
		return false
	}

	if !exists {
		switch c.cfg.Auth.Mode {
		case "open":
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				sendErr("internal_error", "failed to create user")
				c.Close()
				return false
			}

		case "invite":
			if resp.Invite == "" {
				sendErr("invite_required", "invite code required for registration")
				c.Close()
				return false
			}
			if _, err := c.invites.ValidateInvite(resp.Invite); err != nil {
				sendErr("invite_invalid", err.Error())
				c.Close()
				return false
			}
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				sendErr("internal_error", "failed to create user")
				c.Close()
				return false
			}
			if err := c.invites.UseInvite(resp.Invite, resp.Pubkey); err != nil {
				log.Printf("[client] failed to mark invite used: %v", err)
			}

		case "closed":
			sendErr("registration_closed", "server is not accepting new registrations")
			c.Close()
			return false

		default:
			sendErr("internal_error", "unknown auth mode")
			c.Close()
			return false
		}
	}

	user, err := c.users.GetUser(resp.Pubkey)
	if err != nil {
		sendErr("internal_error", "failed to get user")
		c.Close()
		return false
	}
	if user != nil && user.Banned {
		sendErr("banned", "user is banned")
		c.Close()
		return false
	}

	return true
}

// handleAuth processes an auth_response message during the authenticating state (v1).
func (c *Client) handleAuth(env *Envelope) {
	if env.Type != TypeAuthResponse {
		c.SendError("auth_required", "expected auth_response")
		return
	}

	var resp AuthResponse
	if err := json.Unmarshal(env.Payload, &resp); err != nil {
		c.SendError("invalid_payload", "failed to parse auth_response")
		return
	}

	if c.challenge == nil {
		c.SendError("auth_failed", "no challenge issued")
		c.Close()
		return
	}

	if resp.Nonce != c.challenge.Nonce || resp.Timestamp != c.challenge.Timestamp {
		c.SendError("auth_failed", "challenge mismatch")
		c.Close()
		return
	}

	if !auth.VerifyResponse(resp.Pubkey, resp.Signature, resp.Nonce, resp.Timestamp) {
		c.SendError("auth_failed", "invalid signature")
		c.Close()
		return
	}

	if !c.processRegistration(&resp) {
		return
	}

	c.pubkey = resp.Pubkey
	c.state = StateAuthenticated
	c.challenge = nil
	if c.cfg.Privacy.StoreClientIP && c.remoteIP != "" {
		c.users.UpdateLastSeenIP(c.pubkey, c.remoteIP)
	} else {
		c.users.UpdateLastSeen(c.pubkey)
	}

	if c.hub.MaxConnectionsReached() {
		c.SendError("server_full", "server has reached maximum connections")
		c.Close()
		return
	}

	c.hub.Register(c)

	c.SendEnvelope(TypeAuthOK, &AuthOK{Pubkey: c.pubkey})
}
