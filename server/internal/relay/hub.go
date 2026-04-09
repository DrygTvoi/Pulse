package relay

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os"
	"sync"
	"time"

	"github.com/pion/webrtc/v4"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/metrics"
	"github.com/nicholasgasior/pulse-server/internal/privacy"
	"github.com/nicholasgasior/pulse-server/internal/sfu"
	"github.com/nicholasgasior/pulse-server/internal/store"
	"github.com/nicholasgasior/pulse-server/internal/tunnel"
	"github.com/nicholasgasior/pulse-server/internal/turn"
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
	fileStore   *store.FileStore
	turnServer  *turn.Server
	turnWSLn    *turnWSListener // virtual listener for TURN-over-WebSocket
	sfuManager  *sfu.Manager
	tunnelMgr   *tunnel.Manager
	paddingSvc  *privacy.PaddingService
	sealedSvc    *privacy.SealedSenderService
	batchBuf     *privacy.BatchDeliveryBuffer
	metricsCol   *metrics.Collector
	privSettings privacy.EffectiveSettings
	rateLimiter  *RateLimiter

	register   chan *Client
	unregister chan *Client
	stopCh     chan struct{}
}

// NewHub creates a new Hub.
func NewHub(cfg *config.Config, users *store.UserStore, messages *store.MessageStore, invites *store.InviteStore, keys *store.KeyStore, backups *store.BackupStore) *Hub {
	// Resolve effective privacy settings
	ps := privacy.ResolveSettings(
		cfg.Privacy.Preset,
		cfg.Privacy.Padding, cfg.Privacy.PaddingMode, cfg.Privacy.PaddingRateKbps,
		cfg.Privacy.SealedSender, cfg.Privacy.DeliveryJitterMs,
		cfg.Privacy.BatchDelivery, cfg.Privacy.BatchIntervalMs,
		cfg.Privacy.Chaff, cfg.Privacy.ChaffIntervalSec,
	)

	h := &Hub{
		clients:      make(map[string]*Client),
		cfg:          cfg,
		users:        users,
		messages:     messages,
		invites:      invites,
		keys:         keys,
		backups:      backups,
		metricsCol:   metrics.NewCollector(),
		privSettings: ps,
		rateLimiter:  NewRateLimiter(cfg.Limits.MessagesPerMinute),
		register:     make(chan *Client, 64),
		unregister:   make(chan *Client, 64),
		stopCh:       make(chan struct{}),
	}

	// Initialize batch delivery if enabled
	if ps.BatchDelivery && ps.BatchIntervalMs > 0 {
		h.batchBuf = privacy.NewBatchDeliveryBuffer(ps.BatchIntervalMs, func(pubkey string, msgs []privacy.PendingDelivery) {
			h.mu.RLock()
			client, ok := h.clients[pubkey]
			h.mu.RUnlock()
			if ok {
				for _, msg := range msgs {
					client.SendDirect(msg.Data)
				}
			}
		})
		h.batchBuf.Start()
	}

	return h
}

// SetFileStore sets the file store for chunked transfers.
func (h *Hub) SetFileStore(fs *store.FileStore) {
	h.fileStore = fs
}

// SetTurnServer sets the TURN server reference for auth.
func (h *Hub) SetTurnServer(ts *turn.Server) {
	h.turnServer = ts
}

// TurnWSListener returns the virtual net.Listener for TURN-over-WebSocket.
// Pass this to pion/turn as an additional ListenerConfig alongside the
// TLS mux listener (or as a replacement if you want WS-only TURN).
func (h *Hub) TurnWSListener() net.Listener {
	if h.turnWSLn == nil {
		h.turnWSLn = newTurnWSListener(&net.TCPAddr{IP: net.IPv4zero, Port: 443})
	}
	return h.turnWSLn
}

// SetSFUManager sets the SFU manager for media rooms.
func (h *Hub) SetSFUManager(mgr *sfu.Manager) {
	h.sfuManager = mgr
}

