package store

import (
	"database/sql"
	"fmt"
	"time"
)

// User represents a registered user.
type User struct {
	Pubkey   string `json:"pubkey"`
	Created  int64  `json:"created"`
	Banned   bool   `json:"banned"`
	LastSeen int64  `json:"last_seen"`
}

// UserStore provides access to the users table.
type UserStore struct {
	db *sql.DB
}

// NewUserStore creates a new UserStore.
func NewUserStore(db *sql.DB) *UserStore {
	return &UserStore{db: db}
}

// CreateUser inserts a new user.
func (s *UserStore) CreateUser(pubkey string) error {
	now := time.Now().Unix()
	_, err := s.db.Exec(
		"INSERT INTO users (pubkey, created, banned, last_seen) VALUES (?, ?, 0, ?)",
		pubkey, now, now,
	)
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}
	return nil
}

// GetUser returns a user by pubkey.
func (s *UserStore) GetUser(pubkey string) (*User, error) {
	u := &User{}
	var banned int
	err := s.db.QueryRow(
		"SELECT pubkey, created, banned, last_seen FROM users WHERE pubkey = ?",
		pubkey,
	).Scan(&u.Pubkey, &u.Created, &banned, &u.LastSeen)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	u.Banned = banned != 0
	return u, nil
}

// UserExists checks whether a user with the given pubkey exists.
func (s *UserStore) UserExists(pubkey string) (bool, error) {
	var count int
	err := s.db.QueryRow("SELECT COUNT(*) FROM users WHERE pubkey = ?", pubkey).Scan(&count)
	if err != nil {
		return false, fmt.Errorf("failed to check user existence: %w", err)
	}
	return count > 0, nil
}

// BanUser sets the banned flag on a user.
func (s *UserStore) BanUser(pubkey string) error {
	res, err := s.db.Exec("UPDATE users SET banned = 1 WHERE pubkey = ?", pubkey)
	if err != nil {
		return fmt.Errorf("failed to ban user: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("user not found: %s", pubkey)
	}
	return nil
}

// UnbanUser clears the banned flag on a user.
func (s *UserStore) UnbanUser(pubkey string) error {
	res, err := s.db.Exec("UPDATE users SET banned = 0 WHERE pubkey = ?", pubkey)
	if err != nil {
		return fmt.Errorf("failed to unban user: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("user not found: %s", pubkey)
	}
	return nil
}

// DeleteUser removes a user and their associated data.
func (s *UserStore) DeleteUser(pubkey string) error {
	tx, err := s.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}

	if _, err := tx.Exec("DELETE FROM messages WHERE from_key = ? OR to_key = ?", pubkey, pubkey); err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to delete user messages: %w", err)
	}
	if _, err := tx.Exec("DELETE FROM key_bundles WHERE pubkey = ?", pubkey); err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to delete user key bundle: %w", err)
	}
	if _, err := tx.Exec("DELETE FROM backups WHERE pubkey = ?", pubkey); err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to delete user backup: %w", err)
	}
	if _, err := tx.Exec("DELETE FROM users WHERE pubkey = ?", pubkey); err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to delete user: %w", err)
	}

	return tx.Commit()
}

// ListUsers returns all users.
func (s *UserStore) ListUsers() ([]User, error) {
	rows, err := s.db.Query("SELECT pubkey, created, banned, last_seen FROM users ORDER BY created DESC")
	if err != nil {
		return nil, fmt.Errorf("failed to list users: %w", err)
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var u User
		var banned int
		if err := rows.Scan(&u.Pubkey, &u.Created, &banned, &u.LastSeen); err != nil {
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		u.Banned = banned != 0
		users = append(users, u)
	}
	return users, rows.Err()
}

// UpdateLastSeen updates the last_seen timestamp for a user.
func (s *UserStore) UpdateLastSeen(pubkey string) error {
	_, err := s.db.Exec("UPDATE users SET last_seen = ? WHERE pubkey = ?", time.Now().Unix(), pubkey)
	if err != nil {
		return fmt.Errorf("failed to update last_seen: %w", err)
	}
	return nil
}
