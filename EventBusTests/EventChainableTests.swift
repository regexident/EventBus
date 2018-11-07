// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

import Foundation
@testable import EventBus

class EventChainableTests: XCTestCase {
    func testAttachChain() {
        let rootEventBus = EventBus()
        let leafEventBus = EventBus()

        XCTAssertFalse(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
        rootEventBus.attach(chain: leafEventBus, for: FooStubable.self)
        XCTAssertTrue(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
    }

    func testDetachChain() {
        let rootEventBus = EventBus()
        let leafEventBus = EventBus()
        rootEventBus.attach(chain: leafEventBus, for: FooStubable.self)

        XCTAssertTrue(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
        rootEventBus.detach(chain: leafEventBus)
        XCTAssertFalse(rootEventBus.has(chain: leafEventBus, for: FooStubable.self))
    }

    func testDetachAllChains() {
        let rootEventBus = EventBus()
        let leafEventBusA = EventBus()
        let leafEventBusB = EventBus()
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

        let rootEventBus = EventBus()
        let notifiedLeafEventBus = EventBus()
        let ignoredLeafEventBus = EventBus()

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
