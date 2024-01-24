import Foundation

public protocol IStorage {
    /// valueを指定したkey名で保存します。すでに同じkey名が存在する場合は上書きします。
    func upsert<T: Codable>(key: String, value: T) throws
    /// valueを指定したfolder内にあるkey名で保存します。すでに同じkey名が存在する場合は上書きします。
    /// foderは1階層までです。"foo/bar"のような指定はできません。
    func upsert<T: Codable>(folder: String, key: String, value: T) throws
    
    /// 指定したkey名とtypeに一致するオブジェクトを返します。
    func get<T: Codable>(key: String, type: T.Type) throws -> T
    /// 指定したfolder内にあるkey名とtypeに一致するオブジェクトを返します。
    func get<T: Codable>(folder: String, key: String, type: T.Type) throws -> T
    /// 指定したfolder内にある、typeに一致するオブジェクトをすべて返します。
    func gets<T: Codable>(folder: String, type: T.Type) throws -> [T]
    
    /// 指定したkey名とtypeに一致するオブジェクトを削除します。
    func delete(key: String) throws
    /// 指定したfolder内にあるkey名とtypeに一致するオブジェクトを削除します。
    func delete(folder: String, key: String) throws
    /// 指定したfolder内にあるすべてのオブジェクトを削除します。
    func deletes(folder: String) throws
    /// すべてのオブジェクトを削除します。
    func deleteAll() throws
}
