// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// A reduced type-erased interface for EventBus
/// for selectively exposing its type-registration capabilities.
public protocol EventRegistrable: EventBusProtocol {
    /// Registers a given event bus for a given event type.
    ///
    /// - Parameters:
    ///   - eventType: the event type to register
    ///
    /// - Note:
    ///   This only has an effect if the event bus
    ///   has been initialized with the `Options.warnUnknown` flag.
    ///
    /// ```
    /// protocol MyEvent {
    ///     // ...
    /// }
    ///
    /// let eventBus = EventBus()
    /// eventBus.register(forEvent: MyEvent.self)
    /// ```
    func register<T>(forEvent eventType: T.Type)
}
