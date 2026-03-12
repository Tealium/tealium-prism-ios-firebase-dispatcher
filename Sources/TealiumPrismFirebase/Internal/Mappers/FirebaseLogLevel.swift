//
//  FirebaseLogLevel.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 8/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseCore
import Foundation

// MARK: - Firebase Log Level

/// Represents Firebase log level with distinct cases for min and max.
///
/// Maps to Firebase's `FirebaseLoggerLevel` (min/error and max/debug are aliases there).
/// Supports all 7 levels from minimum to maximum verbosity.
///
/// Firebase SDK Reference:
/// - FIRLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Enums/FIRLoggerLevel
/// - setLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Classes/FirebaseConfiguration#/c:objc(cs)FIRConfiguration(im)setLoggerLevel:
enum FirebaseLogLevel: String, CaseIterable {
    case min
    case error
    case warning
    case notice
    case info
    case debug
    case max

    /// Maps string log level names to FirebaseLogLevel.
    ///
    /// Case-insensitive. Returns nil if the string is not recognized.
    static func map(_ levelString: String) -> FirebaseLogLevel? {
        FirebaseLogLevel(rawValue: levelString.lowercased())
    }

    /// String representation for logging/configuration (same as rawValue).
    var stringValue: String { rawValue }

    /// Value for Firebase SDK API calls (e.g. `FirebaseConfiguration.shared.setLoggerLevel(_:)`).
    ///
    /// In Firebase SDK, .min and .error share the same raw value, as do .max and .debug.
    var value: FirebaseLoggerLevel {
        switch self {
        case .min: return .min
        case .error: return .error
        case .warning: return .warning
        case .notice: return .notice
        case .info: return .info
        case .debug: return .debug
        case .max: return .max
        }
    }

    /// Creates FirebaseLogLevel from Firebase SDK value.
    ///
    /// Firebase defines .min = .error and .max = .debug (same raw values),
    /// so when converting back we map: raw 3 → .error, raw 7 → .debug.
    init?(firebaseLoggerLevel: FirebaseLoggerLevel) {
        switch firebaseLoggerLevel {
        case .min, .error: self = .error
        case .warning: self = .warning
        case .notice: self = .notice
        case .info: self = .info
        case .max, .debug: self = .debug
        @unknown default: return nil
        }
    }

    /// Returns the string for a FirebaseLoggerLevel (e.g. when receiving value from SDK).
    ///
    /// Use when you only have FirebaseLoggerLevel; cannot distinguish .min from .error or .max from .debug.
    /// Returns nil if the level is not recognized (e.g., Firebase SDK added a new log level).
    static func string(from loggerLevel: FirebaseLoggerLevel) -> String? {
        FirebaseLogLevel(firebaseLoggerLevel: loggerLevel)?.rawValue
    }
}
