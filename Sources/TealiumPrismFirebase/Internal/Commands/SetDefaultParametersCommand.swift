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
/// Empty dictionary or missing payload clears all default parameters.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setdefaulteventparameters_:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "setdefaultparameters",
///     "setdefaultparameters": [
///         "firebase_params": [
///             "version": "2.1.0",
///             "language": "en",
///             "country": "US"
///         ]
///     ]
/// ]
/// ```
class SetDefaultParametersCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    public let name = FirebaseConstants.SetDefaultParameters.name
    typealias Param = FirebaseConstants.SetDefaultParameters.Param
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetDefaultParameters command")
        
        // Empty payload [] -> clear all default parameters (intended behavior)
        guard let commandData = payload.getDataItem(key: name)?
            .getDataDictionary() else {
            logger?.debug(category: LogCategory.firebase, "Clearing all default parameters (empty payload)")
            firebaseInstance.setDefaultEventParameters(nil)
            return true
        }
        
        // setdefaultparameters exists but firebase_params is missing -> error (not intended)
        guard let paramsData = commandData[Param.params] else {
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
        var processedParams: [String: Any] = [:]
        
        for (key, value) in defaultParams {
            processedParams[key] = value.toDataInput()
        }
        
        logger?.debug(category: LogCategory.firebase, "Setting \(processedParams.count) default parameter(s): \(processedParams.keys.joined(separator: ", "))")
        firebaseInstance.setDefaultEventParameters(processedParams)
        
        return true
    }
}

