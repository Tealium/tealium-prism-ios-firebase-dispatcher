//
//  FirebaseConsent.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseAnalytics

// MARK: - ConsentType Extension

/// Extension for Firebase Analytics ConsentType.
///
/// Firebase SDK Reference:
/// - ConsentType: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Type-Definitions#/c:FIRAnalytics+Consent.h@T@FIRConsentType
extension ConsentType {
    /// Creates a ConsentType from a string value
    /// - Parameter consentString: The consent type string (e.g., "ad_storage", "analytics_storage")
    /// - Returns: The corresponding ConsentType
    static func from(_ consentString: String) -> ConsentType {
        switch consentString {
        case "ad_storage":
            return .adStorage
        case "analytics_storage":
            return .analyticsStorage
        case "ad_user_data":
            return .adUserData
        case "ad_personalization":
            return .adPersonalization
        default:
            return ConsentType(rawValue: consentString)
        }
    }
}

// MARK: - ConsentStatus Extension

/// Extension for Firebase Analytics ConsentStatus.
///
/// Firebase SDK Reference:
/// - ConsentStatus: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Type-Definitions#/c:FIRAnalytics+Consent.h@T@FIRConsentStatus
extension ConsentStatus {
    /// Creates a ConsentStatus from a string value
    /// - Parameter statusString: The consent status string (e.g., "granted", "denied")
    /// - Returns: The corresponding ConsentStatus
    static func from(_ statusString: String) -> ConsentStatus {
        switch statusString.lowercased() {
        case "granted":
            return .granted
        case "denied":
            return .denied
        default:
            return ConsentStatus(rawValue: statusString)
        }
    }
}
