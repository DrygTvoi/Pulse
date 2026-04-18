# Pulse Relay Server — deploy kit

Everything needed to stand up a production Pulse relay. Two paths:

- **Scripted VPS install** — run `setup.sh` on a fresh Debian/Ubuntu root.
- **Docker Compose** — use the bundled `Dockerfile` + `docker-compose.yml`.

---

## Files

| file | purpose |
|---|---|
| `pulse-server` | Server binary (rebuilt from the current tree; non-stripped dev builds can be dropped in as-is) |
| `config.template.toml` | Placeholders (`__DOMAIN__`, `__AUTH_MODE__`, `__TLS_MODE__`, `__LISTEN__`) filled by `setup.sh` |
| `config.example.toml` | Full reference config with every tunable documented. Copy to `config.toml` for manual setups. |
| `nginx-stealth.conf` | nginx reverse-proxy profile that terminates real TLS on :443 and forwards to the Go server on 127.0.0.1:8080. Gives you real nginx JA3S. |
| `pulse.service` | systemd unit. Runs as user `pulse`, ambient `CAP_NET_BIND_SERVICE`, ReadWrite only on `/opt/pulse/data`. |
| `Dockerfile` | Multi-stage build; non-root user; HEALTHCHECK; CAP_NET_BIND_SERVICE for 80/443. |
| `docker-compose.yml` | Docker Compose service definition (443, 80, 3478 exposed; 1G memory). |
| `setup.sh` | Interactive installer: picks auth mode, deploy mode (stealth vs simple), installs, starts systemd unit. |

---

## Scripted install (recommended)

```bash
git clone https://github.com/<you>/pulse.git
cd pulse/server/deploy
sudo bash setup.sh
```

