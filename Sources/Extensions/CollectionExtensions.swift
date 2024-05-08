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
    
    public func uniqued() -> [Element] where Element: Hashable {
        Array(Set(self))
    }
}
