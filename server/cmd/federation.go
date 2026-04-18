package cmd

import (
	"database/sql"
	"fmt"
	"regexp"
	"time"

	"github.com/spf13/cobra"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/store"
)

// ed25519PubkeyHexRe matches exactly 64 hex characters, which corresponds to
// the 32-byte Ed25519 public key used by federation peers.
var ed25519PubkeyHexRe = regexp.MustCompile(`^[0-9a-fA-F]{64}$`)

var federationCmd = &cobra.Command{
	Use:   "federation",
	Short: "Manage federation peers",
}

var fedAddCmd = &cobra.Command{
	Use:   "add [address] [pubkey]",
	Short: "Add a federation peer",
	Args:  cobra.ExactArgs(2),
	RunE:  runFedAdd,
}

var fedListCmd = &cobra.Command{
	Use:   "list",
	Short: "List all federation peers",
	RunE:  runFedList,
}

var fedRemoveCmd = &cobra.Command{
	Use:   "remove [pubkey]",
	Short: "Remove a federation peer",
	Args:  cobra.ExactArgs(1),
	RunE:  runFedRemove,
}

func init() {
	federationCmd.AddCommand(fedAddCmd)
	federationCmd.AddCommand(fedListCmd)
	federationCmd.AddCommand(fedRemoveCmd)
	rootCmd.AddCommand(federationCmd)
}

func openFedDB() (*sql.DB, func(), error) {
	cfg, err := config.Load(cfgFile)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to load config: %w", err)
	}

	effectiveDataDir := dataDir
	if cfg.Server.DataDir != "" && effectiveDataDir == "/data" {
		effectiveDataDir = cfg.Server.DataDir
	}

	db, err := store.Open(effectiveDataDir)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to open database: %w", err)
	}

	if err := store.Migrate(db); err != nil {
		db.Close()
		return nil, nil, fmt.Errorf("failed to run migrations: %w", err)
	}

	cleanup := func() { db.Close() }
	return db, cleanup, nil
}

func runFedAdd(cmd *cobra.Command, args []string) error {
	address := args[0]
	pubkey := args[1]

	if !ed25519PubkeyHexRe.MatchString(pubkey) {
		return fmt.Errorf("invalid ed25519 pubkey hex")
	}

	db, cleanup, err := openFedDB()
	if err != nil {
		return err
	}
	defer cleanup()

	now := time.Now().Unix()
	_, err = db.Exec(
		"INSERT INTO federation_peers (pubkey, address, enabled, added) VALUES (?, ?, 1, ?)",
		pubkey, address, now,
	)
	if err != nil {
		return fmt.Errorf("failed to add federation peer: %w", err)
	}

	fmt.Printf("Federation peer added:\n")
	fmt.Printf("  Address: %s\n", address)
	fmt.Printf("  Pubkey:  %s\n", pubkey)
	return nil
}

func runFedList(cmd *cobra.Command, args []string) error {
	db, cleanup, err := openFedDB()
	if err != nil {
		return err
	}
	defer cleanup()

	rows, err := db.Query("SELECT pubkey, address, enabled, added FROM federation_peers ORDER BY added DESC")
	if err != nil {
		return fmt.Errorf("failed to list federation peers: %w", err)
	}
	defer rows.Close()

	type fedPeer struct {
		Pubkey  string
		Address string
		Enabled int
		Added   int64
	}

	var peers []fedPeer
	for rows.Next() {
		var p fedPeer
		if err := rows.Scan(&p.Pubkey, &p.Address, &p.Enabled, &p.Added); err != nil {
			return fmt.Errorf("failed to scan peer: %w", err)
		}
		peers = append(peers, p)
	}
	if err := rows.Err(); err != nil {
		return err
	}

	if len(peers) == 0 {
		fmt.Println("No federation peers configured.")
		return nil
	}

	fmt.Printf("%-66s %-30s %-8s %s\n", "PUBKEY", "ADDRESS", "ENABLED", "ADDED")
	for _, p := range peers {
		enabledStr := "yes"
		if p.Enabled == 0 {
			enabledStr = "no"
		}
		added := time.Unix(p.Added, 0).Format("2006-01-02")
		fmt.Printf("%-66s %-30s %-8s %s\n", p.Pubkey, p.Address, enabledStr, added)
	}
	return nil
}

func runFedRemove(cmd *cobra.Command, args []string) error {
	pubkey := args[0]

	db, cleanup, err := openFedDB()
	if err != nil {
		return err
	}
	defer cleanup()

	res, err := db.Exec("DELETE FROM federation_peers WHERE pubkey = ?", pubkey)
	if err != nil {
		return fmt.Errorf("failed to remove federation peer: %w", err)
	}

	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("federation peer not found: %s", pubkey)
	}

	fmt.Printf("Federation peer %s removed.\n", pubkey)
	return nil
}
