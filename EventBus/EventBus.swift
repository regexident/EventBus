//
//  EventBus.swift
//  EventBus
//
//  Created by Vincent Esche on 21/11/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import Foundation

public protocol EventBusProtocol: class {
    var options: Options { get }
}

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-subscription capabilities.
public protocol EventSubscribable: EventBusProtocol {
    associatedtype Event

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
    func add(subscriber: Event)

    /// Adds a given object to the list of subscribers of a given event type on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to add to the event bus for the given event type
    ///   - eventType: the event type to subscribe for
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [add(subscriber:for)](EventBus.add(subscriber:for:))
    func add(subscriber: Event, options: Options)

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
    func remove(subscriber: Event)

    /// Removes a given object from the list of subscribers on the event bus.
    ///
    /// - Parameters:
    ///   - subscriber: the subscriber to remove from the event bus for all event types
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [remove(subscriber:)](EventBus.remove(subscriber:))
    /// ```
    func remove(subscriber: Event, options: Options)

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

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-chaining capabilities.
public protocol EventChainable: EventBusProtocol {
    associatedtype Event

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
    func attach<T: EventNotifiable>(chain: T)

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
    func attach<T: EventNotifiable>(chain: T, options: Options)

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
    func detach<T: EventNotifiable>(chain: T)

    /// Detaches a chained event bus from the event bus for a given event type.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///   - eventType: the event type for which to detach the chain from
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [detach(chain:for:)](EventBus.detach(chain:for:))
    func detach<T: EventNotifiable>(chain: T, options: Options)

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

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-notification capabilities.
public protocol EventNotifiable: EventBusProtocol {
    associatedtype Event

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
    func notify(closure: @escaping (Event) -> ()) -> Bool

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
    func notify(options: Options, closure: @escaping (Event) -> ()) -> Bool
}

internal protocol ErrorHandler {
    func eventBusDroppedUnhandledEvent<T>(_ eventBus: EventBus<T>)
    func eventBus<T>(_ eventBus: EventBus<T>, receivedNonClassSubscriber subscriberType: EventBus<T>.Event)
}

internal struct DefaultErrorHandler: ErrorHandler {
    @inline(__always)
    internal func eventBusDroppedUnhandledEvent<T>(_ eventBus: EventBus<T>) {
        #if DEBUG
            typealias ErrorType = UnhandledEventError
            let errorName = String(describing: ErrorType.self)
            print("\(eventBus): Event of type '\(T.self)' was not handled.")
            print("Info: Use a \"Swift Error Breakpoint\" on type \"EventBus.\(errorName)\" to catch.")
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        #endif
    }

    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventBus<T>, receivedNonClassSubscriber subscriberType: EventBus<T>.Event) {
        #if DEBUG
            typealias ErrorType = InvalidSubscriberError
            let errorName = String(describing: ErrorType.self)
            print("\(eventBus): Expected class, found struct/enum: \(subscriberType).")
            print("Info: Use a \"Swift Error Breakpoint\" on type \"EventBus.\(errorName)\" to catch.")
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        #endif
    }
}

internal protocol LogHandler {
    func eventBusReceivedEvent<T>(_ eventBus: EventBus<T>)
}

internal struct DefaultLogHandler: LogHandler {
    func eventBusReceivedEvent<T>(_ eventBus: EventBus<T>) {
        #if DEBUG
            print("\(eventBus): Received event '\(EventBus<T>.Event.self)'.")
        #endif
    }
}

/// Options for configuring the behavior of a given EventBus.
public struct Options: OptionSet {

    /// See protocol `OptionSet`
    public let rawValue: Int

    /// See protocol `OptionSet`
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Print a warning whenever an event gets subscribed to or notified that has not previously
    /// been registered (i.e. via `eventBus.register(forEvent: MyEvent.self)`) with the event bus.
    ///
    /// - Note:
    ///   Warning logs are only emitted if the `DEBUG` compiler flag is present.
    ///
    ///   On debug builds you can catch the error using
    ///   a "Swift Error Breakpoint" on type `StrictnessError`.
    /// ```
    public static let warnUnhandled: Options = .init(rawValue: 1 << 0)

    /// Print a log of emitted events for a given event bus.
    public static let logEvents: Options = .init(rawValue: 1 << 1)
}

/// A type-safe event bus.
public class EventBus<T>: EventBusProtocol {
    public typealias Event = T

    typealias WeakSet = Set<WeakBox>

    /// The event bus' configuration options.
    public let options: Options

    internal var errorHandler: ErrorHandler = DefaultErrorHandler()
    internal var logHandler: LogHandler = DefaultLogHandler()

    fileprivate var subscribed: WeakSet = []
    fileprivate var chained: WeakSet = []

