// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
