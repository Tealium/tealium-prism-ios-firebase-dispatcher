//
//  FirebaseSettingsBuilder.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2025 Tealium. All rights reserved.
//

import FirebaseCore
import Foundation
import TealiumPrismCore

/// Builder for Firebase Dispatcher configuration settings.
///
/// Use this builder to configure Firebase Analytics behavior.
/// For data mappings, use `setMappings(_:)` with `FirebaseMappings` type-safe enums.
///
/// ## Available Configuration Options
///
/// - `setSessionTimeout(_:)` - Session timeout duration (Firebase default is 30 minutes)
/// - `setAnalyticsEnabled(_:)` - Enable/disable analytics collection
/// - `setLogLevel(_:)` - Firebase internal logging verbosity
///
/// ## Example
///
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         .setSessionTimeout(30.minutes)
///         .setAnalyticsEnabled(true)
///         .setMappings { mappings in
///             mappings.mapCommand(.logEvent)
///             mappings.mapFrom("tealium_event", to: .eventName)
///         }
/// })
/// ```
public class FirebaseSettingsBuilder: DispatcherSettingsBuilder<FirebaseMappings> {

    typealias Keys = FirebaseDispatcherConfiguration.Keys

    // MARK: - Session Configuration

    /// Set the session timeout duration.
    ///
    /// This configures how long a session lasts before timing out.
    /// If not set, Firebase applies its own default of 30 minutes.
    /// - Parameter sessionTimeout: The session timeout as a `TimeFrame` (e.g. `30.minutes`).
    /// - Returns: Self for method chaining.
    @discardableResult
    public func setSessionTimeout(_ sessionTimeout: TimeFrame) -> Self {
        _configurationObject.set(sessionTimeout.inSeconds(), key: Keys.sessionTimeout)
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
        guard let levelString = FirebaseLogLevel.toString(level) else {
            // Unknown log level - skip setting it
            return self
        }
        _configurationObject.set(levelString, key: Keys.logLevel)
        return self
    }
}
