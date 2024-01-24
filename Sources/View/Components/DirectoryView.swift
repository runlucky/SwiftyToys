import SwiftUI

/// 指定したディレクトリを表示するビューです。
public struct DirectoryView: View {
    @State var current: URL
    @State var showFile: URL? = nil
    @State var showShareSheet: URL? = nil
    
    public init(current: URL) {
        self._current = State(initialValue: current)
    }

    public var body: some View {
        Form {
            ForEach(current.getChildren()
                        .sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
                        .sorted(by: { lhs, rhs in lhs.hasDirectoryPath }), id: \.self) { child in
                getRowItem(child)
                    .contextMenu {
                        if !child.hasDirectoryPath {
                            getContextMenuButton(text: "開く") {
                                self.showFile = child
                            }
                        } else {
                            Text("\(String.localizedStringWithFormat("%d", child.getSize())) bytes")
                        }

                        getContextMenuButton(text: "共有", "square.and.arrow.up") {
                            self.showShareSheet = child
                        }

                        getContextMenuButton(text: "削除", "trash", destructive: true) {
                            try? child.delete()
                        }
                    }
            }
            .sheet(item: $showFile) { url in
                FileView(url: url) {
                    self.showFile = nil
                }
            }
            .sheet(item: $showShareSheet) { url in
                ShareSheetView(activityItems: [url])
            }
        }
        .font(.system(size: 14, design: .monospaced))
        .environment(\.defaultMinListRowHeight, 32)
        .navigationBarTitle(current.lastPathComponent, displayMode: .inline)
    }

    @ViewBuilder private func getContextMenuButton(text: String, _ systemName: String? = nil, destructive: Bool = false, _ action: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            Button(role: destructive ? .destructive : .none, action: action, label: {
                HStack {
                    Text(text)
                    if let systemName = systemName {
                        Image(systemName: systemName)
                    }
                }
            })
        } else {
            Button(action: action, label: {
                HStack {
                    Text(text)
                    if let systemName = systemName {
                        Image(systemName: systemName)
                    }
                }
            })
        }
    }

    @ViewBuilder private func getRowItem(_ url: URL) -> some View {
        if url.hasDirectoryPath {

            if url.getChildren().count > 0 {
                NavigationLink(destination: DirectoryView(current: url)) {
                    HStack {
                        Image(systemName: "folder")
                        Text("\(url.lastPathComponent) (\(url.getChildren().count) items)")
                    }
                }
            } else {
                HStack {
                    Image(systemName: "folder")
                    Text("\(url.lastPathComponent) (\(url.getChildren().count) items)")
                }
                .opacity(0.5)
            }
        } else {
            Button {
                showFile = url
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                    Text("\(url.lastPathComponent) (\(String.localizedStringWithFormat("%d", url.getSize())) bytes)")
                }
            }
        }
    }
}

internal struct FileView: View {
    private let url: URL
    private let text: String
    private let onClose: () -> Void

    internal init(url: URL, onClose: @escaping () -> Void) {
        self.url = url
        self.onClose = onClose

        let text: String = {
            if let str = try? String(contentsOf: url) {
                return str
            } else if let data = try? Data(contentsOf: url) {
                return data.toHex()
            } else {
                return "***no content***"
            }
        }()

        if text.count > 10000 {
            self.text = text.prefix(10000) + "..."
        } else {
            self.text = text
        }
    }

    internal var body: some View {
        NavigationView {
            ScrollView {
                Text(text)
                    .font(.system(size: 14, design: .monospaced))
            }
            .padding(10)
            .navigationBarTitle(url.lastPathComponent, displayMode: .inline)
            .navigationBarItems(leading: Button("閉じる", action: onClose))
        }
    }
}

extension URL {
    fileprivate func getChildren() -> [URL] {
        let contents = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
        return contents ?? []
    }

    fileprivate func getSize() -> UInt {
        if self.hasDirectoryPath {
            return getChildren().reduce(0) { $0 + $1.getSize() }
        } else {
            return UInt((try? self.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
        }
    }
}

extension URL: Identifiable {
    public var id: URL { self }
}

extension Data {
    fileprivate func toHex(separator: String = " ") -> String {
        "0x" + self.map { String(format: "%.2X", $0) }
            .joined(separator: separator)
    }
}
