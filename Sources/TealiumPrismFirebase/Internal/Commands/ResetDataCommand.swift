//
//  ResetDataCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for resetting Firebase Analytics data.
///
/// Clears all analytics data for this app instance from the device and resets the app instance ID.
/// This is typically used when a user logs out or when privacy regulations require data deletion.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#resetanalyticsdata
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command_name": "resetdata"
/// ]
/// ```
class ResetDataCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.resetData.commandName)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        firebaseInstance.resetAnalyticsData()
    }
}
