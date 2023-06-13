import Foundation

#if canImport(UIKit)
import UIKit
#endif

public final class AppSettings {
    public static let shared = AppSettings()
    private init() {}
    
    /// 端末固有のID
    /// 再インストールすると別の値になる
    public var uuid: String {
        if let uuid = UserDefaults.standard.string(forKey: "AppSettings.uuid") {
            return uuid
        }
        
        #if canImport(UIKit)
        let uuid = (UIKit.UIDevice.current.identifierForVendor ?? UUID()).uuidString.suffix(4).description
        #else
        let uuid = UUID().uuidString.suffix(4).description
        #endif

        UserDefaults.standard.set(uuid, forKey: "AppSettings.uuid")
        return uuid
    }
    
    /// アプリ固有のID
    public var bundleIdentifier: String { Bundle.main.bundleIdentifier ?? "nil bundleIdentifier" }
    /// アプリのバージョン
    public var version: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "不明" }
    /// アプリのビルド番号
    public var buildNumber: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "不明" }
}
