// Binary reality-bridge is a pluggable transport frontend for pulse-server.
// It listens for VLESS/REALITY-obfuscated connections and pipes the unwrapped
// stream to the core Pulse relay (PULSE_CORE_ADDR, default localhost:8443).
//
// TODO: Integrate actual VLESS/REALITY transport listener.
// Currently this is a TCP pipe stub that demonstrates the architecture.
package main

import (
	"io"
	"log"
	"net"
	"os"
	"sync"
)

func main() {
	listenAddr := envOrDefault("REALITY_LISTEN", "0.0.0.0:443")
	coreAddr := envOrDefault("PULSE_CORE_ADDR", "localhost:8443")

	log.Printf("[reality] listening on %s, forwarding to %s", listenAddr, coreAddr)

	ln, err := net.Listen("tcp", listenAddr)
	if err != nil {
		log.Fatalf("[reality] failed to listen: %v", err)
	}
	defer ln.Close()

	for {
		clientConn, err := ln.Accept()
		if err != nil {
			log.Printf("[reality] accept error: %v", err)
			continue
		}
		go handleConnection(clientConn, coreAddr)
	}
}

// handleConnection pipes a client connection to the core relay.
// TODO: Strip VLESS/REALITY obfuscation from clientConn before piping.
// Currently this is a raw TCP pipe (pass-through).
func handleConnection(clientConn net.Conn, coreAddr string) {
	defer clientConn.Close()

	upstreamConn, err := net.Dial("tcp", coreAddr)
	if err != nil {
		log.Printf("[reality] failed to connect to core at %s: %v", coreAddr, err)
		return
	}
	defer upstreamConn.Close()

	var wg sync.WaitGroup
	wg.Add(2)

	// Client → Core
	go func() {
		defer wg.Done()
		io.Copy(upstreamConn, clientConn)
	}()

	// Core → Client
	go func() {
		defer wg.Done()
		io.Copy(clientConn, upstreamConn)
	}()

	wg.Wait()
}

func envOrDefault(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}
