//
//  SetDefaultParametersCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for setting default event parameters in Firebase Analytics.
///
/// Default parameters are automatically included with every event logged to Firebase.
/// These parameters persist across app runs and are of lower precedence than event parameters.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setdefaulteventparameters_:
///
/// Usage:
/// ```swift
/// // Set default parameters that will be included with every event
/// tealium.track("setdefaultparameters", data: [
///     "user_name_for_param_currency": "USD",
///     "user_name_for_param_language": "en",
///     "user_name_for_param_country": "US"
/// ])
///
/// // Clear a specific default parameter (set to empty string)
/// tealium.track("setdefaultparameters", data: [
///     "user_name_for_param_currency": ""
/// ])
///
/// // Clear all default parameters (empty payload or empty firebase_params)
/// tealium.track("setdefaultparameters", data: [])
/// // or
/// tealium.track("setdefaultparameters", data: [
///     "setdefaultparameters_firebase_params": [:]
/// ])
/// ```
///
/// Expected Payload Structure (after mappings):
/// ```
/// payload = [
///     "setdefaultparameters": [
///         "firebase_params": [
///             "currency": "USD",
///             "language": "en",
///             "country": "US"
///         ]
///     ]
/// ]
/// ```
class SetDefaultParametersCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol?
    
    public required init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }
    
    public let name = FirebaseConstants.SetDefaultParameters.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetDefaultParameters command")
        
        // Empty payload [] -> clear all default parameters (intended behavior)
        guard let commandData = payload.getDataItem(key: FirebaseConstants.SetDefaultParameters.name)?
            .getDataDictionary() else {
            logger?.debug(category: LogCategory.firebase, "Clearing all default parameters (empty payload)")
            firebaseInstance.setDefaultEventParameters(nil)
            return true
        }
        
        // setdefaultparameters exists but firebase_params is missing -> error (not intended)
        guard let paramsData = commandData[FirebaseConstants.SetDefaultParameters.Param.params] else {
            logger?.warn(category: LogCategory.firebase, "Missing 'firebase_params' in setdefaultparameters - command skipped")
            return false
        }
        
        // firebase_params exists but is not a dictionary -> error
        guard let defaultParams = paramsData.getDataDictionary() else {
            logger?.warn(category: LogCategory.firebase, "Invalid 'firebase_params' type - expected dictionary - command skipped")
            return false
        }
        
        // firebase_params is empty dictionary {} -> clear all default parameters (intended behavior)
        if defaultParams.isEmpty {
            logger?.debug(category: LogCategory.firebase, "Clearing all default parameters (empty firebase_params)")
            firebaseInstance.setDefaultEventParameters(nil)
            return true
        }
        
        // Process parameters
        var sanitizedParams: [String: Any] = [:]
        
        for (key, value) in defaultParams {
            guard let sanitizedName = validator.validateParameterName(key) else {
                continue
            }
            
            // Firebase supports String, Int, and Double only
            if let intValue = value.get(as: Int.self) {
                sanitizedParams[sanitizedName] = intValue
            } else if let doubleValue = value.get(as: Double.self) {
                sanitizedParams[sanitizedName] = doubleValue
            } else if let stringValue = value.get(as: String.self) {
                // Empty string clears the parameter
                if stringValue.isEmpty {
                    sanitizedParams[sanitizedName] = NSNull()
                } else {
                    let sanitizedValue = validator.validateParameterValue(stringValue)
                    sanitizedParams[sanitizedName] = sanitizedValue
                }
            } 
        }
        
        // If all parameters were invalid/cleared, clear all default parameters
        if sanitizedParams.isEmpty {
            logger?.warn(category: LogCategory.firebase, "All parameters were invalid - command skipped")
            return false
        } else {
            logger?.debug(category: LogCategory.firebase, "Setting \(sanitizedParams.count) default parameter(s): \(sanitizedParams.keys.joined(separator: ", "))")
            firebaseInstance.setDefaultEventParameters(sanitizedParams)
        }
        
        return true
    }
}

