import Foundation

/// オンメモリ上で動作する高速なストレージです
public class MemoryStorage: IStorage {
    private var storage: [String: Data] = [:]
    private let queue = DispatchQueue(label: "OnMemoryStorage", attributes: .concurrent)
    
    public init() {}
    
    public func get<T: Codable>(key: String, type: T.Type) throws -> T {
        var data: Data?
        queue.sync {
            data = storage[key]
        }
        
        guard let data = data else { throw StorageError.notFound(key: key) }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func upsert<T: Codable>(key: String, value: T) throws {
        let data = try JSONEncoder().encode(value)
        
        queue.async (flags: .barrier) {
            self.storage[key] = data
        }
    }

    public func delete(key: String) throws {
        queue.async(flags: .barrier) {
            self.storage.removeValue(forKey: key)
        }
    }
    
    public func deleteAll() throws {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }
}
