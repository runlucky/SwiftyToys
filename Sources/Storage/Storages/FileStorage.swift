import Foundation

/// 標準ファイル入出力を使用したストレージです
public struct FileStorage: IStorage {
    private let fileManager: FileManager
    private let root: URL
    
    public init(fileManager: FileManager = .default, root: URL) {
        self.fileManager = fileManager
        self.root = root
        
        try? createDirectoryIfNeeded(root)
    }
    
    public func get<T: Codable>(key: String, type: T.Type) throws -> T {
        let url = root.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: url.path) else { throw StorageError.notFound(key: key) }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func upsert<T: Codable>(key: String, value: T) throws {
        let url = root.appendingPathComponent(key)
        let data = try JSONEncoder().encode(value)
        fileManager.createFile(atPath: url.path, contents: data)
    }

    public func delete(key: String) throws {
        let url = root.appendingPathComponent(key)
        
        do {
            try fileManager.removeItem(at: url)
            
        } catch CocoaError.fileNoSuchFile {
            // 削除対象のファイルがなかった場合は例外を握りつぶす
            return
        }
    }
    
    public func deleteAll() throws {
        let files = try fileManager.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
        try files.forEach { try fileManager.removeItem(at: $0) }
    }
    
    private func createDirectoryIfNeeded(_ url: URL) throws {
        guard !fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

}