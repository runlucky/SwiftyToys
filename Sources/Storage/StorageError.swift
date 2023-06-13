import Foundation

public enum StorageError: LocalizedError {
    case notFound(key: String)
    
    public var errorDescription: String? {
        switch self {
        case .notFound(key: let key): return "key: \(key) が見つかりませんでした。"
        }
    }
}
