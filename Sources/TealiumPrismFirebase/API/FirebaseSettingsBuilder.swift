//
//  FirebaseSettingsBuilder.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseCore
import TealiumPrismCore

/// Builder for Firebase Dispatcher configuration settings.
///
/// Use this builder to configure Firebase Analytics behavior.
/// For data mappings, use `setMappings(_:)` with helpers from `Mappings+Firebase.swift`.
///
/// ## Available Configuration Options
///
/// - `setSessionTimeout(_:)` - Session timeout in seconds (default: 1800)
/// - `setAnalyticsEnabled(_:)` - Enable/disable analytics collection
/// - `setLogLevel(_:)` - Firebase internal logging verbosity
///
/// ## Example
///
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         .setSessionTimeout(1800)
///         .setAnalyticsEnabled(true)
///         .setMappings([...])
/// })
/// ```
public class FirebaseSettingsBuilder: DispatcherSettingsBuilder {
    
    typealias Keys = FirebaseDispatcherConfiguration.Keys
    
    public override init() {
        super.init()
    }
    
    // MARK: - Session Configuration
    
    /// Set the session timeout in seconds.
    ///
    /// This configures how long a session lasts before timing out.
    /// Default Firebase session timeout is 30 minutes (1800 seconds).
    ///
    /// - Parameter seconds: The session timeout in seconds.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func setSessionTimeout(_ seconds: Int) -> Self {
        _configurationObject.set(seconds, key: Keys.sessionTimeout)
        return self
    }
    
    // MARK: - Analytics Collection Configuration
    
    /// Enable or disable analytics collection.
    ///
    /// When disabled, no analytics data will be collected or sent to Firebase.
    ///
    /// - Parameter enabled: Whether analytics collection should be enabled.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func setAnalyticsEnabled(_ enabled: Bool) -> Self {
        _configurationObject.set(enabled, key: Keys.analyticsEnabled)
        return self
    }
    
    // MARK: - Logging Configuration
    
    /// Set the Firebase internal log level.
    ///
    /// Controls the verbosity of Firebase SDK logging.
    ///
    /// - Parameter level: The FirebaseLoggerLevel enum value.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func setLogLevel(_ level: FirebaseLoggerLevel) -> Self {
        let levelString = FirebaseLogLevel.string(from: level)
        _configurationObject.set(levelString, key: Keys.logLevel)
        return self
    }
}
