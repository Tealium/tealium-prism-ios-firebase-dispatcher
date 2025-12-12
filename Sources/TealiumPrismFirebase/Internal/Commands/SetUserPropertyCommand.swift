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
///
/// **Firebase SDK Reference:**
/// https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
///
/// **Usage:**
/// ```swift
/// tealium.track("set_property", data: [
///     "user_name_for_property_name": "subscription_tier",
///     "user_name_for_property_value": "premium"
/// ])
///
/// // Remove property (empty string)
/// tealium.track("remove_property", data: [
///     "user_name_for_property_name": "subscription_tier",
///     "user_name_for_property_value": ""
/// ])
/// ```
///
/// **Constraints:**
/// - Name: 1-24 alphanumeric characters or underscores, must start with letter
/// - Value: Up to 36 characters, empty string or nil removes the property
/// - Reserved prefixes: "firebase_", "google_", "ga_"
/// - Reserved names: "first_open_time", "last_deep_link_referrer", "user_id"
class SetUserPropertyCommand: FirebaseCommandProtocol {
    
    public let name = FirebaseConstants.SetUserProperty.name
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol
    
    public required init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }
    
    public func execute(payload: DataObject) -> Bool {
        logger.debug(category: LogCategory.firebase, "Executing SetUserProperty command")
        
        guard let propertyData = payload.getDataItem(key: FirebaseConstants.SetUserProperty.name)?
            .getDataDictionary() else {
            return false
        }
        
        guard let name = propertyData[FirebaseConstants.SetUserProperty.Param.propertyName] as? String else {
            logger.warn(category: LogCategory.firebase, 
                       "Missing property name - command skipped")
            return false
        }
        
        let value = propertyData[FirebaseConstants.SetUserProperty.Param.propertyValue] as? String
        
        guard let sanitizedName = validator.validateUserPropertyName(name) else {
            logger.warn(category: LogCategory.firebase, 
                       "Invalid user property name '\(name)' - command skipped")
            return false
        }
        
        // Empty string or nil removes the property
        var sanitizedValue: String? = nil
        if let value = value, !value.isEmpty {
            sanitizedValue = validator.validateUserPropertyValue(value)
        }
        
        if let sanitizedValue = sanitizedValue {
            logger.debug(category: LogCategory.firebase, "Setting user property '\(sanitizedName)' = '\(sanitizedValue)'")
        } else {
            logger.debug(category: LogCategory.firebase, "Removing user property '\(sanitizedName)'")
        }
        
        firebaseInstance.setUserProperty(sanitizedValue, forName: sanitizedName)
        return true
    }
}

