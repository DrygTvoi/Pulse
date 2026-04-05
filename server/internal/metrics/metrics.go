package metrics

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync/atomic"
	"time"
)

// Collector tracks server metrics.
type Collector struct {
	startTime         time.Time
	connectionsTotal  atomic.Int64
	connectionsActive atomic.Int64
	messagesSent      atomic.Int64
	messagesStored    atomic.Int64
	signalsSent       atomic.Int64
	bytesIn           atomic.Int64
	bytesOut          atomic.Int64
	roomsActive       atomic.Int64
	roomsTotal        atomic.Int64
	tunnelsActive     atomic.Int64
	tunnelsTotal      atomic.Int64
	authFailures      atomic.Int64
	uploadBytes       atomic.Int64
	downloadBytes     atomic.Int64
	fedEnvelopes      atomic.Int64
}

// NewCollector creates a new metrics collector.
func NewCollector() *Collector {
	return &Collector{
		startTime: time.Now(),
	}
}

// --- Increment methods ---

func (c *Collector) IncConnections()    { c.connectionsTotal.Add(1); c.connectionsActive.Add(1) }
func (c *Collector) DecConnections()    { c.connectionsActive.Add(-1) }
func (c *Collector) IncMessagesSent()   { c.messagesSent.Add(1) }
func (c *Collector) IncMessagesStored() { c.messagesStored.Add(1) }
func (c *Collector) IncSignals()        { c.signalsSent.Add(1) }
func (c *Collector) AddBytesIn(n int64) { c.bytesIn.Add(n) }
func (c *Collector) AddBytesOut(n int64) { c.bytesOut.Add(n) }
func (c *Collector) IncRooms()          { c.roomsActive.Add(1); c.roomsTotal.Add(1) }
func (c *Collector) DecRooms()          { c.roomsActive.Add(-1) }
func (c *Collector) IncTunnels()        { c.tunnelsActive.Add(1); c.tunnelsTotal.Add(1) }
func (c *Collector) DecTunnels()        { c.tunnelsActive.Add(-1) }
func (c *Collector) IncAuthFailures()   { c.authFailures.Add(1) }
func (c *Collector) AddUploadBytes(n int64) { c.uploadBytes.Add(n) }
func (c *Collector) AddDownloadBytes(n int64) { c.downloadBytes.Add(n) }
func (c *Collector) IncFedEnvelopes()   { c.fedEnvelopes.Add(1) }

// Snapshot returns a JSON-serializable snapshot of all metrics.
type Snapshot struct {
	UptimeSeconds     int64 `json:"uptime_seconds"`
	ConnectionsTotal  int64 `json:"connections_total"`
	ConnectionsActive int64 `json:"connections_active"`
	MessagesSent      int64 `json:"messages_sent"`
	MessagesStored    int64 `json:"messages_stored"`
	SignalsSent       int64 `json:"signals_sent"`
	BytesIn           int64 `json:"bytes_in"`
	BytesOut          int64 `json:"bytes_out"`
	RoomsActive       int64 `json:"rooms_active"`
	RoomsTotal        int64 `json:"rooms_total"`
	TunnelsActive     int64 `json:"tunnels_active"`
	TunnelsTotal      int64 `json:"tunnels_total"`
	AuthFailures      int64 `json:"auth_failures"`
	UploadBytes       int64 `json:"upload_bytes"`
	DownloadBytes     int64 `json:"download_bytes"`
	FedEnvelopes      int64 `json:"fed_envelopes"`
}

// GetSnapshot returns current metrics.
func (c *Collector) GetSnapshot() Snapshot {
	return Snapshot{
		UptimeSeconds:     int64(time.Since(c.startTime).Seconds()),
		ConnectionsTotal:  c.connectionsTotal.Load(),
		ConnectionsActive: c.connectionsActive.Load(),
		MessagesSent:      c.messagesSent.Load(),
		MessagesStored:    c.messagesStored.Load(),
		SignalsSent:       c.signalsSent.Load(),
		BytesIn:           c.bytesIn.Load(),
		BytesOut:          c.bytesOut.Load(),
		RoomsActive:       c.roomsActive.Load(),
		RoomsTotal:        c.roomsTotal.Load(),
		TunnelsActive:     c.tunnelsActive.Load(),
		TunnelsTotal:      c.tunnelsTotal.Load(),
		AuthFailures:      c.authFailures.Load(),
		UploadBytes:       c.uploadBytes.Load(),
		DownloadBytes:     c.downloadBytes.Load(),
		FedEnvelopes:      c.fedEnvelopes.Load(),
	}
}

