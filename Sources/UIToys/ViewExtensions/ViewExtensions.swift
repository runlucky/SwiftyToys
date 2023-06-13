import SwiftUI

extension View {
    @ViewBuilder public func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
    
    @ViewBuilder public func showLabel(_ show: Bool) -> some View {
        if show {
            self
        } else {
            self.labelsHidden()
        }
    }
}
