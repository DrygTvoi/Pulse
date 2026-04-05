package store

import (
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"
)

// FileTransfer represents a chunked file upload in progress or completed.
type FileTransfer struct {
	TransferID string
	Uploader   string
	SHA256     string
	TotalSize  int64
	ChunkCount int
	ChunkSize  int
	Completed  bool
	Created    int64
	Expires    int64
}

// FileStore manages chunked file uploads and storage.
type FileStore struct {
	db      *sql.DB
	dataDir string
}

// NewFileStore creates a new FileStore.
func NewFileStore(db *sql.DB, dataDir string) *FileStore {
	return &FileStore{db: db, dataDir: dataDir}
}

// BlobDir returns the base blob directory path.
func (s *FileStore) BlobDir() string {
	return filepath.Join(s.dataDir, "blobs")
}

// EnsureDirs creates necessary directories.
func (s *FileStore) EnsureDirs() error {
	if err := os.MkdirAll(filepath.Join(s.dataDir, "blobs", "partial"), 0700); err != nil {
		return fmt.Errorf("failed to create blob dirs: %w", err)
	}
	return nil
}

// CreateTransfer registers a new file upload.
func (s *FileStore) CreateTransfer(t *FileTransfer) error {
	_, err := s.db.Exec(
		`INSERT INTO file_store (transfer_id, uploader, sha256, total_size, chunk_count, chunk_size, completed, created, expires)
		 VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?)`,
		t.TransferID, t.Uploader, t.SHA256, t.TotalSize, t.ChunkCount, t.ChunkSize, t.Created, t.Expires,
	)
	if err != nil {
		return fmt.Errorf("failed to create transfer: %w", err)
	}
	// Create partial directory
	dir := filepath.Join(s.dataDir, "blobs", "partial", t.TransferID)
	return os.MkdirAll(dir, 0700)
}

// GetTransfer retrieves a transfer record.
func (s *FileStore) GetTransfer(transferID string) (*FileTransfer, error) {
	var t FileTransfer
	err := s.db.QueryRow(
		`SELECT transfer_id, uploader, sha256, total_size, chunk_count, chunk_size, completed, created, expires
		 FROM file_store WHERE transfer_id = ?`, transferID,
	).Scan(&t.TransferID, &t.Uploader, &t.SHA256, &t.TotalSize, &t.ChunkCount, &t.ChunkSize, &t.Completed, &t.Created, &t.Expires)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get transfer: %w", err)
	}
	return &t, nil
}

// WriteChunk writes a chunk to disk.
func (s *FileStore) WriteChunk(transferID string, chunkIdx int, data []byte) error {
	path := filepath.Join(s.dataDir, "blobs", "partial", transferID, fmt.Sprintf("%d", chunkIdx))
	return os.WriteFile(path, data, 0600)
}

// CountChunks returns how many chunks have been written for a transfer.
func (s *FileStore) CountChunks(transferID string) (int, error) {
	dir := filepath.Join(s.dataDir, "blobs", "partial", transferID)
	entries, err := os.ReadDir(dir)
	if err != nil {
		if os.IsNotExist(err) {
			return 0, nil
		}
		return 0, err
	}
	return len(entries), nil
}

// CompleteTransfer assembles chunks into a final blob and verifies SHA-256.
func (s *FileStore) CompleteTransfer(transferID string, expectedSHA string, chunkCount int) error {
	partialDir := filepath.Join(s.dataDir, "blobs", "partial", transferID)
	finalPath := filepath.Join(s.dataDir, "blobs", transferID)

	outFile, err := os.Create(finalPath)
	if err != nil {
		return fmt.Errorf("failed to create final blob: %w", err)
	}
	defer outFile.Close()

	hasher := sha256.New()
	writer := io.MultiWriter(outFile, hasher)

	for i := 0; i < chunkCount; i++ {
		chunkPath := filepath.Join(partialDir, fmt.Sprintf("%d", i))
		data, err := os.ReadFile(chunkPath)
		if err != nil {
			os.Remove(finalPath)
			return fmt.Errorf("failed to read chunk %d: %w", i, err)
		}
		if _, err := writer.Write(data); err != nil {
			os.Remove(finalPath)
			return fmt.Errorf("failed to write chunk %d: %w", i, err)
		}
	}

	// Verify SHA-256
	actualSHA := hex.EncodeToString(hasher.Sum(nil))
	if actualSHA != expectedSHA {
		os.Remove(finalPath)
		return fmt.Errorf("sha256 mismatch: expected %s, got %s", expectedSHA, actualSHA)
	}

	// Mark completed in DB
	if _, err := s.db.Exec("UPDATE file_store SET completed = 1 WHERE transfer_id = ?", transferID); err != nil {
		os.Remove(finalPath)
		return fmt.Errorf("failed to mark transfer complete: %w", err)
	}

	// Remove partial chunks
	os.RemoveAll(partialDir)

	return nil
}

// DeleteTransfer removes a transfer and its files.
func (s *FileStore) DeleteTransfer(transferID string) error {
	// Remove from DB
	if _, err := s.db.Exec("DELETE FROM file_store WHERE transfer_id = ?", transferID); err != nil {
		return fmt.Errorf("failed to delete transfer: %w", err)
	}
	// Remove files
	os.RemoveAll(filepath.Join(s.dataDir, "blobs", "partial", transferID))
	os.Remove(filepath.Join(s.dataDir, "blobs", transferID))
	return nil
}

// DeleteExpiredFiles removes all expired file transfers and their blobs.
func (s *FileStore) DeleteExpiredFiles() (int64, error) {
	now := time.Now().Unix()
	rows, err := s.db.Query("SELECT transfer_id FROM file_store WHERE expires > 0 AND expires < ?", now)
	if err != nil {
		return 0, fmt.Errorf("failed to query expired files: %w", err)
	}
	defer rows.Close()

	var count int64
	for rows.Next() {
		var tid string
		if err := rows.Scan(&tid); err != nil {
			continue
		}
		if err := s.DeleteTransfer(tid); err == nil {
			count++
		}
	}
	return count, rows.Err()
}

// GetUserStorageUsed returns total bytes used by a user's completed uploads.
func (s *FileStore) GetUserStorageUsed(pubkey string) (int64, error) {
	var total sql.NullInt64
	err := s.db.QueryRow(
		"SELECT COALESCE(SUM(total_size), 0) FROM file_store WHERE uploader = ? AND completed = 1",
		pubkey,
	).Scan(&total)
	if err != nil {
		return 0, fmt.Errorf("failed to get storage used: %w", err)
	}
	return total.Int64, nil
}

// GetBlobPath returns the path to a completed blob file.
func (s *FileStore) GetBlobPath(transferID string) string {
	return filepath.Join(s.dataDir, "blobs", transferID)
}
