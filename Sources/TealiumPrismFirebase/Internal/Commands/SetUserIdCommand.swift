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
/// An empty string clears the user ID.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserid_:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "setuserid",
///     "setuserid": [
///         "firebase_user_id": "USER_12345"  // Empty string clears user ID
///     ]
/// ]
/// ```
class SetUserIdCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }

    public let name = FirebaseConstants.SetUserId.name
    typealias Param = FirebaseConstants.SetUserId.Param
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetUserId command")
        
        guard let userIdData = payload.getDataItem(key: name)?
            .getDataDictionary() else {
            return false
        }
        
        guard let userId = userIdData.get(key: Param.userId,
                                          as: String.self) else {
            return false
        }
        
        guard userId.count <= 256 else {
            logger?.warn(category: LogCategory.firebase, 
                       "User ID exceeds 256 characters limit - command skipped")
            return false
        }
        
        // Empty string clears the user ID
        let userIdToSet = userId.isEmpty ? nil : userId
        
        if let userIdToSet = userIdToSet {
            logger?.debug(category: LogCategory.firebase, "Setting user ID: '\(userIdToSet)'")
        } else {
            logger?.debug(category: LogCategory.firebase, "Clearing user ID")
        }
        
        firebaseInstance.setUserId(userIdToSet)
        
        return true
    }
}