// SetTunnelManager sets the tunnel manager.
func (h *Hub) SetTunnelManager(mgr *tunnel.Manager) {
	h.tunnelMgr = mgr
}

// SetPaddingService sets the padding service.
func (h *Hub) SetPaddingService(ps *privacy.PaddingService) {
	h.paddingSvc = ps
}

// SetSealedSenderService sets the sealed sender service.
func (h *Hub) SetSealedSenderService(ss *privacy.SealedSenderService) {
	h.sealedSvc = ss
}

// Metrics returns the metrics collector.
func (h *Hub) Metrics() *metrics.Collector {
	return h.metricsCol
}

// PrivacySettings returns the effective privacy settings for auth_ok.
func (h *Hub) PrivacySettings() privacy.EffectiveSettings {
	return h.privSettings
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
				if h.metricsCol != nil {
					h.metricsCol.DecConnections()
				}
			}
			h.clients[client.pubkey] = client
			h.mu.Unlock()

			if h.metricsCol != nil {
				h.metricsCol.IncConnections()
			}

			// Register for padding/chaff if enabled
			if h.paddingSvc != nil {
				h.paddingSvc.RegisterClient(client.pubkey,
					func(data []byte) error { return client.SendBinaryDirect(data) },
					func(data []byte) error { return client.SendDirect(data) },
				)
			}

			log.Printf("[hub] client registered: %s", client.pubkey)

		case client := <-h.unregister:
			h.mu.Lock()
			if existing, ok := h.clients[client.pubkey]; ok && existing == client {
				delete(h.clients, client.pubkey)
			}
			h.mu.Unlock()

			if h.metricsCol != nil {
				h.metricsCol.DecConnections()
			}

			// Unregister from padding
			if h.paddingSvc != nil {
				h.paddingSvc.UnregisterClient(client.pubkey)
			}

			// Remove from all SFU rooms
			if h.sfuManager != nil {
				h.sfuManager.RemoveParticipantFromAll(client.pubkey)
			}

			// Close all tunnels
			if h.tunnelMgr != nil {
				h.tunnelMgr.CloseAllForUser(client.pubkey)
			}

			log.Printf("[hub] client unregistered: %s", client.pubkey)

		case <-cleanupTicker.C:
			n, err := h.messages.DeleteExpiredMessages()
			if err != nil {
				log.Printf("[hub] failed to delete expired messages: %v", err)
			} else if n > 0 {
				log.Printf("[hub] deleted %d expired messages", n)
			}
			if h.fileStore != nil {
				fn, ferr := h.fileStore.DeleteExpiredFiles()
				if ferr != nil {
					log.Printf("[hub] failed to delete expired files: %v", ferr)
				} else if fn > 0 {
					log.Printf("[hub] deleted %d expired files", fn)
				}
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

	if h.batchBuf != nil {
		h.batchBuf.Stop()
	}

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
	case TypeUploadStart:
		h.handleUploadStart(client, env.Payload)
	case TypeUploadResume:
		h.handleUploadResume(client, env.Payload)
	case TypeDownloadReq:
		h.handleDownloadReq(client, env.Payload)

	// SFU (Phase 2+3)
	case TypeRoomCreate:
		h.handleRoomCreate(client, env.Payload)
	case TypeRoomJoin:
		h.handleRoomJoin(client, env.Payload)
	case TypeRoomLeave:
		h.handleRoomLeave(client, env.Payload)
	case TypeMediaOffer:
		h.handleMediaOffer(client, env.Payload)
	case TypeMediaCandidate:
		h.handleMediaCandidate(client, env.Payload)
	case TypeTrackPublish:
		h.handleTrackPublish(client, env.Payload)
	case TypeTrackSubscribe:
		h.handleTrackSubscribe(client, env.Payload)
	case TypeTrackPause, TypeTrackResume:
		h.handleTrackPauseResume(client, env.Type, env.Payload)
	case TypeQualityPrefer:
		h.handleQualityPrefer(client, env.Payload)

	// Tunnel (Phase 5)
	case TypeTunnelOpen:
		h.handleTunnelOpen(client, env.Payload)
	case TypeTunnelClose:
		h.handleTunnelClose(client, env.Payload)

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

	// Apply bucket padding to normalize message size (Phase 6)
	if h.privSettings.Padding {
		targetSize := privacy.NormalizeBucketSize(len(msg.Payload))
		if targetSize > len(msg.Payload) {
			padded := make([]byte, targetSize)
			copy(padded, msg.Payload)
			// Fill remainder with spaces (valid JSON padding)
			for i := len(msg.Payload); i < targetSize; i++ {
				padded[i] = ' '
			}
			msg.Payload = json.RawMessage(padded)
		}
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

	if h.metricsCol != nil {
		h.metricsCol.IncMessagesSent()
	}

	// Apply delivery jitter if configured
	jitter := privacy.ApplyJitter(h.privSettings.DeliveryJitterMs)

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

		deliverFn := func() {
			// Use batch delivery if enabled
			if h.batchBuf != nil {
				data, _ := json.Marshal(map[string]interface{}{
					"type": TypeMessage, "id": incoming.ID,
					"from": incoming.From, "body": incoming.Payload,
					"ts": incoming.Created,
				})
				h.batchBuf.Enqueue(msg.To, data)
			} else if err := recipient.SendEnvelope(TypeMessage, incoming); err != nil {
				log.Printf("[hub] failed to deliver to online user %s: %v", msg.To, err)
				h.storeOfflineMessage(client, msg, expires)
			}
			if !h.cfg.Privacy.DeleteOnAck {
				h.storeOfflineMessage(client, msg, expires)
			}
			client.SendEnvelope(TypeStored, &Stored{ID: msg.ID})
		}

		if jitter > 0 {
			go func() {
				time.Sleep(jitter)
				deliverFn()
			}()
		} else {
			deliverFn()
		}
		return
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
	if h.metricsCol != nil {
		h.metricsCol.IncMessagesStored()
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
		client.sendFlat(TypeSignalFail, map[string]string{
			"to":     sig.To,
			"reason": "offline",
		})
		return
	}

	incoming := &IncomingSignal{
		From:    client.pubkey,
		Payload: sig.Payload,
	}
	if err := recipient.SendEnvelope(TypeInSignal, incoming); err != nil {
		client.SendError("delivery_failed", "failed to deliver signal")
	}

	if h.metricsCol != nil {
		h.metricsCol.IncSignals()
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

// --- File transfer handlers ---

func (h *Hub) handleUploadStart(client *Client, payload json.RawMessage) {
	if h.fileStore == nil {
		client.SendError("not_supported", "file transfer not enabled")
		return
	}

	var req UploadStart
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse upload_start")
		return
	}

	if req.TotalSize <= 0 || req.ChunkCount <= 0 || req.ChunkSize <= 0 || req.TransferID == "" || req.SHA256 == "" {
		client.SendError("invalid_payload", "missing required fields")
		return
	}

	if req.TotalSize > h.cfg.Storage.MaxFileBytes {
		client.SendError("file_too_large", fmt.Sprintf("file exceeds %d byte limit", h.cfg.Storage.MaxFileBytes))
		return
	}

	used, err := h.fileStore.GetUserStorageUsed(client.pubkey)
	if err != nil {
		log.Printf("[hub] failed to get storage for %s: %v", client.pubkey, err)
		client.SendError("internal_error", "failed to check quota")
		return
	}
	if used+req.TotalSize > h.cfg.Storage.MaxStoragePerUser {
		client.SendError("quota_exceeded", "storage quota exceeded")
		return
	}

	var expires int64
	if h.cfg.Storage.FileTTL != "" {
		if d, derr := time.ParseDuration(h.cfg.Storage.FileTTL); derr == nil {
			expires = time.Now().Unix() + int64(d.Seconds())
		}
	}

	transfer := &store.FileTransfer{
		TransferID: req.TransferID,
		Uploader:   client.pubkey,
		SHA256:     req.SHA256,
		TotalSize:  req.TotalSize,
		ChunkCount: req.ChunkCount,
		ChunkSize:  req.ChunkSize,
		Created:    time.Now().Unix(),
		Expires:    expires,
	}
	if err := h.fileStore.CreateTransfer(transfer); err != nil {
		log.Printf("[hub] failed to create transfer %s: %v", req.TransferID, err)
		client.SendError("internal_error", "failed to create transfer")
		return
	}

	client.SendEnvelope(TypeUploadAck, &UploadAckResp{
		Type:       TypeUploadAck,
		TransferID: req.TransferID,
		NextChunk:  0,
	})
}

func (h *Hub) handleUploadResume(client *Client, payload json.RawMessage) {
	if h.fileStore == nil {
		client.SendError("not_supported", "file transfer not enabled")
		return
	}

	var req DownloadReq
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse upload_resume")
		return
	}

	transfer, err := h.fileStore.GetTransfer(req.TransferID)
	if err != nil || transfer == nil {
		client.SendError("not_found", "transfer not found")
		return
	}
	if transfer.Uploader != client.pubkey {
		client.SendError("forbidden", "not your transfer")
		return
	}
	if transfer.Completed {
		client.SendError("already_complete", "transfer already completed")
		return
	}

	count, err := h.fileStore.CountChunks(req.TransferID)
	if err != nil {
		client.SendError("internal_error", "failed to count chunks")
		return
	}

	client.SendEnvelope(TypeUploadAck, &UploadAckResp{
		Type:       TypeUploadAck,
		TransferID: req.TransferID,
		NextChunk:  count,
	})
}

// HandleUploadChunk processes an incoming binary chunk from a client.
func (h *Hub) HandleUploadChunk(client *Client, transferID string, chunkIdx, totalChunks int, data []byte) {
	if h.fileStore == nil {
		client.SendError("not_supported", "file transfer not enabled")
		return
	}

	transfer, err := h.fileStore.GetTransfer(transferID)
	if err != nil || transfer == nil {
		client.SendError("not_found", "transfer not found: "+transferID)
		return
	}
	if transfer.Uploader != client.pubkey {
		client.SendError("forbidden", "not your transfer")
		return
	}
	if transfer.Completed {
		client.SendError("already_complete", "transfer already completed")
		return
	}

	if err := h.fileStore.WriteChunk(transferID, chunkIdx, data); err != nil {
		log.Printf("[hub] failed to write chunk %d for %s: %v", chunkIdx, transferID, err)
		client.SendError("internal_error", "failed to write chunk")
		return
	}

	if h.metricsCol != nil {
		h.metricsCol.AddUploadBytes(int64(len(data)))
	}

	count, err := h.fileStore.CountChunks(transferID)
	if err != nil {
		return
	}

	if count >= transfer.ChunkCount {
		if err := h.fileStore.CompleteTransfer(transferID, transfer.SHA256, transfer.ChunkCount); err != nil {
			log.Printf("[hub] transfer completion failed for %s: %v", transferID, err)
			client.SendError("upload_failed", err.Error())
			return
		}
		client.SendEnvelope(TypeUploadComplete, &UploadCompleteResp{
			Type:       TypeUploadComplete,
			TransferID: transferID,
			FileID:     transferID,
			Size:       transfer.TotalSize,
		})
	}
}

func (h *Hub) handleDownloadReq(client *Client, payload json.RawMessage) {
	if h.fileStore == nil {
		client.SendError("not_supported", "file transfer not enabled")
		return
	}

	var req DownloadReq
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse download_req")
		return
	}

	transfer, err := h.fileStore.GetTransfer(req.TransferID)
	if err != nil || transfer == nil {
		client.SendError("not_found", "file not found")
		return
	}
	if !transfer.Completed {
		client.SendError("not_ready", "upload not yet completed")
		return
	}

	blobPath := h.fileStore.GetBlobPath(req.TransferID)
	data, err := os.ReadFile(blobPath)
	if err != nil {
		log.Printf("[hub] failed to read blob %s: %v", req.TransferID, err)
		client.SendError("internal_error", "failed to read file")
		return
	}

	tidBytes, _ := hex.DecodeString(req.TransferID)
	if len(tidBytes) < 16 {
		padded := make([]byte, 16)
		copy(padded, tidBytes)
		tidBytes = padded
	}

	chunkSize := transfer.ChunkSize
	if chunkSize <= 0 {
		chunkSize = 65536
	}
	totalChunks := (len(data) + chunkSize - 1) / chunkSize

	for i := 0; i < totalChunks; i++ {
		start := i * chunkSize
		end := start + chunkSize
		if end > len(data) {
			end = len(data)
		}
		if err := client.SendBinaryChunk(tidBytes, uint32(i), uint32(totalChunks), data[start:end]); err != nil {
			log.Printf("[hub] failed to send chunk %d/%d to %s: %v", i, totalChunks, client.pubkey, err)
			return
		}
		if h.metricsCol != nil {
			h.metricsCol.AddDownloadBytes(int64(end - start))
		}
	}
}

