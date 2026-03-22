package config

import (
	"os"

	"github.com/BurntSushi/toml"
)

type Config struct {
	Server     ServerConfig     `toml:"server"`
	Auth       AuthConfig       `toml:"auth"`
	Storage    StorageConfig    `toml:"storage"`
	Turn       TurnConfig       `toml:"turn"`
	Privacy    PrivacyConfig    `toml:"privacy"`
	Limits     LimitsConfig     `toml:"limits"`
	Federation FederationConfig `toml:"federation"`
}

type ServerConfig struct {
	Listen  string `toml:"listen"`
	DataDir string `toml:"data_dir"`
	TLSMode string `toml:"tls_mode"`
	TLSCert string `toml:"tls_cert"`
	TLSKey  string `toml:"tls_key"`
}

type AuthConfig struct {
	Mode string `toml:"mode"`
}

type StorageConfig struct {
	MessageTTLHours int `toml:"message_ttl_hours"`
	MaxMessageBytes int `toml:"max_message_bytes"`
	MaxBackupBytes  int `toml:"max_backup_bytes"`
}

type TurnConfig struct {
	Enabled bool   `toml:"enabled"`
	Port    int    `toml:"port"`
	Realm   string `toml:"realm"`
}

type PrivacyConfig struct {
	AccessLog   bool `toml:"access_log"`
	DeleteOnAck bool `toml:"delete_on_ack"`
}

type LimitsConfig struct {
	MessagesPerMinute int `toml:"messages_per_minute"`
	MaxConnections    int `toml:"max_connections"`
}

type FederationConfig struct {
	Enabled bool `toml:"enabled"`
}

func DefaultConfig() *Config {
	return &Config{
		Server: ServerConfig{
			Listen:  "0.0.0.0:8443",
			DataDir: "/data",
			TLSMode: "self-signed",
		},
		Auth: AuthConfig{
			Mode: "invite",
		},
		Storage: StorageConfig{
			MessageTTLHours: 168,
			MaxMessageBytes: 524288,
			MaxBackupBytes:  52428800,
		},
		Turn: TurnConfig{
			Enabled: true,
			Port:    3478,
			Realm:   "pulse",
		},
		Privacy: PrivacyConfig{
			AccessLog:   false,
			DeleteOnAck: true,
		},
		Limits: LimitsConfig{
			MessagesPerMinute: 30,
			MaxConnections:    1000,
		},
		Federation: FederationConfig{
			Enabled: false,
		},
	}
}

func Load(path string) (*Config, error) {
	cfg := DefaultConfig()

	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return cfg, nil
		}
		return nil, err
	}

	if err := toml.Unmarshal(data, cfg); err != nil {
		return nil, err
	}

	return cfg, nil
}
