import SwiftUI
import Combine

internal class LogViewModel: ObservableObject {
    @Published internal var logs: [Log] = []
    
    private var subscribers = Set<AnyCancellable>()
    
    internal init() {
        Logger.publisher
            .sink { self.logs.append($0) }
            .store(in: &subscribers)
    }
}
