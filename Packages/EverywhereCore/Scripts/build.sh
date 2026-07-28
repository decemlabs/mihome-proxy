#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_DIR="$ROOT/go"
OUT="$ROOT/EverywhereCore.xcframework"

if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

GO_PATH="$(go env GOPATH)"
GO_BIN="$GO_PATH/bin"
export PATH="$GO_BIN:$PATH"

cd "$CORE_DIR"

MOBILE_VERSION="$(go list -m -f '{{.Version}}' golang.org/x/mobile)"
if ! command -v gomobile >/dev/null 2>&1 || ! command -v gobind >/dev/null 2>&1; then
    echo "→ installing gomobile and gobind $MOBILE_VERSION"
    go install "golang.org/x/mobile/cmd/gomobile@$MOBILE_VERSION"
    go install "golang.org/x/mobile/cmd/gobind@$MOBILE_VERSION"
fi

echo "→ verifying Mihomo-only module graph"
go mod verify
if go list -m all | grep -Eq 'github\.com/(sagernet/sing-box|xtls/xray-core)( |$)'; then
    echo "error: forbidden core dependency found" >&2
    exit 1
fi

echo "→ building iOS device and simulator XCFramework"
rm -rf "$OUT"
gomobile bind \
    -target=ios,iossimulator \
    -tags=with_gvisor \
    -ldflags="-s -w" \
    -o "$OUT" \
    .

echo "✓ built $OUT"
du -sh "$OUT"
