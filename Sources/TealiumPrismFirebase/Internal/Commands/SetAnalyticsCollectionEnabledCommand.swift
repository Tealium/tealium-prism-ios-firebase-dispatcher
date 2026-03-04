//
//  SetAnalyticsCollectionEnabledCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 7/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

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
class SetAnalyticsCollectionEnabledCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    
    init(firebaseInstance: FirebaseCommand) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseConstants.SetAnalyticsCollectionEnabled.name
    typealias Param = FirebaseConstants.SetAnalyticsCollectionEnabled.Param
    
    func execute(payload: DataObject) throws(FirebaseCommandError) {
        guard let enabled = payload.getBoolValue(key: Param.analyticsEnabled) else {
            throw FirebaseCommandError.invalidParameterType(
                parameter: Param.analyticsEnabled,
                expectedType: "boolean (true/false)"
            )
        }
        
        firebaseInstance.setAnalyticsCollectionEnabled(enabled)
    }
}

