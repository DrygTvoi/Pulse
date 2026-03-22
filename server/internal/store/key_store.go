package store

import (
	"database/sql"
	"fmt"
	"time"
)

// KeyBundle represents a user's key bundle for Signal protocol.
type KeyBundle struct {
	Pubkey  string `json:"pubkey"`
	Bundle  []byte `json:"bundle"`
	Updated int64  `json:"updated"`
}

// KeyStore provides access to the key_bundles table.
type KeyStore struct {
	db *sql.DB
}

// NewKeyStore creates a new KeyStore.
func NewKeyStore(db *sql.DB) *KeyStore {
	return &KeyStore{db: db}
}

// PutBundle inserts or replaces a key bundle for a user.
func (s *KeyStore) PutBundle(pubkey string, bundle []byte) error {
	now := time.Now().Unix()
	_, err := s.db.Exec(
		"INSERT INTO key_bundles (pubkey, bundle, updated) VALUES (?, ?, ?) ON CONFLICT(pubkey) DO UPDATE SET bundle = excluded.bundle, updated = excluded.updated",
		pubkey, bundle, now,
	)
	if err != nil {
		return fmt.Errorf("failed to put key bundle: %w", err)
	}
	return nil
}

// GetBundle returns the key bundle for a user.
func (s *KeyStore) GetBundle(pubkey string) (*KeyBundle, error) {
	kb := &KeyBundle{}
	err := s.db.QueryRow(
		"SELECT pubkey, bundle, updated FROM key_bundles WHERE pubkey = ?",
		pubkey,
	).Scan(&kb.Pubkey, &kb.Bundle, &kb.Updated)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get key bundle: %w", err)
	}
	return kb, nil
}
