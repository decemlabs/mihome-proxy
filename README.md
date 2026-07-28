# Mihome Proxy

Mihome Proxy is a native iOS VPN client built around
[Mihomo](https://github.com/MetaCubeX/mihomo). Import or edit a Mihomo YAML
configuration, choose the active profile, and connect through an iOS Packet
Tunnel. While connected, the bundled [zashboard](https://github.com/Zephyruso/zashboard)
provides live traffic, proxy, and rule information.

## Features

- Mihomo YAML configurations: create, import, edit, or refresh from a subscription URL.
- A single active configuration and a native iOS VPN toggle.
- A resource folder for Mihomo assets such as MMDB files, certificates, rule providers, and cache data.
- Optional zashboard runtime dashboard.

## Build from source

```bash
git clone https://github.com/decemlabs/mihome-proxy
cd mihome-proxy
./build.sh
open MihomeProxy.xcodeproj
```

In Xcode, select your Apple development team and register the App ID,
Network Extension capability, and App Group for `com.andre.mihomeproxy` before
installing on a device. Replace that starter reverse-DNS identifier with one
you control before distribution.

`build.sh` wires Runestone, YAML syntax highlighting, zashboard, and the local
`MihomeCore` Swift package into the Xcode project. The package
downloads the checksum-verified Mihomo-only binary from this repository's
GitHub Releases. To run a simulator smoke build:

```bash
./build.sh --build-app
```

Core development requires Go. Build the XCFramework locally and make the app
consume it in one command:

```bash
brew install go
./build.sh --build-core --build-app
```

## MihomeCore

The Go bridge source lives in `MihomeCore/`. It retains the
original gomobile API used by the Network Extension but contains no Xray or
sing-box engine. GitHub Actions tracks stable Mihomo releases and publishes
device/simulator XCFrameworks under `core-vYYYY.MM.DD` tags.

The first Mihomo-only release reduced the iOS arm64 library from 117 MB to
65 MB and the downloadable ZIP from 171 MB to 59 MB. An identical unsigned
Release build reduced the packaged app from 35 MB to 22 MB (36%). Full Mihomo
protocol support remains enabled.

## Acknowledgements

- [mihomo](https://github.com/MetaCubeX/mihomo)
- [zashboard](https://github.com/Zephyruso/zashboard)
- [Runestone](https://github.com/simonbs/Runestone)
- [EverywhereCore](https://github.com/NodePassProject/EverywhereCore), the
  upstream bridge from which the local Mihomo-only package was derived

## License

Mihome Proxy is licensed under the [GNU General Public License v3.0](LICENSE).
