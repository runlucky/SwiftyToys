import Foundation

/// オンメモリ上で動作する高速なストレージです
public class MemoryStorage {
    private var storage: [String: Data] = [:]
    private let queue = DispatchQueue(label: "OnMemoryStorage", attributes: .concurrent)
    
    public init() {}
}

extension MemoryStorage: IStorage {
    public func upsert<T: Codable>(_ key: StorageKey, value: T) throws {
        let data = try JSONEncoder().encode(value)
        
        queue.async (flags: .barrier) {
            self.storage[key.toString()] = data
        }
    }
    
    public func get<T: Codable>(_ key: StorageKey, type: T.Type) throws -> T {
        var data: Data?
        queue.sync {
            data = storage[key.toString()]
        }
        
        guard let data = data else { throw StorageError.notFound(key: key.toString()) }
        return try JSONDecoder().decode(type, from: data)
    }

    public func getKeys(folder: String) throws -> [StorageKey] {
        queue.sync {
            storage.filter { key, value in key.hasPrefix("\(folder).") }
                .map { key, value in StorageKey(folder: folder, file: key.replace(pattern: "\(folder).", to: "")) }
        }
    }
    
    public func delete(_ key: StorageKey) throws {
        queue.async(flags: .barrier) {
            self.storage.removeValue(forKey: key.toString())
        }
    }
    
    public func deleteAll() throws {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }
}
