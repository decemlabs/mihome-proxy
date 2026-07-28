//
//  PersistenceController.swift
//  Everywhere
//
//  Created by NodePassProject on 5/2/26.
//

import CoreData
import Foundation

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "MihomeProxy", managedObjectModel: model)

        // The store lives inside the App Group container so the
        // Network Extension can open the same SQLite and read the
        // active config directly. Without this the NE would need
        // the config blob shipped through providerConfiguration,
        // which iOS caps at 512 KB.
        let storeURL = EVCore.containerURL.appendingPathComponent("MihomeProxy.sqlite")
        Self.migrateLegacyStoreIfNeeded(to: storeURL, model: model)
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data load failed: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Copy a store written by an earlier build from the old app-group layout
    // (or, for older installations, the app sandbox) into the current shared
    // container where the Network Extension can read it.
    private static func migrateLegacyStoreIfNeeded(to newURL: URL, model: NSManagedObjectModel) {
        let fm = FileManager.default
        let legacyURLs = [
            EVCore.containerURL.appendingPathComponent("Everywhere.sqlite"),
            NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Everywhere.sqlite"),
        ]
        guard let legacyURL = legacyURLs.first(where: { fm.fileExists(atPath: $0.path) }) else { return }

        if fm.fileExists(atPath: newURL.path) {
            guard isStoreEmpty(at: newURL, model: model) else { return }
            removeStoreFiles(at: newURL, fm: fm)
        }

        copyStoreFiles(from: legacyURL, to: newURL, fm: fm)
    }

    private static func isStoreEmpty(at url: URL, model: NSManagedObjectModel) -> Bool {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        guard let store = try? coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil
        ) else { return false }
        defer { try? coordinator.remove(store) }

        let ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        ctx.persistentStoreCoordinator = coordinator
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Configuration")
        request.resultType = .countResultType
        return ((try? ctx.count(for: request)) ?? 1) == 0
    }

    private static func storeFileURLs(base: URL) -> [URL] {
        [base,
         URL(fileURLWithPath: base.path + "-wal"),
         URL(fileURLWithPath: base.path + "-shm")]
    }

    private static func copyStoreFiles(from src: URL, to dst: URL, fm: FileManager) {
        for (s, d) in zip(storeFileURLs(base: src), storeFileURLs(base: dst))
            where fm.fileExists(atPath: s.path) {
            try? fm.copyItem(at: s, to: d)
        }
    }

    private static func removeStoreFiles(at url: URL, fm: FileManager) {
        for u in storeFileURLs(base: url) where fm.fileExists(atPath: u.path) {
            try? fm.removeItem(at: u)
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = "Configuration"
        entity.managedObjectClassName = NSStringFromClass(Configuration.self)

        func attr(_ name: String, _ type: NSAttributeType, optional: Bool = false, defaultValue: Any? = nil) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = type
            a.isOptional = optional
            if let defaultValue { a.defaultValue = defaultValue }
            return a
        }

        entity.properties = [
            attr("id", .UUIDAttributeType),
            attr("name", .stringAttributeType, defaultValue: ""),
            attr("type", .stringAttributeType, defaultValue: CoreType.mihomo.rawValue),
            attr("content", .stringAttributeType, defaultValue: ""),
            attr("createdAt", .dateAttributeType),
            attr("updatedAt", .dateAttributeType),
            attr("sourceURL", .stringAttributeType, optional: true),
        ]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }
}
