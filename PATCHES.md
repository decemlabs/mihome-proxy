# Mihome Proxy build notes

Mihome Proxy uses the prebuilt
[EverywhereCore](https://github.com/NodePassProject/EverywhereCore) SwiftPM
binary so that the host app and Packet Tunnel extension can share the same Go
bridge. The app itself only calls the Mihomo entry point.

`Scripts/wire_project.rb` wires these dependencies into
`Everywhere.xcodeproj`:

| Dependency | Targets | Purpose |
| --- | --- | --- |
| `EverywhereCore` | app + Network Extension | Go bridge and Mihomo runtime |
| `Runestone` | app | Configuration editor |
| `TreeSitterYAMLRunestone` | app | YAML highlighting |
| `zashboard` | app resources | Mihomo runtime dashboard |

`libresolv.tbd` is linked into both targets because the Go runtime requires the
system DNS resolver. The extension loads the shared framework from the host
app's `Frameworks/` directory.

## Deliberate temporary limitation

The currently consumed `EverywhereCore` XCFramework still contains engines
that Mihome Proxy does not expose or call. A future Mihomo-only fork of that
binary is required to remove them from the application payload.