    fileprivate let serialQueue: DispatchQueue = DispatchQueue(label: "com.regexident.eventbus")
    fileprivate let queue: DispatchQueue

    /// Creates an event bus with a given configuration and dispatch queue.
    ///
    /// - Parameters:
    ///   - options: the event bus' options
    ///   - queue: the dispatch queue to notify subscribers on
    public init(options: Options? = nil, queue: DispatchQueue = .global()) {
        self.queue = queue
        self.options = options ?? Options()
    }

    @inline(__always)
    fileprivate func warnIfNonClass<T>(_ subscriber: T) {
        // Related bug: https://bugs.swift.org/browse/SR-4420:
        guard !(type(of: subscriber as Any) is AnyClass) else {
            return
        }
//        self.errorHandler.eventBus(self, receivedNonClassSubscriber: type(of: subscriber))
    }

    @inline(__always)
    fileprivate func warnUnhandled() {
        guard self.options.contains(.warnUnhandled) else {
            return
        }
        self.errorHandler.eventBusDroppedUnhandledEvent(self)
    }

    @inline(__always)
    fileprivate func logEvent(_ eventType: Event.Type) {
        guard self.options.contains(.logEvents) else {
            return
        }
        self.logHandler.eventBusReceivedEvent(self)
    }
}

extension EventBus: EventSubscribable {
    public func add(subscriber: Event) {
        return self.add(subscriber: subscriber, options: self.options)
    }

    public func add(subscriber: Event, options: Options) {
        self.warnIfNonClass(subscriber)
        let _ = self.serialQueue.sync {
            self.subscribed.insert(WeakBox(subscriber as AnyObject))
        }
    }

    public func remove(subscriber: Event) {
        return self.remove(subscriber: subscriber, options: self.options)
    }

    public func remove(subscriber: Event, options: Options) {
        self.warnIfNonClass(subscriber)
        let _ = self.serialQueue.sync {
            self.subscribed.remove(WeakBox(subscriber as AnyObject))
        }
    }

    public func removeAllSubscribers() {
        self.serialQueue.sync {
            self.subscribed.removeAll()
        }
    }

    internal func has<T>(subscriber: T) -> Bool {
        return self.has(subscriber: subscriber, options: self.options)
    }

    internal func has<T>(subscriber: T, options: Options) -> Bool {
        self.warnIfNonClass(subscriber)
        return self.serialQueue.sync {
            return self.subscribed.contains { $0.inner === (subscriber as AnyObject) }
        }
    }
}

extension EventBus: EventNotifiable {
    @discardableResult
    public func notify(closure: @escaping (Event) -> ()) -> Bool {
        return self.notify(options: self.options, closure: closure)
    }

    @discardableResult
    public func notify(options: Options, closure: @escaping (Event) -> ()) -> Bool {
        self.logEvent(Event.self)
        return self.serialQueue.sync {
            var handled: Int = 0
            // Notify our direct subscribers:
            for subscriber in self.subscribed.lazy.flatMap({ $0.inner as? T }) {
                self.queue.async {
                    closure(subscriber)
                }
                handled += 1
            }
            // Notify our indirect subscribers:
            for chain in self.chained.lazy.flatMap({ $0.inner as? EventNotifiable }) {
                handled += chain.notify(closure: closure) ? 1 : 0
            }
            if (handled == 0) && options.contains(.warnUnhandled) {
                self.warnUnhandled()
            }
            return handled > 0
        }
    }
}

extension EventBus: EventChainable {
    public func attach<T: EventNotifiable>(chain: T) {
        return self.attach(chain: chain, options: self.options)
    }

    public func attach<T: EventNotifiable>(chain: T, options: Options) {
        let _ = self.serialQueue.sync {
            self.chained.insert(WeakBox(chain as AnyObject))
        }
    }

    public func detach<T: EventNotifiable>(chain: T) {
        return self.detach(chain: chain, options: self.options)
    }

    public func detach<T: EventNotifiable>(chain: T, options: Options) {
        let _ = self.serialQueue.sync {
            self.chained.remove(WeakBox(chain as AnyObject))
        }
    }

    public func detachAllChains() {
        self.serialQueue.sync {
            self.chained.removeAll()
        }
    }

    internal func has<T: EventNotifiable>(chain: T) -> Bool {
        return self.has(chain: chain, options: self.options)
    }

    internal func has<T: EventNotifiable>(chain: T, options: Options) -> Bool {
        return self.serialQueue.sync {
            self.chained.contains { $0.inner === (chain as AnyObject) }
        }
    }
}

extension EventBus: CustomStringConvertible {
    public var description: String {
        var mutableSelf = self
        return Swift.withUnsafePointer(to: &mutableSelf) { pointer in
            let name = String(describing: type(of: mutableSelf))
            let address = String(format: "%p", pointer)
            return "<\(name): \(address)>"
        }
    }
}
