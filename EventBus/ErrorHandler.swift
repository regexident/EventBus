//
//  ErrorHandler.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

internal protocol ErrorHandler {
    func eventBus<T>(_ eventBus: EventBus, receivedUnknownEvent eventType: T.Type)
    func eventBus<T>(_ eventBus: EventBus, droppedUnhandledEvent eventType: T.Type)
    func eventBus<T>(_ eventBus: EventBus, receivedNonClassSubscriber subscriberType: T.Type)
}

internal struct DefaultErrorHandler: ErrorHandler {
    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventBus, receivedUnknownEvent eventType: T.Type) {
        #if DEBUG
        typealias ErrorType = UnknownEventError
        let errorName = String(describing: ErrorType.self)
        let eventTypes = eventBus.registeredEventTypes
        let eventNames = eventTypes.lazy.map { "\($0)" }.joined(separator: ", ")
        let namesString = eventNames.isEmpty ? "" : " (e.g. \(eventNames))"
        print("\(eventBus): Expected event of registered type\(namesString), found: \(eventType).")
        print("Info: Use a \"Swift Error Breakpoint\" on type \"EventBus.\(errorName)\" to catch.")
        if EventBus.isStrict {
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        }
        #endif
    }

    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventBus, droppedUnhandledEvent eventType: T.Type) {
        #if DEBUG
        typealias ErrorType = UnhandledEventError
        let errorName = String(describing: ErrorType.self)
        print("\(eventBus): Event of type '\(eventType)' was not handled.")
        print("Info: Use a \"Swift Error Breakpoint\" on type \"EventBus.\(errorName)\" to catch.")
        if EventBus.isStrict {
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        }
        #endif
    }

    @inline(__always)
    internal func eventBus<T>(_ eventBus: EventBus, receivedNonClassSubscriber subscriberType: T.Type) {
        #if DEBUG
        typealias ErrorType = InvalidSubscriberError
        let errorName = String(describing: ErrorType.self)
        print("\(eventBus): Expected class, found struct/enum: \(subscriberType).")
        print("Info: Use a \"Swift Error Breakpoint\" on type \"EventBus.\(errorName)\" to catch.")
        if EventBus.isStrict {
            do {
                throw ErrorType()
            } catch {
                // intentionally left blank
            }
        }
        #endif
    }
}
