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
///     "setuserproperty": [
///         "firebase_property_name": "tier",
///         "firebase_property_value": "premium"  // Empty string removes property
///     ]
/// ]
/// ```
class SetUserPropertyCommand: FirebaseCommandProtocol {
    
    // MARK: - Constants
    
    let name = "setuserproperty"
    
    enum Param {
        static let propertyName = "firebase_property_name"
        static let propertyValue = "firebase_property_value"
    }
    
    // MARK: - Properties
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    // MARK: - Initialization
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    // MARK: - FirebaseCommandProtocol
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetUserProperty command")
        
        guard let propertyData = payload.getDataItem(key: name)?
            .getDataDictionary() else {
            return false
        }
        
        guard let name = propertyData.get(key: Param.propertyName, as: String.self) else {
            logger?.warn(category: LogCategory.firebase, 
                       "Missing property name - command skipped")
            return false
        }
        
        let value = propertyData.get(key: Param.propertyValue, as: String.self)
        
        // Empty string or nil removes the property
        if let value = value, !value.isEmpty {
            logger?.debug(category: LogCategory.firebase, "Setting user property '\(name)' = '\(value)'")
            firebaseInstance.setUserProperty(value, forName: name)
        } else {
            logger?.debug(category: LogCategory.firebase, "Removing user property '\(name)'")
            firebaseInstance.setUserProperty(nil, forName: name)
        }
        return true
    }
}

