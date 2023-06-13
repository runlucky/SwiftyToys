import SwiftUI

extension Color {
    /// テーブルViewなどグループ化されたUIのメイン背景色
    public static var groupedBackground: Color { Color(.systemGroupedBackground) }
    /// メイン背景色の上に重ねる2次背景色
    public static var groupedBackgroundSecondary: Color { Color(.secondarySystemGroupedBackground ) }
    /// 2次背景色の上に重ねる3次背景色
    public static var groupedBackgroundTertiary: Color { Color(.tertiarySystemGroupedBackground) }

    /// グループ化されていないUIのメイン背景色
    public static var background: Color { Color(.systemBackground) }
    /// メイン背景色の上に重ねる2次背景色
    public static var backgroundSecondary: Color { Color(.secondarySystemBackground) }
    /// 2次背景色の上に重ねる3次背景色
    public static var backgroundTertiary: Color { Color(.tertiarySystemBackground) }

    
    /// 3次コンテンツのテキスト色
    public static var tertiary: Color { Color(.tertiaryLabel) }
    /// プレースホルダーのテキスト色
    public static var textPlaceholder: Color { Color(.placeholderText)}
    /// リンクのテキスト色
    public static var textLink: Color { Color(.link)}

}
