#!/usr/bin/env bash
set -euo pipefail

# ─── Pulse Relay Server — VPS Setup Script ─────────────────────────────
# Run on a fresh Debian/Ubuntu VPS:
#   curl -sSL https://your-host/setup.sh | bash
#   — or —
#   git clone … && cd server/deploy && sudo bash setup.sh

DEPLOY_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/opt/pulse"
SERVICE_NAME="pulse"

# ─── Colors ─────────────────────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[*]${NC} $*"; }
ok()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
die()   { echo -e "${RED}[x]${NC} $*" >&2; exit 1; }

# ─── Root check ─────────────────────────────────────────────────────────

[[ $EUID -eq 0 ]] || die "Run this script as root (sudo bash setup.sh)"

# ─── Interactive prompts ────────────────────────────────────────────────

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Pulse Relay Server — Setup         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# Domain
read -rp "Domain name (e.g. pulse.example.com): " DOMAIN
[[ -n "$DOMAIN" ]] || die "Domain is required"

# Auth mode
echo ""
echo "  1) open   — anyone can register"
echo "  2) invite — require invite codes (default)"
read -rp "Auth mode [1/2]: " auth_choice
case "${auth_choice:-2}" in
    1) AUTH_MODE="open" ;;
    *) AUTH_MODE="invite" ;;
esac

# Deploy mode
echo ""
echo "  1) stealth — nginx reverse proxy (real nginx TLS fingerprint, censorship resistant)"
echo "  2) simple  — Go handles TLS directly (Let's Encrypt auto)"
read -rp "Deploy mode [1/2]: " deploy_choice
case "${deploy_choice:-1}" in
    2) DEPLOY_MODE="simple" ;;
    *) DEPLOY_MODE="stealth" ;;
esac

# Build or pre-built
BUILD_FROM_SOURCE="n"
if [[ -d "$DEPLOY_DIR/../cmd" ]]; then
    echo ""
    read -rp "Build from source? (y/N — N uses pre-built binary): " BUILD_FROM_SOURCE
    BUILD_FROM_SOURCE="${BUILD_FROM_SOURCE:-n}"
fi

echo ""
info "Domain:      $DOMAIN"
info "Auth mode:   $AUTH_MODE"
info "Deploy mode: $DEPLOY_MODE"
info "Build:       $([ "${BUILD_FROM_SOURCE,,}" = "y" ] && echo "from source" || echo "pre-built")"
echo ""
read -rp "Continue? (Y/n): " confirm
[[ "${confirm:-y}" =~ ^[Yy]$ ]] || exit 0

# ─── Build / copy binary ───────────────────────────────────────────────

info "Preparing binary..."

mkdir -p "$INSTALL_DIR/data"

if [[ "${BUILD_FROM_SOURCE,,}" = "y" ]]; then
    # Check for Go
    if ! command -v go &>/dev/null; then
        info "Installing Go..."
        apt-get update -qq && apt-get install -y -qq golang-go >/dev/null 2>&1 \
            || die "Failed to install Go. Install it manually and re-run."
    fi
    info "Building from source..."
    cd "$DEPLOY_DIR/.."
    go build -ldflags="-s -w" -o "$INSTALL_DIR/pulse-server" .
    ok "Built $INSTALL_DIR/pulse-server"
elif [[ -f "$DEPLOY_DIR/pulse-server" ]]; then
    cp "$DEPLOY_DIR/pulse-server" "$INSTALL_DIR/pulse-server"
    ok "Copied pre-built binary"
elif [[ -f "$DEPLOY_DIR/../pulse-server" ]]; then
    cp "$DEPLOY_DIR/../pulse-server" "$INSTALL_DIR/pulse-server"
    ok "Copied pre-built binary"
elif [[ -f "$INSTALL_DIR/pulse-server" ]]; then
    ok "Using existing binary at $INSTALL_DIR/pulse-server"
else
    die "No binary found. Place pulse-server in server/ or run with build-from-source."
fi

chmod +x "$INSTALL_DIR/pulse-server"

# ─── Generate config ───────────────────────────────────────────────────

info "Generating config.toml..."

if [[ "$DEPLOY_MODE" = "stealth" ]]; then
    TLS_MODE="none"
    LISTEN="127.0.0.1:8080"
else
    TLS_MODE="auto"
    LISTEN="0.0.0.0:443"
fi

