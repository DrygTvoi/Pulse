package cmd

import (
	"fmt"
	"time"

	"github.com/spf13/cobra"

	"github.com/nicholasgasior/pulse-server/config"
	"github.com/nicholasgasior/pulse-server/internal/store"
)

var userCmd = &cobra.Command{
	Use:   "user",
	Short: "Manage users",
}

var userListCmd = &cobra.Command{
	Use:   "list",
	Short: "List all users",
	RunE:  runUserList,
}

var userBanCmd = &cobra.Command{
	Use:   "ban [pubkey]",
	Short: "Ban a user",
	Args:  cobra.ExactArgs(1),
	RunE:  runUserBan,
}

var userUnbanCmd = &cobra.Command{
	Use:   "unban [pubkey]",
	Short: "Unban a user",
	Args:  cobra.ExactArgs(1),
	RunE:  runUserUnban,
}

var userDeleteCmd = &cobra.Command{
	Use:   "delete [pubkey]",
	Short: "Delete a user and all their data",
	Args:  cobra.ExactArgs(1),
	RunE:  runUserDelete,
}

func init() {
	userCmd.AddCommand(userListCmd)
	userCmd.AddCommand(userBanCmd)
	userCmd.AddCommand(userUnbanCmd)
	userCmd.AddCommand(userDeleteCmd)
	rootCmd.AddCommand(userCmd)
}

func openUserDB() (*store.UserStore, func(), error) {
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

	users := store.NewUserStore(db)
	cleanup := func() { db.Close() }
	return users, cleanup, nil
}

func runUserList(cmd *cobra.Command, args []string) error {
	users, cleanup, err := openUserDB()
	if err != nil {
		return err
	}
	defer cleanup()

	list, err := users.ListUsers()
	if err != nil {
		return fmt.Errorf("failed to list users: %w", err)
	}

	if len(list) == 0 {
		fmt.Println("No users found.")
		return nil
	}

	fmt.Printf("%-66s %-8s %-12s %s\n", "PUBKEY", "BANNED", "LAST SEEN", "CREATED")
	for _, u := range list {
		bannedStr := "no"
		if u.Banned {
			bannedStr = "YES"
		}
		lastSeen := time.Unix(u.LastSeen, 0).Format("2006-01-02")
		created := time.Unix(u.Created, 0).Format("2006-01-02")
		fmt.Printf("%-66s %-8s %-12s %s\n", u.Pubkey, bannedStr, lastSeen, created)
	}
	return nil
}

func runUserBan(cmd *cobra.Command, args []string) error {
	users, cleanup, err := openUserDB()
	if err != nil {
		return err
	}
	defer cleanup()

	if err := users.BanUser(args[0]); err != nil {
		return fmt.Errorf("failed to ban user: %w", err)
	}

	fmt.Printf("User %s banned.\n", args[0])
	return nil
}

func runUserUnban(cmd *cobra.Command, args []string) error {
	users, cleanup, err := openUserDB()
	if err != nil {
		return err
	}
	defer cleanup()

	if err := users.UnbanUser(args[0]); err != nil {
		return fmt.Errorf("failed to unban user: %w", err)
	}

	fmt.Printf("User %s unbanned.\n", args[0])
	return nil
}

func runUserDelete(cmd *cobra.Command, args []string) error {
	users, cleanup, err := openUserDB()
	if err != nil {
		return err
	}
	defer cleanup()

	if err := users.DeleteUser(args[0]); err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	fmt.Printf("User %s and all associated data deleted.\n", args[0])
	return nil
}
