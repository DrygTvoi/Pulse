package federation

import (
	"database/sql"
	"encoding/json"
	"log"
	"time"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/store"
)

// LocalDeliverer is the interface the hub must satisfy for local message delivery.
type LocalDeliverer interface {
	// DeliverToLocal delivers a message to a locally connected user.
	// Returns true if the user is online and delivery succeeded.
	DeliverToLocal(to string, msgType string, payload json.RawMessage) bool
}

// FederationRouter handles routing of messages between local users and federated peers.
type FederationRouter struct {
	users       *store.UserStore
	peerManager *PeerManager
	deliverer   LocalDeliverer
	db          *sql.DB
	cfg         *config.FederationConfig
}

// NewFederationRouter creates a new FederationRouter.
func NewFederationRouter(users *store.UserStore, pm *PeerManager, deliverer LocalDeliverer, db *sql.DB, cfg *config.FederationConfig) *FederationRouter {
	r := &FederationRouter{
		users:       users,
		peerManager: pm,
		deliverer:   deliverer,
		db:          db,
		cfg:         cfg,
	}

	// Start hint cleanup ticker
	go r.hintCleanupLoop()

	return r
}

// IsLocalUser checks whether a pubkey belongs to a user registered on this server.
func (r *FederationRouter) IsLocalUser(pubkey string) bool {
	exists, err := r.users.UserExists(pubkey)
	if err != nil {
		log.Printf("[federation] error checking local user %s: %v", pubkey, err)
		return false
	}
	return exists
}

// Route routes a federated envelope to its destination.
// If the recipient is local, it is delivered via the hub.
// If remote, it is forwarded to the appropriate federation peer.
func (r *FederationRouter) Route(env *FederatedEnvelope) {
	if env.To == "" {
		log.Printf("[federation] dropping envelope with empty 'to' field")
		return
	}

	// Check if recipient is local
	if r.IsLocalUser(env.To) {
		if !r.deliverer.DeliverToLocal(env.To, env.Type, env.Payload) {
			log.Printf("[federation] local delivery failed for %s (user offline or error)", env.To)
		}
		return
	}

	// Forward to federation peers
	r.forwardToRemote(env)
}

// RouteV2 routes a v2 federation envelope with hop limiting.
func (r *FederationRouter) RouteV2(env *FederatedEnvelopeV2) {
	if env.To == "" {
		return
	}

	// Check hop limit
	maxHops := r.cfg.MaxHops
	if maxHops <= 0 {
		maxHops = 2
	}
	if env.Hops >= maxHops {
		log.Printf("[federation] dropping envelope for %s: max hops (%d) exceeded", env.To[:8], maxHops)
		return
	}

	// Check if recipient is local
	if r.IsLocalUser(env.To) {
		// Convert to v1 envelope for local delivery
		payload, _ := json.Marshal(map[string]interface{}{
			"id":   env.ID,
			"from": env.From,
			"body": env.Body,
			"ts":   env.Ts,
		})
		if !r.deliverer.DeliverToLocal(env.To, "message", payload) {
			log.Printf("[federation] local delivery failed for %s", env.To[:8])
		}
		return
	}

	// Forward with incremented hop count
	env.Hops++
	r.forwardV2ToRemote(env)
}

// forwardToRemote attempts to deliver a message to a remote federation peer (v1).
func (r *FederationRouter) forwardToRemote(env *FederatedEnvelope) {
	peers := r.peerManager.ListPeers()

	// Check hint table for direct routing
	hintPeer := r.getHint(env.To)
	if hintPeer != "" {
		for _, peer := range peers {
			if peer.Pubkey == hintPeer && peer.IsConnected() {
				if err := peer.Send(env); err == nil {
					return
				}
				// Hint failed, clear it
				r.clearHint(env.To, hintPeer)
				break
			}
		}
	}

	// Broadcast to all connected peers
	sent := false
	for _, peer := range peers {
		if !peer.IsConnected() {
			continue
		}
		if err := peer.Send(env); err != nil {
			log.Printf("[federation] failed to forward to peer %s: %v", peer.Pubkey, err)
			continue
		}
		sent = true
		break
	}

	if !sent {
		log.Printf("[federation] no available peer for recipient %s", env.To)
	}
}

