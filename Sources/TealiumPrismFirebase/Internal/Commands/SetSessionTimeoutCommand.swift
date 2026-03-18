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
///     "command_name": "setsessiontimeout",
///     "session_timeout_seconds": 3600
/// ]
/// ```
class SetSessionTimeoutCommand: RemoteCommandProtocol {
    
    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseCommand.setSessionTimeout.rawValue
    
    func execute(payload: DataObject) throws(RemoteCommandError) {
        guard let sessionTimeout = payload.extractConvertible(path: FirebaseDestination.sessionTimeout.path, converter: LenientConverters.double) else {
            throw RemoteCommandError.invalidParameterType(
                parameter: FirebaseDestination.sessionTimeout.path.render(),
                expectedType: "numeric value (seconds)"
            )
        }
        
        firebaseInstance.setSessionTimeoutInterval(sessionTimeout)
    }
}

