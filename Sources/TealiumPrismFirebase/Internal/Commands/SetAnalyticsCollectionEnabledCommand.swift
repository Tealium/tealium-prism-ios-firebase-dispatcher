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
/// - setAnalyticsCollectionEnabled: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setanalyticscollectionenabled_:
///
/// ## Usage Flow
///
/// ### 1. Configuration (FirebaseSettingsBuilder)
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         // TODO: Add configuration here
/// })
/// ```
///
/// ### 2. Tracking Call (Enable Analytics)
/// ```swift
/// tealium.track("consent", data: [
///     "firebase_analytics_collection_enabled": true
/// ])
/// ```
///
/// ### 3. After Mappings (What This Command Receives)
/// ```
/// payload = [
///     "tealium_event": ["setanalyticscollectionenabled"],
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
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: .firebase, "Executing SetAnalyticsCollectionEnabled command")
        
        guard let enabled = extractAnalyticsEnabled(from: payload) else {
            logger?.warn(category: .firebase, 
                "Missing or invalid '\(FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled)' parameter. " +
                "Expected boolean value (true/false)")
            return false
        }
        
        firebaseInstance.setAnalyticsCollectionEnabled(enabled)
        logger?.debug(category: .firebase, "Analytics collection \(enabled ? "enabled" : "disabled")")
        
        return true
    }
    
    // MARK: - Private Methods
    
    /// Extracts analytics enabled flag from payload, supporting both boolean and string conversion.
    private func extractAnalyticsEnabled(from payload: DataObject) -> Bool? {
        // Try as Bool first
        if let enabled = payload.get(key: FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled, as: Bool.self) {
            return enabled
        }
        
        // Try as String and convert
        if let enabledString = payload.get(key: FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled, as: String.self) {
            return enabledString.lowercased() == "true" || enabledString == "1"
        }
        
        // Try as Int (0 = false, non-zero = true)
        if let enabledInt = payload.get(key: FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled, as: Int.self) {
            return enabledInt != 0
        }
        
        return nil
    }
}

