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

// shortID returns the first 8 characters of s for log output, or the entire
// string if it is shorter. Avoids panics on unexpectedly short pubkeys.
func shortID(s string) string {
	if len(s) <= 8 {
		return s
	}
	return s[:8]
}

// FederationRouter handles routing of messages between local users and federated peers.
type FederationRouter struct {
	users       *store.UserStore
	peerManager *PeerManager
	deliverer   LocalDeliverer
	db          *sql.DB
	cfg         *config.FederationConfig
	auth        *FederationAuth
	outbox      *store.FederationOutbox
}

// NewFederationRouter creates a new FederationRouter.
func NewFederationRouter(users *store.UserStore, pm *PeerManager, deliverer LocalDeliverer, db *sql.DB, cfg *config.FederationConfig, auth *FederationAuth) *FederationRouter {
	r := &FederationRouter{
		users:       users,
		peerManager: pm,
		deliverer:   deliverer,
		db:          db,
		cfg:         cfg,
		auth:        auth,
		outbox:      store.NewFederationOutbox(db),
	}

	// Start hint cleanup ticker
	go r.hintCleanupLoop()
	// Periodically retry queued outbox entries so a peer that was offline
	// when the sender asked us to forward eventually receives the message.
	go r.outboxRetryLoop()

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

// Route routes a federated envelope to its destination with hop limiting.
// If the recipient is local, it is delivered via the hub.
// If remote, it is forwarded to the appropriate federation peer.
func (r *FederationRouter) Route(env *FederatedEnvelope) {
	if env.To == "" {
		return
	}

	// Check hop limit
	maxHops := r.cfg.MaxHops
	if maxHops <= 0 {
		maxHops = 2
	}
	if env.Hops >= maxHops {
		log.Printf("[federation] dropping envelope for %s: max hops (%d) exceeded", shortID(env.To), maxHops)
		return
	}

	// Check if recipient is local
	if r.IsLocalUser(env.To) {
		payload, _ := json.Marshal(map[string]interface{}{
			"id":   env.ID,
			"from": env.From,
			"body": env.Body,
			"ts":   env.Ts,
		})
		if !r.deliverer.DeliverToLocal(env.To, "message", payload) {
			log.Printf("[federation] local delivery failed for %s", shortID(env.To))
		}
		return
	}

	// Forward with incremented hop count
	env.Hops++
	r.forwardToRemote(env)
}

// forwardToRemote forwards an envelope to federation peers.
// Signs the envelope with this server's key before forwarding.
func (r *FederationRouter) forwardToRemote(env *FederatedEnvelope) {
	// Sign with our key (each hop re-signs to prove relay authenticity)
	if r.auth != nil {
		r.auth.SignEnvelope(env)
	}

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
	// No peer accepted the envelope — queue it so we can retry when a
	// peer reconnects. Drops silently if the store errors (better to
	// lose one message than to panic the router).
	if r.outbox != nil {
		if err := r.outbox.Enqueue(env.ID, env.To, data); err != nil {
			log.Printf("[federation] outbox enqueue failed for %s: %v", env.To, err)
		}
	}
}

// outboxRetryLoop walks the outbox every 30s. For each pending entry it
// looks up a peer (via hint, else any connected peer) and sends. Success
// removes the row; failure increments the attempt counter. After
// `maxAttempts` tries, entries sit dormant until the janitor purges.
func (r *FederationRouter) outboxRetryLoop() {
	const retryInterval = 30 * time.Second
	const maxAttempts = 12       // ~6 hours at 30s cadence
	const maxAgeSeconds = 7 * 24 * 60 * 60

	ticker := time.NewTicker(retryInterval)
	defer ticker.Stop()
	purgeTicker := time.NewTicker(6 * time.Hour)
	defer purgeTicker.Stop()

	for {
		select {
		case <-purgeTicker.C:
			if r.outbox != nil {
				_, _ = r.outbox.Purge(maxAgeSeconds)
			}
		case <-ticker.C:
			r.drainOutbox(maxAttempts)
		}
	}
}

func (r *FederationRouter) drainOutbox(maxAttempts int) {
	if r.outbox == nil {
		return
	}
	rows, err := r.outbox.Pending(128, maxAttempts)
	if err != nil {
		log.Printf("[federation] outbox scan error: %v", err)
		return
	}
	if len(rows) == 0 {
		return
	}
	peers := r.peerManager.ListPeers()
	for _, row := range rows {
		delivered := false
		// Prefer a hint for the recipient if we have one fresh.
		if hint := r.getHint(row.ToPubkey); hint != "" {
			for _, p := range peers {
				if p.Pubkey == hint && p.IsConnected() {
					if err := p.SendRaw(row.Envelope); err == nil {
						delivered = true
					}
					break
				}
			}
		}
		if !delivered {
			for _, p := range peers {
				if !p.IsConnected() {
					continue
				}
				if err := p.SendRaw(row.Envelope); err == nil {
					delivered = true
					break
				}
			}
		}
		if delivered {
			_ = r.outbox.Delete(row.ID)
		} else {
			_ = r.outbox.MarkAttempt(row.ID)
		}
	}
}

// HandleIncoming processes a federated envelope received from a peer.
func (r *FederationRouter) HandleIncoming(env *FederatedEnvelope, fromPeerPubkey string) {
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
	r.Route(env)
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
		log.Printf("[federation] failed to record hint for %s: %v", shortID(userPubkey), err)
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
		// Expire hints older than 24 hours
		cutoff := time.Now().Add(-24 * time.Hour).Unix()
		r.db.Exec(`DELETE FROM fed_user_hints WHERE last_seen < ?`, cutoff)
	}
}
