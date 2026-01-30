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
    
    init(firebaseInstance: FirebaseCommand) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseConstants.SetSessionTimeout.name
    typealias Param = FirebaseConstants.SetSessionTimeout.Param
    
    func execute(payload: DataObject) throws {
        guard let sessionTimeout = payload.getNumeric(key: Param.sessionTimeout, as: Double.self) else {
            throw FirebaseCommandError.invalidParameterType(
                parameter: Param.sessionTimeout,
                expectedType: "numeric value (seconds)"
            )
        }
        
        firebaseInstance.setSessionTimeoutInterval(sessionTimeout)
    }
}