// --- SFU handlers (Phase 2+3) ---

func (h *Hub) handleRoomCreate(client *Client, payload json.RawMessage) {
	if h.sfuManager == nil || !h.cfg.Media.Enabled {
		client.SendError("not_supported", "media relay not enabled")
		return
	}

	var req RoomCreate
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse room_create")
		return
	}

	if h.sfuManager.RoomCount() >= h.cfg.Limits.MaxRooms {
		client.SendError("rate_limited", "max rooms reached")
		return
	}

	room, err := h.sfuManager.CreateRoom(client.pubkey, req.Max, req.Name, req.E2EE)
	if err != nil {
		client.SendError("internal_error", err.Error())
		return
	}

	if h.metricsCol != nil {
		h.metricsCol.IncRooms()
	}

	client.SendEnvelope(TypeRoomCreated, &RoomCreated{
		Type:   TypeRoomCreated,
		RoomID: room.ID,
		Token:  room.Token,
	})
}

func (h *Hub) handleRoomJoin(client *Client, payload json.RawMessage) {
	if h.sfuManager == nil {
		client.SendError("not_supported", "media relay not enabled")
		return
	}

	var req RoomJoin
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse room_join")
		return
	}

	sendMsg := func(data []byte) error { return client.SendDirect(data) }
	sendBin := func(data []byte) error { return client.SendBinaryDirect(data) }

	room, _, err := h.sfuManager.JoinRoom(req.RoomID, req.Token, client.pubkey, sendMsg, sendBin)
	if err != nil {
		client.SendError("join_failed", err.Error())
		return
	}

	// Send room_info with current participants
	participants := room.GetParticipantInfo()
	pInfos := make([]RoomParticipantInfo, len(participants))
	for i, p := range participants {
		tracks := make([]TrackShortInfo, len(p.Tracks))
		for j, t := range p.Tracks {
			tracks[j] = TrackShortInfo{ID: t.ID, Kind: t.Kind}
		}
		pInfos[i] = RoomParticipantInfo{Pubkey: p.Pubkey, Tracks: tracks}
	}

	client.SendEnvelope(TypeRoomInfo, &RoomInfo{
		Type:         TypeRoomInfo,
		RoomID:       req.RoomID,
		Participants: pInfos,
	})
}

