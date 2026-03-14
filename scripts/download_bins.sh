#!/usr/bin/env bash
# Download and verify Tor + Snowflake binaries for bundling.
# Run once before building: bash scripts/download_bins.sh
#
# Sources:
#   tor:              https://dist.torproject.org/ (from Tor Browser bundle)
#   snowflake-client: https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake
#
# After running this script, build the Go uTLS proxy:
#   cd tools/utls-proxy && go build -ldflags="-s -w" -o ../../assets/bins/linux_x64/pulse-utls-proxy .

set -e
BINS_DIR="$(dirname "$0")/../assets/bins"

# ── Versions ────────────────────────────────────────────────────────────────
TOR_VERSION="13.5.6"          # Tor Browser version (contains tor binary)
SNOWFLAKE_VERSION="2.10.1"    # snowflake-client release tag

# ── Helpers ─────────────────────────────────────────────────────────────────
download() {
  local url="$1" dest="$2"
  echo "  → $url"
  curl -fsSL "$url" -o "$dest"
}

extract_tor_linux() {
  local arch="$1"   # x86_64 or aarch64
  local out_dir="$2"
  local tb_arch
  tb_arch=$([ "$arch" = "x86_64" ] && echo "linux64" || echo "linux-aarch64")

  local tmp=$(mktemp -d)
  echo "[tor] Downloading Tor Browser $TOR_VERSION ($tb_arch)..."
  download \
    "https://dist.torproject.org/torbrowser/${TOR_VERSION}/tor-browser-${tb_arch}-${TOR_VERSION}.tar.xz" \
    "$tmp/tb.tar.xz"

  tar -xJf "$tmp/tb.tar.xz" -C "$tmp" \
    --wildcards "*/Browser/TorBrowser/Tor/tor" \
    --strip-components=4
  mv "$tmp/tor" "$out_dir/tor"
  chmod +x "$out_dir/tor"
  rm -rf "$tmp"
  echo "[tor] ✓ $out_dir/tor"
}

download_snowflake_linux() {
  local arch="$1"   # amd64 or arm64
  local out_dir="$2"
  local tmp=$(mktemp -d)

  echo "[snowflake] Downloading snowflake-client $SNOWFLAKE_VERSION ($arch)..."
  download \
    "https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/-/releases/${SNOWFLAKE_VERSION}/downloads/snowflake-client-linux-${arch}" \
    "$out_dir/snowflake-client"
  chmod +x "$out_dir/snowflake-client"
  echo "[snowflake] ✓ $out_dir/snowflake-client"
}

# ── Linux x64 ───────────────────────────────────────────────────────────────
echo ""
echo "=== Linux x64 ==="
extract_tor_linux      "x86_64" "$BINS_DIR/linux_x64"
download_snowflake_linux "amd64" "$BINS_DIR/linux_x64"

# ── Linux arm64 ─────────────────────────────────────────────────────────────
echo ""
echo "=== Linux arm64 ==="
extract_tor_linux        "aarch64" "$BINS_DIR/linux_arm64"
download_snowflake_linux "arm64"   "$BINS_DIR/linux_arm64"

echo ""
echo "Done. Now build the uTLS proxy:"
echo "  cd tools/utls-proxy"
echo "  go build -ldflags='-s -w' -o ../../assets/bins/linux_x64/pulse-utls-proxy ."
echo "  GOARCH=arm64 go build -ldflags='-s -w' -o ../../assets/bins/linux_arm64/pulse-utls-proxy ."
