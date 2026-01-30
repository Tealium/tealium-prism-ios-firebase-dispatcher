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
    
    init(firebaseInstance: FirebaseCommand) {
        self.firebaseInstance = firebaseInstance
    }

    let name = FirebaseConstants.SetUserProperty.name
    typealias Param = FirebaseConstants.SetUserProperty.Param
    
    func execute(payload: DataObject) throws {
        guard let propertyName = payload.get(key: Param.propertyName, as: String.self) else {
            throw FirebaseCommandError.missingParameter(Param.propertyName)
        }
        
        let value = payload.get(key: Param.propertyValue, as: String.self)
        
        // Empty string or nil removes the property
        if let value = value, !value.isEmpty {
            firebaseInstance.setUserProperty(value, forName: propertyName)
        } else {
            firebaseInstance.setUserProperty(nil, forName: propertyName)
        }
    }
}

