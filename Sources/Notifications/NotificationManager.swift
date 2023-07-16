import Foundation
import UserNotifications
import UIKit

public final class NotificationManager: NSObject {
    public static let shared = NotificationManager()
    private override init() {
        super.init()
    }
    
    public func requestAuthorization(_ options: UNAuthorizationOptions) {
        
        Task {
            do {
                let authorized = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
                logging(.info, "通知許可: \(authorized)")

                if authorized {
                    UNUserNotificationCenter.current().delegate = self
                }
                
            } catch {
                logging(.warning, "通知許可エラー: \(error.dump())")
            }
        }
    }
}


extension NotificationManager: UNUserNotificationCenterDelegate {
    /// アプリがフォアグラウンドの場合でも通知を出したい場合はこのメソッドを実装します。
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        logging(.info, "フォアグラウンド通知: \(notification.id), title: \(notification.title), body: \(notification.body)")
        completionHandler([[.banner, .list, .badge, .sound]])
    }

    /// ユーザが通知に応答したときに呼ばれます
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        logging(.info, "ユーザが通知に応答しました: \(notification.id), title: \(notification.title), body: \(notification.body)")
        completionHandler()
    }
}

extension UNNotification {
    fileprivate var id: String { self.request.identifier }
    fileprivate var body: String { self.request.content.body }
    fileprivate var title: String { self.request.content.title }
}