// PrometheusHandler returns an HTTP handler that exports metrics in Prometheus format.
func (c *Collector) PrometheusHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		s := c.GetSnapshot()
		w.Header().Set("Content-Type", "text/plain; version=0.0.4")
		fmt.Fprintf(w, "# HELP pulse_uptime_seconds Server uptime in seconds\n")
		fmt.Fprintf(w, "# TYPE pulse_uptime_seconds gauge\n")
		fmt.Fprintf(w, "pulse_uptime_seconds %d\n", s.UptimeSeconds)
		fmt.Fprintf(w, "# HELP pulse_connections_total Total connections since start\n")
		fmt.Fprintf(w, "# TYPE pulse_connections_total counter\n")
		fmt.Fprintf(w, "pulse_connections_total %d\n", s.ConnectionsTotal)
		fmt.Fprintf(w, "# HELP pulse_connections_active Current active connections\n")
		fmt.Fprintf(w, "# TYPE pulse_connections_active gauge\n")
		fmt.Fprintf(w, "pulse_connections_active %d\n", s.ConnectionsActive)
		fmt.Fprintf(w, "# HELP pulse_messages_sent Total messages sent\n")
		fmt.Fprintf(w, "# TYPE pulse_messages_sent counter\n")
		fmt.Fprintf(w, "pulse_messages_sent %d\n", s.MessagesSent)
		fmt.Fprintf(w, "# HELP pulse_messages_stored Total messages stored for offline\n")
		fmt.Fprintf(w, "# TYPE pulse_messages_stored counter\n")
		fmt.Fprintf(w, "pulse_messages_stored %d\n", s.MessagesStored)
		fmt.Fprintf(w, "# HELP pulse_signals_sent Total signals sent\n")
		fmt.Fprintf(w, "# TYPE pulse_signals_sent counter\n")
		fmt.Fprintf(w, "pulse_signals_sent %d\n", s.SignalsSent)
		fmt.Fprintf(w, "# HELP pulse_bytes_in Total bytes received\n")
		fmt.Fprintf(w, "# TYPE pulse_bytes_in counter\n")
		fmt.Fprintf(w, "pulse_bytes_in %d\n", s.BytesIn)
		fmt.Fprintf(w, "# HELP pulse_bytes_out Total bytes sent\n")
		fmt.Fprintf(w, "# TYPE pulse_bytes_out counter\n")
		fmt.Fprintf(w, "pulse_bytes_out %d\n", s.BytesOut)
		fmt.Fprintf(w, "# HELP pulse_rooms_active Current active SFU rooms\n")
		fmt.Fprintf(w, "# TYPE pulse_rooms_active gauge\n")
		fmt.Fprintf(w, "pulse_rooms_active %d\n", s.RoomsActive)
		fmt.Fprintf(w, "# HELP pulse_tunnels_active Current active tunnels\n")
		fmt.Fprintf(w, "# TYPE pulse_tunnels_active gauge\n")
		fmt.Fprintf(w, "pulse_tunnels_active %d\n", s.TunnelsActive)
		fmt.Fprintf(w, "# HELP pulse_auth_failures Total auth failures\n")
		fmt.Fprintf(w, "# TYPE pulse_auth_failures counter\n")
		fmt.Fprintf(w, "pulse_auth_failures %d\n", s.AuthFailures)
		fmt.Fprintf(w, "# HELP pulse_fed_envelopes Total federation envelopes\n")
		fmt.Fprintf(w, "# TYPE pulse_fed_envelopes counter\n")
		fmt.Fprintf(w, "pulse_fed_envelopes %d\n", s.FedEnvelopes)
	}
}

// JSONHandler returns an HTTP handler that exports metrics as JSON.
func (c *Collector) JSONHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(c.GetSnapshot())
	}
}
