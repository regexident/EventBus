//
//  EventNotifiableTests.swift
//  EventBusTests
//
//  Created by Vincent Esche on 04/12/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import XCTest

import Foundation
@testable import EventBus

class EventNotifiableTests: XCTestCase {
    func testNotifyNotifiesRelatedSubscribers() {
        let expectation = self.expectation(description: "")

        let fooMock = FooMock { _ in expectation.fulfill() }

        let eventBus = EventBus()
        eventBus.add(subscriber: fooMock, for: FooMockable.self)
        eventBus.notify(FooMockable.self) { subscriber in
            subscriber.foo()
        }

        self.waitForExpectations(timeout: 1.0)
    }

    func testNotifyNotifiesIgnoresUnrelatedSubscribers() {
        let expectation = self.expectation(description: "")
        expectation.isInverted = true

        let fooMock = FooMock { _ in expectation.fulfill() }

        let eventBus = EventBus()
        eventBus.add(subscriber: fooMock, for: FooMockable.self)
        eventBus.notify(BarMockable.self) { subscriber in
            subscriber.bar()
        }

        self.waitForExpectations(timeout: 1.0)
    }

    func testNotifyNotifiesIgnoresUnrelatedSubscribers_() {
        let expectation = self.expectation(description: "")

        let fooBarMock = FooBarMock { event in
            switch event {
            case .foo: expectation.fulfill()
            case _: XCTFail("Should not have called `BarMockable` on subscriber")
            }
        }

        let eventBus = EventBus()
        eventBus.add(subscriber: fooBarMock, for: FooMockable.self)
        eventBus.notify(FooMockable.self) { subscriber in
            subscriber.foo()
        }

        self.waitForExpectations(timeout: 1.0)
    }

    func testNotifyOnUnknownEventEmitsError() {
        let expectation = self.expectation(description: "")

        let errorHandlerMock = ErrorHandlerMock { error in
            switch error {
            case .unknownEvent: expectation.fulfill()
            case _: XCTFail("Should not have emitted `.unknownEvent` on handler")
            }
        }

        let eventBus = EventBus(options: .warnUnknown)
        eventBus.register(forEvent: BarMockable.self)
        eventBus.errorHandler = errorHandlerMock
        eventBus.notify(FooMockable.self) { _ in }

        self.waitForExpectations(timeout: 1.0)
    }

    func testDropOnNotifiedEventEmitsError() {
        let expectation = self.expectation(description: "")

        let errorHandlerMock = ErrorHandlerMock { error in
            switch error {
            case .unhandledEvent: expectation.fulfill()
            case _: XCTFail("Should not have emitted `.unhandledEvent` on handler")
            }
        }

        let eventBus = EventBus(options: .warnUnhandled)
        eventBus.errorHandler = errorHandlerMock
        eventBus.notify(FooMockable.self) { _ in }

        self.waitForExpectations(timeout: 1.0)
    }

    func testNotifyEmitsLog() {
        let expectation = self.expectation(description: "")

        let logHandler = LogHandlerMock {
            expectation.fulfill()
        }

        let eventBus = EventBus(options: .logEvents)
        eventBus.logHandler = logHandler

        eventBus.notify(FooMockable.self) { subscriber in
            subscriber.foo()
        }

        self.waitForExpectations(timeout: 1.0)
    }
}
