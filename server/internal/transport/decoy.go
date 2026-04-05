package transport

import (
	"embed"
	"net/http"
	"os"

	"github.com/nicholasgasior/pulse-server/config"
)

//go:embed decoy_defaults/*
var decoyFS embed.FS

// DecoyHandler serves a fake nginx website for probe resistance.
// Any non-authenticated request sees a plausible web page instead of
// revealing the relay's true purpose.
type DecoyHandler struct {
	serverHeader string
	indexHTML     []byte
	notFoundHTML []byte
	favicon      []byte
	robotsTxt    []byte
}

// NewDecoyHandler creates a DecoyHandler using config overrides or embedded defaults.
func NewDecoyHandler(cfg config.DecoyConfig) *DecoyHandler {
	d := &DecoyHandler{
		serverHeader: cfg.ServerHeader,
	}
	if d.serverHeader == "" {
		d.serverHeader = "nginx/1.24.0"
	}

	d.indexHTML = loadOrEmbed(cfg.IndexHTML, "decoy_defaults/index.html")
	d.notFoundHTML = loadOrEmbed(cfg.NotFoundHTML, "decoy_defaults/404.html")
	d.favicon = loadOrEmbed(cfg.Favicon, "decoy_defaults/favicon.ico")
	d.robotsTxt, _ = decoyFS.ReadFile("decoy_defaults/robots.txt")

	return d
}

func loadOrEmbed(customPath, embedPath string) []byte {
	if customPath != "" {
		if data, err := os.ReadFile(customPath); err == nil {
			return data
		}
	}
	data, _ := decoyFS.ReadFile(embedPath)
	return data
}

// ServeHTTP handles all decoy routes.
func (d *DecoyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Server", d.serverHeader)

	switch r.URL.Path {
	case "/", "/index.html":
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusOK)
		w.Write(d.indexHTML)
	case "/favicon.ico":
		w.Header().Set("Content-Type", "image/x-icon")
		w.WriteHeader(http.StatusOK)
		w.Write(d.favicon)
	case "/robots.txt":
		w.Header().Set("Content-Type", "text/plain")
		w.WriteHeader(http.StatusOK)
		w.Write(d.robotsTxt)
	default:
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusNotFound)
		w.Write(d.notFoundHTML)
	}
}
