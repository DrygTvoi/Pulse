#!/usr/bin/env bash
# Build a signed release APK / App Bundle.
#
# Usage (local, with key.properties on disk):
#   ./scripts/build_release.sh
#
# Usage (CI, via environment variables):
#   KEYSTORE_STORE_PASSWORD=secret \
#   KEYSTORE_KEY_PASSWORD=secret \
#   KEYSTORE_KEY_ALIAS=pulse \
#   KEYSTORE_STORE_FILE=/home/runner/pulse-release.jks \
#   SENTRY_DSN=https://abc123@o0.ingest.sentry.io/0 \
#   ./scripts/build_release.sh
#
# Required env vars for CI (alternative to android/key.properties):
#   KEYSTORE_STORE_PASSWORD  — keystore password
#   KEYSTORE_KEY_PASSWORD    — key entry password
#   KEYSTORE_KEY_ALIAS       — key alias (default: pulse)
#   KEYSTORE_STORE_FILE      — absolute path to .jks file
#
# Optional:
#   SENTRY_DSN               — Sentry project DSN for crash reporting
#                              Get from: https://sentry.io → Settings → Projects → DSN
#   BUILD_TARGET             — "apk" (default) or "appbundle" (for Play Store)

set -euo pipefail

BUILD_TARGET="${BUILD_TARGET:-apk}"
SENTRY_DSN="${SENTRY_DSN:-}"

DART_DEFINES=""
if [ -n "$SENTRY_DSN" ]; then
  DART_DEFINES="--dart-define=SENTRY_DSN=$SENTRY_DSN"
  echo "[build] Sentry DSN configured"
else
  echo "[build] WARNING: SENTRY_DSN not set — crash reporting disabled in this build"
fi

echo "[build] Target: $BUILD_TARGET"
flutter build "$BUILD_TARGET" --release $DART_DEFINES

if [ "$BUILD_TARGET" = "apk" ]; then
  OUT="build/app/outputs/flutter-apk/app-release.apk"
else
  OUT="build/app/outputs/bundle/release/app-release.aab"
fi

echo "[build] Done: $OUT"
echo "[build] SHA-256: $(sha256sum "$OUT" | cut -d' ' -f1)"
