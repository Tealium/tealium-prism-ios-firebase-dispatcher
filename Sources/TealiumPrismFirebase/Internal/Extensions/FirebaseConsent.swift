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
/// - ConsentType: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Type-Definitions#consenttype
extension ConsentType {

    /// The payload key for this consent type (e.g., `"ad_storage"`).
    var key: String {
        switch self {
        case .adStorage: return "ad_storage"
        case .analyticsStorage: return "analytics_storage"
        case .adUserData: return "ad_user_data"
        case .adPersonalization: return "ad_personalization"
        default: return ""
        }
    }

    /// All consent types supported by the Firebase Dispatcher.
    static let all: [ConsentType] = [.adStorage, .analyticsStorage, .adUserData, .adPersonalization]
}

// MARK: - ConsentStatus Extension

/// Extension for Firebase Analytics ConsentStatus.
///
/// Firebase SDK Reference:
/// - ConsentStatus: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Type-Definitions#consentstatus
extension ConsentStatus {
    /// Creates a ConsentStatus from a string value
    /// - Parameter statusString: The consent status string (e.g., "granted", "denied"), case-insensitive matching is supported
    /// - Returns: The corresponding ConsentStatus, or nil if the string is not a valid consent status
    static func from(_ statusString: String) -> ConsentStatus? {
        switch statusString.lowercased() {
        case "granted":
            return .granted
        case "denied":
            return .denied
        default:
            return nil
        }
    }
}
