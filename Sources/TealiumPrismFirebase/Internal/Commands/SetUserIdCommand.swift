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
///     "firebase_user_id": "USER_12345"  // Empty string clears user ID
/// ]
/// ```
class SetUserIdCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    
    init(firebaseInstance: FirebaseCommand) {
        self.firebaseInstance = firebaseInstance
    }

    let name = FirebaseConstants.SetUserId.name
    typealias Param = FirebaseConstants.SetUserId.Param
    
    func execute(payload: DataObject) throws {
        guard let userId = payload.get(key: Param.userId, as: String.self) else {
            throw FirebaseCommandError.missingParameter(Param.userId)
        }
        
        // Empty string clears the user ID
        let userIdToSet = userId.isEmpty ? nil : userId
        
        firebaseInstance.setUserId(userIdToSet)
    }
}
