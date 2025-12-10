import Foundation

extension Data {
    public func toString(_ encoding: String.Encoding) -> String? {
        String(data: self, encoding: encoding)
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
}

