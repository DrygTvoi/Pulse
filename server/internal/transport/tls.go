package transport

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"math/big"
	"net"
	"path/filepath"
	"time"

	"golang.org/x/crypto/acme/autocert"
)

// GenerateSelfSignedTLS creates an in-memory self-signed TLS certificate
// for development and testing. Returns the TLS config and the SHA-256 fingerprint hex.
func GenerateSelfSignedTLS() (*tls.Config, string, error) {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, "", fmt.Errorf("failed to generate private key: %w", err)
	}

	serialNumber, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		return nil, "", fmt.Errorf("failed to generate serial number: %w", err)
	}

	// Collect all local IPs for SAN (so self-signed cert works with IP-based URLs)
	ipAddresses := []net.IP{net.ParseIP("127.0.0.1"), net.ParseIP("::1")}
	if ifaces, err := net.Interfaces(); err == nil {
		for _, iface := range ifaces {
			if addrs, err := iface.Addrs(); err == nil {
				for _, addr := range addrs {
					if ipnet, ok := addr.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
						ipAddresses = append(ipAddresses, ipnet.IP)
					}
				}
			}
		}
	}

	template := x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			Organization: []string{"Pulse Messenger"},
			CommonName:   "pulse-server",
		},
		DNSNames:              []string{"localhost", "pulse-server"},
		IPAddresses:           ipAddresses,
		NotBefore:             time.Now(),
		NotAfter:              time.Now().Add(365 * 24 * time.Hour),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
	}

	certDER, err := x509.CreateCertificate(rand.Reader, &template, &template, &key.PublicKey, key)
	if err != nil {
		return nil, "", fmt.Errorf("failed to create certificate: %w", err)
	}

	// Compute SHA-256 fingerprint of the DER-encoded certificate
	fpRaw := sha256.Sum256(certDER)
	fingerprint := hex.EncodeToString(fpRaw[:])

	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})
	keyDER, err := x509.MarshalECPrivateKey(key)
	if err != nil {
		return nil, "", fmt.Errorf("failed to marshal private key: %w", err)
	}
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "EC PRIVATE KEY", Bytes: keyDER})

	cert, err := tls.X509KeyPair(certPEM, keyPEM)
	if err != nil {
		return nil, "", fmt.Errorf("failed to create key pair: %w", err)
	}

	return &tls.Config{
		Certificates: []tls.Certificate{cert},
		MinVersion:   tls.VersionTLS12,
		NextProtos:   []string{"http/1.1"},
	}, fingerprint, nil
}

// CertFingerprint computes the SHA-256 fingerprint of a TLS config's first certificate.
func CertFingerprint(tlsCfg *tls.Config) string {
	if len(tlsCfg.Certificates) == 0 || len(tlsCfg.Certificates[0].Certificate) == 0 {
		return ""
	}
	fpRaw := sha256.Sum256(tlsCfg.Certificates[0].Certificate[0])
	return hex.EncodeToString(fpRaw[:])
}

// LoadTLS loads TLS certificates from the specified file paths.
func LoadTLS(certPath, keyPath string) (*tls.Config, error) {
	if certPath == "" || keyPath == "" {
		return nil, fmt.Errorf("tls_cert and tls_key paths must be specified for manual TLS mode")
	}

	cert, err := tls.LoadX509KeyPair(certPath, keyPath)
	if err != nil {
		return nil, fmt.Errorf("failed to load TLS certificates: %w", err)
	}

	return &tls.Config{
		Certificates: []tls.Certificate{cert},
		MinVersion:   tls.VersionTLS12,
		NextProtos:   []string{"http/1.1"},
	}, nil
}

// AutoTLS creates a TLS config using Let's Encrypt (ACME) with automatic certificate management.
// dataDir is used to cache certificates. domain is the FQDN to obtain a certificate for.
func AutoTLS(domain, dataDir string) (*tls.Config, *autocert.Manager, error) {
	if domain == "" {
		return nil, nil, fmt.Errorf("auto_tls_domain must be set for tls_mode = \"auto\"")
	}

	cacheDir := filepath.Join(dataDir, "autocert")

	m := &autocert.Manager{
		Prompt:     autocert.AcceptTOS,
		HostPolicy: autocert.HostWhitelist(domain),
		Cache:      autocert.DirCache(cacheDir),
	}

	tlsCfg := m.TLSConfig()
	tlsCfg.MinVersion = tls.VersionTLS12
	// Keep http/1.1 + acme-tls/1; no h2 (simplifies mux)
	tlsCfg.NextProtos = []string{"http/1.1", "acme-tls/1"}

	// Wrap GetCertificate: TURNS clients (libwebrtc) may omit SNI,
	// causing autocert to reject the handshake. Default to our domain.
	origGetCert := tlsCfg.GetCertificate
	tlsCfg.GetCertificate = func(hello *tls.ClientHelloInfo) (*tls.Certificate, error) {
		if hello.ServerName == "" {
			hello.ServerName = domain
		}
		return origGetCert(hello)
	}

	return tlsCfg, m, nil
}
