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
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
///
/// ## Complete Flow Example
///
/// ### 1. Configuration (FirebaseSettingsBuilder)
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         // TODO: Add configuration here
/// })
/// ```
///
/// ### 2. Tracking Call (Your Code)
/// ```swift
/// // Set user property
/// tealium.track("profile_update", data: [
///     "membership_tier": "tier",
///     "membership_level": "premium"
/// ])
///
/// // Remove property (empty string)
/// tealium.track("profile_update", data: [
///     "membership_tier": "tier",
///     "membership_level": ""
/// ])
/// ```
///
/// ### 3. After Mappings (What This Command Receives)
/// ```
/// payload = [
///     "setuserproperty": [
///         "firebase_property_name": "tier",
///         "firebase_property_value": "premium"
///     ]
/// ]
/// ```
class SetUserPropertyCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }

    public let name = FirebaseConstants.SetUserProperty.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetUserProperty command")
        
        guard let propertyData = payload.getDataItem(key: FirebaseConstants.SetUserProperty.name)?
            .getDataDictionary() else {
            return false
        }
        
        guard let name = propertyData.get(key: FirebaseConstants.SetUserProperty.Param.propertyName, as: String.self) else {
            logger?.warn(category: LogCategory.firebase, 
                       "Missing property name - command skipped")
            return false
        }
        
        let value = propertyData.get(key: FirebaseConstants.SetUserProperty.Param.propertyValue, as: String.self)
        
        guard let sanitizedName = validator.validateUserPropertyName(name) else {
            logger?.warn(category: LogCategory.firebase, 
                       "Invalid user property name '\(name)' - command skipped")
            return false
        }
        
        // Empty string or nil removes the property
        var sanitizedValue: String? = nil
        if let value = value, !value.isEmpty {
            sanitizedValue = validator.validateUserPropertyValue(value)
        }
        
        if let sanitizedValue = sanitizedValue {
            logger?.debug(category: LogCategory.firebase, "Setting user property '\(sanitizedName)' = '\(sanitizedValue)'")
        } else {
            logger?.debug(category: LogCategory.firebase, "Removing user property '\(sanitizedName)'")
        }
        
        firebaseInstance.setUserProperty(sanitizedValue, forName: sanitizedName)
        return true
    }
}

