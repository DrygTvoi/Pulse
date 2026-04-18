package store

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

// FederationOutbox persists envelopes that the router could not deliver
// (no connected peer at the time) so they can be retried when a peer
// reconnects. Keeps federation delivery at-least-once instead of the
// previous best-effort that silently dropped.
type FederationOutbox struct {
	db *sql.DB
}

// OutboxRow is the persisted shape of a queued envelope.
type OutboxRow struct {
	ID        string
	ToPubkey  string
	Envelope  []byte
	Created   int64
	Attempts  int
	LastTried int64
}

func NewFederationOutbox(db *sql.DB) *FederationOutbox {
	return &FederationOutbox{db: db}
}

// Enqueue stores an envelope for later retry.
func (s *FederationOutbox) Enqueue(id, toPubkey string, envelope []byte) error {
	_, err := s.db.Exec(
		"INSERT OR IGNORE INTO federation_outbox (id, to_pubkey, envelope, created, attempts, last_attempt) VALUES (?, ?, ?, ?, 0, 0)",
		id, toPubkey, envelope, time.Now().Unix(),
	)
	if err != nil {
		return fmt.Errorf("outbox enqueue: %w", err)
	}
	return nil
}

// OlderThan returns entries older than [maxAge] and with fewer than
// [maxAttempts] delivery attempts, limited to [limit] rows.
func (s *FederationOutbox) Pending(limit int, maxAttempts int) ([]OutboxRow, error) {
	if limit <= 0 {
		limit = 256
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	rows, err := s.db.QueryContext(ctx,
		"SELECT id, to_pubkey, envelope, created, attempts, last_attempt FROM federation_outbox WHERE attempts < ? ORDER BY created ASC LIMIT ?",
		maxAttempts, limit,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []OutboxRow
	for rows.Next() {
		var r OutboxRow
		if err := rows.Scan(&r.ID, &r.ToPubkey, &r.Envelope, &r.Created, &r.Attempts, &r.LastTried); err != nil {
			return nil, err
		}
		out = append(out, r)
	}
	return out, rows.Err()
}

// MarkAttempt increments the attempt counter and updates last_attempt.
func (s *FederationOutbox) MarkAttempt(id string) error {
	_, err := s.db.Exec(
		"UPDATE federation_outbox SET attempts = attempts + 1, last_attempt = ? WHERE id = ?",
		time.Now().Unix(), id,
	)
	return err
}

// Delete removes a delivered entry.
func (s *FederationOutbox) Delete(id string) error {
	_, err := s.db.Exec("DELETE FROM federation_outbox WHERE id = ?", id)
	return err
}

// Purge drops outbox rows older than [maxAgeSeconds] regardless of status.
// Called by a periodic cleanup tick so dead letters don't accumulate.
func (s *FederationOutbox) Purge(maxAgeSeconds int64) (int64, error) {
	cutoff := time.Now().Unix() - maxAgeSeconds
	res, err := s.db.Exec("DELETE FROM federation_outbox WHERE created < ?", cutoff)
	if err != nil {
		return 0, err
	}
	return res.RowsAffected()
}
