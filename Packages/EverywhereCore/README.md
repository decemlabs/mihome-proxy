# EverywhereCore for Mihome Proxy

This package is the Mihomo-only Go bridge used by Mihome Proxy. It is derived
from [NodePassProject/EverywhereCore](https://github.com/NodePassProject/EverywhereCore)
and was modified by Decem Labs in July 2026 to remove Xray and sing-box.

The source is distributed under the repository's GPLv3 license. Mihomo and its
transitive dependencies retain their respective licenses.

## Local build

```sh
Packages/EverywhereCore/Scripts/build.sh
MIHOME_LOCAL_CORE=1 ./build.sh --build-app
```

The generated `EverywhereCore.xcframework` contains iOS device and simulator
slices and is intentionally excluded from Git. Normal application builds
download the checked release artifact declared in `Package.swift`.

## Public bridge

The gomobile bridge intentionally retains the API used by the Network
Extension:

- `SetResourcesPath`
- `StartCore` (accepts only `mihomo`)
- `Suspend` / `Resume`
- `UpdateDefaultInterface`
- `StopAll`
