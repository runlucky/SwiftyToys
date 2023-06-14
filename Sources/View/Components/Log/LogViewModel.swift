import SwiftUI
import Combine

internal class LogViewModel: ObservableObject {
    @Published internal var logs: [Log] = []
    private var subscribers = Set<AnyCancellable>()
    
    internal init() {
        
        Logger.publisher
            .sink { log in
                self.logs.append(log)
                self.fileLog(log)
                
            }
            .store(in: &subscribers)
    }
    
    private func fileLog(_ log: Log) {
        let text = "\(log.timestamp.toString(.UTC, format: "yyyy-MM-dd HH:mm:ss.SSS")), \(log.level.rawValue), \(log.file), \(log.line), \(log.function), \(log.message)"

        if sizeCheck(fileUrl: URL.logs) ?? 0 >= UInt64(10.MB) {
            move(from: URL.logs, dest: URL.logsBackup)
        }
        guard let stream = OutputStream(url: URL.logs, append: true),
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
    
    internal func clearDisplay() {
        self.logs = []
    }
    
    internal func deleteAllLogs() {
        try? URL.logs.delete()
        try? URL.logsBackup.delete()
        self.logs = []
    }
    
    internal func getLogURL() -> [URL] {
        if FileManager.default.fileExists(atPath: URL.logsBackup.path) {
            return [.logs, .logsBackup]
        }
        return [.logs]
    }

}

extension URL {
    fileprivate static var logs: URL { root.appendingPathComponent("logs.txt") }
    fileprivate static var logsBackup: URL { root.appendingPathComponent("logs_old.txt") }
}
