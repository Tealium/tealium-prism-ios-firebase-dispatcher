//
//  SetUserIdCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for setting Firebase Analytics user ID.
///
/// Associates analytics data with a specific user by setting the user ID property.
/// This must be used in accordance with Google's Privacy Policy.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserid_:
///
/// Usage:
/// ```swift
/// // Set user ID on login
/// tealium.track("login", data: [
///     "firebase_user_id": "user123"
/// ])
///
/// // Clear user ID on logout (empty string)
/// tealium.track("logout", data: [
///     "firebase_user_id": ""
/// ])
/// ```
///
/// Expected Payload Structure (after mappings):
/// ```
/// payload = [
///     "setuserid": [
///         "firebase_user_id": "user123"
///     ]
/// ]
/// ```
class SetUserIdCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol
    
    public required init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }

    public let name = FirebaseConstants.SetUserId.name
    
    public func execute(payload: DataObject) -> Bool {
        logger.debug(category: LogCategory.firebase, "Executing SetUserId command")
        
        guard let userIdData = payload.getDataItem(key: FirebaseConstants.SetUserId.name)?
            .getDataDictionary() else {
            return false
        }
        
        guard let userId = userIdData.get(key: FirebaseConstants.SetUserId.Param.userId,
                                          as: String.self) else {
            return false
        }
        
        guard userId.count <= 256 else {
            logger.warn(category: LogCategory.firebase, 
                       "User ID exceeds 256 characters limit - command skipped")
            return false
        }
        
        // Empty string clears the user ID
        let userIdToSet = userId.isEmpty ? nil : userId
        
        if let userIdToSet = userIdToSet {
            logger.debug(category: LogCategory.firebase, "Setting user ID: '\(userIdToSet)'")
        } else {
            logger.debug(category: LogCategory.firebase, "Clearing user ID")
        }
        
        firebaseInstance.setUserId(userIdToSet)
        
        return true
    }
}
