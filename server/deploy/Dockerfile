FROM golang:1.22-alpine AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -ldflags="-s -w" -o pulse-server .

FROM alpine:3.19
# ca-certs for Let's Encrypt / outbound HTTPS, tzdata for correct log
# timestamps, tini for clean SIGTERM forwarding to the Go process.
RUN apk add --no-cache ca-certificates tzdata tini \
    && addgroup -S -g 1000 pulse \
    && adduser -S -u 1000 -G pulse -H -D pulse \
    && mkdir -p /data \
    && chown pulse:pulse /data

COPY --from=builder --chown=root:root /build/pulse-server /usr/local/bin/pulse-server
# Allow the non-root user to bind 443 / 80 (ACME) without needing to run as root.
RUN apk add --no-cache libcap \
    && setcap 'cap_net_bind_service=+ep' /usr/local/bin/pulse-server \
    && apk del libcap

USER pulse
WORKDIR /data
EXPOSE 80 443 3478/udp 3478/tcp
VOLUME /data
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD pulse-server status --config /etc/pulse/config.toml --data-dir /data >/dev/null 2>&1 || exit 1
ENTRYPOINT ["/sbin/tini", "--", "pulse-server"]
CMD ["serve"]
