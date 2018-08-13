//
//  EventChainable.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-chaining capabilities.
public protocol EventChainable: EventBusProtocol {
    /// Attaches a second event bus chained to the event bus.
    ///
    /// - Note:
    ///   - Notified events on `self` get forwarded to chains attached for eventType.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///   - eventType: the event type for which to attach the chain for
    ///
    /// ```
    /// let eventBus = EventBus()
    /// let chainedEventBus = EventBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventBus, for: MyEvent.self)
    /// ```
    func attach<T>(chain: EventNotifiable, for eventType: T.Type)

    /// Attaches a second event bus chained to the event bus.
    ///
    /// - Note:
    ///   - Notified events on `self` get forwarded to chains attached for eventType.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///   - eventType: the event type for which to attach the chain for
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [attach(chain:for:)](EventBus.attach(chain:for:))
    func attach<T>(chain: EventNotifiable, for eventType: T.Type, options: Options)

    /// Detaches a chained event bus from the event bus for a given event type.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///   - eventType: the event type for which to detach the chain from
    ///
    /// ```
    /// let eventBus = EventBus()
    /// let chainedEventBus = EventBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventBus, for: MyEvent.self)
    /// // ...
    /// eventBus.detach(chain: chainedEventBus, for: MyEvent.self)
    /// ```
    func detach<T>(chain: EventNotifiable, for eventType: T.Type)

    /// Detaches a chained event bus from the event bus for a given event type.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///   - eventType: the event type for which to detach the chain from
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [detach(chain:for:)](EventBus.detach(chain:for:))
    func detach<T>(chain: EventNotifiable, for eventType: T.Type, options: Options)

    /// Detaches a second event bus from the event bus.
    ///
    /// - Parameters
    ///   - chain: the event bus to detach
    ///
    /// ```
    /// let eventBus = EventBus()
    /// let chainedEventBus = EventBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventBus, for: MyEvent.self)
    /// // ...
    /// eventBus.detach(chain: chainedEventBus)
    /// ```
    func detach(chain: EventNotifiable)

    /// Detaches all attached event busses from the event bus.
    ///
    /// - Parameters
    ///   - chain: the event bus to detach
    ///
    /// ```
    /// let eventBus = EventBus()
    /// let chainedEventBus = EventBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventBus)
    /// // ...
    /// eventBus.detachAllChains()
    func detachAllChains()
}
