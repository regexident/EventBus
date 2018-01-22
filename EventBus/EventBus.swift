//
//  EventBus.swift
//  EventBus
//
//  Created by Vincent Esche on 21/11/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import Foundation

public protocol EventRegistrable: class {
    func register<T>(forEvent eventType: T.Type)
}

public protocol EventSubscribable: class {
    func add<T>(subscriber: T, for eventType: T.Type)
    func remove<T>(subscriber: T, for eventType: T.Type)
    func remove<T>(subscriber: T)
    func removeAllSubscribers()
}

public protocol EventChainable: class {
    func attach(chain: EventNotifiable)
    func detach(chain: EventNotifiable)
    func detachAllChains()
}

public protocol EventNotifiable: class {
    func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ())
}

public struct Options: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let warnUnknown = Options(rawValue: 1 << 0)

    public static let warnDropped = Options(rawValue: 1 << 1)

    public static let logEvents = Options(rawValue: 1 << 2)
}

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

    public static let shared: EventBus = EventBus()

    public let options: Options

    fileprivate var registered: [ObjectIdentifier: String] = [:]
    fileprivate var subscribed: [ObjectIdentifier: Set<WeakBox>] = [:]
    fileprivate var chained: Set<WeakBox> = []

    fileprivate let serialQueue: DispatchQueue = DispatchQueue(label: "com.regexident.eventbus")
    fileprivate let queue: DispatchQueue

    private var nameAndAddress: String {
        var mutableSelf = self
        return Swift.withUnsafePointer(to: &mutableSelf) { pointer in
            let name = String(describing: type(of: self))
            let address = String(format: "%p", pointer)
            return "<\(name): \(address)>"
        }
    }

    public init(options: Options? = nil, queue: DispatchQueue = .global()) {
        self.queue = queue
        self.options = options ?? Options()
    }

    fileprivate func validateSubscriber<T>(subscriber: T) {
        // Related bug: https://bugs.swift.org/browse/SR-4420:
        if !(type(of: subscriber as Any) is AnyClass) {
            let message = "Expected class, found struct/enum: \(subscriber)"
            #if DEBUG
                fatalError(message)
            #else
                print(message)
            #endif
        }
    }

    fileprivate func warnIfUnknown<T>(_ eventType: T.Type) {
        let identifier = ObjectIdentifier(eventType)
        guard self.options.contains(.warnUnknown) else {
            return
        }
        guard self.registered[identifier] != nil else {
            return
        }
        let names = Array(self.registered.values).joined(separator: ", ")
        let message = "\(self.nameAndAddress): Expected event of registered type (e.g. \(names)), found: \(eventType)"
        #if DEBUG
            fatalError(message)
        #else
            print(message)
        #endif
    }

    fileprivate func warnIfDropped<T>(_ eventType: T.Type) {
        let identifier = ObjectIdentifier(eventType)
        guard self.options.contains(.warnDropped) else {
            return
        }
        guard self.subscribed[identifier] == nil else {
            return
        }
        let message = "\(self.nameAndAddress): Event of type '\(eventType)' was not handled."
        #if DEBUG
            fatalError(message)
        #else
            print(message)
        #endif
    }

    fileprivate func logEvent<T>(_ eventType: T.Type) {
        #if DEBUG
            if self.options.contains(.logEvents) {
                print("\(self.nameAndAddress): Received event '\(eventType)'")
            }
        #endif
    }

    fileprivate func pruned<T>(subscribed: Set<WeakBox>, for eventType: T.Type) -> Set<WeakBox>? {
        let filtered = subscribed.filter { $0.inner is T }
        return filtered.isEmpty ? nil : Set(filtered)
    }
}

extension EventBus: EventRegistrable {
    public func register<T>(forEvent eventType: T.Type) {
        let identifier = ObjectIdentifier(eventType)
        self.registered[identifier] = String(describing: eventType)
    }
}

extension EventBus: EventSubscribable {
    public func add<T>(subscriber: T, for eventType: T.Type) {
        self.validateSubscriber(subscriber: subscriber)
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
        self.validateSubscriber(subscriber: subscriber)
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
        self.validateSubscriber(subscriber: subscriber)
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
        var result: Bool = false
        self.validateSubscriber(subscriber: subscriber)
        self.warnIfUnknown(eventType)
        self.serialQueue.sync {
            let identifier = ObjectIdentifier(eventType)
            guard let subscribed = self.subscribed[identifier] else {
                result = false
                return
            }
            result = subscribed.contains { $0.inner === (subscriber as AnyObject) }
            return
        }
        return result
    }
}

extension EventBus: EventNotifiable {
    public func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ()) {
        self.warnIfUnknown(eventType)
        self.warnIfDropped(eventType)
        self.logEvent(eventType)
        self.serialQueue.sync {
            let identifier = ObjectIdentifier(eventType)
            defer {
                for eventBus in self.chained.flatMap({ $0.inner as? EventNotifiable }) {
                    self.queue.async {
                        eventBus.notify(eventType, closure: closure)
                    }
                }
            }
            guard let subscribed = self.subscribed[identifier] else {
                return
            }
            for subscriber in subscribed.flatMap({ $0.inner as? T }) {
                self.queue.async {
                    closure(subscriber)
                }
            }
        }
    }
}

extension EventBus: EventChainable {
    public func attach(chain: EventNotifiable) {
        self.serialQueue.sync {
            var chained = self.chained
            chained.insert(WeakBox(chain as AnyObject))
            self.chained = Set(chained.filter { $0.inner is EventNotifiable })
        }
    }

    public func detach(chain: EventNotifiable) {
        self.serialQueue.sync {
            var chained = self.chained
            chained.remove(WeakBox(chain as AnyObject))
            self.chained = Set(chained.filter { $0.inner is EventNotifiable })
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
