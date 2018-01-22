//
//  EventSubscribableTests.swift
//  EventBusTests
//
//  Created by Vincent Esche on 04/12/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import XCTest

import Foundation
@testable import EventBus

class EventSubscribableTests: XCTestCase {

    func testAddingSubscriberWithoutRelatedSibling() {
        let fooStub = FooStub()

        let eventBus = EventBus()
        XCTAssertFalse(eventBus.has(subscriber: fooStub, for: FooStubable.self))

        eventBus.add(subscriber: fooStub, for: FooStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStub, for: FooStubable.self))
    }

    func testAddingSubscriberWithRelatedSibling() {
        let fooStubA = FooStub()
        let fooStubB = FooStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooStubA, for: FooStubable.self)
        XCTAssertFalse(eventBus.has(subscriber: fooStubB, for: FooStubable.self))

        eventBus.add(subscriber: fooStubB, for: FooStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStubB, for: FooStubable.self))
    }

    func testAddingSubscriberWithUnrelatedSibling() {
        let fooStub = FooStub()
        let barStub = BarStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooStub, for: FooStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStub, for: FooStubable.self))
        XCTAssertFalse(eventBus.has(subscriber: barStub, for: BarStubable.self))

        eventBus.add(subscriber: barStub, for: BarStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStub, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: barStub, for: BarStubable.self))
    }

    func testAddingSubscriberWithMultipleConformances() {
        let fooBarStub = FooBarStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooBarStub, for: FooStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: FooStubable.self))
        XCTAssertFalse(eventBus.has(subscriber: fooBarStub, for: BarStubable.self))

        eventBus.add(subscriber: fooBarStub, for: BarStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: BarStubable.self))
    }

    func testRemovingSubscriberWithoutRelatedSibling() {
        let fooStub = FooStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooStub, for: FooStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStub, for: FooStubable.self))

        eventBus.remove(subscriber: fooStub, for: FooStubable.self)
        XCTAssertFalse(eventBus.has(subscriber: fooStub, for: FooStubable.self))
    }

    func testRemovingSubscriberWithRelatedSibling() {
        let fooStubA = FooStub()
        let fooStubB = FooStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooStubA, for: FooStubable.self)
        eventBus.add(subscriber: fooStubB, for: FooStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStubA, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: fooStubB, for: FooStubable.self))

        eventBus.remove(subscriber: fooStubA, for: FooStubable.self)
        XCTAssertFalse(eventBus.has(subscriber: fooStubA, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: fooStubB, for: FooStubable.self))
    }

    func testRemovingSubscriberWithUnrelatedSibling() {
        let fooStub = FooStub()
        let barStub = BarStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooStub, for: FooStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStub, for: FooStubable.self))
        XCTAssertFalse(eventBus.has(subscriber: barStub, for: BarStubable.self))

        eventBus.add(subscriber: barStub, for: BarStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooStub, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: barStub, for: BarStubable.self))
    }

    func testRemovingSubscriberWithMultipleConformancesIndividually() {
        let fooBarStub = FooBarStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooBarStub, for: FooStubable.self)
        eventBus.add(subscriber: fooBarStub, for: BarStubable.self)
        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: BarStubable.self))

        eventBus.remove(subscriber: fooBarStub, for: FooStubable.self)
        XCTAssertFalse(eventBus.has(subscriber: fooBarStub, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: BarStubable.self))
    }

    func testRemovingSubscriberWithMultipleConformancesBroadly() {
        let fooBarStub = FooBarStub()

        let eventBus = EventBus()
        eventBus.add(subscriber: fooBarStub, for: FooStubable.self)
        eventBus.add(subscriber: fooBarStub, for: BarStubable.self)

        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: FooStubable.self))
        XCTAssertTrue(eventBus.has(subscriber: fooBarStub, for: BarStubable.self))

        eventBus.remove(subscriber: fooBarStub)
        XCTAssertFalse(eventBus.has(subscriber: fooBarStub, for: FooStubable.self))
        XCTAssertFalse(eventBus.has(subscriber: fooBarStub, for: BarStubable.self))
    }

    func testAddingNonClassSubscriberToEventEmitsError() {
        let expectation = self.expectation(description: "")

        let errorHandlerMock = ErrorHandlerMock { error in
            switch error {
            case .invalidSubscriber: expectation.fulfill()
            case _: XCTFail("Should not have emitted `.invalidSubscriber` on handler")
            }
        }

        let eventBus = EventBus()
        eventBus.errorHandler = errorHandlerMock
        eventBus.add(subscriber: InvalidFooStub(), for: FooStubable.self)

        self.waitForExpectations(timeout: 1.0)
    }

    func testRemovingNonClassSubscriberFromEventEmitsError() {
        let expectation = self.expectation(description: "")

        let errorHandlerMock = ErrorHandlerMock { error in
            switch error {
            case .invalidSubscriber: expectation.fulfill()
            case _: XCTFail("Should not have emitted `.invalidSubscriber` on handler")
            }
        }

        let eventBus = EventBus()
        eventBus.errorHandler = errorHandlerMock
        eventBus.remove(subscriber: InvalidFooStub(), for: FooStubable.self)

        self.waitForExpectations(timeout: 1.0)
    }

    func testRemovingNonClassSubscriberEmitsError() {
        let expectation = self.expectation(description: "")

        let errorHandlerMock = ErrorHandlerMock { error in
            switch error {
            case .invalidSubscriber: expectation.fulfill()
            case _: XCTFail("Should not have emitted `.invalidSubscriber` on handler")
            }
        }

        let eventBus = EventBus()
        eventBus.errorHandler = errorHandlerMock
        eventBus.remove(subscriber: InvalidFooStub())

        self.waitForExpectations(timeout: 1.0)
    }

    func testSubscriptionOfUnknownEventEmitsError() {
        let expectation = self.expectation(description: "")

        let fooStub = FooStub()

        let errorHandlerMock = ErrorHandlerMock { error in
            switch error {
            case .unknownEvent: expectation.fulfill()
            case _: XCTFail("Should not have emitted `.unknownEvent` on handler")
            }
        }

        let eventBus = EventBus(options: .warnUnknown)
        eventBus.register(forEvent: BarMockable.self)
        eventBus.errorHandler = errorHandlerMock
        eventBus.add(subscriber: fooStub, for: FooStubable.self)

        self.waitForExpectations(timeout: 1.0)
    }
}
