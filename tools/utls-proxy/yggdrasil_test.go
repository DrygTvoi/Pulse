package main

import (
	"crypto/ed25519"
	cryptorand "crypto/rand"
	"net"
	"os"
	"path/filepath"
	"strings"
	"testing"

	iwtypes "github.com/Arceliar/ironwood/types"
)

// ── pubkeyToUDPAddr ───────────────────────────────────────────────────────────

func TestPubkeyToUDPAddr_IsYggdrasilRange(t *testing.T) {
	// Yggdrasil node address structure:
	//   byte 0 = 0x02 (prefix)
	//   byte 1 = 0x00–0x7f (leading-1-count, high bit=0 for node)
	//   → first hextet: 0x0200–0x027f → "200:"–"27f:"
	pub, _, err := ed25519.GenerateKey(cryptorand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	addr := pubkeyToUDPAddr(iwtypes.Addr(pub))
	ip16 := addr.IP.To16()
	if ip16 == nil {
		t.Fatalf("pubkeyToUDPAddr returned non-IPv6 addr: %s", addr.IP)
	}
	if ip16[0] != 0x02 {
		t.Errorf("first byte = 0x%02x, want 0x02 (Yggdrasil prefix)", ip16[0])
	}
	if ip16[1] > 0x7f {
		t.Errorf("second byte = 0x%02x > 0x7f: not a valid Yggdrasil node address", ip16[1])
	}
}

func TestPubkeyToUDPAddr_Deterministic(t *testing.T) {
	pub, _, _ := ed25519.GenerateKey(cryptorand.Reader)
	a1 := pubkeyToUDPAddr(iwtypes.Addr(pub))
	a2 := pubkeyToUDPAddr(iwtypes.Addr(pub))
	if !a1.IP.Equal(a2.IP) {
		t.Errorf("not deterministic: %s != %s", a1.IP, a2.IP)
	}
}

func TestPubkeyToUDPAddr_DifferentKeysDifferentAddrs(t *testing.T) {
	pub1, _, _ := ed25519.GenerateKey(cryptorand.Reader)
	pub2, _, _ := ed25519.GenerateKey(cryptorand.Reader)
	a1 := pubkeyToUDPAddr(iwtypes.Addr(pub1))
	a2 := pubkeyToUDPAddr(iwtypes.Addr(pub2))
	if a1.IP.Equal(a2.IP) {
		t.Error("different pubkeys produced same Yggdrasil address (collision)")
	}
}

func TestPubkeyToUDPAddr_FallbackForNonIwAddr(t *testing.T) {
	// A *net.UDPAddr is not an iwtypes.Addr — should return loopback
	other := &net.UDPAddr{IP: net.ParseIP("1.2.3.4"), Port: 1234}
	addr := pubkeyToUDPAddr(other)
	if !addr.IP.Equal(net.IPv6loopback) {
		t.Errorf("expected IPv6 loopback fallback, got %s", addr.IP)
	}
}

// ── Identity key persistence ──────────────────────────────────────────────────

func TestLoadOrCreateYggKey_CreatesAndReloads(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "ygg_identity.key")

	// First call: no file exists → generate and save
	t.Setenv("YGG_KEY_PATH_OVERRIDE", path) // not used by prod code; test uses helper below
	priv1, err := loadOrCreateYggKeyAt(path)
	if err != nil {
		t.Fatalf("first load: %v", err)
	}
	if len(priv1) != ed25519.PrivateKeySize {
		t.Fatalf("wrong key size: %d", len(priv1))
	}

	// File must exist now
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("key file not created: %v", err)
	}
	if len(data) != ed25519.PrivateKeySize {
		t.Fatalf("key file has wrong size: %d", len(data))
	}

	// Second call: loads same key
	priv2, err := loadOrCreateYggKeyAt(path)
	if err != nil {
		t.Fatalf("second load: %v", err)
	}
	if string(priv1) != string(priv2) {
		t.Error("reloaded key does not match generated key")
	}
}

func TestLoadOrCreateYggKey_InvalidFileSizeRegenerates(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "ygg_identity.key")

	// Write garbage (wrong size)
	if err := os.WriteFile(path, []byte("short"), 0600); err != nil {
		t.Fatal(err)
	}
	priv, err := loadOrCreateYggKeyAt(path)
	if err != nil {
		t.Fatalf("expected regeneration on bad file: %v", err)
	}
	if len(priv) != ed25519.PrivateKeySize {
		t.Fatalf("wrong size after regeneration: %d", len(priv))
	}
}

func TestNewSelfSignedYggCert_UsesCorrectKey(t *testing.T) {
	_, priv, err := ed25519.GenerateKey(cryptorand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	cert, err := newSelfSignedYggCert(priv)
	if err != nil {
		t.Fatalf("newSelfSignedYggCert: %v", err)
	}
	if cert == nil {
		t.Fatal("got nil cert")
	}
	if cert.PrivateKey == nil {
		t.Fatal("cert has nil PrivateKey")
	}
	// PrivateKey must be the same ed25519 key
	if string(cert.PrivateKey.(ed25519.PrivateKey)) != string(priv) {
		t.Error("cert private key does not match input")
	}
	if len(cert.Certificate) == 0 {
		t.Error("cert has no DER blocks")
	}
}

// ── yggKeyPath HOME priority ──────────────────────────────────────────────────

func TestYggKeyPath_PrefersHomeDir(t *testing.T) {
	// Override HOME to a temp dir so we can verify the path without touching
	// the real home directory.
	dir := t.TempDir()
	t.Setenv("HOME", dir)

	path := yggKeyPath()

	// Must be under the temp HOME, not under the exe directory.
	if !strings.HasPrefix(path, dir) {
		t.Errorf("key path %q does not start with HOME %q", path, dir)
	}
	// Must be named ygg_identity.key.
	if filepath.Base(path) != "ygg_identity.key" {
		t.Errorf("unexpected filename: %q", filepath.Base(path))
	}
	// The .pulse subdirectory must have been created.
	info, err := os.Stat(filepath.Dir(path))
	if err != nil {
		t.Fatalf("parent dir not created: %v", err)
	}
	if !info.IsDir() {
		t.Error("parent path is not a directory")
	}
}

// ── addrCache round-trip ──────────────────────────────────────────────────────

func TestYggPacketConn_AddrCacheRoundTrip(t *testing.T) {
	// Create a minimal dispatcher (node can be nil for cache-only test)
	disp := &yggDispatcher{}
	pc := newYggPacketConn(disp, 50000, &net.UDPAddr{})

	pub, _, _ := ed25519.GenerateKey(cryptorand.Reader)
	original := iwtypes.Addr(pub)

	// Simulate a ReadFrom by populating addrCache manually
	synth := pubkeyToUDPAddr(original)
	pc.addrCache.Store(synth.IP.String(), original)

	// Verify WriteTo can reverse-lookup
	v, ok := pc.addrCache.Load(synth.IP.String())
	if !ok {
		t.Fatal("addrCache miss after Store")
	}
	retrieved, ok := v.(net.Addr)
	if !ok {
		t.Fatal("stored value is not net.Addr")
	}
	if retrieved.String() != original.String() {
		t.Errorf("round-trip mismatch: got %s, want %s", retrieved, original)
	}
}
