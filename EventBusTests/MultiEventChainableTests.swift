//
//  MultiEventChainableTests.swift
//  EventBusTests
//
//  Created by Vincent Esche on 04/12/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import XCTest

import Foundation
@testable import EventBus

class MultiEventChainableTests: XCTestCase {
    func testAttachChain() {
        let rootEventBus = EventMultiBus()
        let leafEventBus = EventMultiBus()

        XCTAssertFalse(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
        rootEventBus.attach(chain: leafEventBus, for: FooStubable.self)
        XCTAssertTrue(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
    }

    func testDetachChain() {
        let rootEventBus = EventMultiBus()
        let leafEventBus = EventMultiBus()
        rootEventBus.attach(chain: leafEventBus, for: FooStubable.self)

        XCTAssertTrue(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
        rootEventBus.detach(chain: leafEventBus)
        XCTAssertFalse(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
    }

    func testDetachAllChains() {
        let rootEventBus = EventMultiBus()
        let leafEventBusA = EventMultiBus()
        let leafEventBusB = EventMultiBus()
        rootEventBus.attach(chain: leafEventBusA, for: FooStubable.self)
        rootEventBus.attach(chain: leafEventBusB, for: FooStubable.self)

        XCTAssertTrue(rootEventBus.has(chain: leafEventBusA, for: FooStubable.self))
        XCTAssertTrue(rootEventBus.has(chain: leafEventBusB, for: FooStubable.self))
        rootEventBus.detachAllChains()
        XCTAssertFalse(rootEventBus.has(chain: leafEventBusA, for: FooStubable.self))
        XCTAssertFalse(rootEventBus.has(chain: leafEventBusB, for: FooStubable.self))
    }

    func testNotifyNotifiesChains() {
        let notifiedExpectation = self.expectation(description: "")
        let ignoredExpectation = self.expectation(description: "")
        ignoredExpectation.isInverted = true

        let notifiedFooMock = FooMock { _ in notifiedExpectation.fulfill() }
        let ignoredBarMock = BarMock { _ in ignoredExpectation.fulfill() }

        let rootEventBus = EventMultiBus()
        let notifiedLeafEventBus = EventMultiBus()
        let ignoredLeafEventBus = EventMultiBus()

        rootEventBus.attach(chain: notifiedLeafEventBus, for: FooMockable.self)
        rootEventBus.attach(chain: ignoredLeafEventBus, for: BarMockable.self)

        notifiedLeafEventBus.add(subscriber: notifiedFooMock, for: FooMockable.self)
        ignoredLeafEventBus.add(subscriber: ignoredBarMock, for: BarMockable.self)

        rootEventBus.notify(FooMockable.self) { subscriber in
            subscriber.foo()
        }

        self.waitForExpectations(timeout: 1.0)
    }
}
