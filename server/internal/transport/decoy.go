package transport

import (
	crand "crypto/rand"
	"embed"
	"encoding/hex"
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
	// indexETag / indexLastMod are generated once at startup so every
	// deployed server has its own value — a censor that scrapes two distinct
	// Pulse relays can't recognise them by identical static ETags.
	indexETag    string
	indexLastMod string
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

	// Randomise ETag + Last-Modified per-startup. Real nginx derives ETag
	// from mtime+size of the file on disk, so values naturally differ
	// between servers. Hardcoded values here previously looked identical
	// across every Pulse deployment — a stable cross-server fingerprint.
	etagBytes := make([]byte, 4)
	_, _ = crand.Read(etagBytes)
	sizeBytes := make([]byte, 2)
	_, _ = crand.Read(sizeBytes)
	d.indexETag = fmt.Sprintf(`"%s-%x"`, hex.EncodeToString(etagBytes), sizeBytes)
	// Pick a Last-Modified time within the last 6 months, minute granularity
	// like a real file.
	offset := make([]byte, 2)
	_, _ = crand.Read(offset)
	minutesAgo := int64(offset[0])<<8 | int64(offset[1]) // 0..65535 minutes ≈ 45 days
	d.indexLastMod = time.Now().Add(-time.Duration(minutesAgo) * time.Minute).UTC().Format(http.TimeFormat)

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
		// Per-startup randomised ETag + Last-Modified. See NewDecoyHandler.
		w.Header().Set("ETag", d.indexETag)
		w.Header().Set("Last-Modified", d.indexLastMod)

		// Handle If-None-Match (browser cache) — nginx does this
		if r.Header.Get("If-None-Match") == d.indexETag {
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
