// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

internal protocol LogHandler {
    func eventBus<T>(_ eventBus: EventBus, receivedEvent: T.Type)
}

internal struct DefaultLogHandler: LogHandler {
    func eventBus<T>(_ eventBus: EventBus, receivedEvent eventType: T.Type) {
        #if DEBUG
        print("\(eventBus): Received event '\(eventType)'.")
        #endif
    }
}
