import Foundation

/// オンメモリ上で動作する高速なストレージです
public class MemoryStorage {
    private var storage: [String: Data] = [:]
    private let queue = DispatchQueue(label: "OnMemoryStorage", attributes: .concurrent)
    
    public init() {}
}

extension MemoryStorage: IStorage {
    public func upsert<T: Codable>(key: String, value: T) throws {
        let data = try JSONEncoder().encode(value)
        
        queue.async (flags: .barrier) {
            self.storage[key] = data
        }
    }

    public func upsert<T: Codable>(folder: String, key: String, value: T) throws {
        try upsert(key: "\(folder)/\(key)", value: value)
    }
    
    
    public func get<T: Codable>(key: String, type: T.Type) throws -> T {
        var data: Data?
        queue.sync {
            data = storage[key]
        }
        
        guard let data = data else { throw StorageError.notFound(key: key) }
        return try JSONDecoder().decode(type, from: data)
    }

    
    public func get<T: Codable>(folder: String, key: String, type: T.Type) throws -> T {
        try get(key: "\(folder)/\(key)", type: type)
    }
    
    public func gets<T: Codable>(folder: String, type: T.Type) throws -> [T] {
        var results: [T] = []
        
        queue.sync {
            results = storage
                .filter { $0.key.hasPrefix("\(folder)/") }
                .compactMap { try? JSONDecoder().decode(type, from: $1) }
        }
        
        return results
    }
    
    public func delete(key: String) throws {
        queue.async(flags: .barrier) {
            self.storage.removeValue(forKey: key)
        }
    }
    
    public func delete(folder: String, key: String) throws {
        try delete(key: "\(folder)/\(key)")
    }
    
    public func deletes(folder: String) throws {
        queue.async(flags: .barrier) {
            self.storage = self.storage.filter { !$0.key.hasPrefix("\(folder)/") }
        }
    }
    
    public func deleteAll() throws {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }
}
