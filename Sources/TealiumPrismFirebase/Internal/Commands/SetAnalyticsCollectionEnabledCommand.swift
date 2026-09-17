//
//  SetAnalyticsCollectionEnabledCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 7/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
#if canImport(TealiumPrismCore)
import TealiumPrismCore
#else
import TealiumPrism
#endif

/// Command for dynamically enabling or disabling Firebase Analytics collection.
///
/// This command allows you to control whether Firebase Analytics collects data.
/// When disabled, Firebase Analytics stops collecting data but retains previously collected data.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setanalyticscollectionenabled_:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command_name": "setanalyticscollectionenabled",
///     "analytics_collection_enabled": true
/// ]
/// ```
class SetAnalyticsCollectionEnabledCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.setAnalyticsCollectionEnabled.commandName)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        let enabled = try payload.require(.analyticsEnabled, converter: LenientConverters.bool)
        firebaseInstance.setAnalyticsCollectionEnabled(enabled)
    }
}
