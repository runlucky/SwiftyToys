import SwiftUI

extension Button where Label == Image {
    public init(systemName: String, file: String = #file, function: String = #function, line: Int = #line, action: @escaping () -> Void) {
        self.init(action: {
            logging(.info, file: file, function: function, line: line, "[\(systemName)]ボタン押下")
            action()
        }) {
            Image(systemName: systemName)
        }
    }

}
