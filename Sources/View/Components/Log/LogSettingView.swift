import SwiftUI

internal struct LogSettingView: View {
    private let viewModel: LogViewModel
    @State private var showShareSheet = false
    @Binding private var show: Bool

    @AppStorage("LogSetting.level") private var logLevel: LogLevel = .defaultItem
    @AppStorage("LogSetting.UUID") private var logUUID: LogUUID = .defaultItem
    @AppStorage("LogSetting.date") private var logDate: LogDate = .defaultItem


    internal init(_ show: Binding<Bool>, viewModel: LogViewModel) {
        self._show = show
        self.viewModel = viewModel
    }

    internal var body: some View {
        List {
            Section(header: Text("表示設定")) {
                row($logLevel)
                row($logUUID)
                row($logDate)
            }

            Button("ログ共有") {
                showShareSheet = true
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(activityItems: viewModel.getLogURL())
            }

            Button("表示クリア") {
                viewModel.clearDisplay()
                show = false
            }

            Button("ログファイル削除") {
                viewModel.deleteAllLogs()
                show = false
            }
            .foregroundColor(.red)
        }
    }
    
    private func row<T: IPickerItem>(_ item: Binding<T>) -> some View {
        HStack {
            Text(T.title)
            Spacer()
            PickerView(item)
                .pickerStyle(.segmented)
                .frame(width: 150)
        }
    }
}



enum LogLevel: String, IPickerItem {
    case info
    case debug
    
    static var title: String = "ログ表示レベル"
    static var defaultItem: LogLevel = .info
    var displayName: String { self.rawValue }
}

enum LogUUID: String, IPickerItem {
    case visible
    case hidden
    
    static var title: String = "UUID"
    static var defaultItem: LogUUID = .hidden
    var displayName: String { self.rawValue }
}

enum LogDate: String, IPickerItem {
    case visible
    case hidden
    
    static var title: String = "年月日"
    static var defaultItem: LogDate = .hidden
    var displayName: String { self.rawValue }
}
