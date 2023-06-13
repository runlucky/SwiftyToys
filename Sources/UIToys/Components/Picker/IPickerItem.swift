public protocol IPickerItem: Hashable, CaseIterable where AllCases: RandomAccessCollection {
    static var title: String { get }
    static var defaultItem: Self { get }
    var displayName: String { get }
}


/// IPickerItemの例
private enum Fruit {
    case apple
    case banana
    case cherry
}

extension Fruit: IPickerItem {
    static let title: String = "くだもの"
    static let defaultItem: Fruit = .apple
    
    var displayName: String {
        switch self {
        case .apple: return "りんご"
        case .banana: return "バナナ"
        case .cherry: return "さくらんぼ"

        }
    }
}

