#!/usr/bin/env bash
# Top-level build helper. The zashboard dashboard is checked into
# ThirdParty/zashboard/ and MihomeCore/ wraps the released
# Mihomo-only XCFramework.
#
# --build-core builds a local XCFramework.
# --build-app runs the unsigned iOS Simulator smoke build.
# Passing both makes the app build consume the freshly built local core.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

build_core=false
build_app=false
for argument in "$@"; do
  case "$argument" in
    --build-core)
      build_core=true
      ;;
    --build-app)
      build_app=true
      ;;
    *)
      echo "usage: $0 [--build-core] [--build-app]" >&2
      exit 2
      ;;
  esac
done

if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app/Contents/Developer ]]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

if [[ "$build_core" == true ]]; then
  MihomeCore/Scripts/build.sh
  export MIHOME_LOCAL_CORE=1
fi

# wire_project.rb needs the xcodeproj gem; install it (user dir, no sudo) if absent.
ruby -e "require 'xcodeproj'" 2>/dev/null || gem install --user-install xcodeproj

ruby Scripts/wire_project.rb

if [[ "$build_app" == true ]]; then
  if [[ "${MIHOME_LOCAL_CORE:-0}" == "1" && \
    ! -d MihomeCore/MihomeCore.xcframework ]]; then
    echo "error: local core is missing; run with --build-core" >&2
    exit 1
  fi
  echo "→ xcodebuild simulator smoke test"
  xcodebuild \
    -project MihomeProxy.xcodeproj \
    -scheme MihomeProxy \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -configuration Debug \
    CODE_SIGNING_ALLOWED=NO \
    build
fi

echo "✓ done"
