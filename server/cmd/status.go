package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"time"

	"github.com/spf13/cobra"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/store"
)

var statusCmd = &cobra.Command{
	Use:   "status",
	Short: "Show server status information",
	RunE:  runStatus,
}

func init() {
	rootCmd.AddCommand(statusCmd)
}

func runStatus(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(cfgFile)
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	effectiveDataDir := dataDir
	if cfg.Server.DataDir != "" && effectiveDataDir == "/data" {
		effectiveDataDir = cfg.Server.DataDir
	}

	// Database info
	dbPath := filepath.Join(effectiveDataDir, "pulse.db")
	var dbSize int64
	if info, err := os.Stat(dbPath); err == nil {
		dbSize = info.Size()
	}

	// User count
	var userCount int
	db, err := store.Open(effectiveDataDir)
	if err == nil {
		defer db.Close()
		if err := store.Migrate(db); err == nil {
			users := store.NewUserStore(db)
			list, err := users.ListUsers()
			if err == nil {
				userCount = len(list)
			}
		}
	}

	// Memory stats
	var memStats runtime.MemStats
	runtime.ReadMemStats(&memStats)

	fmt.Println("Pulse Server Status")
	fmt.Println("====================")
	fmt.Printf("Go version:   %s\n", runtime.Version())
	fmt.Printf("Platform:     %s/%s\n", runtime.GOOS, runtime.GOARCH)
	fmt.Printf("Data dir:     %s\n", effectiveDataDir)
	fmt.Printf("DB size:      %s\n", formatBytes(dbSize))
	fmt.Printf("Users:        %d\n", userCount)
	fmt.Printf("Memory alloc: %s\n", formatBytes(int64(memStats.Alloc)))
	fmt.Printf("Memory sys:   %s\n", formatBytes(int64(memStats.Sys)))
	fmt.Printf("Goroutines:   %d\n", runtime.NumGoroutine())
	fmt.Printf("Timestamp:    %s\n", time.Now().Format(time.RFC3339))

	return nil
}

func formatBytes(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(b)/float64(div), "KMGTPE"[exp])
}
