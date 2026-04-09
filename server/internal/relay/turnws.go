package relay

import (
	"io"
	"net"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

// turnWSListener is a net.Listener that produces virtual connections from
// WebSocket clients. Each authenticated client can start a TURN session by
// sending binary frames with BinaryTypeTurnData (0x30). The STUN payload is
// piped through a virtual net.Conn into pion/turn.
//
// This eliminates the need for a separate TLS connection for TURN, making
// all traffic (messaging + calls) flow through a single WebSocket — invisible
// to DPI.
type turnWSListener struct {
	ch   chan net.Conn
	addr net.Addr
	done chan struct{}
	once sync.Once
}

func newTurnWSListener(addr net.Addr) *turnWSListener {
	return &turnWSListener{
		ch:   make(chan net.Conn, 32),
		addr: addr,
		done: make(chan struct{}),
	}
}

func (l *turnWSListener) Accept() (net.Conn, error) {
	select {
	case c := <-l.ch:
		return c, nil
	case <-l.done:
		return nil, net.ErrClosed
	}
}

func (l *turnWSListener) Close() error {
	l.once.Do(func() { close(l.done) })
	return nil
}

func (l *turnWSListener) Addr() net.Addr { return l.addr }

// turnWSConn is a virtual net.Conn that bridges a WebSocket client's TURN
// binary frames (0x30) with pion/turn's TCP TURN interface.
//
// Write path: pion/turn → turnWSConn.Write() → WS binary frame 0x30+data → client
// Read path:  client → WS binary frame 0x30+data → turnWSConn.incoming → pion/turn reads
type turnWSConn struct {
	ws       *websocket.Conn // for writes (server → client)
	sendCh   chan []byte     // binary send channel on the Client
	incoming chan []byte     // data from WS client → pion/turn reads
	buf      []byte          // leftover from partial reads
	remote   net.Addr
	local    net.Addr
	done     chan struct{}
	once     sync.Once
}

func newTurnWSConn(sendBinary chan []byte, remoteAddr string) *turnWSConn {
	return &turnWSConn{
		sendCh:   sendBinary,
		incoming: make(chan []byte, 64),
		remote:   &net.TCPAddr{IP: net.ParseIP(remoteAddr), Port: 0},
		local:    &net.TCPAddr{IP: net.IPv4(127, 0, 0, 1), Port: 443},
		done:     make(chan struct{}),
	}
}

// feedData is called by the Client when a 0x30 binary frame arrives.
func (c *turnWSConn) feedData(data []byte) {
	select {
	case c.incoming <- data:
	case <-c.done:
	}
}

// Read implements net.Conn — pion/turn calls this to read STUN messages.
func (c *turnWSConn) Read(b []byte) (int, error) {
	// Drain leftover buffer first
	if len(c.buf) > 0 {
		n := copy(b, c.buf)
		c.buf = c.buf[n:]
		return n, nil
	}
	select {
	case data, ok := <-c.incoming:
		if !ok {
			return 0, io.EOF
		}
		n := copy(b, data)
		if n < len(data) {
			c.buf = data[n:]
		}
		return n, nil
	case <-c.done:
		return 0, io.EOF
	}
}

// Write implements net.Conn — pion/turn calls this to send STUN responses.
// Wraps data with 0x30 prefix and sends as WS binary frame.
func (c *turnWSConn) Write(b []byte) (int, error) {
	frame := make([]byte, 1+len(b))
	frame[0] = BinaryTypeTurnData
	copy(frame[1:], b)
	select {
	case c.sendCh <- frame:
		return len(b), nil
	case <-c.done:
		return 0, io.ErrClosedPipe
	}
}

func (c *turnWSConn) Close() error {
	c.once.Do(func() { close(c.done) })
	return nil
}

func (c *turnWSConn) LocalAddr() net.Addr                { return c.local }
func (c *turnWSConn) RemoteAddr() net.Addr               { return c.remote }
func (c *turnWSConn) SetDeadline(t time.Time) error      { return nil }
func (c *turnWSConn) SetReadDeadline(t time.Time) error  { return nil }
func (c *turnWSConn) SetWriteDeadline(t time.Time) error { return nil }
