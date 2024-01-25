import Foundation
import Combine

public final class Logger: ObservableObject {
    @Published internal var logs: [Log] = []
    private var subscribers = Set<AnyCancellable>()

    private let _publisher = PassthroughSubject<Log, Never>()
    public var publisher: AnyPublisher<Log, Never> {
        _publisher.eraseToAnyPublisher()
    }
    
    
    public static let shared = Logger()
    private init() {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { log in
            self.logs.append(log)
            self.fileLog(log)
            self.consoleLog(log)
        }
        .store(in: &subscribers)
    }

    fileprivate func log(logLevel: Log.Level, file: String, function: String, line: Int, message: String, allowDuplicate: Bool) {
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

    private var recentLogs: [String] = []
    private let queue = DispatchQueue(label: "Infrastructure.Logger")
    
    internal func clearOnMemoryLogs() {
        self.logs = []
    }
    
    internal func deleteAllLogs() {
        try? URL.log.delete()
        try? URL.logBackup.delete()
        self.logs = []
    }
    
    internal func getLogURL() -> [URL] {
        if FileManager.default.fileExists(atPath: URL.logBackup.path) {
            return [.log, .logBackup]
        }
        return [.log]
    }

}

extension Logger {
    private func fileLog(_ log: Log) {
        let text = "\(log.timestamp.toString(.UTC, format: "yyyy-MM-dd HH:mm:ss.SSS")), \(log.level.rawValue), \(log.file), \(log.line), \(log.function), \(log.message)"
        
        if sizeCheck(fileUrl: .log) ?? 0 >= UInt64(10.MB) {
            move(from: .log, dest: .logBackup)
        }
        guard let stream = OutputStream(url: .log, append: true),
              let text = (text + "\n").data(using: .utf8) else { return }
        
        stream.open()
        defer { stream.close() }
        
        text.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            if let address = buffer.bindMemory(to: UInt8.self).baseAddress {
                stream.write(address, maxLength: buffer.count)
            }
        }
    }
    
    private func sizeCheck(fileUrl: URL) -> UInt64? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: fileUrl.path)
        return attributes?[FileAttributeKey.size] as? UInt64
    }
    
    private func move(from: URL, dest: URL) {
        do {
            try dest.delete()
            try FileManager.default.moveItem(at: from, to: dest)
        } catch {
            logging(.warning, "ファイルの移動に失敗しました: \(error.dump()), from: \(from.path), dest: \(dest.path)")
        }
    }
    
    private func consoleLog(_ log: Log) {
        print("\(log.timestamp.toString(.UTC, format: "yyyy-MM-dd HH:mm:ss.SSS")), \(log.level.rawValue), \(log.file), \(log.line), \(log.function), \(log.message)")
    }
}

extension URL {
    private static var logs: URL { try! appSupport.add(folder: "Log") }
    fileprivate static var log: URL { logs.appendingPathComponent("log.txt") }
    fileprivate static var logBackup: URL { logs.appendingPathComponent("log_old.txt") }
}


/// allowDuplicate = false にすると、直近200件のログに同じ内容があれば処理をスキップします。
public func logging(_ level: Log.Level, file: String = #file, function: String = #function, line: Int = #line, _ message: String, allowDuplicate: Bool = true) {
    Logger.shared.log(logLevel: level, file: file, function: function, line: line, message: message, allowDuplicate: allowDuplicate)
}
