package store

import (
	"database/sql"
	"fmt"
	"time"
)

// Backup represents an encrypted user backup.
type Backup struct {
	Pubkey   string `json:"pubkey"`
	Data     []byte `json:"data"`
	Checksum string `json:"checksum"`
	Updated  int64  `json:"updated"`
}

// BackupStore provides access to the backups table.
type BackupStore struct {
	db *sql.DB
}

// NewBackupStore creates a new BackupStore.
func NewBackupStore(db *sql.DB) *BackupStore {
	return &BackupStore{db: db}
}

// PutBackup inserts or replaces a backup for a user.
func (s *BackupStore) PutBackup(pubkey string, data []byte, checksum string) error {
	now := time.Now().Unix()
	_, err := s.db.Exec(
		"INSERT INTO backups (pubkey, data, checksum, updated) VALUES (?, ?, ?, ?) ON CONFLICT(pubkey) DO UPDATE SET data = excluded.data, checksum = excluded.checksum, updated = excluded.updated",
		pubkey, data, checksum, now,
	)
	if err != nil {
		return fmt.Errorf("failed to put backup: %w", err)
	}
	return nil
}

// GetBackup returns the backup for a user.
func (s *BackupStore) GetBackup(pubkey string) (*Backup, error) {
	b := &Backup{}
	err := s.db.QueryRow(
		"SELECT pubkey, data, checksum, updated FROM backups WHERE pubkey = ?",
		pubkey,
	).Scan(&b.Pubkey, &b.Data, &b.Checksum, &b.Updated)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get backup: %w", err)
	}
	return b, nil
}
