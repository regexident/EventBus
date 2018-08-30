//
//  NSLocking+Extensions.swift
//  EventBus
//
//  Created by Vincent Esche on 8/30/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

protocol NSTryLocking: NSLocking {
    func `try`() -> Bool
}

extension NSLock: NSTryLocking {}
extension NSConditionLock: NSTryLocking {}
extension NSRecursiveLock: NSTryLocking {}

extension NSLocking {
    public func with<T>(closure: () -> T) -> T {
        self.lock()
        let result = closure()
        self.unlock()
        return result
    }
}

extension NSTryLocking {
    public func tryWith<T>(closure: () -> T) -> T? {
        guard self.try() else {
            return nil
        }
        let result = closure()
        self.unlock()
        return result
    }
}
