//
//  EventChainableTests.swift
//  EventBusTests
//
//  Created by Vincent Esche on 04/12/2016.
//  Copyright © 2016 Vincent Esche. All rights reserved.
//

import XCTest

import Foundation
@testable import EventBus

class EventChainableTests: XCTestCase {
    func testAttachChain() {
        let rootEventBus = EventBus()
        let leafEventBus = EventBus()

        XCTAssertFalse(rootEventBus.has(chain: leafEventBus))
        rootEventBus.attach(chain: leafEventBus)
        XCTAssertTrue(rootEventBus.has(chain: leafEventBus))
    }

    func testDetachChain() {
        let rootEventBus = EventBus()
        let leafEventBus = EventBus()
        rootEventBus.attach(chain: leafEventBus)

        XCTAssertTrue(rootEventBus.has(chain: leafEventBus))
        rootEventBus.detach(chain: leafEventBus)
        XCTAssertFalse(rootEventBus.has(chain: leafEventBus))
    }

    func testDetachAllChains() {
        let rootEventBus = EventBus()
        let leafEventBusA = EventBus()
        let leafEventBusB = EventBus()
        rootEventBus.attach(chain: leafEventBusA)
        rootEventBus.attach(chain: leafEventBusB)

        XCTAssertTrue(rootEventBus.has(chain: leafEventBusA))
        XCTAssertTrue(rootEventBus.has(chain: leafEventBusB))
        rootEventBus.detachAllChains()
        XCTAssertFalse(rootEventBus.has(chain: leafEventBusA))
        XCTAssertFalse(rootEventBus.has(chain: leafEventBusB))
    }

    func testNotifyNotifiesChains() {
        let expectation = self.expectation(description: "")

        let fooMock = FooMock { _ in expectation.fulfill() }

        let rootEventBus = EventBus()
        let leafEventBus = EventBus()

        rootEventBus.attach(chain: leafEventBus)
        leafEventBus.add(subscriber: fooMock, for: FooMockable.self)

        rootEventBus.notify(FooMockable.self) { subscriber in
            subscriber.foo()
        }

        self.waitForExpectations(timeout: 1.0)
    }
}
