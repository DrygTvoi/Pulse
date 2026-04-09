package relay

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
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
	pongWait       = 150 * time.Second
	maxMessageSize = 1 << 20 // 1 MB

	// Ping jitter range: wide range to avoid DPI fingerprinting.
	// 15-120s matches real browser WebSocket keepalive variance.
	pingIntervalMin = 15 * time.Second
	pingIntervalMax = 120 * time.Second
)

// randomPingInterval returns a random duration in [pingIntervalMin, pingIntervalMax).
func randomPingInterval() time.Duration {
	spread := pingIntervalMax - pingIntervalMin
	return pingIntervalMin + time.Duration(rand.Int63n(int64(spread)))
}

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
	turnConn     *turnWSConn // virtual conn for TURN-over-WebSocket (nil until first 0x30 frame)

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

// Start begins the client's read and write pumps.
// Does NOT send auth challenge immediately — waits for client hello first
// (probe resistance: silent until client proves it knows the protocol).
func (c *Client) Start() {
	go c.writePump()
	go c.readPump()

	// Auth deadline: close if client doesn't authenticate within 30s.
	// Real MQTT brokers / nginx proxies do the same for idle connections.
	go func() {
		timer := time.NewTimer(30 * time.Second)
		defer timer.Stop()
		select {
		case <-timer.C:
			if c.state != StateAuthenticated {
				c.Close()
			}
		case <-c.done:
		}
	}()
}

// sendAuthChallenge generates and sends the auth challenge.
// Called only after receiving a valid "hello" from the client.
func (c *Client) sendAuthChallenge() {
	challenge, err := auth.GenerateChallenge()
	if err != nil {
		log.Printf("[client] failed to generate challenge: %v", err)
		c.Close()
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
		c.Close()
		return
	}
	select {
	case c.send <- data:
	default:
		log.Printf("[client] send buffer full on challenge")
		c.Close()
	}
}

// Close cleanly shuts down the client connection.
func (c *Client) Close() {
	c.closeOnce.Do(func() {
		close(c.done)
		if c.turnConn != nil {
			c.turnConn.Close()
		}
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
		// Pre-auth: silence (don't leak server identity to probers).
		// Post-auth: send error so legitimate clients can handle it.
		if c.state == StateAuthenticated {
			c.SendError("invalid_json", "failed to parse message")
		}
		return
	}

	var mt string
	if t, ok := raw["type"]; ok {
		json.Unmarshal(t, &mt)
	}
	if mt == "" {
		if c.state == StateAuthenticated {
			c.SendError("invalid_json", "missing type field")
		}
		return
	}

	switch c.state {
	case StateConnected:
		// Probe resistance: server is silent until client sends "hello".
		// This prevents active probers from getting auth_challenge by just connecting.
		if mt == "hello" {
			c.sendAuthChallenge()
		}
		// Any other message type in Connected state → silence (don't reveal server identity)
	case StateAuthenticating:
		c.handleAuth(mt, message)
	case StateAuthenticated:
		env := c.toEnvelope(mt, message)
		if env != nil {
			c.hub.HandleMessage(c, env)
		}
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
	if msgType != TypeAuthResponse {
		// Silent close — don't reveal expected message type
		c.Close()
		return
	}

	var resp AuthResponse
	if err := json.Unmarshal(raw, &resp); err != nil {
		c.Close()
		return
	}

	if c.challenge == nil || resp.Nonce != c.challenge.Nonce || resp.Timestamp != c.challenge.Timestamp {
		c.Close()
		return
	}

	if !auth.VerifyResponse(resp.Pubkey, resp.Signature, resp.Nonce, resp.Timestamp) {
		c.Close()
		return
	}

	// Verify PoW solution if challenge was issued
	if c.powChallenge != nil {
		sol := &metrics.PoWSolution{Seed: resp.PoWSeed, Nonce: resp.PoWNonce}
		if !metrics.VerifyPoW(c.powChallenge, sol) {
			c.Close()
			return
		}
		c.powChallenge = nil
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
		c.Close()
		return
	}
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

	// Issue sealed sender delivery certificates if enabled
	if pCerts := c.hub.GetSealedCerts(); len(pCerts) > 0 {
		ok.SealedCerts = make([]DeliveryCert, len(pCerts))
		for i, pc := range pCerts {
			ok.SealedCerts[i] = DeliveryCert{Token: pc.Token, Expires: pc.Expires}
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

	case frameType == BinaryTypeTurnData:
		// TURN-over-WebSocket: client sends STUN data through existing WS
		if len(data) < 2 {
			return
		}
		stunPayload := data[1:]
		if c.turnConn == nil {
			// First TURN frame — create virtual connection and register with TURN listener
			c.turnConn = newTurnWSConn(c.sendBinary, c.remoteIP)
			if c.hub.turnWSLn != nil {
				select {
				case c.hub.turnWSLn.ch <- c.turnConn:
					log.Printf("[turn-ws] new TURN-over-WS session for %s", c.pubkey[:16])
				default:
					log.Printf("[turn-ws] listener full, dropping TURN-over-WS for %s", c.pubkey[:16])
					c.turnConn.Close()
					c.turnConn = nil
					return
				}
			}
		}
		c.turnConn.feedData(stunPayload)

	case frameType == BinaryTypePadding:
		// Padding frame (0xFF) — silently discard
		return

	default:
		// Unknown frame type — silently discard (don't leak server info)
		return
	}
}

// writePump writes messages to the WebSocket connection.
func (c *Client) writePump() {
	ticker := time.NewTimer(randomPingInterval())
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
			ticker.Reset(randomPingInterval())

		case <-c.done:
			return
		}
	}
}

// processRegistration checks user existence, handles registration, and checks ban status.
// Returns true if registration succeeded and user is not banned.
// NOTE: All failures close silently — no error messages before auth is complete
// (prevents fingerprinting by probers).
func (c *Client) processRegistration(resp *AuthResponse) bool {
	exists, err := c.users.UserExists(resp.Pubkey)
	if err != nil {
		c.Close()
		return false
	}

	if !exists {
		switch c.cfg.Auth.Mode {
		case "open":
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				c.Close()
				return false
			}

		case "invite":
			if resp.Invite == "" {
				c.Close()
				return false
			}
			if _, err := c.invites.ValidateInvite(resp.Invite); err != nil {
				c.Close()
				return false
			}
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				c.Close()
				return false
			}
			if err := c.invites.UseInvite(resp.Invite, resp.Pubkey); err != nil {
				log.Printf("[client] failed to mark invite used: %v", err)
			}

		case "closed":
			c.Close()
			return false

		default:
			c.Close()
			return false
		}
	}

	user, err := c.users.GetUser(resp.Pubkey)
	if err != nil {
		c.Close()
		return false
	}
	if user != nil && user.Banned {
		c.Close()
		return false
	}

	return true
}
