import Foundation

extension Data {
    public func toString(_ encoding: String.Encoding) -> String? {
        String(data: self, encoding: encoding)
    }
}

