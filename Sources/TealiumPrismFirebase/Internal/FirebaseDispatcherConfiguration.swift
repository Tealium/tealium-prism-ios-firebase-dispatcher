//
//  FirebaseDispatcherConfiguration.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 30/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import FirebaseCore
import TealiumPrismCore

/// Configuration for Firebase Dispatcher module.
///
/// Holds the settings for Firebase Analytics initialization and behavior.
struct FirebaseDispatcherConfiguration {
    /// Session timeout in seconds. Default Firebase session timeout is 30 minutes (1800 seconds).
    let sessionTimeout: Double?
    /// Whether analytics collection is enabled.
    let analyticsEnabled: Bool?
    /// Firebase internal log level. If nil (not provided or invalid), Firebase's default is used.
    let logLevel: FirebaseLogLevel?
    
    enum Keys {
        static let sessionTimeout = "session_timeout_seconds"
        static let analyticsEnabled = "analytics_collection_enabled"
        static let logLevel = "log_level"
    }
    
    init(configuration: DataObject) {
        sessionTimeout = configuration.getAsDouble(key: Keys.sessionTimeout)
        analyticsEnabled = configuration.get(key: Keys.analyticsEnabled)
        logLevel = configuration.get(key: Keys.logLevel, as: String.self).flatMap { FirebaseLogLevel.map($0) }
    }
}
