// pulse-psiphon — Psiphon tunnel client for Pulse messenger.
//
// Starts a Psiphon tunnel and exposes a local SOCKS5 proxy.
// Prints the SOCKS5 port to stdout on successful connection.
// Exits when stdin closes (parent process died).
//
// Build:
//   go build -ldflags="-s -w" -o ../../assets/bins/linux_x64/pulse-psiphon .
//
// Architecture:
//   Dart → SOCKS5 127.0.0.1:port → Psiphon tunnel → exit VPS → relay
//   GFW sees: Psiphon obfuscated protocol (OSSH/TLS-OSSH/FRONTED-MEEK)
//   GFW does NOT see: relay hostname, WebSocket traffic, message content
package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"

	clientlib "github.com/Psiphon-Labs/psiphon-tunnel-core/ClientLibrary/clientlib"
)

func main() {
	// Accept data directory as first argument so the caller (Dart) can pass
	// a platform-appropriate writable path (app support dir on Android/Linux).
	// Falls back to os.TempDir() for backward compatibility.
	dataDir := filepath.Join(os.TempDir(), "pulse-psiphon")
	if len(os.Args) >= 2 && os.Args[1] != "" {
		dataDir = os.Args[1]
	}
	if err := os.MkdirAll(dataDir, 0700); err != nil {
		fmt.Fprintf(os.Stderr, "[psiphon] data dir error: %v\n", err)
		os.Exit(1)
	}

	timeout := 120 // generous timeout for first bootstrap
	networkID := "WIFI"
	platform := "Linux_im.pulse.messenger"

	params := clientlib.Parameters{
		DataRootDirectory:             &dataDir,
		NetworkID:                     &networkID,
		ClientPlatform:                &platform,
		EstablishTunnelTimeoutSeconds: &timeout,
	}

	// Config JSON — uses Psiphon's public infrastructure.
	// PropagationChannelId/SponsorId: standard third-party embedding IDs.
	// RemoteServerListUrl: Psiphon's public S3-hosted server list.
	configJSON := []byte(`{
		"PropagationChannelId": "FFFFFFFFFFFFFFFF",
		"SponsorId":            "FFFFFFFFFFFFFFFF",
		"LocalSocksProxyPort":  0,
		"DisableLocalHTTPProxy": true,
		"RemoteServerListUrl": "https://s3.amazonaws.com//psiphon/web/mjr4-p23r-puwl/server_list_compressed",
		"RemoteServerListSignaturePublicKey": "MIICIDANBgkqhkiG9w0BAQEFAAOCAg0AMIICCAKCAgEAt7Ls+/39r+T6zNW7GiVpJfzq/xvL9SBH5rIFnk0RXYEYavax3WS6HOD35eTAqn8AniOwiH+DOkvgSKF2caqk/y1dfq47Pdymtwzp9ikpB1C5OfAysXzBiwVJlCdajBKvBZDerV1cMvRzCKvKwRmvDmHgphQQ7WfXIGbRbmmk6opMBh3roE42KcotLFtqp0RRwLtcBRNtCdsrVsjiI1Lqz/lH+T61sGjSjQ3CHMuZYSQJZo/KrvzgQXpkaCTdbObxHqb6/+i1qaVOfEsvjoiyzTxJADvSytVtcTjijhPEV6XskJVHE1Zgl+7rATr/pDQkw6DPCNBS1+Y6fy7GstZALQXwEDN/qhQI9kWkHijT8ns+i1vGg00Mk/6J75arLhqcodWsdeG/M/moWgqQAnlZAGVtJI1OgeF5fsPpXu4kctOfuZlGjVZXQNW34aOzm8r8S0eVZitPlbhcPiR4gT/aSMz/wd8lZlzZYsje/Jr8u/YtlwjjreZrGRmG8KMOzukV3lLmMppXFMvl4bxv6YFEmIuTsOhbLTwFgh7KYNjodLj/LsqRVfwz31PgWQFTEPICV7GCvgVlPRxnofqKSjgTWI4mxDhBpVcATvaoBl1L/6WLbFvBsoAUBItWwctO2xalKxF5szhGm8lccoc5MZr8kfE0uxMgsxz4er68iCID+rsCAQM=",
		"DisableRemoteServerListFetcher": false
	}`)

	fmt.Fprintf(os.Stderr, "[psiphon] starting tunnel (timeout %ds)...\n", timeout)

	tunnel, err := clientlib.StartTunnel(
		context.Background(),
		configJSON,
		"", // no embedded server entries — fetch from remote list
		params,
		nil, // no params delta
		func(notice clientlib.NoticeEvent) {
			// Log important notices to stderr
			switch notice.Type {
			case "Tunnels":
				count, _ := notice.Data["count"].(float64)
				fmt.Fprintf(os.Stderr, "[psiphon] tunnels: %d\n", int(count))
			case "EstablishTunnelTimeout":
				fmt.Fprintf(os.Stderr, "[psiphon] establishment timeout\n")
			case "Alert":
				msg, _ := notice.Data["message"].(string)
				fmt.Fprintf(os.Stderr, "[psiphon] alert: %s\n", msg)
			case "AvailableEgressRegions":
				fmt.Fprintf(os.Stderr, "[psiphon] egress regions available\n")
			}
		},
	)
	if err != nil {
		fmt.Fprintf(os.Stderr, "[psiphon] failed: %v\n", err)
		os.Exit(1)
	}

	// Print SOCKS5 port — Dart reads this to know where to connect.
	fmt.Println(tunnel.SOCKSProxyPort)
	fmt.Fprintf(os.Stderr, "[psiphon] SOCKS5 on 127.0.0.1:%d\n", tunnel.SOCKSProxyPort)

	// Stay alive until stdin closes (parent process died).
	io.Copy(io.Discard, os.Stdin)
	tunnel.Stop()
	fmt.Fprintf(os.Stderr, "[psiphon] stopped\n")
}
