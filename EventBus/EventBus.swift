//
//  EventBus.swift
//  EventBus
//
//  Created by Vincent Esche on 21/11/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import Foundation

public protocol EventSubscribable {
    func add<T>(subscriber: T, for eventType: T.Type)
    func remove<T>(subscriber: T, for eventType: T.Type)
}

public protocol EventNotifyable {
    func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ())
}

/// Event bus
public class EventBus: EventNotifyable, EventSubscribable {

    struct WeakSubscriber : Equatable, Hashable {
        weak var inner: AnyObject?

        init(_ inner: AnyObject) {
            self.inner = inner
        }

        static func == (lhs: WeakSubscriber, rhs: WeakSubscriber) -> Bool {
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

    var subscribers: [ObjectIdentifier: Set<WeakSubscriber>] = [:]

    private let serialQueue: DispatchQueue = DispatchQueue(label: "com.regexident.eventbus")
    private let queue: DispatchQueue

    public init(queue: DispatchQueue = DispatchQueue.global()) {
        self.queue = queue
    }

    public func add<T>(subscriber: T, for eventType: T.Type) {
        self.serialQueue.sync {
            guard type(of: subscriber) is AnyClass else {
                fatalError("Expected class, found struct/enum: \(subscriber)")
            }
            let identifier = ObjectIdentifier(eventType)
            var subscribers = self.subscribers[identifier] ?? []
            let weakSubscriber = WeakSubscriber(subscriber as AnyObject)
            subscribers.insert(weakSubscriber)
            self.subscribers[identifier] = subscribers
            self.cleanup(eventType)
        }
    }

    public func remove<T>(subscriber: T, for eventType: T.Type) {
        self.serialQueue.sync {
            guard type(of: subscriber) is AnyClass else {
                fatalError("Expected class, found struct/enum: \(subscriber)")
            }
            let identifier = ObjectIdentifier(eventType)
            let weakSubscriber = WeakSubscriber(subscriber as AnyObject)
            let _ = self.subscribers[identifier]?.remove(weakSubscriber)
            self.cleanup(eventType)
        }
    }

    public func notify<T>(_ eventType: T.Type, closure: @escaping (T) -> ()) {
        self.serialQueue.sync {
            let identifier = ObjectIdentifier(eventType)
            guard let subscribers = self.subscribers[identifier] else {
                return
            }
            for subscriber in subscribers.flatMap({ $0.inner as? T }) {
                self.queue.async {
                    closure(subscriber)
                }
            }
        }
    }

    private func cleanup<T>(_ eventType: T.Type) {
        let identifier = ObjectIdentifier(eventType)
        guard let subscribers = self.subscribers[identifier] else {
            return
        }
        self.subscribers[identifier] = Set(subscribers.filter { $0.inner is T })
    }
}
