#!/usr/bin/env bash
# session-viewer launcher: pick a prebuilt binary for the current host,
# or build from src/ on the fly if missing.

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SKILL_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS-$ARCH" in
  darwin-arm64)  BIN="$SCRIPT_DIR/session-viewer-darwin-arm64" ;;
  darwin-x86_64) BIN="$SCRIPT_DIR/session-viewer-darwin-x86_64" ;;
  linux-x86_64)  BIN="$SCRIPT_DIR/session-viewer-linux-x86_64" ;;
  linux-aarch64) BIN="$SCRIPT_DIR/session-viewer-linux-aarch64" ;;
  *)             BIN="$SCRIPT_DIR/session-viewer-${OS}-${ARCH}" ;;
esac

if [[ ! -x "$BIN" ]]; then
  echo "session-viewer: prebuilt binary not found for $OS-$ARCH ($BIN)" >&2
  echo "session-viewer: building from source via cargo…" >&2
  if ! command -v cargo >/dev/null 2>&1; then
    echo "session-viewer: cargo not installed; cannot build" >&2
    exit 127
  fi
  ( cd "$SKILL_DIR/src" && cargo build --release )
  cp "$SKILL_DIR/src/target/release/session-viewer" "$BIN"
  chmod +x "$BIN"
fi

exec "$BIN" "$@"
