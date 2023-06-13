import Foundation

extension URL {
    public var exists: Bool {
        FileManager.default.fileExists(atPath: self.path)
    }

    public func delete() throws {
        guard self.exists else { return }
        try FileManager.default.removeItem(at: self)
    }

    private static var library: URL { FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first! }
    public static var root: URL { library.appendingPathComponent(AppSettings.shared.bundleIdentifier) }
}