// forwardV2ToRemote forwards a v2 envelope to federation peers.
func (r *FederationRouter) forwardV2ToRemote(env *FederatedEnvelopeV2) {
	peers := r.peerManager.ListPeers()

	hintPeer := r.getHint(env.To)
	if hintPeer != "" {
		for _, peer := range peers {
			if peer.Pubkey == hintPeer && peer.IsConnected() {
				data, _ := json.Marshal(env)
				if err := peer.SendRaw(data); err == nil {
					return
				}
				r.clearHint(env.To, hintPeer)
				break
			}
		}
	}

	data, _ := json.Marshal(env)
	for _, peer := range peers {
		if !peer.IsConnected() {
			continue
		}
		if err := peer.SendRaw(data); err == nil {
			return
		}
	}
}

// HandleIncoming processes an envelope received from a federation peer.
func (r *FederationRouter) HandleIncoming(env *FederatedEnvelope) {
	if env.To == "" {
		return
	}

	if r.IsLocalUser(env.To) {
		if r.deliverer.DeliverToLocal(env.To, env.Type, env.Payload) {
			// Record hint: from-user was reached via this path
			// We don't know the peer pubkey here, but the PeerManager caller can set it
		}
		return
	}

	// Do not forward further (v1 has no hop limit, just drop)
	log.Printf("[federation] dropping message for non-local user %s", env.To)
}

// HandleIncomingV2 processes a v2 federated envelope with hop limiting.
func (r *FederationRouter) HandleIncomingV2(env *FederatedEnvelopeV2, fromPeerPubkey string) {
	if env.To == "" {
		return
	}

	if r.IsLocalUser(env.To) {
		payload, _ := json.Marshal(map[string]interface{}{
			"id":   env.ID,
			"from": env.From,
			"body": env.Body,
			"ts":   env.Ts,
		})
		if r.deliverer.DeliverToLocal(env.To, "message", payload) {
			// Record hint: sender's server is fromPeerPubkey
			r.recordHint(env.From, fromPeerPubkey)
		}
		return
	}

	// Forward with hop check
	r.RouteV2(env)
}

// --- User hints ---

func (r *FederationRouter) recordHint(userPubkey, peerPubkey string) {
	if r.db == nil {
		return
	}
	_, err := r.db.Exec(
		`INSERT OR REPLACE INTO fed_user_hints (pubkey, peer_pubkey, last_seen) VALUES (?, ?, ?)`,
		userPubkey, peerPubkey, time.Now().Unix(),
	)
	if err != nil {
		log.Printf("[federation] failed to record hint for %s: %v", userPubkey[:8], err)
	}
}

func (r *FederationRouter) getHint(userPubkey string) string {
	if r.db == nil {
		return ""
	}
	var peerPubkey string
	err := r.db.QueryRow(
		`SELECT peer_pubkey FROM fed_user_hints WHERE pubkey = ? ORDER BY last_seen DESC LIMIT 1`,
		userPubkey,
	).Scan(&peerPubkey)
	if err != nil {
		return ""
	}
	return peerPubkey
}

func (r *FederationRouter) clearHint(userPubkey, peerPubkey string) {
	if r.db == nil {
		return
	}
	r.db.Exec(`DELETE FROM fed_user_hints WHERE pubkey = ? AND peer_pubkey = ?`, userPubkey, peerPubkey)
}

func (r *FederationRouter) hintCleanupLoop() {
	ticker := time.NewTicker(1 * time.Hour)
	defer ticker.Stop()

	for range ticker.C {
		if r.db == nil {
			continue
		}
		// Expire hints older than 7 days
		cutoff := time.Now().Add(-7 * 24 * time.Hour).Unix()
		r.db.Exec(`DELETE FROM fed_user_hints WHERE last_seen < ?`, cutoff)
	}
}
