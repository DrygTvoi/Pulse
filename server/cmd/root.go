package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	cfgFile string
	dataDir string
)

var rootCmd = &cobra.Command{
	Use:   "pulse-server",
	Short: "Pulse Messenger relay server",
	Long:  "Pulse is a transport-agnostic E2EE messenger relay server.",
}

func init() {
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "config.toml", "path to config file")
	rootCmd.PersistentFlags().StringVar(&dataDir, "data-dir", "/data", "path to data directory")
}

func Execute() error {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		return err
	}
	return nil
}
