//
//  FirebaseDispatcherConfiguration.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 30/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Configuration for Firebase Dispatcher module.
///
/// Holds the settings for Firebase Analytics initialization and behavior.
struct FirebaseDispatcherConfiguration {
    /// Session timeout in seconds. Default Firebase session timeout is 30 minutes (1800 seconds).
    let sessionTimeout: Double?
    /// Whether analytics collection is enabled.
    let analyticsEnabled: Bool?
    /// Firebase internal log level string representation.
    let logLevel: String?
    
    enum Keys {
        static let sessionTimeout = "firebase_session_timeout_seconds"
        static let analyticsEnabled = "firebase_analytics_collection_enabled"
        static let logLevel = "firebase_log_level"
    }
    
    enum Defaults {
        // Firebase SDK defaults:
        // - Session timeout: 1800 seconds (30 minutes)
        // - Analytics enabled: true
        // - Log level: .notice
        // We use nil defaults to allow Firebase SDK defaults unless explicitly configured
        static let sessionTimeout: Double? = nil
        static let analyticsEnabled: Bool? = nil
        static let logLevel: String? = nil
    }
    
    init(configuration: DataObject) {
        sessionTimeout = configuration.getNumeric(key: Keys.sessionTimeout, as: Double.self) ?? Defaults.sessionTimeout
        analyticsEnabled = configuration.get(key: Keys.analyticsEnabled) ?? Defaults.analyticsEnabled
        logLevel = configuration.get(key: Keys.logLevel) ?? Defaults.logLevel
    }
}
