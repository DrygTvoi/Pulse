package backup

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"

	"github.com/nicholasgasior/pulse-server/internal/store"
)

// Handler processes backup put/get operations with validation.
type Handler struct {
	backups      *store.BackupStore
	maxSizeBytes int
}

// PutRequest represents a backup upload request.
type PutRequest struct {
	Data     []byte `json:"data"`
	Checksum string `json:"checksum"`
}

// GetResponse represents a backup download response.
type GetResponse struct {
	Data     []byte `json:"data"`
	Checksum string `json:"checksum"`
	Updated  int64  `json:"updated"`
}

// NewHandler creates a new backup Handler.
func NewHandler(backups *store.BackupStore, maxSizeBytes int) *Handler {
	return &Handler{
		backups:      backups,
		maxSizeBytes: maxSizeBytes,
	}
}

// HandleBackupPut validates and stores an encrypted backup blob.
func (h *Handler) HandleBackupPut(pubkey string, payload json.RawMessage) error {
	var req PutRequest
	if err := json.Unmarshal(payload, &req); err != nil {
		return fmt.Errorf("invalid backup payload: %w", err)
	}

	if len(req.Data) == 0 {
		return fmt.Errorf("backup data is empty")
	}

	if len(req.Data) > h.maxSizeBytes {
		return fmt.Errorf("backup exceeds maximum size (%d > %d bytes)", len(req.Data), h.maxSizeBytes)
	}

	// Verify checksum if provided
	if req.Checksum != "" {
		computed := sha256.Sum256(req.Data)
		computedHex := hex.EncodeToString(computed[:])
		if computedHex != req.Checksum {
			return fmt.Errorf("checksum mismatch: expected %s, got %s", req.Checksum, computedHex)
		}
	} else {
		// Generate checksum if not provided
		computed := sha256.Sum256(req.Data)
		req.Checksum = hex.EncodeToString(computed[:])
	}

	if err := h.backups.PutBackup(pubkey, req.Data, req.Checksum); err != nil {
		log.Printf("[backup] failed to store backup for %s: %v", pubkey, err)
		return fmt.Errorf("failed to store backup: %w", err)
	}

	log.Printf("[backup] stored backup for %s (%d bytes)", pubkey, len(req.Data))
	return nil
}

// HandleBackupGet retrieves a user's encrypted backup blob.
func (h *Handler) HandleBackupGet(pubkey string) (*GetResponse, error) {
	b, err := h.backups.GetBackup(pubkey)
	if err != nil {
		log.Printf("[backup] failed to get backup for %s: %v", pubkey, err)
		return nil, fmt.Errorf("failed to get backup: %w", err)
	}
	if b == nil {
		return nil, nil
	}

	return &GetResponse{
		Data:     b.Data,
		Checksum: b.Checksum,
		Updated:  b.Updated,
	}, nil
}
