import Foundation

/// URLRequestやURLComponentsを使いやすくしたwrapperです
public class RequestBuilder {
    private let method: HttpMethod
    private let scheme: String
    private let host: String
    private let path: String
    private var headers: [(header: String, value: String)] = []
    private var body: Data?
    private var queries: [URLQueryItem] = []

    public init(_ method: HttpMethod, scheme: String = "https", host: String, path: String) {
        self.method = method
        self.scheme = scheme
        self.host = host
        self.path = path
    }
    
    public func add(header: String, _ value: String) -> RequestBuilder {
        self.headers += [(header, value)]
        return self
    }

    public func add(body data: Data) -> RequestBuilder {
        self.body = data
        return self
    }

    public func add(body string: String) -> RequestBuilder {
        self.body = string.data(using: .utf8)
        return self
    }

    /// クエリパラメータを追加して返します。
    /// valueがnilの場合は何もせず返します
    public func add(query: String, _ value: String?) -> RequestBuilder {
        guard let value else { return self }

        self.queries += [URLQueryItem(name: query, value: value)]
        return self
    }

    public func request() async throws(RequestBuilderError) -> APIResponse {
        let request = try build()
        let response = try await sendRequest(request)

        guard let statusCode = response.statusCode,
              (200...299).contains(statusCode) else {
            throw .badResponse(response)
        }

        return response
    }

    private func build() throws(RequestBuilderError) -> URLRequest {
        var component = URLComponents()
        component.scheme = scheme
        component.host = host
        component.path = path
        component.queryItems?.append(contentsOf: queries)

        guard let url = component.url else { throw .invalidRequestURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        headers.forEach { header, value in
            request.addValue(value, forHTTPHeaderField: header)
        }

        return request
    }
    
    private func sendRequest(_ request: URLRequest) async throws(RequestBuilderError) -> APIResponse {
        let start = Date()
        let url = request.url?.absoluteString ?? "nil"

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            let response = APIResponse(body: data, response: urlResponse)
            logging(.info, "\(url), response(\(response.statusCode?.description ?? "nil")), \(round(start.elapsedTime * 1000) / 1000) s, \(response.body.count) bytes")

            return response
            
        } catch {
            let url = request.url?.absoluteString ?? "nil"
            logging(.warning, "\(url), error \(error.dump()), \(round(start.elapsedTime * 1000) / 1000) s,")
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet): throw .offline
            case (NSURLErrorDomain, NSURLErrorTimedOut              ): throw .offline // タイムアウトもオフライン扱いにする
            case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost ): throw .offline // 接続が切れた場合もオフライン扱いにする
            default: throw .unknown(error)
            }
        }
    }
}

public enum RequestBuilderError: LocalizedError {
    case badResponse(APIResponse)
    case offline
    case invalidRequestURL
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .badResponse(let response): "code: \(response.statusCode?.description ?? "nil"), body: \(response.stringBody ?? "nil")"
        case .offline                  : "オフラインです"
        case .invalidRequestURL        : "無効なリクエストです"
        case .unknown(let error)       : "不明なエラーです, \(error.dump())"
        }
    }
}
