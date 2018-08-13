//
//  Errors.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

internal struct InvalidSubscriberError: Error {
    // intentionally left blank
}

internal struct UnknownEventError: Error {
    // intentionally left blank
}

internal struct UnhandledEventError: Error {
    // intentionally left blank
}
