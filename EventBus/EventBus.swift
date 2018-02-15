//
//  EventBus.swift
//  EventBus
//
//  Created by Vincent Esche on 21/11/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import Foundation

/// A reduced type-erased interface for EventBus
/// for selectively exposing its type-registration capabilities.
public protocol EventRegistrable: class {

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

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-subscription capabilities.
public protocol EventSubscribable: class {
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
public protocol EventChainable: class {
    /// Attaches a second event bus chained to the event bus.
    ///
    /// - Note:
    ///   - Notified events get copy-forwarded to attached chains.
    ///
    /// - Parameters
    ///   - chain: the event bus to attach
    ///
    /// ```
    /// let eventBus = EventBus()
    /// let chainedEventBus = EventBus()
    /// // ...
    /// eventBus.attach(chain: chainedEventBus)
    /// ```
    func attach(chain: EventNotifiable)

    /// Detaches a second event bus from the event bus.
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

/// A reduced type-erased interface for EventBus
/// for selectively exposing its event-notification capabilities.
public protocol EventNotifiable: class {

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
    ///   By setting `EventBus.isStrict = true` you can catch the error using
    ///   a "Swift Error Breakpoint" on type `StrictnessError`.
    /// ```
    public static let warnUnknown = Options(rawValue: 1 << 0)

    /// Print a warning whenever an event gets subscribed to or notified that has not previously
    /// been registered (i.e. via `eventBus.register(forEvent: MyEvent.self)`) with the event bus.
    ///
    /// - Note:
    ///   Warning logs are only emitted if the `DEBUG` compiler flag is present.
    ///
    ///   By setting `EventBus.isStrict = true` you can catch the error using
    ///   a "Swift Error Breakpoint" on type `StrictnessError`.
    /// ```
    public static let warnUnhandled = Options(rawValue: 1 << 1)

    /// Print a log of emitted events for a given event bus.
    public static let logEvents = Options(rawValue: 1 << 2)
}

internal protocol ErrorHandler {
    func eventBus<T>(_ eventBus: EventBus, receivedUnknownEvent eventType: T.Type)
    func eventBus<T>(_ eventBus: EventBus, droppedUnhandledEvent eventType: T.Type)
    func eventBus<T>(_ eventBus: EventBus, receivedNonClassSubscriber subscriberType: T.Type)
}

internal struct DefaultErrorHandler: ErrorHandler {
    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventBus, receivedUnknownEvent eventType: T.Type) {
        #if DEBUG
            let eventTypes = eventBus.registeredEventTypes
            let eventNames = eventTypes.lazy.map { "\($0)" }.joined(separator: ", ")
            let message = "\(eventBus): Expected event of registered type (e.g. \(eventNames)), found: \(eventType)."
            print(message)
            if EventBus.isStrict {
                do {
                    throw StrictnessError.unknownEvent
                } catch {
                    // Use a "Swift Error Breakpoint" on type "StrictnessError" to catch.
                }
            }
        #endif
    }

    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventBus, droppedUnhandledEvent eventType: T.Type) {
        #if DEBUG
            let message = "\(eventBus): Event of type '\(eventType)' was not handled."
            print(message)
            if EventBus.isStrict {
                do {
                    throw StrictnessError.unhandledEvent
                } catch {
                    // Use a "Swift Error Breakpoint" on type "StrictnessError" to catch.
                }
            }
        #endif
    }

    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventBus, receivedNonClassSubscriber subscriberType: T.Type) {
        #if DEBUG
            let message = "\(eventBus): Expected class, found struct/enum: \(subscriberType)."
            print(message)
            if EventBus.isStrict {
                do {
                    throw StrictnessError.invalidSubscriber
                } catch {
                    // Use a "Swift Error Breakpoint" on type "StrictnessError" to catch.
                }
            }
        #endif
    }
}

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

/// A type-safe event bus.
public class EventBus {

    internal struct WeakBox: Hashable {
        internal weak var inner: AnyObject?

        internal init(_ inner: AnyObject) {
            self.inner = inner
        }

        internal static func == (lhs: WeakBox, rhs: WeakBox) -> Bool {
            return lhs.inner === rhs.inner
        }

        internal var hashValue: Int {
            guard let inner = self.inner else {
                return 0
            }
            return ObjectIdentifier(inner).hashValue
        }
    }

    public static var isStrict: Bool = false

    /// A global shared event bus configured using default options.
    public static let shared: EventBus = EventBus()

    /// The event bus' configuration options.
    public let options: Options

    internal var errorHandler: ErrorHandler = DefaultErrorHandler()
    internal var logHandler: LogHandler = DefaultLogHandler()

