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
	Media      MediaConfig      `toml:"media"`
	Privacy    PrivacyConfig    `toml:"privacy"`
	Limits     LimitsConfig     `toml:"limits"`
	Federation FederationConfig `toml:"federation"`
	Decoy      DecoyConfig      `toml:"decoy"`
	Tunnel     TunnelConfig     `toml:"tunnel"`
}

type ServerConfig struct {
	Listen        string `toml:"listen"`
	DataDir       string `toml:"data_dir"`
	TLSMode       string `toml:"tls_mode"`
	TLSCert       string `toml:"tls_cert"`
	TLSKey        string `toml:"tls_key"`
	AutoTLSDomain string `toml:"auto_tls_domain"` // domain for Let's Encrypt (tls_mode = "auto")
}

type AuthConfig struct {
	Mode string `toml:"mode"`
}

type StorageConfig struct {
	MessageTTLHours   int    `toml:"message_ttl_hours"`
	MaxMessageBytes   int    `toml:"max_message_bytes"`
	MaxBackupBytes    int    `toml:"max_backup_bytes"`
	MaxFileBytes      int64  `toml:"max_file_bytes"`
	MaxStoragePerUser int64  `toml:"max_storage_per_user"`
	FileTTL           string `toml:"file_ttl"`
}

type TurnConfig struct {
	Enabled    bool   `toml:"enabled"`
	Port       int    `toml:"port"`
	Realm      string `toml:"realm"`
	PublicHost string `toml:"public_host"` // hostname/IP for TURN URIs (defaults to Realm)
}

type MediaConfig struct {
	Enabled          bool   `toml:"enabled"`
	Mode             string `toml:"mode"` // "stealth" (ICE-TCP) | "performance" (UDP) | "ws-relay" | "all"
	MaxRoomSize      int    `toml:"max_room_size"`
	LastNVideo       int    `toml:"last_n_video"`
	Simulcast        bool   `toml:"simulcast"`
	SpeakerDetect    bool   `toml:"speaker_detect"`
	SpeakerThreshold int    `toml:"speaker_threshold"` // dBFS threshold for "speaking"
}

type PrivacyConfig struct {
	AccessLog             bool   `toml:"access_log"`
	DeleteOnAck           bool   `toml:"delete_on_ack"`
	StoreClientIP         bool   `toml:"store_client_ip"`
	StripForwardedHeaders bool   `toml:"strip_forwarded_headers"`
	Preset                string `toml:"preset"` // "standard" | "private" | "paranoid" | "custom"
	Padding               bool   `toml:"padding"`
	PaddingMode           string `toml:"padding_mode"`     // "cbr" | "burst"
	PaddingRateKbps       int    `toml:"padding_rate_kbps"` // constant bitrate rate
	PaddingJitterPct      int    `toml:"padding_jitter_pct"`
	SealedSender          bool   `toml:"sealed_sender"`
	SealedCertCount       int    `toml:"sealed_cert_count"`
	SealedCertTTL         string `toml:"sealed_cert_ttl"`
	DeliveryJitterMs      int    `toml:"delivery_jitter_ms"`
	BatchDelivery         bool   `toml:"batch_delivery"`
	BatchIntervalMs       int    `toml:"batch_interval_ms"`
	Chaff                 bool   `toml:"chaff"`
	ChaffIntervalSec      int    `toml:"chaff_interval_sec"`
}

type LimitsConfig struct {
	MessagesPerMinute int `toml:"messages_per_minute"`
	SignalsPerMinute  int `toml:"signals_per_minute"`
	MaxConnections    int `toml:"max_connections"`
	MaxRooms          int `toml:"max_rooms"`
	PoWDifficulty     int `toml:"pow_difficulty"` // leading zero bits for PoW (0=disabled, 16=~100ms, 20=~1s)
}

type FederationConfig struct {
	Enabled bool   `toml:"enabled"`
	Mode    string `toml:"mode"` // "disabled" | "private" | "open"
	MaxHops int    `toml:"max_hops"`
}

type DecoyConfig struct {
	ServerHeader string `toml:"server_header"`
	IndexHTML    string `toml:"index_html"`
	Favicon      string `toml:"favicon"`
	NotFoundHTML string `toml:"not_found_html"`
}

type TunnelConfig struct {
	Enabled            bool     `toml:"enabled"`
	MaxTunnelsPerUser  int      `toml:"max_tunnels_per_user"`
	BandwidthLimitMbps int      `toml:"bandwidth_limit_mbps"`
	AllowedPorts       []int    `toml:"allowed_ports"`
	BlockedHosts       []string `toml:"blocked_hosts"`
	DNSProvider        string   `toml:"dns_provider"` // "doh" | "system"
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
			MessageTTLHours:   168,
			MaxMessageBytes:   536870912, // 512 MB
			MaxBackupBytes:    52428800,
			MaxFileBytes:      104857600,  // 100 MB
			MaxStoragePerUser: 1073741824, // 1 GB
			FileTTL:           "168h",
		},
		Turn: TurnConfig{
			Enabled: true,
			Port:    3478,
			Realm:   "pulse",
		},
		Media: MediaConfig{
			Enabled:          true,
			Mode:             "stealth",
			MaxRoomSize:      25,
			LastNVideo:       6,
			Simulcast:        true,
			SpeakerDetect:    true,
			SpeakerThreshold: -40,
		},
		Privacy: PrivacyConfig{
			AccessLog:             false,
			DeleteOnAck:           true,
			StoreClientIP:         false,
			StripForwardedHeaders: true,
			Preset:                "standard",
			PaddingMode:           "cbr",
			PaddingRateKbps:       32,
			PaddingJitterPct:      20,
			SealedCertCount:       50,
			SealedCertTTL:         "24h",
			BatchIntervalMs:       2000,
			ChaffIntervalSec:      300,
		},
		Limits: LimitsConfig{
			MessagesPerMinute: 60,
			SignalsPerMinute:  120,
			MaxConnections:    1000,
			MaxRooms:          100,
			PoWDifficulty:     16, // ~100ms to solve
		},
		Federation: FederationConfig{
			Enabled: false,
			Mode:    "disabled",
			MaxHops: 2,
		},
		Decoy: DecoyConfig{
			ServerHeader: "nginx/1.24.0",
		},
		Tunnel: TunnelConfig{
			Enabled:            false,
			MaxTunnelsPerUser:  32,
			BandwidthLimitMbps: 100,
			AllowedPorts:       []int{80, 443},
			DNSProvider:        "doh",
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
