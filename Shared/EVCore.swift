//
//  EVCore.swift
//  Everywhere
//
//  Created by NodePassProject on 5/17/26.
//

import Foundation

final class EVCore {
    // MARK: - Identifiers

    enum Identifier {
        /// Bundle identifier prefix for the Mihome Proxy app family.
        static let bundle = "com.andre.mihomeproxy"
        /// App Group suite shared between the app and Network Extension.
        static let appGroupSuite = "group.\(bundle)"
        /// Bundle identifier of the packet tunnel Network Extension.
        static let networkExtension = "\(bundle).NetworkExtension"
        /// Description shown for the VPN profile in iOS Settings.
        static let tunnelDescription = "Mihome Proxy"
    }

    /// Fallback DNS servers used when the user hasn't customized them.
    static let defaultDNSServers = ["1.1.1.1", "8.8.8.8"]

    /// App Group `UserDefaults` shared between the app and Network Extension.
    /// Prefer the typed `getX` / `setX` accessors below over direct access.
    ///
    /// Lazily initialized: the first access registers the values in
    /// ``registeredDefaults``. `register(defaults:)` only affects keys that
    /// have not been explicitly written, so user-set values always win.
    /// Swift's `static let` semantics make this thread-safe and run-once.
    private static let userDefaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: Identifier.appGroupSuite)!
        defaults.register(defaults: registeredDefaults)
        return defaults
    }()

    /// Defaults applied to App Group `UserDefaults` on first access.
    /// The single source of truth for any setting whose unset value isn't
    /// the type's natural zero (`false`/`""`/`nil`/empty collection). Bool
    /// settings that default to `false` are omitted because `bool(forKey:)`
    /// already returns `false` for unset keys.
    private static let registeredDefaults: [String: Any] = [
        UserDefaultsKey.dnsServers: defaultDNSServers,
        UserDefaultsKey.useZashboard: true,
    ]

    // MARK: - UserDefaults Keys

    private enum UserDefaultsKey {
        static let activeByCoreType = "activeByCoreType"
        static let activeConfigurationID = "activeConfigurationID"
        static let alwaysOnEnabled = "alwaysOnEnabled"
        static let dnsServers = "dnsServers"
        static let tunnelIncludeAPNs = "tunnelIncludeAPNs"
        static let tunnelIncludeAllNetworks = "tunnelIncludeAllNetworks"
        static let tunnelIncludeCellularServices = "tunnelIncludeCellularServices"
        static let tunnelIncludeLocalNetworks = "tunnelIncludeLocalNetworks"
        static let useZashboard = "useZashboard"
    }

    // MARK: - App Group Container

    /// On-disk container shared between the app and Network Extension.
    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Identifier.appGroupSuite
        ) else {
            fatalError("App Group container missing for \(Identifier.appGroupSuite).")
        }
        return url
    }

    /// Root directory for user-injected Mihomo assets such as MMDB files,
    /// certificates, rule providers, and cache.db.
    static func resourcesURL() -> URL {
        let url = containerURL
            .appendingPathComponent("Resources", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        migrateLegacyMihomoResources(into: url)
        return url
    }

    private static func migrateLegacyMihomoResources(into resourcesURL: URL) {
        let fm = FileManager.default
        let legacyURL = resourcesURL.appendingPathComponent(CoreType.mihomo.rawValue, isDirectory: true)
        guard fm.fileExists(atPath: legacyURL.path),
              let entries = try? fm.contentsOfDirectory(at: legacyURL, includingPropertiesForKeys: nil) else { return }
        for entry in entries {
            let destination = resourcesURL.appendingPathComponent(entry.lastPathComponent)
            guard !fm.fileExists(atPath: destination.path) else { continue }
            try? fm.moveItem(at: entry, to: destination)
        }
        try? fm.removeItem(at: legacyURL)
    }

    // MARK: - Typed UserDefaults Accessors
    
    static func getActiveConfigurationID() -> UUID? {
        guard let raw = userDefaults.string(forKey: UserDefaultsKey.activeConfigurationID) else { return nil }
        return UUID(uuidString: raw)
    }

    static func setActiveConfigurationID(_ id: UUID?) {
        userDefaults.set(id?.uuidString, forKey: UserDefaultsKey.activeConfigurationID)
    }

    /// Reads the old multi-core selection once so an in-place upgrade keeps
    /// the user's active Mihomo configuration when the same App Group is used.
    static func migrateLegacyMihomoActiveConfigurationID() -> UUID? {
        defer { userDefaults.removeObject(forKey: UserDefaultsKey.activeByCoreType) }
        guard let raw = userDefaults.dictionary(forKey: UserDefaultsKey.activeByCoreType) as? [String: String],
              let id = raw[CoreType.mihomo.rawValue] else { return nil }
        return UUID(uuidString: id)
    }
    
    static func getAlwaysOnEnabled() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.alwaysOnEnabled)
    }

    static func setAlwaysOnEnabled(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKey.alwaysOnEnabled)
    }
    
    static func getDNSServers() -> [String] {
        userDefaults.stringArray(forKey: UserDefaultsKey.dnsServers)!
    }

    static func setDNSServers(_ servers: [String]) {
        userDefaults.set(servers, forKey: UserDefaultsKey.dnsServers)
    }
    
    static func getTunnelIncludeAllNetworks() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.tunnelIncludeAllNetworks)
    }

    static func setTunnelIncludeAllNetworks(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKey.tunnelIncludeAllNetworks)
    }

    static func getTunnelIncludeLocalNetworks() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.tunnelIncludeLocalNetworks)
    }

    static func setTunnelIncludeLocalNetworks(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKey.tunnelIncludeLocalNetworks)
    }

    static func getTunnelIncludeAPNs() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.tunnelIncludeAPNs)
    }

    static func setTunnelIncludeAPNs(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKey.tunnelIncludeAPNs)
    }

    static func getTunnelIncludeCellularServices() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.tunnelIncludeCellularServices)
    }

    static func setTunnelIncludeCellularServices(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKey.tunnelIncludeCellularServices)
    }
    
    static func getUseZashboard() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.useZashboard)
    }

    static func setUseZashboard(_ value: Bool) {
        userDefaults.set(value, forKey: UserDefaultsKey.useZashboard)
    }
}
