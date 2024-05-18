import SwiftUI

public struct LogSettingView: View {
    @Binding var showSettingView: Bool
    
    @Binding var showTimestamp: Bool
    @Binding var showLevel: Bool
    @Binding var showFile: Bool
    @Binding var showLine: Bool
    @Binding var showFunction: Bool
    
    @Binding var lineLimit: Int
    @Binding var fontSize: Int
    
    public init(showSettingView: Binding<Bool>, showTimestamp: Binding<Bool>, showLevel: Binding<Bool>, showFile: Binding<Bool>, showLine: Binding<Bool>, showFunction: Binding<Bool>, lineLimit: Binding<Int>, fontSize: Binding<Int>) {
        self._showSettingView = showSettingView
        self._showTimestamp = showTimestamp
        self._showLevel = showLevel
        self._showFile = showFile
        self._showLine = showLine
        self._showFunction = showFunction
        self._lineLimit = lineLimit
        self._fontSize = fontSize
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("時刻", isOn: $showTimestamp)
                    Toggle("ログレベル", isOn: $showLevel)
                    Toggle("ファイル", isOn: $showFile)
                    Toggle("行", isOn: $showLine)
                    Toggle("メソッド名", isOn: $showFunction)
                }
                
                Section {
                    Stepper("最大表示行数: \(lineLimit == 0 ? "nil" : lineLimit.description)", value: $lineLimit, in: 0...5)
                    Stepper("フォントサイズ: \(fontSize.description)", value: $fontSize, in: 6...24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { showSettingView = false }
                }
            }
            .navigationTitle("表示設定")
        }
    }
}

