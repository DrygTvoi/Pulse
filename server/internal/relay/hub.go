package relay

import (
	"encoding/json"
	"log"
	"sync"
	"time"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/store"
)

// Hub manages all connected clients and routes messages between them.
type Hub struct {
	mu          sync.RWMutex
	clients     map[string]*Client // pubkey → client
	cfg         *config.Config
	users       *store.UserStore
	messages    *store.MessageStore
	invites     *store.InviteStore
	keys        *store.KeyStore
	backups     *store.BackupStore
	rateLimiter *RateLimiter

	register   chan *Client
	unregister chan *Client
	stopCh     chan struct{}
}

// NewHub creates a new Hub.
func NewHub(cfg *config.Config, users *store.UserStore, messages *store.MessageStore, invites *store.InviteStore, keys *store.KeyStore, backups *store.BackupStore) *Hub {
	return &Hub{
		clients:     make(map[string]*Client),
		cfg:         cfg,
		users:       users,
		messages:    messages,
		invites:     invites,
		keys:        keys,
		backups:     backups,
		rateLimiter: NewRateLimiter(cfg.Limits.MessagesPerMinute),
		register:    make(chan *Client, 64),
		unregister:  make(chan *Client, 64),
		stopCh:      make(chan struct{}),
	}
}

// Run starts the hub's main event loop.
func (h *Hub) Run() {
	cleanupTicker := time.NewTicker(1 * time.Hour)
	rateLimitCleanup := time.NewTicker(5 * time.Minute)
	defer cleanupTicker.Stop()
	defer rateLimitCleanup.Stop()

	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			// If there's an existing connection for this pubkey, close it
			if existing, ok := h.clients[client.pubkey]; ok {
				existing.Close()
			}
			h.clients[client.pubkey] = client
			h.mu.Unlock()
			log.Printf("[hub] client registered: %s", client.pubkey)

		case client := <-h.unregister:
			h.mu.Lock()
			if existing, ok := h.clients[client.pubkey]; ok && existing == client {
				delete(h.clients, client.pubkey)
			}
			h.mu.Unlock()
			log.Printf("[hub] client unregistered: %s", client.pubkey)

		case <-cleanupTicker.C:
			n, err := h.messages.DeleteExpiredMessages()
			if err != nil {
				log.Printf("[hub] failed to delete expired messages: %v", err)
			} else if n > 0 {
				log.Printf("[hub] deleted %d expired messages", n)
			}

		case <-rateLimitCleanup.C:
			h.rateLimiter.Cleanup()

		case <-h.stopCh:
			return
		}
	}
}

// Stop shuts down the hub.
func (h *Hub) Stop() {
	close(h.stopCh)

	h.mu.Lock()
	defer h.mu.Unlock()
	for _, client := range h.clients {
		client.Close()
	}
}

// Register registers a client after authentication.
func (h *Hub) Register(client *Client) {
	h.register <- client
}

// Unregister removes a client.
func (h *Hub) Unregister(client *Client) {
	h.unregister <- client
}

// ConnectionCount returns the number of active connections.
func (h *Hub) ConnectionCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// MaxConnectionsReached checks if the server has hit the connection limit.
func (h *Hub) MaxConnectionsReached() bool {
	return h.ConnectionCount() >= h.cfg.Limits.MaxConnections
}

// HandleMessage processes an incoming envelope from an authenticated client.
func (h *Hub) HandleMessage(client *Client, env *Envelope) {
	switch env.Type {
	case TypeSend:
		h.handleSend(client, env.Payload)
	case TypeSignal:
		h.handleSignal(client, env.Payload)
	case TypeFetch:
		h.handleFetch(client, env.Payload)
	case TypeAck:
		h.handleAck(client, env.Payload)
	case TypeKeysPut:
		h.handleKeysPut(client, env.Payload)
	case TypeKeysGet:
		h.handleKeysGet(client, env.Payload)
	case TypePing:
		h.handlePing(client)
	case TypeBackupPut:
		h.handleBackupPut(client, env.Payload)
	case TypeBackupGet:
		h.handleBackupGet(client)
	default:
		client.SendError("unknown_type", "unknown message type: "+env.Type)
	}
}

