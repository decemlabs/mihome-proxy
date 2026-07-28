# Mihomo bridge notes

The fork keeps Mihomo unpatched. The Go wrapper performs only the integration
required by `NEPacketTunnelProvider`:

- duplicates the packet-tunnel file descriptor before giving it to Mihomo;
- forces Mihomo's home directory to the App Group resources directory;
- resets interface and resolver caches after an iOS path change;
- uses `hub.ApplyConfig` so the external-controller server for zashboard starts;
- disables default DNS hijacking when the user has not enabled Mihomo DNS.

The build enables `with_gvisor`, because Mihome Proxy normalizes every TUN
configuration to the gVisor stack. Optional Mihomo proxy types remain available;
only the unrelated Xray and sing-box engines are removed.
