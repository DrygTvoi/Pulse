// pulse-utls-proxy — local HTTP CONNECT proxy that uses uTLS to mimic
// Chrome's TLS ClientHello fingerprint for all upstream connections.
//
// Usage:
//   pulse-utls-proxy             → prints port to stdout, exits when stdin closes
//
// Build:
//   go build -ldflags="-s -w" -o ../../assets/bins/linux_x64/pulse-utls-proxy .
//   GOARCH=arm64 go build -ldflags="-s -w" -o ../../assets/bins/linux_arm64/pulse-utls-proxy .
//
// Dart side starts this as a subprocess, reads the port from the first line of
// stdout, then routes WebSocket connections through it via HttpClient.findProxy.
package main

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"

	tls "github.com/refraction-networking/utls"
)

func main() {
	// Bind on a random port on loopback only.
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		fmt.Fprintln(os.Stderr, "[utls-proxy] listen error:", err)
		os.Exit(1)
	}

	port := listener.Addr().(*net.TCPAddr).Port
	// Print port to stdout — Dart reads this to know where to connect.
	fmt.Println(port)

	// Exit cleanly when Dart closes stdin (parent process died).
	go func() {
		io.Copy(io.Discard, os.Stdin)
		os.Exit(0)
	}()

	http.Serve(listener, http.HandlerFunc(handleConnect))
}

func handleConnect(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodConnect {
		http.Error(w, "only CONNECT supported", http.StatusMethodNotAllowed)
		return
	}

	host := r.Host
	// Ensure port is present.
	if !strings.Contains(host, ":") {
		host += ":443"
	}
	hostname := host[:strings.LastIndex(host, ":")]

	// Connect to upstream TCP.
	upstream, err := net.Dial("tcp", host)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadGateway)
		return
	}

	// uTLS handshake with Chrome fingerprint — this is what defeats DPI.
	tlsConn := tls.UClient(upstream, &tls.Config{
		ServerName:         hostname,
		InsecureSkipVerify: false,
	}, tls.HelloChrome_Auto)

	if err := tlsConn.Handshake(); err != nil {
		tlsConn.Close()
		http.Error(w, "TLS handshake: "+err.Error(), http.StatusBadGateway)
		return
	}

	// Tell the HTTP client the tunnel is ready.
	hijacker, ok := w.(http.Hijacker)
	if !ok {
		tlsConn.Close()
		http.Error(w, "hijack unsupported", http.StatusInternalServerError)
		return
	}
	clientConn, _, err := hijacker.Hijack()
	if err != nil {
		tlsConn.Close()
		return
	}

	clientConn.Write([]byte("HTTP/1.1 200 Connection Established\r\n\r\n"))

	// Bidirectional pipe: Dart ↔ uTLS ↔ real server.
	done := make(chan struct{}, 2)
	go func() { io.Copy(tlsConn, clientConn); done <- struct{}{} }()
	go func() { io.Copy(clientConn, tlsConn); done <- struct{}{} }()
	<-done
	tlsConn.Close()
	clientConn.Close()
}

