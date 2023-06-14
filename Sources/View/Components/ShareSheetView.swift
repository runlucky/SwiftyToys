import SwiftUI

/// UIActivityViewControllerを表示します
public struct ShareSheetView: UIViewControllerRepresentable {
    private let activityItems: [Any]
    private let applicationActivities: [UIActivity]?
    private let excludedActivityTypes: [UIActivity.ActivityType]?

    /// activityItems: 共有したい対象物
    /// applicationActivities: 自作した共有先
    /// excludedActivityTypes: 表示しない共有先
    public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        vc.excludedActivityTypes = excludedActivityTypes
        vc.excludedActivityTypes = excludedActivityTypes
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
