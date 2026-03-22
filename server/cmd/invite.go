package cmd

import (
	"fmt"
	"time"

	"github.com/spf13/cobra"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/store"
)

var inviteCmd = &cobra.Command{
	Use:   "invite",
	Short: "Manage invite codes",
}

var inviteCreateCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a new invite code",
	RunE:  runInviteCreate,
}

var inviteListCmd = &cobra.Command{
	Use:   "list",
	Short: "List all invite codes",
	RunE:  runInviteList,
}

var inviteRevokeCmd = &cobra.Command{
	Use:   "revoke [code]",
	Short: "Revoke an invite code",
	Args:  cobra.ExactArgs(1),
	RunE:  runInviteRevoke,
}

var inviteMaxUses int

func init() {
	inviteCreateCmd.Flags().IntVar(&inviteMaxUses, "max-uses", 1, "maximum number of times the invite can be used")
	inviteCmd.AddCommand(inviteCreateCmd)
	inviteCmd.AddCommand(inviteListCmd)
	inviteCmd.AddCommand(inviteRevokeCmd)
	rootCmd.AddCommand(inviteCmd)
}

func openDB() (*store.InviteStore, func(), error) {
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

	invites := store.NewInviteStore(db)
	cleanup := func() { db.Close() }
	return invites, cleanup, nil
}

func runInviteCreate(cmd *cobra.Command, args []string) error {
	invites, cleanup, err := openDB()
	if err != nil {
		return err
	}
	defer cleanup()

	inv, err := invites.CreateInvite("admin", inviteMaxUses)
	if err != nil {
		return fmt.Errorf("failed to create invite: %w", err)
	}

	fmt.Printf("Invite code: %s\n", inv.Code)
	fmt.Printf("Max uses:    %d\n", inv.MaxUses)
	return nil
}

func runInviteList(cmd *cobra.Command, args []string) error {
	invites, cleanup, err := openDB()
	if err != nil {
		return err
	}
	defer cleanup()

	list, err := invites.ListInvites()
	if err != nil {
		return fmt.Errorf("failed to list invites: %w", err)
	}

	if len(list) == 0 {
		fmt.Println("No invite codes found.")
		return nil
	}

	fmt.Printf("%-36s %-12s %-10s %-10s %s\n", "CODE", "CREATED BY", "USES", "MAX USES", "CREATED")
	for _, inv := range list {
		created := time.Unix(inv.Created, 0).Format("2006-01-02")
		fmt.Printf("%-36s %-12s %-10d %-10d %s\n", inv.Code, inv.CreatedBy, inv.UseCount, inv.MaxUses, created)
	}
	return nil
}

func runInviteRevoke(cmd *cobra.Command, args []string) error {
	invites, cleanup, err := openDB()
	if err != nil {
		return err
	}
	defer cleanup()

	if err := invites.RevokeInvite(args[0]); err != nil {
		return fmt.Errorf("failed to revoke invite: %w", err)
	}

	fmt.Printf("Invite %s revoked.\n", args[0])
	return nil
}
