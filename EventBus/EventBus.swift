//
//  EventBus.swift
//  EventBus
//
//  Created by Vincent Esche on 21/11/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import Foundation

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

/// Event bus
public class EventBus {

    struct WeakBox : Hashable {
        weak var inner: AnyObject?

        init(_ inner: AnyObject) {
            self.inner = inner
        }

        static func == (lhs: WeakBox, rhs: WeakBox) -> Bool {
            return lhs.inner === rhs.inner
        }

        var hashValue: Int {
            guard let inner = self.inner else {
                return 0
            }
            return ObjectIdentifier(inner).hashValue
        }
    }

    public static let shared: EventBus = EventBus()

    fileprivate var subscribed: [ObjectIdentifier: Set<WeakBox>] = [:]
    fileprivate var chained: Set<WeakBox> = []

    fileprivate let serialQueue: DispatchQueue = DispatchQueue(label: "com.regexident.eventbus")
    fileprivate let queue: DispatchQueue

    public init(queue: DispatchQueue = DispatchQueue.global()) {
        self.queue = queue
    }
}

extension EventBus : EventSubscribable {

    public func add<T>(subscriber: T, for eventType: T.Type) {
        self.serialQueue.sync {
            // Temporarily disabled due to https://bugs.swift.org/browse/SR-4420:
//            guard type(of: subscriber) is AnyClass else {
//                fatalError("Expected class, found struct/enum: \(subscriber)")
//            }
            let identifier = ObjectIdentifier(eventType)
            var subscribed = self.subscribed[identifier] ?? []
            let weakBox = WeakBox(subscriber as AnyObject)
            subscribed.insert(weakBox)
            self.subscribed[identifier] = Set(subscribed.filter { $0.inner is T })
        }
    }

    public func remove<T>(subscriber: T, for eventType: T.Type) {
        self.serialQueue.sync {
            // Temporarily disabled due to https://bugs.swift.org/browse/SR-4420:
//            guard type(of: subscriber) is AnyClass else {
//                fatalError("Expected class, found struct/enum: \(subscriber)")
//            }
            let identifier = ObjectIdentifier(eventType)
            var subscribed = self.subscribed[identifier] ?? []
            let weakBox = WeakBox(subscriber as AnyObject)
            let _ = subscribed.remove(weakBox)
            self.subscribed[identifier] = Set(subscribed.filter { $0.inner is T })
        }
    }

    public func remove<T>(subscriber: T) {
        self.serialQueue.sync {
            // Temporarily disabled due to https://bugs.swift.org/browse/SR-4420:
//            guard type(of: subscriber) is AnyClass else {
//                fatalError("Expected class, found struct/enum: \(subscriber)")
//            }
            for (identifier, var subscribed) in self.subscribed {
                let weakBox = WeakBox(subscriber as AnyObject)
                let _ = subscribed.remove(weakBox)
                self.subscribed[identifier] = Set(subscribed.filter { $0.inner is T })
            }
        }
    }

    public func removeAllSubscribers() {
        self.serialQueue.sync {
            self.subscribed = [:]
        }
    }
}

extension EventBus : EventNotifiable {

    public func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ()) {
        self.serialQueue.sync {
            defer {
                for eventBus in chained.flatMap({ $0.inner as? EventNotifiable }) {
                    self.queue.async {
                        eventBus.notify(eventType, closure: closure)
                    }
                }
            }
            let identifier = ObjectIdentifier(eventType)
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

extension EventBus : EventChainable {

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
}
