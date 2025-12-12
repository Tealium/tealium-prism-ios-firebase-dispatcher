//
//  SetUserPropertiesCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for setting multiple Firebase Analytics user properties at once.
///
/// Sets multiple user properties using parallel arrays. Up to 25 user property names are supported.
/// Once set, user property values persist throughout the app lifecycle and across sessions.
///
/// **Firebase SDK Reference:**
/// https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
///
/// **Usage:**
/// ```swift
/// tealium.track("set_properties", data: [
///     "user_name_for_property_names": ["subscription_tier", "user_level", "account_type"],
///     "user_name_for_property_values": ["premium", "expert", "business"]
/// ])
/// ```
///
/// **Constraints:**
/// - Name: 1-24 alphanumeric characters or underscores, must start with letter
/// - Value: Up to 36 characters, empty string or nil removes the property
/// - Reserved prefixes: "firebase_", "google_", "ga_"
/// - Reserved names: "first_open_time", "last_deep_link_referrer", "user_id"
/// - Arrays must have matching length (values[i] corresponds to names[i])
class SetUserPropertiesCommand: FirebaseCommandProtocol {
    
    public let name = FirebaseConstants.SetUserProperties.name
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol
    
    public required init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }
    
    public func execute(payload: DataObject) -> Bool {
        logger.debug(category: LogCategory.firebase, "Executing SetUserProperties command")
        
        guard let propertyData = payload.getDataItem(key: FirebaseConstants.SetUserProperties.name)?
            .getDataDictionary() else {
            return false
        }
        
        guard let names = propertyData[FirebaseConstants.SetUserProperties.Param.propertyNames] as? [String] else {
            logger.warn(category: LogCategory.firebase, 
                       "Missing or invalid property names array - command skipped")
            return false
        }
        
        guard let values = propertyData[FirebaseConstants.SetUserProperties.Param.propertyValues] as? [String] else {
            logger.warn(category: LogCategory.firebase, 
                       "Missing or invalid property values array - command skipped")
            return false
        }
        
        guard !names.isEmpty else {
            logger.warn(category: LogCategory.firebase, 
                       "Empty property names array - command skipped")
            return false
        }
        
        guard names.count == values.count else {
            logger.warn(category: LogCategory.firebase, 
                       "Property names array (\(names.count) items) and values array (\(values.count) items) must have matching length - command skipped")
            return false
        }
        
        logger.debug(category: LogCategory.firebase, "Setting \(names.count) user properties")
        
        // Set each property (continues even if some fail validation)
        for (index, name) in names.enumerated() {
            let value = values[index]
            setProperty(name: name, value: value)
        }
                
        return true
    }
    
    // MARK: - Private Helpers
    
    private func setProperty(name: String, value: String?) -> Bool {
        guard let sanitizedName = validator.validateUserPropertyName(name) else {
            logger.warn(category: LogCategory.firebase, 
                       "Invalid user property name '\(name)' - skipping")
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

