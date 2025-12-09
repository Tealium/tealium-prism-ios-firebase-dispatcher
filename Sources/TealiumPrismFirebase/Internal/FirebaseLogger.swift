//
//  FirebaseLogger.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseCore

// MARK: - FirebaseLoggerLevel Extension

/// Extension for Firebase Core FirebaseLoggerLevel.
///
/// Firebase SDK Reference:
/// - FirebaseLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Enums/FIRLoggerLevel
/// - setLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Classes/FirebaseConfiguration#/c:objc(cs)FIRConfiguration(im)setLoggerLevel:
extension FirebaseLoggerLevel {
    /// Creates a FirebaseLoggerLevel from a string value.
    ///
    /// Supported values (case-insensitive):
    /// - "error" → `.error`
    /// - "warning" → `.warning`
    /// - "notice" → `.notice` (default level)
    /// - "info" → `.info`
    /// - "debug" → `.debug`
    /// - "min" → `.min`
    /// - "max" → `.max`
    ///
    /// If the string doesn't match any known value, defaults to `.min`.
    ///
    /// - Parameter logLevelString: The log level string (e.g., "debug", "error", "notice")
    /// - Returns: The corresponding FirebaseLoggerLevel, or `.min` if invalid
    static func from(_ logLevelString: String) -> FirebaseLoggerLevel {
        switch logLevelString.lowercased() {
        case "error":
            return .error
        case "warning":
            return .warning
        case "notice":
            return .notice
        case "info":
            return .info
        case "debug":
            return .debug
        case "min":
            return .min
        case "max":
            return .max
        default:
            return .min
        }
    }
}