func (h *Hub) handleRoomLeave(client *Client, payload json.RawMessage) {
	if h.sfuManager == nil {
		return
	}

	var req RoomLeave
	if err := json.Unmarshal(payload, &req); err != nil {
		return
	}

	h.sfuManager.LeaveRoom(req.RoomID, client.pubkey)
	client.SendEnvelope(TypeRoomLeft, &RoomLeft{
		Type:   TypeRoomLeft,
		RoomID: req.RoomID,
	})
}

func (h *Hub) handleMediaOffer(client *Client, payload json.RawMessage) {
	if h.sfuManager == nil {
		client.SendError("not_supported", "media relay not enabled")
		return
	}

	var req MediaOffer
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse media_offer")
		return
	}

	answerSDP, err := h.sfuManager.HandleMediaOffer(req.RoomID, client.pubkey, req.SDP)
	if err != nil {
		client.SendError("media_error", err.Error())
		return
	}

	client.SendEnvelope(TypeMediaAnswer, &MediaAnswer{
		Type:   TypeMediaAnswer,
		RoomID: req.RoomID,
		SDP:    answerSDP,
	})
}

func (h *Hub) handleMediaCandidate(client *Client, payload json.RawMessage) {
	if h.sfuManager == nil {
		return
	}

	var req MediaCandidate
	if err := json.Unmarshal(payload, &req); err != nil {
		return
	}

	candidate := webrtc.ICECandidateInit{
		Candidate: req.Candidate,
	}
	if req.SDPMid != "" {
		candidate.SDPMid = &req.SDPMid
	}
	idx := uint16(req.SDPMLineIndex)
	candidate.SDPMLineIndex = &idx

	h.sfuManager.HandleICECandidate(req.RoomID, client.pubkey, candidate)
}

