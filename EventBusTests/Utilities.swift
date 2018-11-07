// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

@testable import EventBus

protocol FooStubable {}
protocol BarStubable {}

class FooStub: FooStubable {}
class BarStub: BarStubable {}
class FooBarStub: FooStubable, BarStubable {}

enum MockEvent { case foo, bar }

protocol FooMockable { func foo() }
protocol BarMockable { func bar() }

class Mock {
    fileprivate let closure: (MockEvent) -> ()

    init(closure: ((MockEvent) -> ())? = nil) {
        self.closure = closure ?? { _ in }
    }
}

struct InvalidFooStub: FooStubable {}

class FooMock: Mock, FooMockable {
    func foo() { self.closure(.foo) }
}

class BarMock: Mock, BarMockable {
    func bar() { self.closure(.bar) }
}

class FooBarMock: Mock, FooMockable, BarMockable {
    func foo() { self.closure(.foo) }
    func bar() { self.closure(.bar) }
}

enum MockError { case unknownEvent, unhandledEvent, invalidSubscriber }

class ErrorHandlerMock: ErrorHandler {
    fileprivate let closure: (MockError) -> ()

    init(closure: ((MockError) -> ())? = nil) {
        self.closure = closure ?? { _ in }
    }

    func eventBus<T>(_ eventBus: EventBus, receivedUnknownEvent eventType: T.Type) {
        self.closure(.unknownEvent)
    }

    func eventBus<T>(_ eventBus: EventBus, droppedUnhandledEvent eventType: T.Type) {
        self.closure(.unhandledEvent)
    }

    func eventBus<T>(_ eventBus: EventBus, receivedNonClassSubscriber subscriberType: T.Type) {
        self.closure(.invalidSubscriber)
    }
}

class LogHandlerMock: LogHandler {
    fileprivate let closure: () -> ()

    init(closure: (() -> ())? = nil) {
        self.closure = closure ?? { }
    }

    func eventBus<T>(_ eventBus: EventBus, receivedEvent eventType: T.Type) {
        self.closure()
    }
}
