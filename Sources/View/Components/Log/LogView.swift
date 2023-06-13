import SwiftUI
import Combine

public struct LogView: View {
    @StateObject private var viewModel = LogViewModel()
    
    public init() {}
    
    public var body: some View {
        List {
            ForEach(viewModel.logs) { log in
                Text(log.message)
            }
        }
    }
}
