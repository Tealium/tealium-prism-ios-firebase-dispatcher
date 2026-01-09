//
//  SetSessionTimeoutCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 7/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for dynamically changing Firebase Analytics session timeout interval.
///
/// This command allows you to update the session timeout after initialization.
/// A session is a period of time during which a user is actively engaged with your app.
///
/// Firebase SDK Reference:
/// - setSessionTimeoutInterval: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setsessiontimeoutinterval_:
///
/// ## Usage Flow
///
/// ### 1. Configuration (FirebaseSettingsBuilder)
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         // TODO: Add configuration here
/// })
/// ```
///
/// ### 2. Tracking Call
/// ```swift
/// tealium.track("update_session", data: [
///     "new_timeout": 3600  // Change to 1 hour
/// ])
/// ```
///
/// ### 3. After Mappings (What This Command Receives)
/// ```
/// payload = [
///     "tealium_event": ["setsessiontimeout"],
///     "firebase_session_timeout_seconds": 3600
/// ]
/// ```
class SetSessionTimeoutCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    public let name = FirebaseConstants.SetSessionTimeout.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetSessionTimeout command")
        
        guard let sessionTimeout = extractSessionTimeout(from: payload) else {
            logger?.warn(category: LogCategory.firebase, 
                "Missing or invalid '\(FirebaseConstants.SetSessionTimeout.Param.sessionTimeout)' parameter. " +
                "Expected numeric value (seconds)")
            return false
        }
        
        firebaseInstance.setSessionTimeoutInterval(sessionTimeout)
        logger?.debug(category: LogCategory.firebase, "Session timeout updated to \(sessionTimeout) seconds")
        
        return true
    }
    
    // MARK: - Private Methods
    
    /// Extracts session timeout from payload, supporting both numeric types and string conversion.
    private func extractSessionTimeout(from payload: DataObject) -> TimeInterval? {
        // Try as Double first
        if let timeout = payload.get(key: FirebaseConstants.SetSessionTimeout.Param.sessionTimeout, as: Double.self) {
            return timeout
        }
        
        // Try as Int
        if let timeout = payload.get(key: FirebaseConstants.SetSessionTimeout.Param.sessionTimeout, as: Int.self) {
            return TimeInterval(timeout)
        }
        
        // Try as String and convert
        if let timeoutString = payload.get(key: FirebaseConstants.SetSessionTimeout.Param.sessionTimeout, as: String.self),
           let timeout = Double(timeoutString) {
            return timeout
        }
        
        return nil
    }
}

