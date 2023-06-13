import Foundation

public struct Log: Codable {
    public let timestamp: Date
    public let level: Level
    public let function: String
    public let file: String
    public let line: Int
    public let message: String

    public init(timestamp: Date, level: Level, function: String, file: String, line: Int, message: String) {
        self.timestamp = timestamp
        self.level     = level
        self.function  = function
        self.file      = file
        self.line      = line
        self.message   = message
    }

    public enum Level: String, Codable {
        /// デバッグ時に使用。サーバへの送信は行わない
        case debug   = "D"
        /// ユーザ操作や重要な処理開始・終了など、特筆すべきこと
        case info    = "I"
        /// 例外発生や想定外の挙動など異常系のログ
        case warning = "W"
        /// アプリがこれ以上実行できなくなる致命的なエラー
        case error   = "E"
    }
}

extension Log: Identifiable {
    public var id: String {
        timestamp.toString(.UTC, format: "yyyy-MM-dd_HH-mm-ss.SSS") .description + message
    }
}
