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

// StoreMessage inserts a new message.
func (s *MessageStore) StoreMessage(msg *Message) error {
	_, err := s.db.Exec(
		"INSERT INTO messages (id, from_key, to_key, payload, created, expires, delivered) VALUES (?, ?, ?, ?, ?, ?, 0)",
		msg.ID, msg.FromKey, msg.ToKey, msg.Payload, msg.Created, msg.Expires,
	)
	if err != nil {
		return fmt.Errorf("failed to store message: %w", err)
	}
	return nil
}

// GetMessagesForUser returns undelivered messages for a user, optionally filtered by
// created timestamp and limited in count.
func (s *MessageStore) GetMessagesForUser(pubkey string, since int64, limit int) ([]Message, error) {
	if limit <= 0 {
		limit = 100
	}

	rows, err := s.db.Query(
		"SELECT id, from_key, to_key, payload, created, expires, delivered FROM messages WHERE to_key = ? AND delivered = 0 AND created >= ? ORDER BY created ASC LIMIT ?",
		pubkey, since, limit,
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
