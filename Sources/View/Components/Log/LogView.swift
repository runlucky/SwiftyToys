import SwiftUI
import Combine

public struct LogView: View {
    @StateObject private var viewModel = Logger.shared
    @State private var showSheet = false
    
    @AppStorage("LogSetting.level") private var logLevel: LogLevel = .defaultItem
    @AppStorage("LogSetting.UUID") private var logUUID: LogUUID = .defaultItem
    @AppStorage("LogSetting.date") private var logDate: LogDate = .defaultItem
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                if viewModel.logs.isEmpty {
                    Text("no content...")
                }
                
                ForEach(viewModel.logs) { log in
                    if showDebugLog(log) {
                        Text(getText(log))
                            .lineLimit(nil)
                            .font(.system(size: 12, design: .monospaced))
                    }
                }
            }
            .navigationBarTitle(Text("ログ"))
            .navigationBarItems(trailing:
                Button(systemName: "gear") { showSheet = true }
                    .padding(10)
            )
            .environment(\.defaultMinListRowHeight, 12)
        }
        .sheet(isPresented: $showSheet) {
            LogSettingView($showSheet)
        }
    }
    
    private func showDebugLog(_ log: Log) -> Bool {
        if logLevel == .debug { return true }
        if log.level == .debug { return false }
        return true
    }
    
    private func getText(_ log: Log) -> String {
        var result = ""
        
        switch logDate {
        case .visible: result += "\(log.timestamp.toString(.current, format: "yyyy-MM-dd HH:mm:ss.SSS"))"
        case .hidden: result += "\(log.timestamp.toString(.current, format: "HH:mm:ss.SSS"))"
        }
        
        if logUUID == .visible { result += ", \(AppSettings.shared.uuid)" }
        result += ", \(log.level.rawValue), \(log.file)(\(log.line)), \(log.function), \(log.message)"
        
        return result
    }
    
}
