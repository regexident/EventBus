//
//  EventMultiBus.swift
//  EventMultiBus
//
//  Created by Vincent Esche on 21/11/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import Foundation

public protocol EventMultiBusProtocol: class {
    var options: EventMultiBus.Options { get }
}

/// A reduced type-erased interface for EventMultiBus
/// for selectively exposing its type-registration capabilities.
public protocol EventRegistrable: EventMultiBusProtocol {

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
    /// let eventBus = EventMultiBus()
    /// eventBus.register(forEvent: MyEvent.self)
    /// ```
    func register<T>(forEvent eventType: T.Type)
}

/// A reduced type-erased interface for EventMultiBus
/// for selectively exposing its event-subscription capabilities.
public protocol EventMultiSubscribable: EventMultiBusProtocol {
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
    /// let eventBus = EventMultiBus()
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
    ///   [add(subscriber:for)](EventMultiBus.add(subscriber:for:))
    func add<T>(subscriber: T, for eventType: T.Type, options: EventMultiBus.Options)

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
    /// let eventBus = EventMultiBus()
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
    ///   [remove(subscriber:for:)](EventMultiBus.remove(subscriber:for:))
    func remove<T>(subscriber: T, for eventType: T.Type, options: EventMultiBus.Options)

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
    /// let eventBus = EventMultiBus()
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
    ///   [remove(subscriber:)](EventMultiBus.remove(subscriber:))
    /// ```
    func remove<T>(subscriber: T, options: EventMultiBus.Options)

    /// Removes all objects from the list of subscribers on the event bus.
    ///
    /// ```
    /// protocol MyEvent {
    ///     // ...
    /// }
    ///
    /// let eventBus = EventMultiBus()
    /// // ...
    /// eventBus.add(subscriber: subscriber, for: MyEvent.self)
    /// // ...
    /// eventBus.removeAllSubscribers()
    /// ```
    func removeAllSubscribers()
}

/// A reduced type-erased interface for EventMultiBus
/// for selectively exposing its event-chaining capabilities.
public protocol EventMultiChainable: EventMultiBusProtocol {
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
    /// let eventBus = EventMultiBus()
    /// let chainedEventMultiBus = EventMultiBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventMultiBus, for: MyEvent.self)
    /// ```
    func attach<T>(chain: EventMultiNotifiable, for eventType: T.Type)

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
    ///   [attach(chain:for:)](EventMultiBus.attach(chain:for:))
    func attach<T>(chain: EventMultiNotifiable, for eventType: T.Type, options: EventMultiBus.Options)

    /// Detaches a chained event bus from the event bus for a given event type.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///   - eventType: the event type for which to detach the chain from
    ///
    /// ```
    /// let eventBus = EventMultiBus()
    /// let chainedEventMultiBus = EventMultiBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventMultiBus, for: MyEvent.self)
    /// // ...
    /// eventBus.detach(chain: chainedEventMultiBus, for: MyEvent.self)
    /// ```
    func detach<T>(chain: EventMultiNotifiable, for eventType: T.Type)

    /// Detaches a chained event bus from the event bus for a given event type.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///   - eventType: the event type for which to detach the chain from
    ///   - options: temporarily overwritten options for this call
    ///
    /// - SeeAlso:
    ///   [detach(chain:for:)](EventMultiBus.detach(chain:for:))
    func detach<T>(chain: EventMultiNotifiable, for eventType: T.Type, options: EventMultiBus.Options)

    /// Detaches a second event bus from the event bus.
    ///
    /// - Parameters
    ///   - chain: the event bus to detach
    ///
    /// ```
    /// let eventBus = EventMultiBus()
    /// let chainedEventMultiBus = EventMultiBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventMultiBus, for: MyEvent.self)
    /// // ...
    /// eventBus.detach(chain: chainedEventMultiBus)
    /// ```
    func detach(chain: EventMultiNotifiable)

    /// Detaches all attached event busses from the event bus.
    ///
    /// - Parameters
    ///   - chain: the event bus to detach
    ///
    /// ```
    /// let eventBus = EventMultiBus()
    /// let chainedEventMultiBus = EventMultiBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventMultiBus)
    /// // ...
    /// eventBus.detachAllChains()
    func detachAllChains()
}

