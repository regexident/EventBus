//
//  EventSubscribable.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-subscription capabilities.
public protocol EventSubscribable: EventBusProtocol {
    /// Adds a given object to the list of subscribers of a given event type on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to add to the event bus for the given event type
    ///   - eventType: the event type to subscribe for
    ///
    /// ```
    /// protocol MyEvent {
    ///     // ...
    /// }
    ///
    /// let eventBus = EventBus()
    /// // ...
    /// eventBus.add(subscriber: subscriber, for: MyEvent.self)
    /// ```
    func add<T>(subscriber: T, for eventType: T.Type)

    /// Adds a given object to the list of subscribers of a given event type on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to add to the event bus for the given event type
    ///   - eventType: the event type to subscribe for
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [add(subscriber:for)](EventBus.add(subscriber:for:))
    func add<T>(subscriber: T, for eventType: T.Type, options: Options)

    /// Removes a given object from the list of subscribers of a given event type on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to remove from the event bus for the given event type
    ///   - eventType: the event type to unsubscribe from
    ///
    /// ```
    /// protocol MyEvent {
    ///     // ...
    /// }
    ///
    /// let eventBus = EventBus()
    /// // ...
    /// eventBus.add(subscriber: subscriber, for: MyEvent.self)
    /// // ...
    /// eventBus.remove(subscriber: subscriber, for: MyEvent.self)
    /// ```
    func remove<T>(subscriber: T, for eventType: T.Type)

    /// Removes a given object from the list of subscribers of a given event type on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to remove from the event bus for the given event type
    ///   - eventType: the event type to unsubscribe from
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [remove(subscriber:for:)](EventBus.remove(subscriber:for:))
    func remove<T>(subscriber: T, for eventType: T.Type, options: Options)

    /// Removes a given object from the list of subscribers on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to remove from the event bus for all event types
    ///
    /// ```
    /// protocol MyEvent {
    ///     // ...
    /// }
    ///
    /// let eventBus = EventBus()
    /// // ...
    /// eventBus.add(subscriber: subscriber, for: MyEvent.self)
    /// // ...
    /// eventBus.remove(subscriber: subscriber)
    /// ```
    func remove<T>(subscriber: T)

    /// Removes a given object from the list of subscribers on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to remove from the event bus for all event types
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [remove(subscriber:)](EventBus.remove(subscriber:))
    /// ```
    func remove<T>(subscriber: T, options: Options)

    /// Removes all objects from the list of subscribers on the event bus.
    ///
    /// ```
    /// protocol MyEvent {
    ///     // ...
    /// }
    ///
    /// let eventBus = EventBus()
    /// // ...
    /// eventBus.add(subscriber: subscriber, for: MyEvent.self)
    /// // ...
    /// eventBus.removeAllSubscribers()
    /// ```
    func removeAllSubscribers()
}
