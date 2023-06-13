import Foundation

extension Date {
    public func toString(_ timeZone: TimeZone, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        
        return formatter.string(from: self)
    }
    
    public var toUnixTime: Int { Int(self.timeIntervalSince1970) }

    /// 1970/01/01 00:00:00(UTC) を返します
    public static var unixEpoch: Date { Date(timeIntervalSince1970: 0) }

    public func add(_ time: TimeInterval) -> Date {
        self.addingTimeInterval(time)
    }

    /// 指定した時間経ったかどうか
    public func elapses(moreThan: TimeInterval) -> Bool {
        self.add(moreThan) < Date()
    }

    /// 指定した時間以内かどうか
    public func isWithIn(_ time: TimeInterval) -> Bool {
        !elapses(moreThan: time)
    }
}