func (h *Hub) handleTrackPublish(client *Client, payload json.RawMessage) {
	// Track publication happens automatically via onTrack callback
	// when the client starts sending media after SDP negotiation.
	// This message serves as an intent notification.
	client.SendEnvelope(TypeAckResp, &AckResponse{ID: "track_publish"})
}

func (h *Hub) handleTrackSubscribe(client *Client, payload json.RawMessage) {
	if h.sfuManager == nil {
		return
	}

	var req TrackSubscribe
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse track_subscribe")
		return
	}

	room := h.sfuManager.GetRoom(req.RoomID)
	if room == nil {
		client.SendError("not_found", "room not found")
		return
	}

	if err := room.SubscribeTrackWithLayer(client.pubkey, req.TrackID, req.Layer); err != nil {
		client.SendError("subscribe_failed", err.Error())
		return
	}

	client.SendEnvelope(TypeTrackSubscribed, &TrackSubscribed{
		Type:    TypeTrackSubscribed,
		RoomID:  req.RoomID,
		TrackID: req.TrackID,
	})
}

func (h *Hub) handleTrackPauseResume(client *Client, msgType string, payload json.RawMessage) {
	if h.sfuManager == nil {
		return
	}

	var req TrackPause
	if err := json.Unmarshal(payload, &req); err != nil {
		return
	}

	room := h.sfuManager.GetRoom(req.RoomID)
	if room == nil {
		return
	}

	if msgType == TypeTrackPause {
		room.UnsubscribeTrack(client.pubkey, req.TrackID)
	} else {
		room.SubscribeTrack(client.pubkey, req.TrackID)
	}
}

