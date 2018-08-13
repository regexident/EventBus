//
//  EventRegistrable.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

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
