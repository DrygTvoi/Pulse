package store

import (
	"database/sql"
	"fmt"
)

const currentVersion = 4

var migrations = []string{
	// Version 1: initial schema
	`CREATE TABLE IF NOT EXISTS users (
		pubkey TEXT PRIMARY KEY,
		created INTEGER NOT NULL,
		banned INTEGER NOT NULL DEFAULT 0,
		last_seen INTEGER NOT NULL
	);

	CREATE TABLE IF NOT EXISTS invites (
		code TEXT PRIMARY KEY,
		created_by TEXT NOT NULL,
		created INTEGER NOT NULL,
		used_by TEXT NOT NULL DEFAULT '',
		max_uses INTEGER NOT NULL DEFAULT 1,
		use_count INTEGER NOT NULL DEFAULT 0
	);

	CREATE TABLE IF NOT EXISTS messages (
		id TEXT PRIMARY KEY,
		from_key TEXT NOT NULL,
		to_key TEXT NOT NULL,
		payload BLOB NOT NULL,
		created INTEGER NOT NULL,
		expires INTEGER NOT NULL DEFAULT 0,
		delivered INTEGER NOT NULL DEFAULT 0
	);

	CREATE INDEX IF NOT EXISTS idx_messages_to_key ON messages(to_key);
	CREATE INDEX IF NOT EXISTS idx_messages_expires ON messages(expires);

	CREATE TABLE IF NOT EXISTS key_bundles (
		pubkey TEXT PRIMARY KEY,
		bundle BLOB NOT NULL,
		updated INTEGER NOT NULL
	);

	CREATE TABLE IF NOT EXISTS backups (
		pubkey TEXT PRIMARY KEY,
		data BLOB NOT NULL,
		checksum TEXT NOT NULL,
		updated INTEGER NOT NULL
	);

	CREATE TABLE IF NOT EXISTS federation_peers (
		pubkey TEXT PRIMARY KEY,
		address TEXT NOT NULL,
		enabled INTEGER NOT NULL DEFAULT 1,
		added INTEGER NOT NULL
	);`,

	// Version 2: file transfer store
	`CREATE TABLE IF NOT EXISTS file_store (
		transfer_id TEXT PRIMARY KEY,
		uploader TEXT NOT NULL,
		sha256 TEXT NOT NULL,
		total_size INTEGER NOT NULL,
		chunk_count INTEGER NOT NULL,
		chunk_size INTEGER NOT NULL,
		completed INTEGER NOT NULL DEFAULT 0,
		created INTEGER NOT NULL,
		expires INTEGER NOT NULL DEFAULT 0
	);

	CREATE INDEX IF NOT EXISTS idx_file_store_uploader ON file_store(uploader);
	CREATE INDEX IF NOT EXISTS idx_file_store_expires ON file_store(expires);`,

	// Version 3: federation v2 hints + sealed sender secrets + admin/metrics tables
	`CREATE TABLE IF NOT EXISTS fed_user_hints (
		pubkey TEXT NOT NULL,
		peer_pubkey TEXT NOT NULL,
		last_seen INTEGER NOT NULL,
		PRIMARY KEY (pubkey, peer_pubkey)
	);

	CREATE TABLE IF NOT EXISTS server_secrets (
		key TEXT PRIMARY KEY,
		value BLOB NOT NULL,
		updated INTEGER NOT NULL
	);

	ALTER TABLE federation_peers ADD COLUMN server_name TEXT NOT NULL DEFAULT '';
	ALTER TABLE federation_peers ADD COLUMN server_version TEXT NOT NULL DEFAULT '';
	ALTER TABLE federation_peers ADD COLUMN features TEXT NOT NULL DEFAULT '';
	ALTER TABLE federation_peers ADD COLUMN user_count INTEGER NOT NULL DEFAULT 0;
	ALTER TABLE federation_peers ADD COLUMN last_seen INTEGER NOT NULL DEFAULT 0;`,

	// Version 4: client IP tracking (optional, controlled by store_client_ip config)
	`ALTER TABLE users ADD COLUMN last_ip TEXT NOT NULL DEFAULT '';`,
}

// Migrate runs all pending migrations.
func Migrate(db *sql.DB) error {
	// Create schema_version table if it doesn't exist
	if _, err := db.Exec(`CREATE TABLE IF NOT EXISTS schema_version (version INTEGER NOT NULL)`); err != nil {
		return fmt.Errorf("failed to create schema_version table: %w", err)
	}

	current, err := getSchemaVersion(db)
	if err != nil {
		return err
	}

	for i := current; i < currentVersion; i++ {
		tx, err := db.Begin()
		if err != nil {
			return fmt.Errorf("failed to begin migration transaction: %w", err)
		}

		if _, err := tx.Exec(migrations[i]); err != nil {
			tx.Rollback()
			return fmt.Errorf("migration %d failed: %w", i+1, err)
		}

		if err := setSchemaVersion(tx, i+1); err != nil {
			tx.Rollback()
			return fmt.Errorf("failed to set schema version: %w", err)
		}

		if err := tx.Commit(); err != nil {
			return fmt.Errorf("failed to commit migration: %w", err)
		}
	}

	return nil
}

func getSchemaVersion(db *sql.DB) (int, error) {
	var version int
	err := db.QueryRow("SELECT version FROM schema_version LIMIT 1").Scan(&version)
	if err == sql.ErrNoRows {
		return 0, nil
	}
	if err != nil {
		return 0, fmt.Errorf("failed to get schema version: %w", err)
	}
	return version, nil
}

func setSchemaVersion(tx *sql.Tx, version int) error {
	// Delete existing version
	if _, err := tx.Exec("DELETE FROM schema_version"); err != nil {
		return err
	}
	_, err := tx.Exec("INSERT INTO schema_version (version) VALUES (?)", version)
	return err
}
