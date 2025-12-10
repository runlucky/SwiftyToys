import Foundation

extension Encodable {
    public func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
