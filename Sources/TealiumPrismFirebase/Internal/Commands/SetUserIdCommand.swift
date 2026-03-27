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
///     "command_name": "setuserid",
///     "user_id": "USER_12345"  // Empty string clears user ID
/// ]
/// ```
class SetUserIdCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.setUserId.rawValue)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        guard let userId = payload.extract(path: FirebaseDestination.userId.path, as: String.self) else {
            throw CommandError.missingParameter(FirebaseDestination.userId.path.render())
        }
        
        // Empty string clears the user ID
        let userIdToSet = userId.isEmpty ? nil : userId
        
        firebaseInstance.setUserId(userIdToSet)
    }
}
