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
///     "setanalyticscollectionenabled": [
///         "firebase_analytics_collection_enabled": true
///     ]
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
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetAnalyticsCollectionEnabled command")
        
        guard let commandData = payload.getDataItem(key: FirebaseConstants.SetAnalyticsCollectionEnabled.name)?
            .getDataDictionary() else {
            logger?.warn(category: LogCategory.firebase, "Missing command data - command skipped")
            return false
        }
        
        guard let enabled = extractAnalyticsEnabled(from: commandData) else {
            logger?.warn(category: LogCategory.firebase, 
                "Missing or invalid '\(FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled)' parameter. " +
                "Expected boolean value (true/false)")
            return false
        }
        
        firebaseInstance.setAnalyticsCollectionEnabled(enabled)
        logger?.debug(category: LogCategory.firebase, "Analytics collection \(enabled ? "enabled" : "disabled")")
        
        return true
    }
    
    // MARK: - Private Methods
    
    /// Extracts analytics enabled flag from command data, supporting both boolean and string conversion.
    private func extractAnalyticsEnabled(from commandData: [String: DataItem]) -> Bool? {
        // Try as Bool first
        if let enabled = commandData.get(key: FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled, as: Bool.self) {
            return enabled
        }
        
        // Try as String and convert
        if let enabledString = commandData.get(key: FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled, as: String.self) {
            return enabledString.lowercased() == "true" || enabledString == "1"
        }
        
        // Try as Int (0 = false, non-zero = true)
        if let enabledInt = commandData.get(key: FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled, as: Int.self) {
            return enabledInt != 0
        }
        
        return nil
    }
}

