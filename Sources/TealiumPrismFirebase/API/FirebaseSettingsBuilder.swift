//
//  FirebaseSettingsBuilder.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
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
/// - `setGA360Mode(_:)` - Extended parameter value limits (500 vs 100 chars)
/// - `setLogLevel(_:)` - Firebase internal logging verbosity
/// - `setInvalidCharacterStrategy(_:)` - How to handle invalid characters
///
/// ## Example
///
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         .setSessionTimeout(1800)
///         .setAnalyticsEnabled(true)
///         .setGA360Mode(false)
///         .setMappings([...])
/// })
/// ```
public class FirebaseSettingsBuilder: DispatcherSettingsBuilder {
    
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
        _configurationObject.set(seconds, key: FirebaseConstants.Initialize.Param.sessionTimeout)
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
        _configurationObject.set(enabled, key: FirebaseConstants.Initialize.Param.analyticsEnabled)
        return self
    }
    
    // MARK: - Validation Configuration
    
    /// Set the validation strategy for handling invalid characters in event/parameter names.
    ///
    /// Firebase has restrictions on allowed characters in event and parameter names.
    /// This setting controls how invalid characters are handled:
    /// - `"replace"`: Replace invalid characters with underscores
    /// - `"remove"`: Remove invalid characters completely
    /// - Any other value defaults to remove behavior
    ///
    /// - Parameter strategy: The validation strategy to use.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func setInvalidCharacterStrategy(_ strategy: String) -> Self {
        _configurationObject.set(strategy, key: FirebaseConstants.Initialize.Param.invalidCharStrategy)
        return self
    }
    
    // MARK: - GA360 Configuration
    
    /// Enable GA360 mode for extended parameter value limits.
    ///
    /// Standard Firebase Analytics has a 100 character limit for parameter values.
    /// GA360 mode extends this to 500 characters.
    ///
    /// - Parameter enabled: Whether GA360 mode should be enabled.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func setGA360Mode(_ enabled: Bool) -> Self {
        _configurationObject.set(enabled, key: FirebaseConstants.Initialize.Param.ga360Mode)
        return self
    }
    
    // MARK: - Logging Configuration
    
    /// Set the Firebase internal log level.
    ///
    /// Controls the verbosity of Firebase SDK logging.
    /// Valid values: "min", "error", "warning", "notice", "info", "debug", "max"
    ///
    /// - Parameter level: The log level string.
    /// - Returns: Self for method chaining.
    @discardableResult
    public func setLogLevel(_ level: String) -> Self {
        _configurationObject.set(level, key: FirebaseConstants.Initialize.Param.logLevel)
        return self
    }
}
