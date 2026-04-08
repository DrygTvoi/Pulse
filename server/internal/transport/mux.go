package transport

import (
	"bytes"
	"io"
	"log"
	"net"
	"sync"
	"time"
)

// chanListener implements net.Listener backed by a channel.
// Used to split a single TLS listener into STUN and HTTP streams.
type chanListener struct {
	ch     chan net.Conn
	addr   net.Addr
	closeOnce sync.Once
	done   chan struct{}
}

func newChanListener(addr net.Addr) *chanListener {
	return &chanListener{
		ch:   make(chan net.Conn, 16),
		addr: addr,
		done: make(chan struct{}),
	}
}

func (l *chanListener) Accept() (net.Conn, error) {
	select {
	case c := <-l.ch:
		return c, nil
	case <-l.done:
		return nil, net.ErrClosed
	}
}

func (l *chanListener) Close() error {
	l.closeOnce.Do(func() { close(l.done) })
	return nil
}

func (l *chanListener) Addr() net.Addr { return l.addr }

// peekConn wraps a net.Conn, prepending already-read bytes to future reads.
type peekConn struct {
	net.Conn
	reader io.Reader
}

func (c *peekConn) Read(b []byte) (int, error) {
	return c.reader.Read(b)
}

// isSTUN returns true if the first byte looks like STUN/TURN.
// RFC 5389 §6: STUN messages have first two bits = 00.
// HTTP methods start with uppercase ASCII letters (bits 01xxxxxx).
func isSTUN(b byte) bool {
	return (b >> 6) == 0
}

// muxAcceptLoop reads from parent TLS listener, peeks at the first byte
// of each connection, and routes STUN traffic to stunLn, HTTP to httpLn.
func muxAcceptLoop(parent net.Listener, stunLn, httpLn *chanListener) {
	for {
		conn, err := parent.Accept()
		if err != nil {
			return // listener closed
		}

		buf := make([]byte, 1)
		conn.SetReadDeadline(time.Now().Add(5 * time.Second))
		_, err = io.ReadFull(conn, buf)
		conn.SetReadDeadline(time.Time{})
		if err != nil {
			conn.Close()
			continue
		}

		pc := &peekConn{
			Conn:   conn,
			reader: io.MultiReader(bytes.NewReader(buf), conn),
		}

		if isSTUN(buf[0]) {
			log.Printf("[mux] STUN/TURN connection from %s (byte=0x%02x)", conn.RemoteAddr(), buf[0])
			select {
			case stunLn.ch <- pc:
			default:
				log.Printf("[mux] WARNING: STUN channel full, dropping %s", conn.RemoteAddr())
				conn.Close()
			}
		} else {
			select {
			case httpLn.ch <- pc:
			default:
				log.Printf("[mux] WARNING: HTTP channel full, dropping %s", conn.RemoteAddr())
				conn.Close()
			}
		}
	}
}
