import SwiftUI

public struct PickerView<T: IPickerItem>: View {
    @Binding private var item: T
    public init(_ item: Binding<T>) {
        self._item = item
    }
    
    public var body: some View {
        Picker(T.title, selection: $item) {
            ForEach(T.allCases, id: \.self) {
                Text($0.displayName).tag($0)
            }
        }
    }
}
