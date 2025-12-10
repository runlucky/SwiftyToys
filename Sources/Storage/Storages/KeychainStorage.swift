import Foundation

/// Keychainを使用したストレージです
public class KeychainStorage {
    private let bundleIdentifier: String
    private let account: String
    
    /// bundleIdentifier - 特にこだわりが無ければ `Bundle.main.bundleIdentifier!` を指定してください
    /// account - 利用しているユーザ名などを指定してください
    public init(bundleIdentifier: String, account: String) {
        self.bundleIdentifier = bundleIdentifier
        self.account = account
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

extension KeychainStorage: IStorage {
    public func upsert<T: Codable>(_ key: StorageKey, value: T) throws {
        let data = try value.encode()
        
        let query: [String: Any] = [
            kSecClass              as String: kSecClassGenericPassword,
            kSecAttrLabel          as String: bundleIdentifier,
            kSecAttrService        as String: "\(bundleIdentifier).\(key.toString())",
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
    
    public func get<T: Codable>(_ key: StorageKey, type: T.Type) throws -> T {
        let query: [String: Any] = [
            kSecClass              as String: kSecClassGenericPassword,
            kSecAttrLabel          as String: bundleIdentifier,
            kSecAttrService        as String: "\(bundleIdentifier).\(key.toString())",
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
            throw StorageError.notFound(key: key.toString())

        case errSecSuccess:
            guard let item = item,
                  let value = item[kSecValueData as String] as? Data else {
                throw KeychainError.unexpectedPasswordData
            }
            return try value.decode(type)

        default:
            throw KeychainError.unhandled(error: status)
        }
    }

    public func getKeys(folder: String) throws -> [StorageKey] {
        throw KeychainError.notSupported
    }
    

    public func delete(_ key: StorageKey) throws {
        let query: [String: Any] = [
            kSecClass            as String: kSecClassGenericPassword,
            kSecAttrLabel        as String: bundleIdentifier,
            kSecAttrService      as String: "\(bundleIdentifier).\(key.toString())",
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
}

public enum KeychainError: Error {
    case unexpectedPasswordData
    case unhandled(error: OSStatus)
    case deleteError(error: OSStatus)
    case notSupported
}