/// A reduced type-erased interface for EventMultiBus
/// for selectively exposing its event-notification capabilities.
public protocol EventMultiNotifiable: EventMultiBusProtocol {

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
    /// let eventBus = EventMultiBus()
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
    ///   [notify(_:closure:)](EventMultiBus.notify(_:closure:))
    @discardableResult
    func notify<T>(_ eventType: T.Type, options: EventMultiBus.Options, closure: @escaping (T) -> ()) -> Bool
}

internal protocol ErrorMultiHandler {
    func eventBus<T>(_ eventBus: EventMultiBus, receivedUnknownEvent eventType: T.Type)
    func eventBus<T>(_ eventBus: EventMultiBus, droppedUnhandledEvent eventType: T.Type)
    func eventBus<T>(_ eventBus: EventMultiBus, receivedNonClassSubscriber subscriberType: T.Type)
}

internal struct DefaultErrorMultiHandler: ErrorMultiHandler {
    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventMultiBus, receivedUnknownEvent eventType: T.Type) {
        #if DEBUG
            typealias ErrorType = UnknownEventError
            let errorName = String(describing: ErrorType.self)
            let eventTypes = eventBus.registeredEventTypes
            let eventNames = eventTypes.lazy.map { "\($0)" }.joined(separator: ", ")
            let namesString = eventNames.isEmpty ? "" : " (e.g. \(eventNames))"
            print("\(eventBus): Expected event of registered type\(namesString), found: \(eventType).")
            print("Info: Use a \"Swift Error Breakpoint\" on type \"EventMultiBus.\(errorName)\" to catch.")
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        #endif
    }

    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventMultiBus, droppedUnhandledEvent eventType: T.Type) {
        #if DEBUG
            typealias ErrorType = UnhandledEventError
            let errorName = String(describing: ErrorType.self)
            print("\(eventBus): Event of type '\(eventType)' was not handled.")
            print("Info: Use a \"Swift Error Breakpoint\" on type \"EventMultiBus.\(errorName)\" to catch.")
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        #endif
    }

    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventMultiBus, receivedNonClassSubscriber subscriberType: T.Type) {
        #if DEBUG
            typealias ErrorType = InvalidSubscriberError
            let errorName = String(describing: ErrorType.self)
            print("\(eventBus): Expected class, found struct/enum: \(subscriberType).")
            print("Info: Use a \"Swift Error Breakpoint\" on type \"EventMultiBus.\(errorName)\" to catch.")
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        #endif
    }
}

internal protocol LogMultiHandler {
    func eventBus<T>(_ eventBus: EventMultiBus, receivedEvent: T.Type)
}

internal struct DefaultLogMultiHandler: LogMultiHandler {
    func eventBus<T>(_ eventBus: EventMultiBus, receivedEvent eventType: T.Type) {
        #if DEBUG
            print("\(eventBus): Received event '\(eventType)'.")
        #endif
    }
}

/// A type-safe event bus.
public class EventMultiBus: EventMultiBusProtocol {

    /// Options for configuring the behavior of a given EventMultiBus.
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
        public static let warnUnknown: Options = .init(rawValue: 1 << 0)

        /// Print a warning whenever an event gets subscribed to or notified that has not previously
        /// been registered (i.e. via `eventBus.register(forEvent: MyEvent.self)`) with the event bus.
        ///
        /// - Note:
        ///   Warning logs are only emitted if the `DEBUG` compiler flag is present.
        ///
        ///   On debug builds you can catch the error using
        ///   a "Swift Error Breakpoint" on type `StrictnessError`.
        /// ```
        public static let warnUnhandled: Options = .init(rawValue: 1 << 1)

