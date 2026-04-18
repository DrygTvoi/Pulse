package store

import (
	"database/sql"
	"fmt"
	"time"
)

// Message represents a stored message.
type Message struct {
	ID        string `json:"id"`
	FromKey   string `json:"from_key"`
	ToKey     string `json:"to_key"`
	Payload   []byte `json:"payload"`
	Created   int64  `json:"created"`
	Expires   int64  `json:"expires"`
	Delivered int64  `json:"delivered"`
}

// MessageStore provides access to the messages table.
type MessageStore struct {
	db *sql.DB
}

// NewMessageStore creates a new MessageStore.
func NewMessageStore(db *sql.DB) *MessageStore {
	return &MessageStore{db: db}
}

// StoreMessage inserts a new message. Uses INSERT OR IGNORE so that a
// retried send with the same ID is a no-op instead of a constraint error
// (the sender may retry after a timeout while our INSERT already landed).
func (s *MessageStore) StoreMessage(msg *Message) error {
	_, err := s.db.Exec(
		"INSERT OR IGNORE INTO messages (id, from_key, to_key, payload, created, expires, delivered) VALUES (?, ?, ?, ?, ?, ?, 0)",
		msg.ID, msg.FromKey, msg.ToKey, msg.Payload, msg.Created, msg.Expires,
	)
	if err != nil {
		return fmt.Errorf("failed to store message: %w", err)
	}
	return nil
}

// GetMessagesForUser returns undelivered, non-expired messages for a
// user, optionally filtered by created timestamp and limited in count.
// Expiry is enforced inline so users never see stale messages in the
// window between DeleteExpiredMessages() sweeps.
func (s *MessageStore) GetMessagesForUser(pubkey string, since int64, limit int) ([]Message, error) {
	if limit <= 0 {
		limit = 100
	}

	now := time.Now().Unix()
	rows, err := s.db.Query(
		"SELECT id, from_key, to_key, payload, created, expires, delivered FROM messages "+
			"WHERE to_key = ? AND delivered = 0 AND created >= ? "+
			"AND (expires = 0 OR expires > ?) "+
			"ORDER BY created ASC LIMIT ?",
		pubkey, since, now, limit,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to get messages: %w", err)
	}
	defer rows.Close()

	var messages []Message
	for rows.Next() {
		var m Message
		if err := rows.Scan(&m.ID, &m.FromKey, &m.ToKey, &m.Payload, &m.Created, &m.Expires, &m.Delivered); err != nil {
			return nil, fmt.Errorf("failed to scan message: %w", err)
		}
		messages = append(messages, m)
	}
	return messages, rows.Err()
}

// DeleteMessage removes a message by ID.
func (s *MessageStore) DeleteMessage(id string) error {
	_, err := s.db.Exec("DELETE FROM messages WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete message: %w", err)
	}
	return nil
}

// DeleteExpiredMessages removes all messages past their expiry time.
func (s *MessageStore) DeleteExpiredMessages() (int64, error) {
	now := time.Now().Unix()
	res, err := s.db.Exec("DELETE FROM messages WHERE expires > 0 AND expires < ?", now)
	if err != nil {
		return 0, fmt.Errorf("failed to delete expired messages: %w", err)
	}
	return res.RowsAffected()
}

// MarkDelivered sets the delivered timestamp on a message.
func (s *MessageStore) MarkDelivered(id string) error {
	now := time.Now().Unix()
	_, err := s.db.Exec("UPDATE messages SET delivered = ? WHERE id = ?", now, id)
	if err != nil {
		return fmt.Errorf("failed to mark message delivered: %w", err)
	}
	return nil
}

// CountPendingForUser returns the number of undelivered messages for a user.
func (s *MessageStore) CountPendingForUser(pubkey string) (int, error) {
	var count int
	err := s.db.QueryRow(
		"SELECT COUNT(*) FROM messages WHERE to_key = ? AND delivered = 0",
		pubkey,
	).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count pending messages: %w", err)
	}
	return count, nil
}
