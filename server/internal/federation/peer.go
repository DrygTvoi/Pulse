package federation

import (
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

const (
	peerPongWait       = 60 * time.Second
	peerPingInterval   = (peerPongWait * 9) / 10
	peerWriteWait      = 10 * time.Second
	peerReconnectDelay = 10 * time.Second
	peerMaxReconnect   = 5 * time.Minute
)

// FederatedEnvelope wraps a message being forwarded between federated servers.
type FederatedEnvelope struct {
	Type    string          `json:"type"`
	From    string          `json:"from"`
	To      string          `json:"to"`
	Payload json.RawMessage `json:"payload"`
}

// Peer represents a persistent WebSocket connection to a federation peer.
type Peer struct {
	mu       sync.Mutex
	Address  string
	Pubkey   string
	conn     *websocket.Conn
	auth     *FederationAuth
	send     chan []byte
	done     chan struct{}
	stopped  bool
	onRecv   func(*FederatedEnvelope)
}

// NewPeer creates a new federation peer.
func NewPeer(address, pubkey string, auth *FederationAuth, onRecv func(*FederatedEnvelope)) *Peer {
	return &Peer{
		Address: address,
		Pubkey:  pubkey,
		auth:    auth,
		send:    make(chan []byte, 256),
		done:    make(chan struct{}),
		onRecv:  onRecv,
	}
}

// Connect establishes a WS connection and performs the federation handshake.
func (p *Peer) Connect() error {
	p.mu.Lock()
	if p.stopped {
		p.mu.Unlock()
		return fmt.Errorf("peer is stopped")
	}
	p.mu.Unlock()

	wsURL := p.Address + "/federation"
	dialer := websocket.Dialer{
		HandshakeTimeout: 10 * time.Second,
	}

	conn, _, err := dialer.Dial(wsURL, nil)
	if err != nil {
		return fmt.Errorf("failed to connect to peer %s: %w", p.Address, err)
	}

	// Perform federation handshake
	remotePub, err := p.auth.PerformHandshake(conn)
	if err != nil {
		conn.Close()
		return fmt.Errorf("handshake failed with %s: %w", p.Address, err)
	}

	// Verify we connected to the expected peer
	if p.Pubkey != "" && remotePub != p.Pubkey {
		conn.Close()
		return fmt.Errorf("peer pubkey mismatch: expected %s, got %s", p.Pubkey, remotePub)
	}
	p.Pubkey = remotePub

	p.mu.Lock()
	p.conn = conn
	p.mu.Unlock()

	go p.readPump()
	go p.writePump()

	log.Printf("[federation] connected to peer %s (%s)", p.Address, p.Pubkey)
	return nil
}

// Disconnect closes the connection to the peer.
func (p *Peer) Disconnect() {
	p.mu.Lock()
	defer p.mu.Unlock()

	p.stopped = true
	select {
	case <-p.done:
	default:
		close(p.done)
	}
	if p.conn != nil {
		p.conn.Close()
		p.conn = nil
	}
}

// Send queues a federated envelope for delivery to this peer.
func (p *Peer) Send(env *FederatedEnvelope) error {
	data, err := json.Marshal(env)
	if err != nil {
		return fmt.Errorf("failed to marshal envelope: %w", err)
	}

	select {
	case p.send <- data:
		return nil
	case <-p.done:
		return fmt.Errorf("peer is disconnected")
	default:
		return fmt.Errorf("peer send buffer full")
	}
}

// SendRaw queues raw JSON bytes for delivery to this peer.
func (p *Peer) SendRaw(data []byte) error {
	select {
	case p.send <- data:
		return nil
	case <-p.done:
		return fmt.Errorf("peer is disconnected")
	default:
		return fmt.Errorf("peer send buffer full")
	}
}

// IsConnected returns whether the peer has an active connection.
func (p *Peer) IsConnected() bool {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.conn != nil
}

// readPump reads messages from the peer connection.
func (p *Peer) readPump() {
	defer func() {
		p.mu.Lock()
		if p.conn != nil {
			p.conn.Close()
			p.conn = nil
		}
		p.mu.Unlock()
	}()

	p.mu.Lock()
	conn := p.conn
	p.mu.Unlock()

	if conn == nil {
		return
	}

	conn.SetReadDeadline(time.Now().Add(peerPongWait))
	conn.SetPongHandler(func(string) error {
		conn.SetReadDeadline(time.Now().Add(peerPongWait))
		return nil
	})

	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseNormalClosure) {
				log.Printf("[federation] read error from peer %s: %v", p.Address, err)
			}
			return
		}

		var env FederatedEnvelope
		if err := json.Unmarshal(message, &env); err != nil {
			log.Printf("[federation] invalid message from peer %s: %v", p.Address, err)
			continue
		}

		if p.onRecv != nil {
			p.onRecv(&env)
		}
	}
}

