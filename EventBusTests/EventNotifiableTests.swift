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
            case .bar: XCTFail("Should not have called `BarMockable` on subscriber")
            }
        }

        let eventBus = EventBus()
        eventBus.add(subscriber: fooBarMock, for: FooMockable.self)
        eventBus.notify(FooMockable.self) { subscriber in
            subscriber.foo()
        }

        self.waitForExpectations(timeout: 1.0)
    }
}
