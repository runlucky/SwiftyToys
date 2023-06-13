import Foundation

public protocol IStorage {
    func get<T: Codable>(key: String, type: T.Type) throws -> T
    func upsert<T: Codable>(key: String, value: T) throws
    func delete(key: String) throws
    func deleteAll() throws
}
