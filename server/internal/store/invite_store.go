package store

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"fmt"
	"time"
)

// Invite represents an invite code.
type Invite struct {
	Code      string `json:"code"`
	CreatedBy string `json:"created_by"`
	Created   int64  `json:"created"`
	UsedBy    string `json:"used_by"`
	MaxUses   int    `json:"max_uses"`
	UseCount  int    `json:"use_count"`
}

// InviteStore provides access to the invites table.
type InviteStore struct {
	db *sql.DB
}

// NewInviteStore creates a new InviteStore.
func NewInviteStore(db *sql.DB) *InviteStore {
	return &InviteStore{db: db}
}

// CreateInvite generates a new invite code.
func (s *InviteStore) CreateInvite(createdBy string, maxUses int) (*Invite, error) {
	codeBytes := make([]byte, 16)
	if _, err := rand.Read(codeBytes); err != nil {
		return nil, fmt.Errorf("failed to generate invite code: %w", err)
	}

	inv := &Invite{
		Code:      hex.EncodeToString(codeBytes),
		CreatedBy: createdBy,
		Created:   time.Now().Unix(),
		MaxUses:   maxUses,
	}

	_, err := s.db.Exec(
		"INSERT INTO invites (code, created_by, created, used_by, max_uses, use_count) VALUES (?, ?, ?, '', ?, 0)",
		inv.Code, inv.CreatedBy, inv.Created, inv.MaxUses,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create invite: %w", err)
	}
	return inv, nil
}

// ValidateInvite checks if an invite code is valid and has remaining uses.
func (s *InviteStore) ValidateInvite(code string) (*Invite, error) {
	inv := &Invite{}
	err := s.db.QueryRow(
		"SELECT code, created_by, created, used_by, max_uses, use_count FROM invites WHERE code = ?",
		code,
	).Scan(&inv.Code, &inv.CreatedBy, &inv.Created, &inv.UsedBy, &inv.MaxUses, &inv.UseCount)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("invite not found")
	}
	if err != nil {
		return nil, fmt.Errorf("failed to validate invite: %w", err)
	}

	if inv.UseCount >= inv.MaxUses {
		return nil, fmt.Errorf("invite has been fully used")
	}

	return inv, nil
}

// UseInvite marks an invite as used by a pubkey.
func (s *InviteStore) UseInvite(code string, pubkey string) error {
	res, err := s.db.Exec(
		"UPDATE invites SET use_count = use_count + 1, used_by = ? WHERE code = ? AND use_count < max_uses",
		pubkey, code,
	)
	if err != nil {
		return fmt.Errorf("failed to use invite: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("invite not found or already fully used")
	}
	return nil
}

// RevokeInvite deletes an invite code.
func (s *InviteStore) RevokeInvite(code string) error {
	res, err := s.db.Exec("DELETE FROM invites WHERE code = ?", code)
	if err != nil {
		return fmt.Errorf("failed to revoke invite: %w", err)
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("invite not found: %s", code)
	}
	return nil
}

// ListInvites returns all invites.
func (s *InviteStore) ListInvites() ([]Invite, error) {
	rows, err := s.db.Query(
		"SELECT code, created_by, created, used_by, max_uses, use_count FROM invites ORDER BY created DESC",
	)
	if err != nil {
		return nil, fmt.Errorf("failed to list invites: %w", err)
	}
	defer rows.Close()

	var invites []Invite
	for rows.Next() {
		var inv Invite
		if err := rows.Scan(&inv.Code, &inv.CreatedBy, &inv.Created, &inv.UsedBy, &inv.MaxUses, &inv.UseCount); err != nil {
			return nil, fmt.Errorf("failed to scan invite: %w", err)
		}
		invites = append(invites, inv)
	}
	return invites, rows.Err()
}
