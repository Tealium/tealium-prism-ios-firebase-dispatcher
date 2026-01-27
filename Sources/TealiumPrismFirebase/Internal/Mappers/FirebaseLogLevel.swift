//
//  FirebaseLogLevel.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 8/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import FirebaseCore

// MARK: - Firebase Log Level Mappings

/// Maps string log level names to Firebase LoggerLevel enum values.
///
/// Supports all 7 Firebase log levels from minimum to maximum verbosity.
///
/// Firebase SDK Reference:
/// - FIRLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Enums/FIRLoggerLevel
/// - setLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Classes/FirebaseConfiguration#/c:objc(cs)FIRConfiguration(im)setLoggerLevel:
struct FirebaseLogLevel {
    
    /// Maps string log level names to FirebaseLoggerLevel enum values.
    ///
    /// Ordered from least verbose (min) to most verbose (max):
    /// - `min` → Minimum log level (least verbose)
    /// - `error` → Error level, matches ASL_LEVEL_ERR
    /// - `warning` → Warning level, matches ASL_LEVEL_WARNING
    /// - `notice` → Notice level, matches ASL_LEVEL_NOTICE (default)
    /// - `info` → Info level, matches ASL_LEVEL_INFO
    /// - `debug` → Debug level, matches ASL_LEVEL_DEBUG
    /// - `max` → Maximum log level (most verbose)
    static let mapping: [String: FirebaseLoggerLevel] = [
        "min": .min,
        "error": .error,
        "warning": .warning,
        "notice": .notice,
        "info": .info,
        "debug": .debug,
        "max": .max
    ]
    
    /// Returns the mapped FirebaseLoggerLevel for the given string, or `.notice` as default.
    ///
    /// Case-insensitive mapping supports common variations:
    /// - "debug", "DEBUG", "Debug" all map to `.debug`
    ///
    /// - Parameter levelString: The log level name (e.g., "debug", "info", "max")
    /// - Returns: The corresponding FirebaseLoggerLevel, or `.notice` if not recognized
    ///
    /// Example:
    /// ```swift
    /// let level = FirebaseLogLevel.map("debug")  // Returns .debug
    /// let unknown = FirebaseLogLevel.map("invalid")  // Returns .notice (default)
    /// ```
    static func map(_ levelString: String) -> FirebaseLoggerLevel {
        return mapping[levelString.lowercased()] ?? .notice
    }
    
    /// Returns whether the given string is a valid Firebase log level.
    ///
    /// - Parameter levelString: The log level name to validate
    /// - Returns: `true` if the level is recognized, `false` otherwise
    ///
    /// Example:
    /// ```swift
    /// FirebaseLogLevel.isValid("debug")    // true
    /// FirebaseLogLevel.isValid("invalid")  // false
    /// ```
    static func isValid(_ levelString: String) -> Bool {
        return mapping[levelString.lowercased()] != nil
    }
    
    /// All valid log level names in order from least to most verbose.
    static let allLevels: [String] = ["min", "error", "warning", "notice", "info", "debug", "max"]
    
    /// Returns the string representation for the given FirebaseLoggerLevel enum value.
    ///
    /// Maps FirebaseLoggerLevel enum values back to their string names.
    ///
    /// - Parameter loggerLevel: The FirebaseLoggerLevel enum value
    /// - Returns: The corresponding string representation (e.g., "error", "warning", "debug")
    ///
    /// Example:
    /// ```swift
    /// let levelString = FirebaseLogLevel.string(from: .debug)  // Returns "debug"
    /// ```
    static func string(from loggerLevel: FirebaseLoggerLevel) -> String {
        // Handle the distinct enum cases
        // Note: .min == .error and .max == .debug, so we can't distinguish them
        switch loggerLevel {
        case .min, .error:
            return "error"
        case .warning:
            return "warning"
        case .notice:
            return "notice"
        case .info:
            return "info"
        case .max, .debug:
            return "debug"
        @unknown default:
            return "notice"
        }
    }
}