func (h *Hub) handleQualityPrefer(client *Client, payload json.RawMessage) {
	if h.sfuManager == nil {
		client.SendEnvelope(TypeAckResp, &AckResponse{ID: "quality"})
		return
	}

	var req QualityPrefer
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse quality_prefer")
		return
	}

	room := h.sfuManager.GetRoom(req.RoomID)
	if room == nil {
		client.SendError("not_found", "room not found")
		return
	}

	if req.Layer != "" {
		if err := room.SwitchLayer(client.pubkey, req.TrackID, req.Layer); err != nil {
			client.SendError("switch_failed", err.Error())
			return
		}
	}

	client.SendEnvelope(TypeAckResp, &AckResponse{ID: "quality"})
}

// --- Tunnel handlers (Phase 5) ---

func (h *Hub) handleTunnelOpen(client *Client, payload json.RawMessage) {
	if h.tunnelMgr == nil || !h.cfg.Tunnel.Enabled {
		client.SendError("not_supported", "tunnel not enabled")
		return
	}

	var req TunnelOpen
	if err := json.Unmarshal(payload, &req); err != nil {
		client.SendError("invalid_payload", "failed to parse tunnel_open")
		return
	}

	sendBin := func(data []byte) error {
		return client.SendBinaryDirect(data)
	}

	remoteIP, err := h.tunnelMgr.OpenTunnel(client.pubkey, req.TunnelID, req.Host, req.Port, sendBin)
	if err != nil {
		client.SendEnvelope(TypeTunnelError, &TunnelError{
			Type:     TypeTunnelError,
			TunnelID: req.TunnelID,
			Reason:   err.Error(),
		})
		return
	}

	if h.metricsCol != nil {
		h.metricsCol.IncTunnels()
	}

	client.SendEnvelope(TypeTunnelOpened, &TunnelOpened{
		Type:     TypeTunnelOpened,
		TunnelID: req.TunnelID,
		RemoteIP: remoteIP,
	})
}

