//
//  InitializeCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 7/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import FirebaseCore
import TealiumPrismCore

/// Command for initializing Firebase Analytics configuration.
///
/// This command configures Firebase Analytics settings including:
/// - Log level for internal Firebase logging
/// - Session timeout interval
/// - Analytics collection enabled/disabled
/// - GA360 mode (500 char vs 100 char limit)
/// - Invalid character handling strategy
///
/// Firebase SDK References:
/// - setLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Classes/FirebaseConfiguration#setloggerlevel_:
/// - setSessionTimeoutInterval: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setsessiontimeoutinterval_:
/// - setAnalyticsCollectionEnabled: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setanalyticscollectionenabled_:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "initialize",
///     "firebase_log_level": "max",
///     "firebase_session_timeout_seconds": 1800,
///     "firebase_analytics_collection_enabled": true,
///     "firebase_ga360_mode": false,
///     "firebase_invalid_char_strategy": "replace"
/// ]
/// ```
///
/// **Note:** Unlike other commands, Initialize reads parameters directly from the root
/// payload (not from a nested container) because these are configuration settings.
class InitializeCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }
    
    public let name = FirebaseConstants.Initialize.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing Initialize command")
        
        // 1. Configure log level (must be done before Firebase is configured)
        if let logLevel = payload.get(key: FirebaseConstants.Initialize.Param.logLevel, as: String.self) {
            configureLogLevel(logLevel)
        }
        
        // 2. Configure validator settings
        configureValidator(from: payload)
        
        // 3. Configure session timeout
        if let sessionTimeout = extractSessionTimeout(from: payload) {
            firebaseInstance.setSessionTimeoutInterval(sessionTimeout)
            logger?.debug(category: LogCategory.firebase, "Session timeout set to \(sessionTimeout) seconds")
        }
        
        // 4. Configure analytics collection
        if let analyticsEnabled = payload.get(key: FirebaseConstants.Initialize.Param.analyticsEnabled, as: Bool.self) {
            firebaseInstance.setAnalyticsCollectionEnabled(analyticsEnabled)
            logger?.debug(category: LogCategory.firebase, "Analytics collection enabled: \(analyticsEnabled)")
        }
        
        return true
    }
    
    // MARK: - Private Configuration Methods
    
    /// Configures Firebase log level.
    private func configureLogLevel(_ levelString: String) {
        // Validate log level
        guard FirebaseLogLevel.isValid(levelString) else {
            logger?.warn(category: LogCategory.firebase, 
                "Unknown log level '\(levelString)', using 'notice' as default. " +
                "Valid values: \(FirebaseLogLevel.allLevels.joined(separator: ", "))")
            firebaseInstance.setLoggerLevel(.notice)
            return
        }
        
        let loggerLevel = FirebaseLogLevel.map(levelString)
        firebaseInstance.setLoggerLevel(loggerLevel)
        logger?.debug(category: LogCategory.firebase, "Firebase log level set to '\(levelString)' (\(loggerLevel))")
    }
    
    /// Configures validator with GA360 mode and invalid character strategy.
    private func configureValidator(from payload: DataObject) {
        // Configure GA360 mode
        if let ga360Mode = payload.get(key: FirebaseConstants.Initialize.Param.ga360Mode, as: Bool.self) {
            validator.setGA360Mode(ga360Mode)
            logger?.debug(category: LogCategory.firebase, 
                "GA360 mode: \(ga360Mode) (parameter value limit: \(ga360Mode ? 500 : 100) characters)")
        }
        
        // Configure invalid character strategy
        if let strategy = payload.get(key: FirebaseConstants.Initialize.Param.invalidCharStrategy, as: String.self) {
            validator.setInvalidCharStrategy(strategy)
            logger?.debug(category: LogCategory.firebase, 
                "Invalid character strategy set to '\(strategy)'")
        }
    }
    
    /// Extracts session timeout from payload, supporting both numeric types and string conversion.
    private func extractSessionTimeout(from payload: DataObject) -> TimeInterval? {
        // Try as Double first
        if let timeout = payload.get(key: FirebaseConstants.Initialize.Param.sessionTimeout, as: Double.self) {
            return timeout
        }
        
        // Try as Int
        if let timeout = payload.get(key: FirebaseConstants.Initialize.Param.sessionTimeout, as: Int.self) {
            return TimeInterval(timeout)
        }
        
        // Try as String and convert
        if let timeoutString = payload.get(key: FirebaseConstants.Initialize.Param.sessionTimeout, as: String.self),
           let timeout = Double(timeoutString) {
            return timeout
        }
        
        return nil
    }
}

