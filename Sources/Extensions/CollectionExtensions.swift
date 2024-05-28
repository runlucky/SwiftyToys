//
//  File.swift
//  
//
//  Created by kakeru on 2024/05/08.
//

import Foundation

extension Collection {
    @inlinable public var hasElement: Bool {
        !self.isEmpty
    }
    
    /// 重複した要素を削除して返します
    public func uniqued() -> [Element] where Element: Hashable {
        Array(Set(self))
    }
}
