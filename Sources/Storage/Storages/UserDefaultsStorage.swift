import Foundation

/// UserDefaultsを使用したストレージです
public struct UserDefaultsStorage {
    private let userDefaults: UserDefaults
    private let bundleIdentifier: String
    
    /// bundleIdentifier - 特にこだわりが無ければ `Bundle.main.bundleIdentifier!` を指定してください
    public init(userDefaults: UserDefaults = .standard, bundleIdentifier: String) {
        self.userDefaults = userDefaults
        self.bundleIdentifier = bundleIdentifier
    }
}

extension UserDefaultsStorage: IStorage {
    public func upsert<T: Codable>(_ key: StorageKey, value: T) throws {
        let data = try value.encode()
        userDefaults.set(data, forKey: key.toString())
    }

    public func get<T: Codable>(_ key: StorageKey, type: T.Type) throws -> T {
        guard let data = userDefaults.data(forKey: key.toString()) else {
            throw StorageError.notFound(key: key.toString())
        }
        return try data.decode(type)
    }

    public func getKeys(folder: String) throws -> [StorageKey] {
        userDefaults.dictionaryRepresentation().compactMap { key, value in
            guard key.hasPrefix("\(folder).") else { return nil }
            return StorageKey(folder: folder, file: key.replace(pattern: "\(folder).", to: ""))
        }
    }
    
    public func delete(_ key: StorageKey) throws {
        userDefaults.removeObject(forKey: key.toString())
    }
    
    public func deleteAll() throws {
        userDefaults.removePersistentDomain(forName: bundleIdentifier)
    }

}