sed -e "s/__DOMAIN__/${DOMAIN}/g" \
    -e "s/__AUTH_MODE__/${AUTH_MODE}/g" \
    -e "s/__TLS_MODE__/${TLS_MODE}/g" \
    -e "s/__LISTEN__/${LISTEN}/g" \
    "$DEPLOY_DIR/config.template.toml" > "$INSTALL_DIR/config.toml"

ok "Config written to $INSTALL_DIR/config.toml"

# ─── Create pulse user ─────────────────────────────────────────────────

if ! id -u pulse &>/dev/null; then
    useradd --system --no-create-home --shell /usr/sbin/nologin pulse
    ok "Created system user 'pulse'"
fi

chown -R pulse:pulse "$INSTALL_DIR"

# ─── Stealth mode: nginx + certbot ────────────────────────────────────

if [[ "$DEPLOY_MODE" = "stealth" ]]; then
    info "Installing nginx + certbot..."
    apt-get update -qq || warn "Some repos failed (non-fatal, continuing)"
    apt-get install -y -qq nginx certbot python3-certbot-nginx >/dev/null 2>&1
    ok "nginx + certbot installed"

    # Deploy nginx config
    sed "s/__DOMAIN__/${DOMAIN}/g" \
        "$DEPLOY_DIR/nginx-stealth.conf" > "/etc/nginx/sites-available/pulse.conf"

    ln -sf /etc/nginx/sites-available/pulse.conf /etc/nginx/sites-enabled/pulse.conf
    rm -f /etc/nginx/sites-enabled/default

    # Test config (without certs — will fail on ssl, that's OK before certbot)
    info "Obtaining Let's Encrypt certificate..."
    # Stop nginx to free port 80 for standalone mode, then use nginx plugin
    systemctl stop nginx 2>/dev/null || true
    certbot certonly --standalone -d "$DOMAIN" --non-interactive --agree-tos \
        --register-unsafely-without-email \
        || die "certbot failed. Make sure DNS points to this server and port 80 is open."

    ok "TLS certificate obtained"

    # Now test and start nginx
    nginx -t || die "nginx config test failed"
    systemctl enable nginx
    systemctl restart nginx
    ok "nginx running"

    # Auto-renew hook to reload nginx
    cat > /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh <<'HOOK'
#!/bin/bash
systemctl reload nginx
HOOK
    chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
fi

# ─── Simple mode: open port 80 for ACME ───────────────────────────────

if [[ "$DEPLOY_MODE" = "simple" ]]; then
    info "Simple mode: Go will handle Let's Encrypt on port 443"
    info "Port 80 must be open for ACME HTTP-01 challenge"
fi

# ─── Firewall ──────────────────────────────────────────────────────────

if command -v ufw &>/dev/null; then
    info "Configuring firewall (ufw)..."
    ufw allow 22/tcp   comment "SSH"       >/dev/null 2>&1
    ufw allow 80/tcp   comment "HTTP/ACME" >/dev/null 2>&1
    ufw allow 443/tcp  comment "HTTPS"     >/dev/null 2>&1
    ufw allow 3478/udp comment "TURN UDP"  >/dev/null 2>&1
    ufw allow 3478/tcp comment "TURN TCP"  >/dev/null 2>&1
    ufw --force enable >/dev/null 2>&1
    ok "Firewall configured"
else
    warn "ufw not found — make sure ports 80, 443, 3478 (tcp+udp) are open"
fi

# ─── Systemd service ──────────────────────────────────────────────────

info "Installing systemd service..."
cp "$DEPLOY_DIR/pulse.service" /etc/systemd/system/pulse.service
systemctl daemon-reload
systemctl enable pulse
systemctl restart pulse

# Wait a moment and check
sleep 2
if systemctl is-active --quiet pulse; then
    ok "pulse service is running"
else
    warn "pulse service failed to start — check: journalctl -u pulse"
fi

# ─── Done ──────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Setup complete!                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  Domain:     ${CYAN}${DOMAIN}${NC}"
echo -e "  Config:     ${INSTALL_DIR}/config.toml"
echo -e "  Data:       ${INSTALL_DIR}/data/"
echo -e "  Logs:       journalctl -u pulse -f"
echo ""
echo -e "  Connection: ${GREEN}wss://${DOMAIN}/ws${NC}"
echo ""
if [[ "$DEPLOY_MODE" = "stealth" ]]; then
    echo -e "  nginx:      systemctl status nginx"
fi
echo -e "  Service:    systemctl status pulse"
echo ""