// writePump writes messages to the peer connection.
func (p *Peer) writePump() {
	ticker := time.NewTicker(peerPingInterval)
	defer func() {
		ticker.Stop()
		p.mu.Lock()
		if p.conn != nil {
			p.conn.Close()
			p.conn = nil
		}
		p.mu.Unlock()
	}()

	for {
		select {
		case message, ok := <-p.send:
			p.mu.Lock()
			conn := p.conn
			p.mu.Unlock()
			if conn == nil {
				return
			}

			conn.SetWriteDeadline(time.Now().Add(peerWriteWait))
			if !ok {
				conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := conn.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Printf("[federation] write error to peer %s: %v", p.Address, err)
				return
			}

		case <-ticker.C:
			p.mu.Lock()
			conn := p.conn
			p.mu.Unlock()
			if conn == nil {
				return
			}
			conn.SetWriteDeadline(time.Now().Add(peerWriteWait))
			if err := conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}

		case <-p.done:
			return
		}
	}
}

// PeerManager manages all federation peer connections.
type PeerManager struct {
	mu    sync.RWMutex
	peers map[string]*Peer // pubkey -> peer
	auth  *FederationAuth
	onRecv func(*FederatedEnvelope)
	stopCh chan struct{}
}

// NewPeerManager creates a new PeerManager.
func NewPeerManager(auth *FederationAuth, onRecv func(*FederatedEnvelope)) *PeerManager {
	return &PeerManager{
		peers:  make(map[string]*Peer),
		auth:   auth,
		onRecv: onRecv,
		stopCh: make(chan struct{}),
	}
}

// AddPeer adds and connects to a new federation peer.
func (pm *PeerManager) AddPeer(address, pubkey string) error {
	pm.mu.Lock()
	if _, exists := pm.peers[pubkey]; exists {
		pm.mu.Unlock()
		return fmt.Errorf("peer already exists: %s", pubkey)
	}

	peer := NewPeer(address, pubkey, pm.auth, pm.onRecv)
	pm.peers[pubkey] = peer
	pm.mu.Unlock()

	// Connect in the background with reconnection loop
	go pm.reconnectLoop(peer)

	return nil
}

// RemovePeer disconnects and removes a federation peer.
func (pm *PeerManager) RemovePeer(pubkey string) error {
	pm.mu.Lock()
	peer, exists := pm.peers[pubkey]
	if !exists {
		pm.mu.Unlock()
		return fmt.Errorf("peer not found: %s", pubkey)
	}
	delete(pm.peers, pubkey)
	pm.mu.Unlock()

	peer.Disconnect()
	return nil
}

// GetPeer returns a peer by pubkey.
func (pm *PeerManager) GetPeer(pubkey string) *Peer {
	pm.mu.RLock()
	defer pm.mu.RUnlock()
	return pm.peers[pubkey]
}

// ListPeers returns all peers.
func (pm *PeerManager) ListPeers() []*Peer {
	pm.mu.RLock()
	defer pm.mu.RUnlock()

	peers := make([]*Peer, 0, len(pm.peers))
	for _, p := range pm.peers {
		peers = append(peers, p)
	}
	return peers
}

// AcceptPeer handles an incoming federation WS connection.
func (pm *PeerManager) AcceptPeer(conn *websocket.Conn) error {
	remotePub, err := pm.auth.AcceptHandshake(conn)
	if err != nil {
		conn.Close()
		return fmt.Errorf("failed to accept handshake: %w", err)
	}

	pm.mu.Lock()
	existing, exists := pm.peers[remotePub]
	if exists {
		// Update existing peer with new connection
		existing.mu.Lock()
		if existing.conn != nil {
			existing.conn.Close()
		}
		existing.conn = conn
		existing.mu.Unlock()
		pm.mu.Unlock()

		go existing.readPump()
		go existing.writePump()
		log.Printf("[federation] reconnected incoming peer %s", remotePub)
		return nil
	}

	// New incoming peer
	peer := NewPeer("", remotePub, pm.auth, pm.onRecv)
	peer.conn = conn
	pm.peers[remotePub] = peer
	pm.mu.Unlock()

	go peer.readPump()
	go peer.writePump()
	log.Printf("[federation] accepted new peer %s", remotePub)
	return nil
}

// Stop disconnects all peers and stops the manager.
func (pm *PeerManager) Stop() {
	close(pm.stopCh)

	pm.mu.Lock()
	defer pm.mu.Unlock()

	for _, peer := range pm.peers {
		peer.Disconnect()
	}
	pm.peers = make(map[string]*Peer)
}

// reconnectLoop maintains a persistent connection to a peer with backoff.
func (pm *PeerManager) reconnectLoop(peer *Peer) {
	delay := peerReconnectDelay

	for {
		select {
		case <-pm.stopCh:
			return
		case <-peer.done:
			return
		default:
		}

		if err := peer.Connect(); err != nil {
			log.Printf("[federation] connect to %s failed: %v (retry in %v)", peer.Address, err, delay)

			select {
			case <-time.After(delay):
			case <-pm.stopCh:
				return
			case <-peer.done:
				return
			}

			// Increase backoff up to max
			delay = delay * 2
			if delay > peerMaxReconnect {
				delay = peerMaxReconnect
			}
			continue
		}

		// Reset backoff on successful connect
		delay = peerReconnectDelay

		// Wait for disconnection, then reconnect
		select {
		case <-pm.stopCh:
			return
		case <-peer.done:
			return
		}
	}
}
