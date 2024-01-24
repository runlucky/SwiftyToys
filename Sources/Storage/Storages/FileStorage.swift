import Foundation

/// 標準ファイル入出力を使用したストレージです
public struct FileStorage {
    private let fileManager: FileManager
    private let root: URL
    
    public init(_ fileManager: FileManager = .default, root: URL) {
        self.fileManager = fileManager
        self.root = root
        
        if !root.exists {
            try? fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        }
    }
    
    private func upsert<T: Codable>(_ url: URL, value: T) throws {
        let data = try JSONEncoder().encode(value)
        let isSuccess = fileManager.createFile(atPath: url.path, contents: data)
        if !isSuccess {
            logging(.warning, "ファイル作成に失敗, key: \(url.absoluteString)")
            throw StorageError.createFileFailed(key: url.absoluteString)
        }
    }
    
    private func get<T: Codable>(_ url: URL, type: T.Type) throws -> T {
        guard fileManager.fileExists(atPath: url.path) else { throw StorageError.notFound(key: url.absoluteString) }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    private func delete(_ url: URL) throws {
        do {
            try fileManager.removeItem(at: url)
        } catch CocoaError.fileNoSuchFile {
            // 削除対象のファイルがなかった場合は例外を握りつぶす
            return
        }
    }
}


extension FileStorage: IStorage {
    public func upsert<T: Codable>(key: String, value: T) throws {
        try upsert(root.appendingPathComponent(key), value: value)
    }

    public func upsert<T: Codable>(folder: String, key: String, value: T) throws {
        try upsert(try root.add(folder: folder).appendingPathComponent(key), value: value)
    }

    public func get<T: Codable>(key: String, type: T.Type) throws -> T {
        try get(root.appendingPathComponent(key), type: type)
    }
    
    public func get<T: Codable>(folder: String, key: String, type: T.Type) throws -> T {
        try get(try root.add(folder: folder).appendingPathComponent(key), type: type)
    }

    public func gets<T: Codable>(folder: String, type: T.Type) throws -> [T] {
        let files = try root.add(folder: folder).getChildren()
        
        return files.compactMap {
            guard let data = try? Data(contentsOf: $0) else { return nil }
            return try? JSONDecoder().decode(type, from: data)
        }
    }
    
    
    public func delete(key: String) throws {
        try delete(root.appendingPathComponent(key))
    }
    
    public func delete(folder: String, key: String) throws {
        try delete(try root.add(folder: folder).appendingPathComponent(key))
    }
    
    public func deletes(folder: String) throws {
        let files = try root.add(folder: folder).getChildren()
        try files.forEach { try delete($0) }

    }
    
    public func deleteAll() throws {
        let files = try root.getChildren()
        try files.forEach { try delete($0) }
    }
    

}

extension URL {
    fileprivate func getChildren() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
    }
}
