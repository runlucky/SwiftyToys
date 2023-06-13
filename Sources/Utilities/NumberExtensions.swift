import Foundation

extension Int {
    public var seconds: TimeInterval { TimeInterval(self) }
    public var minutes: TimeInterval { TimeInterval(self * 60) }
    public var hours: TimeInterval { TimeInterval(self) * 60.minutes }
    public var days: TimeInterval { TimeInterval(self) * 24.hours }

    public var KB: Int { self * 1024 }
    public var MB: Int { self * 1024.KB }
    public var GB: Int { self * 1024.MB }
}

extension Double {
    /// scale: 小数点以下の桁数
    public func toDecimal(scale: Int16) -> Decimal {
        NSDecimalNumber(value: self).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .plain, scale: scale, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)).decimalValue
    }
}

extension Float {
    /// scale: 小数点以下の桁数
    public func toDecimal(scale: Int16) -> Decimal {
        NSDecimalNumber(value: self).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .plain, scale: scale, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)).decimalValue
    }
}

extension Decimal {
    public func toDouble() -> Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

extension CVarArg {
    public func format(_ format: String) -> String {
        String(format: format, self)
    }
}
