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
/// ## Complete Flow Example
///
/// ### 1. Configuration (FirebaseSettingsBuilder)
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         // TODO: Add configuration here
/// })
/// ```
///
/// ### 2. Tracking Call (Your Code)
/// ```swift
/// // Reset all analytics data (e.g., on user logout)
/// tealium.track("logout")
/// ```
///
/// ### 3. After Mappings (What This Command Receives)
/// ```
/// // Payload structure after Prism mappings
/// payload = [
///     "tealium_event": ["resetdata"]  // Command name in tealium_event array
/// ]
/// ```
class ResetDataCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }

    public let name = FirebaseConstants.ResetData.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing ResetData command")
        firebaseInstance.resetAnalyticsData()
        logger?.debug(category: LogCategory.firebase, "Firebase Analytics data reset completed")
        return true
    }
}

