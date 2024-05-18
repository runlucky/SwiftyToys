import SwiftUI

public struct LogView: View {
    @StateObject private var viewModel = Logger.shared
    @State private var showSheet = false

    @AppStorage("LogView.showTimestamp") var showTimestamp = true
    @AppStorage("LogView.showLevel") var showLevel = true
    @AppStorage("LogView.showFile") var showFile = true
    @AppStorage("LogView.showLine") var showLine = true
    @AppStorage("LogView.showFunction") var showFunction = true
    
    @AppStorage("LogView.lineLimit") var lineLimit = 1
    @AppStorage("LogView.fontSize") var fontSize = 12

    public init() { }
    
    public var body: some View {
        List {
            if viewModel.logs.isEmpty {
                Text("no content...")
            }
            
            ForEach(viewModel.logs) { log in
                Text(getLogTextAttribute(log))
                    .font(.system(size: CGFloat(fontSize), design: .monospaced))
                    .lineLimit(lineLimit == 0 ? nil : lineLimit)
                    .listRowInsets(.init(top: 3, leading: 10, bottom: 3, trailing: 10))
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .navigationBarTitle(Text("ログ"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(systemName: "gear") {
                    showSheet = true
                }
            }
        }
        
        .sheet(isPresented: $showSheet) {
            LogSettingView(showSettingView: $showSheet,
                           showTimestamp: $showTimestamp,
                           showLevel: $showLevel,
                           showFile: $showFile,
                           showLine: $showLine,
                           showFunction: $showFunction,
                           lineLimit: $lineLimit,
                           fontSize: $fontSize)
            .presentationDetents([.medium, .large, .fraction(0.35)])
        }
    }
    
    private func getLogTextAttribute(_ log: Log) -> AttributedString {
        let text = [timestamp(log), level(log), file(log), line(log), function(log), log.message]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        var attributed = AttributedString(text)

        if showTimestamp, let range = attributed.range(of: timestamp(log)) {
            attributed[range].foregroundColor = .text.opacity(0.6)
        }
        if showLevel, let range = attributed.range(of: level(log)) {
            attributed[range].foregroundColor = log.level.color
        }
        if showFile, let range = attributed.range(of: file(log)) {
            attributed[range].foregroundColor = .mint
        }
        if showLine, let range = attributed.range(of: line(log)) {
            attributed[range].foregroundColor = .mint
        }
        if showFunction, let range = attributed.range(of: function(log)) {
            attributed[range].foregroundColor = .indigo
        }
        return attributed
    }
    
    private func timestamp(_ log: Log) -> String {
        showTimestamp ? log.timestamp.toString(.current, format: "HH:mm:ss.SSS") : ""
    }
    
    private func level(_ log: Log) -> String {
        showLevel ? log.level.rawValue : ""
    }
    
    private func file(_ log: Log) -> String {
        showFile ? log.file : ""
    }
    
    private func line(_ log: Log) -> String {
        showLine ? "\(log.line)" : ""
    }
    
    private func function(_ log: Log) -> String {
        showFunction ? log.function : ""
    }
}

#Preview {
    NavigationStack {
        LogView()
    }
}

extension Log.Level {
    fileprivate var color: Color {
        switch self {
        case .debug  : .text.opacity(0.6)
        case .info   : .text.opacity(0.6)
        case .warning: .orange
        case .error  : .red
        }
    }
}
