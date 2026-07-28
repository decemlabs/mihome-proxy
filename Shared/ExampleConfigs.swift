//
//  ExampleConfigs.swift
//  Mihome Proxy
//
//  Created by NodePassProject on 5/2/26.
//

import Foundation

// Minimal Mihomo starter config. It routes everything through a
// placeholder direct outbound — replace it with your real proxy server
// before use. The TUN inbound that consumes the iOS NEPacketTunnelFlow
// utun is injected by ConfigNormalizer at start time, so don't add one
// here (a duplicate would conflict with ours).
//
// Mihomo exposes its Clash-compatible REST API on 127.0.0.1:9090;
// the bundled zashboard connects to that endpoint while the tunnel runs.
enum ExampleConfigs {
    static let mihomo = """
    log-level: warning
    external-controller: 127.0.0.1:9090
    mode: rule
    proxies: []
    proxy-groups: []
    rules:
      - MATCH,DIRECT
    """
}
