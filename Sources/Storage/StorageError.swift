import Foundation

public enum StorageError: LocalizedError {
    case notFound(key: String)
    case createFileFailed(key: String)

    public var errorDescription: String? {
        switch self {
        case .notFound(key: let key): "key: \(key) が見つかりませんでした。"
        case .createFileFailed(key: let key): "key: \(key) のファイル作成に失敗しました。"
        }
    }
}
