import Foundation
import SwiftUI

extension View {
    /// iOS 16未満を考慮した presentationDetents
    @ViewBuilder public func presentationDetentsIfAvailable(_ detents: [PresentationDetentWrapper]) -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents(Set(detents.map { $0.toPresentationDetent }))

        } else {
            self
        }
    }
}

public enum PresentationDetentWrapper {
    case medium
    case large
    case fraction(CGFloat)
    
    @available(iOS 16.0, *)
    public var toPresentationDetent: PresentationDetent {
        switch self {
        case .medium: return .medium
        case .large: return .large
        case .fraction(let value): return .fraction(value)
        }
    }
}
