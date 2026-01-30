//
//  SetUserPropertyCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for setting a single Firebase Analytics user property.
///
/// Sets a user property to a given value. Up to 25 user property names are supported.
/// Once set, user property values persist throughout the app lifecycle and across sessions.
/// Empty string removes the property.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "setuserproperty",
///     "firebase_property_name": "tier",
///     "firebase_property_value": "premium"  // Empty string removes property
/// ]
/// ```
class SetUserPropertyCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }

    let name = FirebaseConstants.SetUserProperty.name
    typealias Param = FirebaseConstants.SetUserProperty.Param
    
    func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetUserProperty command")
        
        guard let propertyName = payload.get(key: Param.propertyName, as: String.self) else {
            logger?.warn(category: LogCategory.firebase, 
                       "Missing property name - command skipped")
            return false
        }
        
        let value = payload.get(key: Param.propertyValue, as: String.self)
        
        // Empty string or nil removes the property
        if let value = value, !value.isEmpty {
            logger?.debug(category: LogCategory.firebase, "Setting user property '\(propertyName)' = '\(value)'")
            firebaseInstance.setUserProperty(value, forName: propertyName)
        } else {
            logger?.debug(category: LogCategory.firebase, "Removing user property '\(propertyName)'")
            firebaseInstance.setUserProperty(nil, forName: propertyName)
        }
        return true
    }
}

