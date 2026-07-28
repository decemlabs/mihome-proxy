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
git clone <your-fork-url> mihome-proxy
cd mihome-proxy
./build.sh
open Everywhere.xcodeproj
```

In Xcode, select your Apple development team and register the App ID,
Network Extension capability, and App Group for `com.andre.mihomeproxy` before
installing on a device. Replace that starter reverse-DNS identifier with one
you control before distribution.

`build.sh` wires Runestone, YAML syntax highlighting, zashboard, and the
prebuilt `EverywhereCore` dependency into the Xcode project. To run a simulator
smoke build as part of the setup:

```bash
./build.sh --build-app
```

## Current core limitation

The application starts only Mihomo and has no Xray or sing-box configuration
paths. It temporarily consumes the upstream `EverywhereCore` XCFramework,
which still bundles those engines internally. Forking that dependency into a
Mihomo-only XCFramework is the next step for reducing the final IPA size.

## Acknowledgements

- [mihomo](https://github.com/MetaCubeX/mihomo)
- [zashboard](https://github.com/Zephyruso/zashboard)
- [Runestone](https://github.com/simonbs/Runestone)

## License

Mihome Proxy is licensed under the [GNU General Public License v3.0](LICENSE).
