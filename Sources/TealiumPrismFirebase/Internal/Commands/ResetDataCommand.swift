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
/// Usage:
/// ```swift
/// // Reset all analytics data (e.g., on user logout)
/// tealium.track("resetdata", data: [:])
/// ```
class ResetDataCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let logger: LoggerProtocol
    
    public required init(firebaseInstance: FirebaseCommand, validator: FirebaseValidator, logger: LoggerProtocol) {
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.logger = logger
    }

    public let name = FirebaseConstants.ResetData.name
    
    public func execute(payload: DataObject) -> Bool {
        logger.debug(category: LogCategory.firebase, "Executing ResetData command")
        firebaseInstance.resetAnalyticsData()
        logger.debug(category: LogCategory.firebase, "Firebase Analytics data reset completed")
        return true
    }
}

