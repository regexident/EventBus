//
//  LogHandler.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

internal protocol LogHandler {
    func eventBus<T>(_ eventBus: EventBus, receivedEvent: T.Type)
}

internal struct DefaultLogHandler: LogHandler {
    func eventBus<T>(_ eventBus: EventBus, receivedEvent eventType: T.Type) {
        #if DEBUG
        print("\(eventBus): Received event '\(eventType)'.")
        #endif
    }
}
