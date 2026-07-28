//
//  ConfigNormalizer.swift
//  Mihome Proxy
//
//  Created by NodePassProject on 5/24/26.
//

import Foundation

// Rewrites a Mihomo configuration so its TUN inbound consumes the iOS
// NEPacketTunnelProvider's utun directly. MihomeCore injects the actual
// file descriptor when it starts Mihomo; this layer only owns the config.
//
// We also pin the Clash RESTful API to 127.0.0.1:9090 with no
// auth, no dashboard, and no CORS allow-list — that's the address the
// bundled zashboard attaches to for runtime queries. We strip the user's
// conflicting controller/UI/secret keys and append the local controller.
//
// This Clash-API rewriting is the UI-facing half of normalization: it
// only exists so zashboard can attach. When the user turns zashboard
// off (`useZashboard == false`) we skip it entirely and leave every
// controller/UI/secret key exactly as written — only the TUN + log
// normalization, which the tunnel itself depends on, still runs.
//
// TUN strategy: patch the user's `tun:` block (if any) in place to force
// the fields the iOS NE depends on and strip the fields that conflict with
// the NE-supplied fd. Everything else the user wrote on the TUN inbound —
// `loopback_address` / `loopback-address`, `dns_*` / `dns-hijack`,
// `route_address` / `route-address`, `strict_route`, `udp_timeout`,
// `exclude_mptcp`, `endpoint-independent-nat`, etc. — flows through
// untouched. If no TUN inbound is declared, we append a minimal
// canonical one. For mihomo the sub-block is walked line by line;
// no YAML parser is involved.
//
// `MihomoNormalizer` performs the YAML-aware line rewriting.
enum ConfigNormalizer {
    static func normalize(_ content: String, useZashboard: Bool) throws -> String {
        try MihomoNormalizer.normalize(content, useZashboard: useZashboard)
    }
}
