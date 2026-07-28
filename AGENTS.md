# Repository Guidelines

## Project Structure & Module Organization

This is a native iOS Mihomo VPN client. `Everywhere/` contains the SwiftUI host app: configuration screens, editor, dashboard, resources, and app entitlements. `EverywhereNE/` is the Packet Tunnel Network Extension. Code shared by both targets lives in `Shared/`, including Core Data, App Group helpers, configuration normalization, and starter YAML. Keep tunnel-specific iOS APIs in `EverywhereNE/`; do not import them into shared UI code.

`ThirdParty/zashboard/` is a checked-in static dashboard bundle. Treat it as generated vendor content. Xcode and SwiftPM wiring is maintained in `Everywhere.xcodeproj/` and `Scripts/wire_project.rb`.

## Build, Test, and Development Commands

- `./build.sh` installs the Ruby `xcodeproj` dependency if needed and makes project dependency wiring idempotent.
- `./build.sh --build-app` rewires the project and runs a simulator smoke build.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Everywhere.xcodeproj -scheme Everywhere -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build` builds without signing.

Run VPN behavior only on a signed physical iPhone; the simulator is for UI/build validation.

## Coding Style & Naming Conventions

Use four-space indentation and standard Swift formatting. Types use `UpperCamelCase`; properties and functions use `lowerCamelCase`. Keep SwiftUI views focused on rendering and move persistence or tunnel behavior into `Core/`, `TunnelManager`, or shared helpers. Mihomo configurations are YAML; preserve user YAML unless `MihomoNormalizer` must enforce Network Extension requirements.

## Testing Guidelines

There is currently no XCTest target. Before submitting a change, run the simulator build and manually check the affected UI flow. For normalizer changes, cover configurations with and without `tun:`, dashboard enabled/disabled, and comments/indented YAML. Test a real tunnel on device when modifying `EverywhereNE/`, entitlements, or VPN settings.

## Commit & Pull Request Guidelines

Existing history uses short imperative summaries, often versioned releases (for example, `Update zashboard` or `1.4(23)`). Use concise imperative subjects such as `Simplify Mihomo configuration import`. Keep commits scoped. PRs should explain user-visible behavior, list build/device checks, link relevant issues, and include screenshots for SwiftUI changes. Never commit signing certificates, provisioning profiles, or private subscription URLs.
