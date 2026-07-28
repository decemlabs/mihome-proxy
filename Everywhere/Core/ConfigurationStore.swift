//
//  ConfigurationStore.swift
//  Everywhere
//
//  Created by NodePassProject on 5/2/26.
//

import Combine
import CoreData
import Foundation

final class ConfigurationStore: ObservableObject {
    static let shared = ConfigurationStore()

    @Published private(set) var configurations: [Configuration] = []

    /// The configuration the tunnel will run with.
    @Published private(set) var activeID: UUID?

    var active: Configuration? {
        guard let id = activeID else { return nil }
        return configurations.first { $0.id == id }
    }

    private let context: NSManagedObjectContext

    private init() {
        self.context = PersistenceController.shared.container.viewContext

        self.activeID = EVCore.getActiveConfigurationID()
        reload()
        migrateToMihomoOnly()
        reload()
        seedIfEmpty()
    }

    func reload() {
        let request = NSFetchRequest<Configuration>(entityName: "Configuration")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Configuration.createdAt, ascending: true)
        ]
        configurations = (try? context.fetch(request)) ?? []
        if let activeID, !configurations.contains(where: { $0.id == activeID }) {
            self.activeID = nil
            persistActiveID()
        }
    }

    @discardableResult
    func create(name: String, content: String, sourceURL: String? = nil) -> Configuration {
        let cfg = Configuration(context: context)
        cfg.id = UUID()
        cfg.name = name
        cfg.type = CoreType.mihomo.rawValue
        cfg.content = content
        cfg.sourceURL = sourceURL
        cfg.createdAt = Date()
        cfg.updatedAt = Date()
        save()
        reload()
        if activeID == nil {
            activeID = cfg.id
            persistActiveID()
        }
        return cfg
    }

    func update(_ cfg: Configuration, name: String? = nil, content: String? = nil) {
        if let name { cfg.name = name }
        if let content { cfg.content = content }
        cfg.updatedAt = Date()
        save()
        objectWillChange.send()
    }

    func delete(_ cfg: Configuration) {
        let id = cfg.id
        let wasActive = activeID == id
        context.delete(cfg)
        save()
        reload()
        if wasActive {
            activeID = configurations.first?.id
            persistActiveID()
        }
    }

    func setActive(_ cfg: Configuration) {
        activeID = cfg.id
        persistActiveID()
    }

    // MARK: - Persistence helpers

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            NSLog("ConfigurationStore: save failed: \(error)")
        }
    }

    private func persistActiveID() {
        EVCore.setActiveConfigurationID(activeID)
    }

    private func migrateToMihomoOnly() {
        let unsupported = configurations.filter { $0.type != CoreType.mihomo.rawValue }
        unsupported.forEach { context.delete($0) }
        if !unsupported.isEmpty { save() }

        if activeID == nil {
            activeID = EVCore.migrateLegacyMihomoActiveConfigurationID()
            if activeID != nil { persistActiveID() }
        }
    }

    // MARK: - First-run seeding

    private func seedIfEmpty() {
        guard configurations.isEmpty else { return }
        create(name: "mihomo", content: CoreType.defaultConfig)
    }
}
