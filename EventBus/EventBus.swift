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

/// A type-safe event bus.
public class EventBus: EventBusProtocol {

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

    typealias WeakSet = Set<WeakBox>

    public static var isStrict: Bool = false

    /// A global shared event bus configured using default options.
    public static let shared: EventBus = EventBus()

    /// The event bus' configuration options.
    public let options: Options

    /// The event bus' label used for debugging.
    public let label: String?

    internal var errorHandler: ErrorHandler = DefaultErrorHandler()
    internal var logHandler: LogHandler = DefaultLogHandler()

    fileprivate var knownTypes: [ObjectIdentifier: Any] = [:]

    fileprivate var registered: Set<ObjectIdentifier> = []
    fileprivate var subscribed: [ObjectIdentifier: WeakSet] = [:]
    fileprivate var chained: [ObjectIdentifier: WeakSet] = [:]

    fileprivate let lock: NSRecursiveLock = .init()
    fileprivate let notificationQueue: DispatchQueue

    /// Creates an event bus with a given configuration and dispatch notificationQueue.
    ///
    /// - Parameters:
    ///   - options: the event bus' options
    ///   - notificationQueue: the dispatch notificationQueue to notify subscribers on
    public init(options: Options? = nil, label: String? = nil, notificationQueue: DispatchQueue = .global()) {
        self.options = options ?? Options()
        self.label = label
        self.notificationQueue = notificationQueue
    }

    /// The event types the event bus is registered for.
    public var registeredEventTypes: [Any] {
        return self.registered.compactMap { self.knownTypes[$0] }
    }

    /// The event types the event bus has subscribers for.
    public var subscribedEventTypes: [Any] {
        return self.subscribed.keys.compactMap { self.knownTypes[$0] }
    }

    /// The event types the event bus has chains for.
    public var chainedEventTypes: [Any] {
        return self.chained.keys.compactMap { self.knownTypes[$0] }
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

extension EventBus: EventRegistrable {
    public func register<T>(forEvent eventType: T.Type) {
        let identifier = ObjectIdentifier(eventType)
        self.registered.insert(identifier)
        self.knownTypes[identifier] = String(describing: eventType)
    }
}

extension EventBus: EventSubscribable {
    public func add<T>(subscriber: T, for eventType: T.Type) {
        return self.add(subscriber: subscriber, for: eventType, options: self.options)
    }

    public func add<T>(subscriber: T, for eventType: T.Type, options: Options) {
        self.warnIfNonClass(subscriber)
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.lock.with {
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
        self.lock.with {
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
        self.lock.with {
            for (identifier, subscribed) in self.subscribed {
                self.subscribed[identifier] = self.update(set: subscribed) { subscribed in
                    subscribed.remove(WeakBox(subscriber as AnyObject))
                }
            }
        }
    }

    public func removeAllSubscribers() {
        self.lock.with {
            self.subscribed = [:]
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
        return self.lock.with {
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
        return self.notify(eventType, options: self.options, closure: closure)
    }

    @discardableResult
    public func notify<T>(_ eventType: T.Type, options: Options, closure: @escaping (T) -> ()) -> Bool {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.logEvent(eventType)
        return self.lock.with {
            var handled: Int = 0
            let identifier = ObjectIdentifier(eventType)
            // Notify our direct subscribers:
            if let subscribers = self.subscribed[identifier] {
                for subscriber in subscribers.lazy.compactMap({ $0.inner as? T }) {
                    self.notificationQueue.async {
                        closure(subscriber)
                    }
                }
                handled += subscribers.count
            }
            // Notify our indirect subscribers:
            if let chains = self.chained[identifier] {
                for chain in chains.lazy.compactMap({ $0.inner as? EventNotifiable }) {
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

extension EventBus: EventChainable {
    public func attach<T>(chain: EventNotifiable, for eventType: T.Type) {
        return self.attach(chain: chain, for: eventType, options: self.options)
    }

    public func attach<T>(chain: EventNotifiable, for eventType: T.Type, options: Options) {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.lock.with {
            self.updateChains(for: eventType) { chained in
                chained.insert(WeakBox(chain as AnyObject))
            }
        }
    }

    public func detach<T>(chain: EventNotifiable, for eventType: T.Type) {
        return self.detach(chain: chain, for: eventType, options: self.options)
    }

    public func detach<T>(chain: EventNotifiable, for eventType: T.Type, options: Options) {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        self.lock.with {
            self.updateChains(for: eventType) { chained in
                chained.remove(WeakBox(chain as AnyObject))
            }
        }
    }

    public func detach(chain: EventNotifiable) {
        self.lock.with {
            for (identifier, chained) in self.chained {
                self.chained[identifier] = self.update(set: chained) { chained in
                    chained.remove(WeakBox(chain as AnyObject))
                }
            }
        }
    }

    public func detachAllChains() {
        self.lock.with {
            self.chained = [:]
        }
    }

    internal func has<T>(chain: EventNotifiable, for eventType: T.Type) -> Bool {
        return self.has(chain: chain, for: eventType, options: self.options)
    }

    internal func has<T>(chain: EventNotifiable, for eventType: T.Type, options: Options) -> Bool {
        if options.contains(.warnUnknown) {
            self.warnIfUnknown(eventType)
        }
        return self.lock.with {
            guard let chained = self.chained[ObjectIdentifier(eventType)] else {
                return false
            }
            return chained.contains { $0.inner === (chain as AnyObject) }
        }
    }
}

extension EventBus: CustomStringConvertible {
    public var description: String {
        var mutableSelf = self
        return Swift.withUnsafePointer(to: &mutableSelf) { pointer in
            let name = String(describing: type(of: self))
            let address = String(format: "%p", pointer)
            let label = self.label.map { " \"\($0)\"" } ?? ""
            return "<\(name): \(address)\(label)>"
        }
    }
}