    fileprivate var registered: [ObjectIdentifier: Any] = [:]
    fileprivate var subscribed: [ObjectIdentifier: Set<WeakBox>] = [:]
    fileprivate var chained: Set<WeakBox> = []

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
        return Array(self.registered.values)
    }

    fileprivate func warnIfNonClass<T>(_ subscriber: T) {
        // Related bug: https://bugs.swift.org/browse/SR-4420:
        guard !(type(of: subscriber as Any) is AnyClass) else {
            return
        }
        self.errorHandler.eventBus(self, receivedNonClassSubscriber: type(of: subscriber))
    }

    fileprivate func warnIfUnknown<T>(_ eventType: T.Type) {
        guard self.options.contains(.warnUnknown) else {
            return
        }
        guard self.registered[ObjectIdentifier(eventType)] == nil else {
            return
        }
        self.errorHandler.eventBus(self, receivedUnknownEvent: eventType)
    }

    fileprivate func warnUnhandled<T>(_ eventType: T.Type) {
        guard self.options.contains(.warnUnhandled) else {
            return
        }
        self.errorHandler.eventBus(self, droppedUnhandledEvent: eventType)
    }

    fileprivate func logEvent<T>(_ eventType: T.Type) {
        guard self.options.contains(.logEvents) else {
            return
        }
        self.logHandler.eventBus(self, receivedEvent: eventType)
    }

    fileprivate func pruned<T>(subscribed: Set<WeakBox>, for eventType: T.Type) -> Set<WeakBox>? {
        let filtered = subscribed.lazy.filter { $0.inner is T }
        return filtered.isEmpty ? nil : Set(filtered)
    }
}

fileprivate enum StrictnessError: Error {
    case invalidSubscriber
    case unknownEvent
    case unhandledEvent
}

extension EventBus: EventRegistrable {
    public func register<T>(forEvent eventType: T.Type) {
        let identifier = ObjectIdentifier(eventType)
        self.registered[identifier] = String(describing: eventType)
    }
}

extension EventBus: EventSubscribable {
    public func add<T>(subscriber: T, for eventType: T.Type) {
        self.warnIfNonClass(subscriber)
        self.warnIfUnknown(eventType)
        self.serialQueue.sync {
            let identifier = ObjectIdentifier(eventType)
            var subscribed = self.subscribed[identifier] ?? []
            let weakBox = WeakBox(subscriber as AnyObject)
            subscribed.insert(weakBox)
            self.subscribed[identifier] = self.pruned(subscribed: subscribed, for: eventType)
        }
    }

    public func remove<T>(subscriber: T, for eventType: T.Type) {
        self.warnIfNonClass(subscriber)
        self.warnIfUnknown(eventType)
        self.serialQueue.sync {
            let identifier = ObjectIdentifier(eventType)
            var subscribed = self.subscribed[identifier] ?? []
            let weakBox = WeakBox(subscriber as AnyObject)
            let _ = subscribed.remove(weakBox)
            self.subscribed[identifier] = self.pruned(subscribed: subscribed, for: eventType)
        }
    }

    public func remove<T>(subscriber: T) {
        self.warnIfNonClass(subscriber)
        self.serialQueue.sync {
            for (identifier, var subscribed) in self.subscribed {
                let weakBox = WeakBox(subscriber as AnyObject)
                let _ = subscribed.remove(weakBox)
                self.subscribed[identifier] = subscribed
            }
        }
    }

    public func removeAllSubscribers() {
        self.serialQueue.sync {
            self.subscribed = [:]
        }
    }

    internal func has<T>(subscriber: T, for eventType: T.Type) -> Bool {
        self.warnIfNonClass(subscriber)
        self.warnIfUnknown(eventType)
        return self.serialQueue.sync {
            guard let subscribed = self.subscribed[ObjectIdentifier(eventType)] else {
                return false
            }
            return subscribed.contains { $0.inner === (subscriber as AnyObject) }
        }
    }
}

extension EventBus: EventNotifiable {
    @discardableResult
    public func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ()) -> Bool {
        self.warnIfUnknown(eventType)
        self.logEvent(eventType)
        var handled: Int = 0
        self.serialQueue.sync {
            let identifier = ObjectIdentifier(eventType)
            defer {
                let chainedEventBuses = self.chained.lazy.flatMap({ $0.inner as? EventNotifiable })
                for eventBus in chainedEventBuses {
                    handled += eventBus.notify(eventType, closure: closure) ? 1 : 0
                }
            }
            guard let subscribed = self.subscribed[identifier] else {
                return
            }
            let subscribers = subscribed.flatMap({ $0.inner as? T })
            for subscriber in subscribers {
                self.queue.async {
                    closure(subscriber)
                }
            }
            handled += subscribers.count
        }
        if handled == 0 {
            self.warnUnhandled(eventType)
        }
        return handled > 0
    }
}

extension EventBus: EventChainable {
    public func attach(chain: EventNotifiable) {
        self.serialQueue.sync {
            var chained = self.chained
            chained.insert(WeakBox(chain as AnyObject))
            self.chained = Set(chained.lazy.filter { $0.inner is EventNotifiable })
        }
    }

    public func detach(chain: EventNotifiable) {
        self.serialQueue.sync {
            var chained = self.chained
            chained.remove(WeakBox(chain as AnyObject))
            self.chained = Set(chained.lazy.filter { $0.inner is EventNotifiable })
        }
    }

    public func detachAllChains() {
        self.serialQueue.sync {
            self.chained = []
        }
    }

    internal func has(chain: EventNotifiable) -> Bool {
        var result: Bool = false
        self.serialQueue.sync {
            result = self.chained.contains {
                $0.inner === (chain as AnyObject)
            }
            return
        }
        return result
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
