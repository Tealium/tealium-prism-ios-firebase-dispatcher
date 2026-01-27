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
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setsessiontimeoutinterval_:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "setsessiontimeout",
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
    typealias Param = FirebaseConstants.SetSessionTimeout.Param
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetSessionTimeout command")
        
        guard let sessionTimeout = payload.getNumeric(key: Param.sessionTimeout, as: Double.self) else {
            logger?.warn(category: LogCategory.firebase, 
                "Missing or invalid '\(Param.sessionTimeout)' parameter. " +
                "Expected numeric value (seconds)")
            return false
        }
        
        firebaseInstance.setSessionTimeoutInterval(sessionTimeout)
        logger?.debug(category: LogCategory.firebase, "Session timeout updated to \(sessionTimeout) seconds")
        
        return true
    }
}

