//
//  Shared.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 2/22/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

internal struct InvalidSubscriberError: Error {
    // intentionally left blank
}

internal struct UnknownEventError: Error {
    // intentionally left blank
}

internal struct UnhandledEventError: Error {
    // intentionally left blank
}

internal struct WeakBox: Hashable {
    internal weak var inner: AnyObject?

    internal init(_ inner: AnyObject) {
        self.inner = inner
    }

    internal static func == (lhs: WeakBox, rhs: WeakBox) -> Bool {
        return lhs.inner === rhs.inner
    }

    internal static func == (lhs: WeakBox, rhs: AnyObject) -> Bool {
        return lhs.inner === rhs
    }

    internal var hashValue: Int {
        guard let inner = self.inner else {
            return 0
        }
        return ObjectIdentifier(inner).hashValue
    }
}
