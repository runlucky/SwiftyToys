import Foundation

public protocol IStorage {
    /// valueを指定したkey名で保存します。すでに同じkey名が存在する場合は上書きします。
    func upsert<T: Codable>(_ key: StorageKey, value: T) throws
    
    /// 指定したkey名とtypeに一致するオブジェクトを返します。
    func get<T: Codable>(_ key: StorageKey, type: T.Type) throws -> T
    /// 指定したfolder内にある、typeに一致するオブジェクトをすべて返します。
    func getKeys(folder: String) throws -> [StorageKey]
    
    /// 指定したkey名とtypeに一致するオブジェクトを削除します。
    func delete(_ key: StorageKey) throws
    /// すべてのオブジェクトを削除します。
    func deleteAll() throws
}


public struct StorageKey {
    public let folder: String?
    public let file: String
    /// folderは省略可能です。nilの場合はroot階層の指定になります。
    /// folderは1階層までです。"/"を用いて"foo/bar"のような記載はできません。
    public init(folder: String? = nil, file: String) {
        self.folder = folder
        self.file = file
    }
    
    internal func toString() -> String {
        if let folder {
            return "\(folder).\(file)"
        }
        return file
    }
}
