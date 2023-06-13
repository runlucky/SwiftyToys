import Foundation

/// UserDefaultsを使用したストレージです
public struct UserDefaultsStorage: IStorage {
    private let userDefaults: UserDefaults
    private let bundleIdentifier: String
    
    /// bundleIdentifier - 特にこだわりが無ければ `Bundle.main.bundleIdentifier!` を指定してください
    public init(userDefaults: UserDefaults = .standard, bundleIdentifier: String) {
        self.userDefaults = userDefaults
        self.bundleIdentifier = bundleIdentifier
    }
    
    public func get<T: Codable>(key: String, type: T.Type) throws -> T {
        guard let data = userDefaults.data(forKey: key) else { throw StorageError.notFound(key: key)  }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func upsert<T: Codable>(key: String, value: T) throws {
        let data = try JSONEncoder().encode(value)
        userDefaults.set(data, forKey: key)
    }

    public func delete(key: String) throws {
        userDefaults.removeObject(forKey: key)
    }
    
    public func deleteAll() throws {
        userDefaults.removePersistentDomain(forName: bundleIdentifier)
    }
}