        /// Print a log of emitted events for a given event bus.
        public static let logEvents: Options = .init(rawValue: 1 << 2)
    }

    typealias WeakSet = Set<WeakBox>

    /// A global shared event bus configured using default options.
    public static let shared: EventMultiBus = EventMultiBus()

    /// The event bus' configuration options.
    public let options: Options

    internal var errorHandler: ErrorMultiHandler = DefaultErrorMultiHandler()
    internal var logHandler: LogMultiHandler = DefaultLogMultiHandler()

    fileprivate var knownTypes: [ObjectIdentifier: Any] = [:]

    fileprivate var registered: Set<ObjectIdentifier> = []
    fileprivate var subscribed: [ObjectIdentifier: WeakSet] = [:]
    fileprivate var chained: [ObjectIdentifier: WeakSet] = [:]

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

    /// The event types the event bus is registered for.
    public var registeredEventTypes: [Any] {
        return self.registered.flatMap { self.knownTypes[$0] }
    }

    /// The event types the event bus has subscribers for.
    public var subscribedEventTypes: [Any] {
        return self.subscribed.keys.flatMap { self.knownTypes[$0] }
    }

    /// The event types the event bus has chains for.
    public var chainedEventTypes: [Any] {
        return self.chained.keys.flatMap { self.knownTypes[$0] }
    }

    @inline(__always)
    fileprivate func warnIfNonClass<T>(_ subscriber: T) {
        // Related bug: https://bugs.swift.org/browse/SR-4420:
        guard !(type(of: subscriber as Any) is AnyClass) else {
            return
        }
        self.errorHandler.eventBus(self, receivedNonClassSubscriber: type(of: subscriber))
    }

    @inline(__always)
    fileprivate func warnIfUnknown<T>(_ eventType: T.Type) {
        guard self.options.contains(.warnUnknown) else {
            return
        }
        guard !self.registered.contains(ObjectIdentifier(eventType)) else {
            return
        }
        self.errorHandler.eventBus(self, receivedUnknownEvent: eventType)
    }

    @inline(__always)
    fileprivate func warnUnhandled<T>(_ eventType: T.Type) {
        guard self.options.contains(.warnUnhandled) else {
            return
        }
        self.errorHandler.eventBus(self, droppedUnhandledEvent: eventType)
    }

    @inline(__always)
    fileprivate func logEvent<T>(_ eventType: T.Type) {
        guard self.options.contains(.logEvents) else {
            return
        }
        self.logHandler.eventBus(self, receivedEvent: eventType)
    }

    @inline(__always)
    fileprivate func updateSubscribers<T>(for eventType: T.Type, closure: (inout WeakSet) -> ()) {
        let identifier = ObjectIdentifier(eventType)
        let subscribed = self.subscribed[identifier] ?? []
        self.subscribed[identifier] = self.update(set: subscribed, closure: closure)
        self.knownTypes[identifier] = String(describing: eventType)
    }

    @inline(__always)
    fileprivate func updateChains<T>(for eventType: T.Type, closure: (inout WeakSet) -> ()) {
        let identifier = ObjectIdentifier(eventType)
        let chained = self.chained[identifier] ?? []
        self.chained[identifier] = self.update(set: chained, closure: closure)
        self.knownTypes[identifier] = String(describing: eventType)
    }

    @inline(__always)
    fileprivate func update(set: WeakSet, closure: (inout WeakSet) -> ()) -> WeakSet? {
        var mutableSet = set
        closure(&mutableSet)
        // Remove weak nil elements while we're at it:
        let filteredSet = mutableSet.filter { $0.inner != nil }
        return filteredSet.isEmpty ? nil : filteredSet
    }
}

extension EventMultiBus: EventRegistrable {
    public func register<T>(forEvent eventType: T.Type) {
        let identifier = ObjectIdentifier(eventType)
        self.registered.insert(identifier)
        self.knownTypes[identifier] = String(describing: eventType)
    }
}

extension EventMultiBus: EventMultiSubscribable {
    public func add<T>(subscriber: T, for eventType: T.Type) {
        return self.add(subscriber: subscriber, for: eventType, options: self.options)
    }

    public func add<T>(subscriber: T, for eventType: T.Type, options: Options) {
        self.warnIfNonClass(subscriber)
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.serialQueue.sync {
            self.updateSubscribers(for: eventType) { subscribed in
                subscribed.insert(WeakBox(subscriber as AnyObject))
            }
        }
    }

    public func remove<T>(subscriber: T, for eventType: T.Type) {
        return self.remove(subscriber: subscriber, for: eventType, options: self.options)
    }

    public func remove<T>(subscriber: T, for eventType: T.Type, options: Options) {
        self.warnIfNonClass(subscriber)
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.serialQueue.sync {
            self.updateSubscribers(for: eventType) { subscribed in
                subscribed.remove(WeakBox(subscriber as AnyObject))
            }
        }
    }

    public func remove<T>(subscriber: T) {
        return self.remove(subscriber: subscriber, options: self.options)
    }

