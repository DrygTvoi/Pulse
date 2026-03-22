FROM golang:1.22-alpine AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -ldflags="-s -w" -o pulse-server .

FROM alpine:3.19
RUN apk add --no-cache ca-certificates
COPY --from=builder /build/pulse-server /usr/local/bin/
EXPOSE 8443 3478/udp 3478/tcp
VOLUME /data
ENTRYPOINT ["pulse-server"]
CMD ["serve"]
