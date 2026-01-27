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
///     "command": "setanalyticscollectionenabled",
///     "firebase_analytics_collection_enabled": true
/// ]
/// ```
class SetAnalyticsCollectionEnabledCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    public let name = FirebaseConstants.SetAnalyticsCollectionEnabled.name
    typealias Param = FirebaseConstants.SetAnalyticsCollectionEnabled.Param
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetAnalyticsCollectionEnabled command")
        
        guard let enabled = payload.getBoolValue(key: Param.analyticsEnabled) else {
            logger?.warn(category: LogCategory.firebase, 
                "Missing or invalid '\(Param.analyticsEnabled)' parameter. " +
                "Expected boolean value (true/false)")
            return false
        }
        
        firebaseInstance.setAnalyticsCollectionEnabled(enabled)
        logger?.debug(category: LogCategory.firebase, "Analytics collection \(enabled ? "enabled" : "disabled")")
        
        return true
    }
}

