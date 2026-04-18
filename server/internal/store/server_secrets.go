package store

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
	"io"
	"os"
	"path/filepath"
)

// ServerSecretWrapper encrypts and decrypts server-side secrets (federation
// private key, sealed-sender secret, etc.) before they are written to the
// key_bundles table.
//
// The wrapping key lives in a file on disk (data_dir/server_master.key)
// with mode 0600. An attacker who steals the SQLite file alone gets only
// opaque ciphertext — they need the master key file too. That gives us a
// clear security boundary even though the DB and master key sit on the
// same machine: a stolen backup of the DB is useless without the key file.
//
// Callers that explicitly want plaintext (user key bundles, etc.) continue
// to use KeyStore.PutBundle/GetBundle directly.
type ServerSecretWrapper struct {
	gcm cipher.AEAD
}

// NewServerSecretWrapper loads or creates the wrapping key in [dataDir].
// The key file is chmod 0600 so only the server's UNIX user can read it.
func NewServerSecretWrapper(dataDir string) (*ServerSecretWrapper, error) {
	if dataDir == "" {
		return nil, fmt.Errorf("data_dir is empty")
	}
	if err := os.MkdirAll(dataDir, 0700); err != nil {
		return nil, fmt.Errorf("create data_dir: %w", err)
	}
	keyPath := filepath.Join(dataDir, "server_master.key")

	key, err := os.ReadFile(keyPath)
	if err != nil {
		if !os.IsNotExist(err) {
			return nil, fmt.Errorf("read master key: %w", err)
		}
		key = make([]byte, 32) // AES-256
		if _, err := io.ReadFull(rand.Reader, key); err != nil {
			return nil, fmt.Errorf("generate master key: %w", err)
		}
		if err := os.WriteFile(keyPath, key, 0600); err != nil {
			return nil, fmt.Errorf("write master key: %w", err)
		}
	}
	if len(key) != 32 {
		return nil, fmt.Errorf("master key must be 32 bytes, got %d", len(key))
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("new cipher: %w", err)
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, fmt.Errorf("new gcm: %w", err)
	}
	return &ServerSecretWrapper{gcm: gcm}, nil
}

// Wrap returns nonce || ciphertext. Safe against tampering (AEAD).
func (w *ServerSecretWrapper) Wrap(plaintext []byte) ([]byte, error) {
	nonce := make([]byte, w.gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, err
	}
	return w.gcm.Seal(nonce, nonce, plaintext, nil), nil
}

// Unwrap accepts nonce || ciphertext as produced by Wrap and returns the
// plaintext. For backward compatibility with existing plaintext secrets,
// a buffer shorter than nonce+tag overhead is returned as-is — the caller
// can then detect legacy format and migrate.
func (w *ServerSecretWrapper) Unwrap(blob []byte) ([]byte, error) {
	ns := w.gcm.NonceSize()
	if len(blob) < ns+w.gcm.Overhead() {
		// Legacy plaintext value — pass through.
		return blob, nil
	}
	nonce, ciphertext := blob[:ns], blob[ns:]
	return w.gcm.Open(nil, nonce, ciphertext, nil)
}
