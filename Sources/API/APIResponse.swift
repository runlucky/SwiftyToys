import Foundation

public struct APIResponse: Equatable {
    internal let body: Data
    internal let response: URLResponse
    public var statusCode: Int? { (response as? HTTPURLResponse)?.statusCode }
    public var stringBody: String? { body.toString(.utf8) }

    public func decode<T: Codable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: body)
    }
}