func (h *Hub) handleSend(client *Client, payload json.RawMessage) {
	var msg SendMessage
	if err := json.Unmarshal(payload, &msg); err != nil {
		client.SendError("invalid_payload", "failed to parse send message")
		return
	}

	if msg.To == "" || msg.ID == "" {
		client.SendError("invalid_payload", "missing 'to' or 'id' field")
		return
	}

	if len(msg.Payload) > h.cfg.Storage.MaxMessageBytes {
		client.SendError("payload_too_large", "message exceeds maximum size")
		return
	}

	if !h.rateLimiter.Allow(client.pubkey) {
		client.SendError("rate_limited", "message rate limit exceeded")
		return
	}

	// Calculate expiry
	var expires int64
	if msg.TTL > 0 {
		expires = time.Now().Unix() + msg.TTL
	} else if h.cfg.Storage.MessageTTLHours > 0 {
		expires = time.Now().Unix() + int64(h.cfg.Storage.MessageTTLHours)*3600
	}

	// Try to deliver to online recipient
	h.mu.RLock()
	recipient, online := h.clients[msg.To]
	h.mu.RUnlock()

	if online {
		incoming := &IncomingMessage{
			ID:      msg.ID,
			From:    client.pubkey,
			Payload: msg.Payload,
			Created: time.Now().Unix(),
		}
		if err := recipient.SendEnvelope(TypeMessage, incoming); err != nil {
			log.Printf("[hub] failed to deliver to online user %s: %v", msg.To, err)
			// Fall through to store for offline delivery
		} else {
			// Delivered online — optionally store or just confirm
			if !h.cfg.Privacy.DeleteOnAck {
				h.storeOfflineMessage(client, msg, expires)
			}
			client.SendEnvelope(TypeStored, &Stored{ID: msg.ID})
			return
		}
	}

	// Store for offline delivery
	h.storeOfflineMessage(client, msg, expires)
	client.SendEnvelope(TypeStored, &Stored{ID: msg.ID})
}

func (h *Hub) storeOfflineMessage(client *Client, msg SendMessage, expires int64) {
	storeMsg := &store.Message{
		ID:      msg.ID,
		FromKey: client.pubkey,
		ToKey:   msg.To,
		Payload: msg.Payload,
		Created: time.Now().Unix(),
		Expires: expires,
	}
	if err := h.messages.StoreMessage(storeMsg); err != nil {
		log.Printf("[hub] failed to store message %s: %v", msg.ID, err)
		client.SendError("store_failed", "failed to store message")
	}
}

func (h *Hub) handleSignal(client *Client, payload json.RawMessage) {
	var sig Signal
	if err := json.Unmarshal(payload, &sig); err != nil {
		client.SendError("invalid_payload", "failed to parse signal")
		return
	}

	if sig.To == "" {
		client.SendError("invalid_payload", "missing 'to' field")
		return
	}

	if !h.rateLimiter.Allow(client.pubkey) {
		client.SendError("rate_limited", "signal rate limit exceeded")
		return
	}

	h.mu.RLock()
	recipient, online := h.clients[sig.To]
	h.mu.RUnlock()

	if !online {
		client.SendError("user_offline", "recipient is not online")
		return
	}

	incoming := &IncomingSignal{
		From:    client.pubkey,
		Payload: sig.Payload,
	}
	if err := recipient.SendEnvelope(TypeInSignal, incoming); err != nil {
		client.SendError("delivery_failed", "failed to deliver signal")
	}
}

func (h *Hub) handleFetch(client *Client, payload json.RawMessage) {
	var f Fetch
	if err := json.Unmarshal(payload, &f); err != nil {
		client.SendError("invalid_payload", "failed to parse fetch request")
		return
	}

	if f.Limit <= 0 || f.Limit > 100 {
		f.Limit = 100
	}

	messages, err := h.messages.GetMessagesForUser(client.pubkey, f.Since, f.Limit)
	if err != nil {
		log.Printf("[hub] failed to fetch messages for %s: %v", client.pubkey, err)
		client.SendError("fetch_failed", "failed to fetch messages")
		return
	}

	for _, m := range messages {
		incoming := &IncomingMessage{
			ID:      m.ID,
			From:    m.FromKey,
			Payload: m.Payload,
			Created: m.Created,
		}
		if err := client.SendEnvelope(TypeMessage, incoming); err != nil {
			log.Printf("[hub] failed to send stored message to %s: %v", client.pubkey, err)
			return
		}
	}
}