    public func remove<T>(subscriber: T, options: Options) {
        self.warnIfNonClass(subscriber)
        self.serialQueue.sync {
            for (identifier, subscribed) in self.subscribed {
                self.subscribed[identifier] = self.update(set: subscribed) { subscribed in
                    subscribed.remove(WeakBox(subscriber as AnyObject))
                }
            }
        }
    }

    public func removeAllSubscribers() {
        self.serialQueue.sync {
            self.subscribed.removeAll()
        }
    }

    internal func has<T>(subscriber: T, for eventType: T.Type) -> Bool {
        return self.has(subscriber: subscriber, for: eventType, options: self.options)
    }

    internal func has<T>(subscriber: T, for eventType: T.Type, options: Options) -> Bool {
        self.warnIfNonClass(subscriber)
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        return self.serialQueue.sync {
            guard let subscribed = self.subscribed[ObjectIdentifier(eventType)] else {
                return false
            }
            return subscribed.contains { $0.inner === (subscriber as AnyObject) }
        }
    }
}

extension EventMultiBus: EventMultiNotifiable {
    @discardableResult
    public func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ()) -> Bool {
        return self.notify(eventType, options: self.options, closure: closure)
    }

    @discardableResult
    public func notify<T>(_ eventType: T.Type, options: Options, closure: @escaping (T) -> ()) -> Bool {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.logEvent(eventType)
        return self.serialQueue.sync {
            var handled: Int = 0
            let identifier = ObjectIdentifier(eventType)
            // Notify our direct subscribers:
            if let subscribers = self.subscribed[identifier] {
                for subscriber in subscribers.lazy.flatMap({ $0.inner as? T }) {
                    self.queue.async {
                        closure(subscriber)
                    }
                    handled += 1
                }
            }
            // Notify our indirect subscribers:
            if let chains = self.chained[identifier] {
                for chain in chains.lazy.flatMap({ $0.inner as? EventMultiNotifiable }) {
                    handled += chain.notify(eventType, closure: closure) ? 1 : 0
                }
            }
            if (handled == 0) && options.contains(.warnUnhandled) {
                self.warnUnhandled(eventType)
            }
            return handled > 0
        }
    }
}

extension EventMultiBus: EventMultiChainable {
    public func attach<T>(chain: EventMultiNotifiable, for eventType: T.Type) {
        return self.attach(chain: chain, for: eventType, options: self.options)
    }

    public func attach<T>(chain: EventMultiNotifiable, for eventType: T.Type, options: Options) {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.serialQueue.sync {
            self.updateChains(for: eventType) { chained in
                chained.insert(WeakBox(chain as AnyObject))
            }
        }
    }

    public func detach<T>(chain: EventMultiNotifiable, for eventType: T.Type) {
        return self.detach(chain: chain, for: eventType, options: self.options)
    }

    public func detach<T>(chain: EventMultiNotifiable, for eventType: T.Type, options: Options) {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.serialQueue.sync {
            self.updateChains(for: eventType) { chained in
                chained.remove(WeakBox(chain as AnyObject))
            }
        }
    }

    public func detach(chain: EventMultiNotifiable) {
        self.serialQueue.sync {
            for (identifier, chained) in self.chained {
                self.chained[identifier] = self.update(set: chained) { chained in
                    chained.remove(WeakBox(chain as AnyObject))
                }
            }
        }
    }

    public func detachAllChains() {
        self.serialQueue.sync {
            self.chained.removeAll()
        }
    }

    internal func has<T>(chain: EventMultiNotifiable, for eventType: T.Type) -> Bool {
        return self.has(chain: chain, for: eventType, options: self.options)
    }

    internal func has<T>(chain: EventMultiNotifiable, for eventType: T.Type, options: Options) -> Bool {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        return self.serialQueue.sync {
            guard let chained = self.chained[ObjectIdentifier(eventType)] else {
                return false
            }
            return chained.contains { $0.inner === (chain as AnyObject) }
        }
    }
}

extension EventMultiBus: CustomStringConvertible {
    public var description: String {
        var mutableSelf = self
        return Swift.withUnsafePointer(to: &mutableSelf) { pointer in
            let name = String(describing: type(of: mutableSelf))
            let address = String(format: "%p", pointer)
            return "<\(name): \(address)>"
        }
    }
}
