package transport

import (
	"embed"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"

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

// setNginxHeaders sets response headers mimicking nginx defaults.
func (d *DecoyHandler) setNginxHeaders(w http.ResponseWriter, contentType string, body []byte) {
	h := w.Header()
	h.Set("Server", d.serverHeader)
	h.Set("Content-Type", contentType)
	h.Set("Content-Length", strconv.Itoa(len(body)))
	h.Set("Connection", "keep-alive")
	// nginx uses HTTP-date format for Date (set by Go by default, but ETag/Last-Modified add realism)
	h.Set("Accept-Ranges", "bytes")
}

// ServeHTTP handles all decoy routes.
func (d *DecoyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// nginx rejects most methods on static content
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		d.setNginxHeaders(w, "text/html", d.notFoundHTML)
		w.Header().Set("Allow", "GET, HEAD")
		w.WriteHeader(http.StatusMethodNotAllowed)
		if r.Method != http.MethodHead {
			fmt.Fprintf(w, "<html>\r\n<head><title>405 Not Allowed</title></head>\r\n"+
				"<body>\r\n<center><h1>405 Not Allowed</h1></center>\r\n"+
				"<hr><center>%s</center>\r\n</body>\r\n</html>\r\n", d.serverHeader)
		}
		return
	}

	switch r.URL.Path {
	case "/", "/index.html":
		d.setNginxHeaders(w, "text/html", d.indexHTML)
		// Fake ETag — nginx generates these from mtime+size
		w.Header().Set("ETag", `"65a8f3c0-264"`)
		w.Header().Set("Last-Modified", "Thu, 18 Jan 2024 09:15:12 GMT")

		// Handle If-None-Match (browser cache) — nginx does this
		if r.Header.Get("If-None-Match") == `"65a8f3c0-264"` {
			w.WriteHeader(http.StatusNotModified)
			return
		}
		w.WriteHeader(http.StatusOK)
		if r.Method != http.MethodHead {
			w.Write(d.indexHTML)
		}

	case "/favicon.ico":
		d.setNginxHeaders(w, "image/x-icon", d.favicon)
		// Cache favicon aggressively like real nginx
		w.Header().Set("Cache-Control", "public, max-age=2592000")
		w.Header().Set("Expires", time.Now().Add(30*24*time.Hour).UTC().Format(http.TimeFormat))
		w.WriteHeader(http.StatusOK)
		if r.Method != http.MethodHead {
			w.Write(d.favicon)
		}

	case "/robots.txt":
		d.setNginxHeaders(w, "text/plain", d.robotsTxt)
		w.WriteHeader(http.StatusOK)
		if r.Method != http.MethodHead {
			w.Write(d.robotsTxt)
		}

	default:
		// nginx returns 404 with the standard error page for unknown paths
		body := d.notFoundHTML
		d.setNginxHeaders(w, "text/html", body)
		w.WriteHeader(http.StatusNotFound)
		if r.Method != http.MethodHead {
			w.Write(body)
		}
	}
}
