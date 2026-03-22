package federation

import (
	"encoding/json"
	"log"

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
}

// NewFederationRouter creates a new FederationRouter.
func NewFederationRouter(users *store.UserStore, pm *PeerManager, deliverer LocalDeliverer) *FederationRouter {
	return &FederationRouter{
		users:       users,
		peerManager: pm,
		deliverer:   deliverer,
	}
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

// forwardToRemote attempts to deliver a message to a remote federation peer.
func (r *FederationRouter) forwardToRemote(env *FederatedEnvelope) {
	peers := r.peerManager.ListPeers()

	// Try to find a connected peer that might know about this user.
	// In a simple federation model, we broadcast to all connected peers.
	// A more sophisticated implementation would maintain a user-to-server mapping.
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

// HandleIncoming processes an envelope received from a federation peer.
func (r *FederationRouter) HandleIncoming(env *FederatedEnvelope) {
	if env.To == "" {
		log.Printf("[federation] dropping incoming envelope with empty 'to' field")
		return
	}

	// Only deliver if the recipient is local
	if r.IsLocalUser(env.To) {
		if !r.deliverer.DeliverToLocal(env.To, env.Type, env.Payload) {
			log.Printf("[federation] incoming delivery failed for %s", env.To)
		}
		return
	}

	// Do not forward further to prevent routing loops
	log.Printf("[federation] dropping message for non-local user %s", env.To)
}