You'll be asked for:
- Domain (for Let's Encrypt / nginx)
- Auth mode (`open` = anyone can self-register; `invite` = `pulse-server invite create`)
- Deploy mode:
  - `stealth` — nginx in front, real JA3S, strongest anti-DPI
  - `simple` — Go handles TLS, self-cert persisted, builtin nginx decoy on unknown paths

The script:

1. Creates user `pulse`, installs binary to `/opt/pulse/pulse-server`
2. Writes `/opt/pulse/config.toml` from the template
3. In stealth mode: installs nginx, certbot, issues Let's Encrypt cert, drops `nginx-stealth.conf` into `/etc/nginx/sites-available/pulse`
4. Installs & enables `pulse.service`
5. Prints the federation pubkey to log on first start

---

## Docker Compose — two variants

### `docker-compose.yml` — Go handles TLS

Simplest; the Go server itself terminates TLS on :443 (self-signed or
Let's Encrypt via ACME). nginx is not involved.

```bash
cp config.example.toml config.toml
# edit listen=, tls_mode=, auth.mode, federation.enabled as needed
docker compose up -d
```

Ports exposed: 443 (WSS + decoy), 80 (ACME HTTP-01), 3478 (TURN UDP+TCP).

### `docker-compose.stealth.yml` — nginx + pulse + certbot

Full stealth topology: real nginx (JA3S = vanilla nginx) in front,
pulse speaks plaintext on an internal docker network, certbot issues
and renews Let's Encrypt certs automatically. Recommended for public
deployments behind DPI.

```bash
# 1. Point DOMAIN's DNS at this host.
# 2. Prepare config and nginx snippet:
cp config.example.toml config.toml
# → edit config.toml:
#      [server] tls_mode = "none"
#      [server] listen   = "0.0.0.0:8080"
#      [auth]   mode     = "open" | "invite"
cp nginx/pulse.conf.template nginx/pulse.conf
sed -i "s/__DOMAIN__/pulse.example.com/g" nginx/pulse.conf

# 3. Launch (CERTBOT_EMAIL is required by Let's Encrypt):
CERTBOT_EMAIL=you@example.com \
  docker compose -f docker-compose.stealth.yml up -d
```

What you get:
- `:80` and `:443` published by the **nginx** container
- `pulse` container reachable only via the internal `pulse-net`
- `server_master.key`, `pulse.db`, `self_signed.*`, `backups/` persist in the `pulse-data` volume
- Let's Encrypt cert + renewal automation in the `nginx-letsencrypt` volume
- Decoy pages served by Go still work — nginx forwards every unmatched path to `pulse_backend` so `/admin`, `/wp-login.php` etc. return the nginx-flavoured 404 from the Go decoy handler

⚠️ This topology exposes HTTPS/WSS on :443 only. nginx doesn't speak
STUN, so **TURN-on-443** isn't available here. UDP TURN on :3478 is
commented out at the bottom of the compose file — uncomment if you
need classic STUN/TURN allocations (host network mode required, since
STUN doesn't traverse NAT).

### `docker-compose.mux.yml` — HAProxy + nginx + pulse (HTTPS+TURN both on 443)

If you need **both** nginx-identical JA3S **and** TURN-over-TCP-443
(most useful for clients behind GFW / networks that block UDP), run
the HAProxy-fronted stack. HAProxy listens on :443 and sniffs the
first few bytes:

- TLS handshake (`0x16 0x03 ...`) → nginx:8443 (which proxies to
  pulse:8080 over the internal docker network). Real nginx JA3S.
- STUN / TURN packets → pulse:3478 (Go handles STUN muxing natively)

```bash
cp config.example.toml config.toml
# → in config.toml:
#     [server] tls_mode = "none"
#     [server] listen   = "0.0.0.0:8080"
#     [turn]   enabled  = true
#     [turn]   port     = 3478
#     [media]  mode     = "stealth"

cp nginx/pulse-mux.conf.template nginx/pulse-mux.conf
sed -i "s/__DOMAIN__/pulse.example.com/g" nginx/pulse-mux.conf

CERTBOT_EMAIL=you@example.com \
  docker compose -f docker-compose.mux.yml up -d

# Optional: also publish UDP TURN on :3478 (bypasses docker NAT)
docker compose -f docker-compose.mux.yml --profile udp-turn up -d
```

HAProxy uses PROXY protocol v2 toward nginx so logs still show real
client IPs. ACME HTTP-01 on :80 is forwarded to nginx unchanged.

State persists in the `pulse-data` volume:
- `pulse.db` (SQLite)
- `server_master.key` (AES-GCM wrapping key for secrets at rest, chmod 600)
- `self_signed.pem` / `self_signed.key` (persisted across restarts so clients keep trusting the fingerprint)
- `autocert/` (Let's Encrypt cache)
- `backups/` (output of `pulse-server backup`)

---

## Day-2 commands

```bash
pulse-server status                                      # connection count, memory, goroutines
pulse-server invite create --max-uses 5                  # generate an invite code
pulse-server user list                                   # registered pubkeys
pulse-server federation add <address> <pubkey>           # peer with another relay
pulse-server backup [/path/to/out.tar.gz]                # consistent tar.gz snapshot
```

---

## Stealth vs simple — pick one

**Stealth** (`tls_mode = "none"`, `listen = "127.0.0.1:8080"`):
- nginx does the actual TLS handshake → JA3S is identical to a vanilla nginx
- Config in `nginx-stealth.conf` forwards `/` → Go, serves a decoy page for `/wp-admin`, `/admin`, etc.
- Best choice behind GFW / active DPI.

**Simple** (`tls_mode = "self-signed" | "manual" | "auto"`, `listen = "0.0.0.0:443"`):
- Go server handles TLS itself. JA3S mimics nginx (cipher order, curve prefs, session tickets)
- Built-in probe-resistant handler: unknown paths → nginx-looking `Welcome to nginx!` + `404 Not Found` with `Server: nginx/1.24.0`
- ICE-TCP muxed on :443, TURN-over-TLS works
- `self_signed` regenerated only on first run, then persisted in `data_dir` — fingerprint stable across restarts.

Both serve the decoy for every non-authenticated request.

---

## Federation bring-up

On server X:
```bash
pulse-server federation add wss://serverY.example.com:443 <Y_pubkey_hex>
```
On server Y:
```bash
pulse-server federation add wss://serverX.example.com:443 <X_pubkey_hex>
```

Messages for users not local to X will now be forwarded to Y (store-and-forward queue handles peer downtime). `federation.mode = "open"` lets any remote peer deliver to local users; `"private"` restricts to the explicit peer list.
