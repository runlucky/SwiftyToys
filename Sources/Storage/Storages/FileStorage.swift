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
    
    func toURL(_ key: StorageKey) throws -> URL {
        if let folder = key.folder {
            return try root.add(folder: folder).appendingPathComponent(key.file)
        }

        return root.appendingPathComponent(key.file)
    }
}


extension FileStorage: IStorage {

    public func upsert<T: Codable>(_ key: StorageKey, value: T) throws {
        let url = try toURL(key)
        let data = try JSONEncoder().encode(value)

        let isSuccess = fileManager.createFile(atPath: url.path, contents: data)
        if !isSuccess {
            logging(.warning, "ファイル作成に失敗, key: \(url.absoluteString)")
            throw StorageError.createFileFailed(key: url.absoluteString)
        }
    }

    public func get<T: Codable>(_ key: StorageKey, type: T.Type) throws -> T {
        let url = try toURL(key)
        guard fileManager.fileExists(atPath: url.path) else { throw StorageError.notFound(key: url.absoluteString) }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }

    public func getKeys(folder: String) throws -> [StorageKey] {
        try root.add(folder: folder)
                .getChildren()
                .map { StorageKey(folder: folder, file: $0.lastPathComponent) }
    }
    
    
    public func delete(_ key: StorageKey) throws {
        let url = try toURL(key)
        // 削除対象のファイルがなかった場合は例外扱いにしない
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }
    
    public func deleteAll() throws {
        try root.getChildren()
                .forEach { try fileManager.removeItem(at: $0) }
    }}

extension URL {
    fileprivate func getChildren() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
    }
}

