package cmd

import (
	"archive/tar"
	"compress/gzip"
	"database/sql"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/spf13/cobra"
	_ "modernc.org/sqlite"

	"github.com/nicholasgasior/pulse-server/config"
)

var backupCmd = &cobra.Command{
	Use:   "backup [output-path]",
	Short: "Create a consistent backup of the server database and data_dir",
	Long: `Creates a tar.gz archive containing a consistent SQLite snapshot
(via VACUUM INTO — WAL/SHM are merged in, so they are safe to omit),
the server master-wrapping key, the self-signed TLS material, and the
Let's Encrypt autocert cache directory if present.

If no output path is given, the archive is written to
{data_dir}/backups/pulse-YYYYMMDD-HHMMSS.tar.gz.`,
	Args: cobra.MaximumNArgs(1),
	RunE: runBackup,
}

func runBackup(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(cfgFile)
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	effectiveDataDir := cfg.Server.DataDir
	if cmd.Flags().Changed("data-dir") || effectiveDataDir == "" {
		effectiveDataDir = dataDir
	}
	if effectiveDataDir == "" {
		return fmt.Errorf("data_dir is not configured")
	}

	// Resolve output path.
	var outPath string
	if len(args) == 1 && args[0] != "" {
		outPath = args[0]
	} else {
		ts := time.Now().UTC().Format("20060102-150405")
		outPath = filepath.Join(effectiveDataDir, "backups", fmt.Sprintf("pulse-%s.tar.gz", ts))
	}

	if err := os.MkdirAll(filepath.Dir(outPath), 0o700); err != nil {
		return fmt.Errorf("failed to create output directory: %w", err)
	}

	// Step 1: snapshot the live SQLite DB to a temp file via VACUUM INTO.
	// This produces a self-contained DB that already has any WAL/SHM pages
	// merged in — safer than tarring pulse.db while the server may be
	// writing to it.
	tmpDir, err := os.MkdirTemp("", "pulse-backup-")
	if err != nil {
		return fmt.Errorf("failed to create temp dir: %w", err)
	}
	defer os.RemoveAll(tmpDir)

	snapshotPath := filepath.Join(tmpDir, "pulse.db")
	if err := sqliteVacuumInto(filepath.Join(effectiveDataDir, "pulse.db"), snapshotPath); err != nil {
		return fmt.Errorf("failed to snapshot database: %w", err)
	}

	// Step 2: collect entries to include in the archive.
	// Each entry is a (disk path, archive path) pair so we can relocate
	// the snapshot from /tmp into pulse.db at the archive root.
	type entry struct {
		diskPath    string
		archivePath string
	}

	entries := []entry{
		{diskPath: snapshotPath, archivePath: "pulse.db"},
	}

	// Optional files — include if present, skip silently if not.
	optionalFiles := []string{
		"server_master.key",
		"self_signed.pem",
		"self_signed.key",
	}
	for _, name := range optionalFiles {
		p := filepath.Join(effectiveDataDir, name)
		if info, err := os.Stat(p); err == nil && !info.IsDir() {
			entries = append(entries, entry{diskPath: p, archivePath: name})
		}
	}

	// Step 3: create the tar.gz archive.
	out, err := os.OpenFile(outPath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0o600)
	if err != nil {
		return fmt.Errorf("failed to create output file: %w", err)
	}
	defer out.Close()

	gz := gzip.NewWriter(out)
	defer gz.Close()
	tw := tar.NewWriter(gz)
	defer tw.Close()

	for _, e := range entries {
		if err := addFileToTar(tw, e.diskPath, e.archivePath); err != nil {
			return fmt.Errorf("failed to archive %s: %w", e.archivePath, err)
		}
	}

	// Autocert cache — directory, recurse.
	autocertDir := filepath.Join(effectiveDataDir, "autocert")
	if info, err := os.Stat(autocertDir); err == nil && info.IsDir() {
		if err := addDirToTar(tw, autocertDir, "autocert"); err != nil {
			return fmt.Errorf("failed to archive autocert dir: %w", err)
		}
	}

	// Flush writers explicitly so a failure here surfaces before we report
	// success. Deferred Close()s will no-op after explicit close.
	if err := tw.Close(); err != nil {
		return fmt.Errorf("failed to finalize tar: %w", err)
	}
	if err := gz.Close(); err != nil {
		return fmt.Errorf("failed to finalize gzip: %w", err)
	}
	if err := out.Close(); err != nil {
		return fmt.Errorf("failed to close output: %w", err)
	}

	fmt.Println(outPath)
	return nil
}

