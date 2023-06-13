import Foundation

extension String {
    internal var length: Int {
        (self as NSString).length
    }

    public func replace(pattern: String, to: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return "" }
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.length), withTemplate: to)
    }
}
