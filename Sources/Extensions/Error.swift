import Foundation

extension Error {
    public func dump() -> String {
        "domain: \(domain), code: \(code), description: \(localizedDescription)"
    }

    public var domain: String { (self as NSError).domain.replacing(/.*\./, with: "") }
    public var code: Int { (self as NSError).code }
}
