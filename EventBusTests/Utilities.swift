//
//  Utilities.swift
//  EventBusTests
//
//  Created by Vincent Esche on 9/4/17.
//  Copyright © 2017 Vincent Esche. All rights reserved.
//

import Foundation

protocol FooStubable {}
protocol BarStubable {}

class FooStub: FooStubable {}
class BarStub: BarStubable {}
class FooBarStub: FooStubable, BarStubable {}

enum Event { case foo, bar }

protocol FooMockable { func foo() }
protocol BarMockable { func bar() }

class Mock {
    fileprivate let closure: (Event) -> ()

    init(closure: ((Event) -> ())? = nil) {
        self.closure = closure ?? { _ in }
    }
}

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
