import Foundation

extension String {
    internal var length: Int {
        (self as NSString).length
    }

    public func replace(pattern: String, to: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return "" }
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.length), withTemplate: to)
    }
    
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(self.utf8))
    }
    
    public func toDate(_ timeZone: TimeZone, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        
        return formatter.date(from: self)
    }

}
