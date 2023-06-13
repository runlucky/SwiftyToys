import Foundation

extension Error {
    public func dump() -> String {
        let e = self as NSError
        return "domain: \(e.domain.replace(pattern: ".*\\.", to: "")), code: \(e.code), type: \(self), description: \(e.localizedDescription)"
    }
}
