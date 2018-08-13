//
//  Options.swift
//  EventBus (Framework)
//
//  Created by Vincent Esche on 8/13/18.
//  Copyright © 2018 Vincent Esche. All rights reserved.
//

import Foundation

/// Options for configuring the behavior of a given EventBus.
public struct Options: OptionSet {

    /// See protocol `OptionSet`
    public let rawValue: Int

    /// See protocol `OptionSet`
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Print a warning whenever an event gets subscribed to or notified that has not previously
    /// been registered (i.e. via `eventBus.register(forEvent: MyEvent.self)`) with the event bus.
    ///
    /// - Note:
    ///   Warning logs are only emitted if the `DEBUG` compiler flag is present.
    ///
    ///   By setting `EventBus.isStrict = true` you can catch the error using
    ///   a "Swift Error Breakpoint" on type `StrictnessError`.
    /// ```
    public static let warnUnknown = Options(rawValue: 1 << 0)

    /// Print a warning whenever an event gets subscribed to or notified that has not previously
    /// been registered (i.e. via `eventBus.register(forEvent: MyEvent.self)`) with the event bus.
    ///
    /// - Note:
    ///   Warning logs are only emitted if the `DEBUG` compiler flag is present.
    ///
    ///   By setting `EventBus.isStrict = true` you can catch the error using
    ///   a "Swift Error Breakpoint" on type `StrictnessError`.
    /// ```
    public static let warnUnhandled = Options(rawValue: 1 << 1)

    /// All available warnings:
    /// - `.warnUnknown`
    /// - `.warnUnhandled`
    public static var allWarnings: Options {
        return [.warnUnknown, .warnUnhandled]
    }
    
    /// Print a log of emitted events for a given event bus.
    public static let logEvents = Options(rawValue: 1 << 2)
}
