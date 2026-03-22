package main

import (
	"os"

	"github.com/nicholasgasior/pulse-server/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
}