// sqliteVacuumInto opens the source DB read-only and copies a consistent
// snapshot to dst via `VACUUM INTO`. modernc.org/sqlite (pure Go) is used,
// so no external sqlite3 binary is required. VACUUM INTO produces a
// self-contained DB with no WAL/SHM sidecars.
func sqliteVacuumInto(srcPath, dstPath string) error {
	// Open read-only so a backup on a live server doesn't contend with
	// writers for anything beyond the checkpoint VACUUM INTO takes.
	db, err := sql.Open("sqlite", srcPath+"?mode=ro&_pragma=busy_timeout(10000)")
	if err != nil {
		return err
	}
	defer db.Close()
	if err := db.Ping(); err != nil {
		return err
	}

	// VACUUM INTO refuses if the destination exists. The path is inside a
	// freshly-minted tempdir so this is purely defensive.
	_ = os.Remove(dstPath)

	// SQLite parses the destination as a string literal; escape single quotes.
	escaped := strings.ReplaceAll(dstPath, "'", "''")
	if _, err := db.Exec(fmt.Sprintf("VACUUM INTO '%s'", escaped)); err != nil {
		return err
	}
	return nil
}

// addFileToTar writes a single regular file into the tar stream under the
// given archive-relative name.
func addFileToTar(tw *tar.Writer, diskPath, archivePath string) error {
	info, err := os.Stat(diskPath)
	if err != nil {
		return err
	}
	if info.IsDir() {
		return fmt.Errorf("%s is a directory", diskPath)
	}

	hdr, err := tar.FileInfoHeader(info, "")
	if err != nil {
		return err
	}
	hdr.Name = archivePath
	if err := tw.WriteHeader(hdr); err != nil {
		return err
	}

	f, err := os.Open(diskPath)
	if err != nil {
		return err
	}
	defer f.Close()

	if _, err := io.Copy(tw, f); err != nil {
		return err
	}
	return nil
}

// addDirToTar recursively adds a directory tree to the tar stream, rooted at
// the supplied archive prefix. Symlinks are stored as symlinks; other
// non-regular entries are skipped.
func addDirToTar(tw *tar.Writer, rootDisk, rootArchive string) error {
	return filepath.Walk(rootDisk, func(path string, info os.FileInfo, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		rel, err := filepath.Rel(rootDisk, path)
		if err != nil {
			return err
		}
		archivePath := rootArchive
		if rel != "." {
			archivePath = filepath.Join(rootArchive, rel)
		}
		// Normalise to forward slashes — tar uses POSIX path separators.
		archivePath = filepath.ToSlash(archivePath)

		var link string
		if info.Mode()&os.ModeSymlink != 0 {
			if link, err = os.Readlink(path); err != nil {
				return err
			}
		}

		hdr, err := tar.FileInfoHeader(info, link)
		if err != nil {
			return err
		}
		hdr.Name = archivePath

		if err := tw.WriteHeader(hdr); err != nil {
			return err
		}

		if info.Mode().IsRegular() {
			f, err := os.Open(path)
			if err != nil {
				return err
			}
			_, copyErr := io.Copy(tw, f)
			f.Close()
			if copyErr != nil {
				return copyErr
			}
		}
		return nil
	})
}
