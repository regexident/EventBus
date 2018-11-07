// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
