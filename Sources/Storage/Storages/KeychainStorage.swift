import Foundation

/// Keychainを使用したストレージです
public class KeychainStorage: IStorage {
    private let bundleIdentifier: String
    private let account: String
    
    /// bundleIdentifier - 特にこだわりが無ければ `Bundle.main.bundleIdentifier!` を指定してください
    /// account - 利用しているユーザ名などを指定してください
    public init(bundleIdentifier: String, account: String) {
        self.bundleIdentifier = bundleIdentifier
        self.account = account
    }
    
    public func get<T: Codable>(key: String, type: T.Type) throws -> T {
        let query: [String: Any] = [
            kSecClass              as String: kSecClassGenericPassword,
            kSecAttrLabel          as String: bundleIdentifier,
            kSecAttrService        as String: "\(bundleIdentifier).\(key)",
            kSecAttrAccount        as String: account,
            kSecMatchLimit         as String: kSecMatchLimitOne,
            kSecReturnAttributes   as String: true,
            kSecReturnData         as String: true,
            kSecAttrSynchronizable as String: kCFBooleanFalse!,
        ]

        var item: CFTypeRef?

        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecItemNotFound:
            throw StorageError.notFound(key: key)

        case errSecSuccess:
            guard let item = item,
                  let value = item[kSecValueData as String] as? Data else {
                throw KeychainError.unexpectedPasswordData
            }
            return try JSONDecoder().decode(type, from: value)

        default:
            throw KeychainError.unhandled(error: status)
        }
    }
    
    public func upsert<T: Codable>(key: String, value: T) throws {
        let data = try JSONEncoder().encode(value)
        
        let query: [String: Any] = [
            kSecClass              as String: kSecClassGenericPassword,
            kSecAttrLabel          as String: bundleIdentifier,
            kSecAttrService        as String: "\(bundleIdentifier).\(key)",
            kSecAttrAccount        as String: account,
            kSecValueData          as String: data,
            kSecAttrAccessible     as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrSynchronizable as String: kCFBooleanFalse!
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        switch status {
        case errSecItemNotFound:
            SecItemAdd(query as CFDictionary, nil)
            
        case errSecSuccess:
            SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
            
        default:
            throw KeychainError.unhandled(error: status)
        }
        
    }

    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass            as String: kSecClassGenericPassword,
            kSecAttrLabel        as String: bundleIdentifier,
            kSecAttrService      as String: "\(bundleIdentifier).\(key)",
            kSecAttrAccount      as String: account,
        ]
        try delete(query as CFDictionary)
    }
    
    public func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass            as String: kSecClassGenericPassword,
            kSecAttrLabel        as String: bundleIdentifier,
        ]
        try delete(query as CFDictionary)
    }
    
    private func delete(_ query: CFDictionary) throws {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        
        switch status {
        case errSecItemNotFound:
            return

        case errSecSuccess:
            let status = SecItemDelete(query)
            if status != errSecSuccess { throw KeychainError.deleteError(error: status) }

        default:
            throw KeychainError.unhandled(error: status)
        }
    }
}

public enum KeychainError: Error {
    case unexpectedPasswordData
    case unhandled(error: OSStatus)
    case deleteError(error: OSStatus)
}
