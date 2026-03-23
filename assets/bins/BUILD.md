# Bundled Binary Build Notes

## Tor (Android ARM64)
- **Source**: Orbot 17.9.2 `libtor.so` (extracted from APK)
- **Size**: ~9.2 MB, ARM64 ELF, has `main()` entry point (directly executable)
- **Path**: `android_arm64/tor`

## Snowflake Client (Android ARM64)
- **Source**: https://gitlab.torproject.org/nicenoise/snowflake (v2 branch)
- **Size**: ~17 MB
- **Path**: `android_arm64/snowflake-client`

### Build patch (anet v0.0.5)
The `anet` dependency requires a patch for Go 1.22+ compatibility:
```diff
- //go:linkname net.zoneCache
```
This `go:linkname` directive is incompatible with Go 1.22+. Remove it before building.

### Build command
```bash
CGO_ENABLED=1 \
GOOS=android \
GOARCH=arm64 \
CC=aarch64-linux-android21-clang \
go build -o snowflake-client ./client
```

### Bridge configuration
Bridges use CDN77 domain fronting:
- Front domains: `app.datapacket.com`, `www.datapacket.com`
- URL: `https://1098762253.rsc.cdn77.org/`
- Fingerprints: `2B280B23...`, `8838024...`

## Linux / Windows
Tor and Snowflake are expected to be installed at system level or built natively.
The `linux_x64/`, `linux_arm64/`, and `windows_x64/` directories hold platform-specific binaries.
