import Foundation

extension Measurement {
    public func toString(_ format: String) -> String {
        self.value.format(format) + " " + self.unit.symbol
    }
}
