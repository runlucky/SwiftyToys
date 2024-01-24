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
    public func upsert<T: Codable>(key: String, value: T) throws {
        let data = try JSONEncoder().encode(value)
        userDefaults.set(data, forKey: key)
    }

    public func upsert<T: Codable>(folder: String, key: String, value: T) throws {
        try upsert(key: "\(folder)/\(key)", value: value)
    }
    
    
    public func get<T: Codable>(key: String, type: T.Type) throws -> T {
        guard let data = userDefaults.data(forKey: key) else { throw StorageError.notFound(key: key)  }
        return try JSONDecoder().decode(type, from: data)
    }

    
    public func get<T: Codable>(folder: String, key: String, type: T.Type) throws -> T {
        try get(key: "\(folder)/\(key)", type: type)
    }
    
    public func gets<T: Codable>(folder: String, type: T.Type) throws -> [T] {
        userDefaults.dictionaryRepresentation().compactMap { key, value in
            guard key.hasPrefix("\(folder)/"),
                  let value = value as? Data else { return nil }
            return try? JSONDecoder().decode(type, from: value)
        }
    }
    
    public func delete(key: String) throws {
        userDefaults.removeObject(forKey: key)
    }
    
    public func delete(folder: String, key: String) throws {
        try delete(key: "\(folder)/\(key)")
    }
    
    public func deletes(folder: String) throws {
        userDefaults.dictionaryRepresentation()
            .filter { $0.key.hasPrefix("\(folder)/") }
            .forEach { userDefaults.removeObject(forKey: $0.key) }
    }
    
    public func deleteAll() throws {
        userDefaults.removePersistentDomain(forName: bundleIdentifier)
    }

}
