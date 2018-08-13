//
//  EventNotifiable.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-notification capabilities.
public protocol EventNotifiable: EventBusProtocol {

    /// Notifies all subscribers (and chained event busses)
    ///
    /// - Parameters:
    ///   - eventType: the event type for which to notify subscribers for
    ///   - closure: the closure to perform on subscribers for the given event type
    ///
    /// ```
    /// protocol MyEvent {
    ///     func handle(value: Int)
    /// }
    ///
    /// let eventBus = EventBus()
    /// // ...
    /// eventBus.add(subscriber: subscriber, for: MyEvent.self)
    /// // ...
    /// eventBus.notify(MyEvent.self) { subscriber in
    ///     subscriber.handle(value: 42)
    /// }
    /// ```
    @discardableResult
    func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ()) -> Bool

    /// Notifies all subscribers (and chained event busses)
    ///
    /// - Parameters:
    ///   - eventType: the event type for which to notify subscribers for
    ///   - options: temporarily overwritten options for this call
    ///   - closure: the closure to perform on subscribers for the given event type
    ///
    /// - SeeAlso:
    ///   [notify(_:closure:)](EventBus.notify(_:closure:))
    @discardableResult
    func notify<T>(_ eventType: T.Type, options: Options, closure: @escaping (T) -> ()) -> Bool
}
