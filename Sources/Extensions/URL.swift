import Foundation

extension URL {
    public var exists: Bool {
        FileManager.default.fileExists(atPath: self.path)
    }

    public func add(folder: String) throws -> URL {
        let url = self.appendingPathComponent(folder)

        if !url.exists {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        
        return url
    }

    public func delete() throws {
        guard self.exists else { return }
        try FileManager.default.removeItem(at: self)
    }

    public static var library: URL { FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first! }
    public static var root: URL { library.appendingPathComponent(AppSettings.shared.bundleIdentifier) }
}