func (h *Hub) handleTunnelClose(client *Client, payload json.RawMessage) {
	if h.tunnelMgr == nil {
		return
	}

	var req TunnelClose
	if err := json.Unmarshal(payload, &req); err != nil {
		return
	}

	h.tunnelMgr.CloseTunnel(client.pubkey, req.TunnelID)
	if h.metricsCol != nil {
		h.metricsCol.DecTunnels()
	}
}

// HandleTunnelData handles binary tunnel data from client (0x20 frames).
func (h *Hub) HandleTunnelData(client *Client, data []byte) {
	if h.tunnelMgr == nil {
		return
	}
	h.tunnelMgr.HandleTunnelData(client.pubkey, data)
}

// HandleWSRelayMedia handles binary ws-relay media frames (0x10-0x15).
func (h *Hub) HandleWSRelayMedia(client *Client, data []byte) {
	if h.sfuManager == nil {
		return
	}
	h.sfuManager.HandleWSRelayFrame(client.pubkey, data)
}

// HandleSealedSend processes a sealed sender message.
func (h *Hub) HandleSealedSend(cert, to, body string) bool {
	if h.sealedSvc == nil || !h.privSettings.SealedSender {
		return false
	}

	if !h.sealedSvc.VerifyCert(cert) {
		return false
	}

	// Deliver to recipient (we don't know the sender — that's the point)
	h.mu.RLock()
	recipient, online := h.clients[to]
	h.mu.RUnlock()

	if online {
		msg := map[string]interface{}{
			"type": "message",
			"id":   fmt.Sprintf("sealed_%d", time.Now().UnixNano()),
			"from": "sealed",
			"body": body,
			"ts":   time.Now().Unix(),
		}
		data, _ := json.Marshal(msg)
		recipient.SendDirect(data)
		return true
	}

	// Store for offline delivery (no sender info)
	storeMsg := &store.Message{
		ID:      fmt.Sprintf("sealed_%d", time.Now().UnixNano()),
		FromKey: "sealed",
		ToKey:   to,
		Payload: json.RawMessage(fmt.Sprintf(`"%s"`, body)),
		Created: time.Now().Unix(),
		Expires: time.Now().Unix() + int64(h.cfg.Storage.MessageTTLHours)*3600,
	}
	h.messages.StoreMessage(storeMsg)
	return true
}

// GetSealedCerts returns delivery certificates for a user (called during auth_ok).
func (h *Hub) GetSealedCerts() []privacy.DeliveryCert {
	if h.sealedSvc == nil || !h.privSettings.SealedSender {
		return nil
	}
	return h.sealedSvc.IssueCerts()
}