func (h *Hub) handleAck(client *Client, payload json.RawMessage) {
	var ack Ack
	if err := json.Unmarshal(payload, &ack); err != nil {
		client.SendError("invalid_payload", "failed to parse ack")
		return
	}

	if h.cfg.Privacy.DeleteOnAck {
		if err := h.messages.DeleteMessage(ack.ID); err != nil {
			log.Printf("[hub] failed to delete message %s: %v", ack.ID, err)
		}
	} else {
		if err := h.messages.MarkDelivered(ack.ID); err != nil {
			log.Printf("[hub] failed to mark message %s delivered: %v", ack.ID, err)
		}
	}

	client.SendEnvelope(TypeAckResp, &AckResponse{ID: ack.ID})
}

func (h *Hub) handleKeysPut(client *Client, payload json.RawMessage) {
	var kp KeysPut
	if err := json.Unmarshal(payload, &kp); err != nil {
		client.SendError("invalid_payload", "failed to parse keys_put")
		return
	}

	if err := h.keys.PutBundle(client.pubkey, kp.Bundle); err != nil {
		log.Printf("[hub] failed to store key bundle for %s: %v", client.pubkey, err)
		client.SendError("store_failed", "failed to store key bundle")
		return
	}

	client.SendEnvelope(TypeAckResp, &AckResponse{ID: "keys"})
}

func (h *Hub) handleKeysGet(client *Client, payload json.RawMessage) {
	var kg KeysGet
	if err := json.Unmarshal(payload, &kg); err != nil {
		client.SendError("invalid_payload", "failed to parse keys_get")
		return
	}

	kb, err := h.keys.GetBundle(kg.Pubkey)
	if err != nil {
		log.Printf("[hub] failed to get key bundle for %s: %v", kg.Pubkey, err)
		client.SendError("fetch_failed", "failed to get key bundle")
		return
	}
	if kb == nil {
		client.SendError("not_found", "key bundle not found for "+kg.Pubkey)
		return
	}

	client.SendEnvelope(TypeKeys, &KeysResponse{
		Pubkey: kb.Pubkey,
		Bundle: kb.Bundle,
	})
}

func (h *Hub) handlePing(client *Client) {
	client.SendEnvelope(TypePong, &PongResponse{})
}

func (h *Hub) handleBackupPut(client *Client, payload json.RawMessage) {
	var bp BackupPut
	if err := json.Unmarshal(payload, &bp); err != nil {
		client.SendError("invalid_payload", "failed to parse backup_put")
		return
	}

	if len(bp.Data) > h.cfg.Storage.MaxBackupBytes {
		client.SendError("payload_too_large", "backup exceeds maximum size")
		return
	}

	if err := h.backups.PutBackup(client.pubkey, bp.Data, bp.Checksum); err != nil {
		log.Printf("[hub] failed to store backup for %s: %v", client.pubkey, err)
		client.SendError("store_failed", "failed to store backup")
		return
	}

	client.SendEnvelope(TypeAckResp, &AckResponse{ID: "backup"})
}

// DeliverToLocal delivers a message to a locally connected user.
// Returns true if the user is online and delivery succeeded.
// This method is used by the federation router.
func (h *Hub) DeliverToLocal(to string, msgType string, payload json.RawMessage) bool {
	h.mu.RLock()
	client, online := h.clients[to]
	h.mu.RUnlock()

	if !online {
		return false
	}

	env := &Envelope{
		Type:    msgType,
		Payload: payload,
	}
	data, err := json.Marshal(env)
	if err != nil {
		log.Printf("[hub] failed to marshal federated envelope for %s: %v", to, err)
		return false
	}

	select {
	case client.send <- data:
		return true
	case <-client.done:
		return false
	default:
		return false
	}
}

func (h *Hub) handleBackupGet(client *Client) {
	b, err := h.backups.GetBackup(client.pubkey)
	if err != nil {
		log.Printf("[hub] failed to get backup for %s: %v", client.pubkey, err)
		client.SendError("fetch_failed", "failed to get backup")
		return
	}
	if b == nil {
		client.SendError("not_found", "no backup found")
		return
	}

	client.SendEnvelope(TypeBackup, &BackupResponse{
		Data:     b.Data,
		Checksum: b.Checksum,
	})
}
