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
    
    public var expirationDate: Date? {
      guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
            let data = try? Data(contentsOf: url),
            let start = "<?xml".data(using: .utf8),
            let end = "</plist>".data(using: .utf8),
            let startRange = data.range(of: start),
            let endRange = data.range(of: end) else {
        return nil
      }
      
      let range = Range(uncheckedBounds: (lower: startRange.lowerBound, upper: endRange.upperBound))
      guard let dictionary = try? PropertyListSerialization.propertyList(from: data.subdata(in: range), options: [], format: nil),
            let plist = dictionary as? [String: Any],
            let expirationDate = plist["ExpirationDate"] as? Date else {
          return nil
      }
      
      return expirationDate
    }
}
