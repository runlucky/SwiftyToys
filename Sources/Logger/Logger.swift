import Foundation
import Combine

public struct Logger {
    private static let _publisher = PassthroughSubject<Log, Never>()
    public static var publisher: AnyPublisher<Log, Never> {
        _publisher.eraseToAnyPublisher()
    }

    fileprivate static func log(logLevel: Log.Level, file: String, function: String, line: Int, message: String, allowDuplicate: Bool) {
        let ban: Bool = queue.sync {
            if 200 < recentLogs.count {
                recentLogs.removeFirst()
            }
            
            if allowDuplicate {
                recentLogs.append(message)
                return false
            }

            if recentLogs.contains(message) { return true }
            recentLogs.append(message)
            return false
        }
        if ban { return }

        let file = NSString(string: NSString(string: file).lastPathComponent).deletingPathExtension
        let function = function.replace(pattern: "\\(.*\\)", to: "")
        _publisher.send(Log(timestamp: Date(), level: logLevel, function: function, file: file, line: line, message: message))
    }

    private static var recentLogs: [String] = []
    private static let queue = DispatchQueue(label: "Infrastructure.Logger")
}

/// allowDuplicate = false にすると、直近200件のログに同じ内容があれば処理をスキップします。
public func logging(_ level: Log.Level, file: String = #file, function: String = #function, line: Int = #line, _ message: String, allowDuplicate: Bool = true) {
    Logger.log(logLevel: level, file: file, function: function, line: line, message: message, allowDuplicate: allowDuplicate)
}
