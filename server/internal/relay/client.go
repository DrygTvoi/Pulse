package relay

import (
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/auth"
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

	send   chan []byte
	closeOnce sync.Once
	done      chan struct{}
}

// NewClient creates a new Client for the given WebSocket connection.
func NewClient(hub *Hub, conn *websocket.Conn, cfg *config.Config, users *store.UserStore, invites *store.InviteStore) *Client {
	return &Client{
		hub:     hub,
		conn:    conn,
		state:   StateConnected,
		cfg:     cfg,
		users:   users,
		invites: invites,
		send:    make(chan []byte, 256),
		done:    make(chan struct{}),
	}
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

	if err := c.SendEnvelope(TypeAuthChallenge, &AuthChallenge{
		Nonce:     challenge.Nonce,
		Timestamp: challenge.Timestamp,
	}); err != nil {
		log.Printf("[client] failed to send challenge: %v", err)
		c.conn.Close()
		return
	}

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
func (c *Client) SendEnvelope(msgType string, payload interface{}) error {
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
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseNormalClosure) {
				log.Printf("[client] read error for %s: %v", c.pubkey, err)
			}
			return
		}

		var env Envelope
		if err := json.Unmarshal(message, &env); err != nil {
			c.SendError("invalid_json", "failed to parse message")
			continue
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

// handleAuth processes an auth_response message during the authenticating state.
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

	// Verify the challenge
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

	// Check if user exists
	exists, err := c.users.UserExists(resp.Pubkey)
	if err != nil {
		c.SendError("internal_error", "failed to check user")
		c.Close()
		return
	}

	if !exists {
		// Handle registration based on auth mode
		switch c.cfg.Auth.Mode {
		case "open":
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				c.SendError("internal_error", "failed to create user")
				c.Close()
				return
			}

		case "invite":
			if resp.Invite == "" {
				c.SendError("invite_required", "invite code required for registration")
				c.Close()
				return
			}
			if _, err := c.invites.ValidateInvite(resp.Invite); err != nil {
				c.SendError("invite_invalid", err.Error())
				c.Close()
				return
			}
			if err := c.users.CreateUser(resp.Pubkey); err != nil {
				c.SendError("internal_error", "failed to create user")
				c.Close()
				return
			}
			if err := c.invites.UseInvite(resp.Invite, resp.Pubkey); err != nil {
				log.Printf("[client] failed to mark invite used: %v", err)
			}

		case "closed":
			c.SendError("registration_closed", "server is not accepting new registrations")
			c.Close()
			return

		default:
			c.SendError("internal_error", "unknown auth mode")
			c.Close()
			return
		}
	}

	// Check if user is banned
	user, err := c.users.GetUser(resp.Pubkey)
	if err != nil {
		c.SendError("internal_error", "failed to get user")
		c.Close()
		return
	}
	if user != nil && user.Banned {
		c.SendError("banned", "user is banned")
		c.Close()
		return
	}

	// Authentication successful
	c.pubkey = resp.Pubkey
	c.state = StateAuthenticated
	c.challenge = nil

	// Update last seen
	c.users.UpdateLastSeen(c.pubkey)

	// Check connection limit
	if c.hub.MaxConnectionsReached() {
		c.SendError("server_full", "server has reached maximum connections")
		c.Close()
		return
	}

	c.hub.Register(c)

	c.SendEnvelope(TypeAuthOK, &AuthOK{Pubkey: c.pubkey})
}
