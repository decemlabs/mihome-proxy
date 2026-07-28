# Mihome Proxy build notes

Mihome Proxy keeps its Mihomo-only Go bridge in
`Packages/MihomeCore/`. The Swift package downloads a prebuilt XCFramework
from this repository's `core-*` releases, while `MIHOME_LOCAL_CORE=1` selects
the locally generated framework.

`Scripts/wire_project.rb` wires these dependencies into
`MihomeProxy.xcodeproj`:

| Dependency | Targets | Purpose |
| --- | --- | --- |
| Local `MihomeCore` package | app + Network Extension | Mihomo Go bridge and runtime |
| `Runestone` | app | Configuration editor |
| `TreeSitterYAMLRunestone` | app | YAML highlighting |
| `zashboard` | app resources | Mihomo runtime dashboard |

`libresolv.tbd` is linked into both targets because the Go runtime requires the
system DNS resolver. The extension loads the shared framework from the host
app's `Frameworks/` directory.

## Core release model

`core-ci.yml` validates the Go module, excludes the sing-box and xray-core
modules, runs Go tests, and builds the device/simulator XCFramework.
`core-release.yml` checks the Go proxy daily for stable Mihomo updates,
publishes a `ditto` archive, and writes its SwiftPM checksum into the local
package manifest.

The bridge API stays compatible with the original upstream EverywhereCore so the
Network Extension can keep calling `EvcoreStartCore` and related lifecycle
functions. Internally, `StartCore` rejects every value except `mihomo`.

The first release measured 59 MB compressed, 193 MB unpacked, and 65 MB for
the device arm64 library. The upstream three-engine artifact was respectively
171 MB, 575 MB, and 117 MB. With otherwise identical unsigned Release builds,
the packaged application fell from 35 MB to 22 MB and the Network Extension
executable from 97 MB to 55 MB.
