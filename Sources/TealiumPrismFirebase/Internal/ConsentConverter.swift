//
//  ConsentConverter.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 11/05/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseAnalytics

/// Bidirectional mapping between payload string values and Firebase consent types/statuses.
///
/// Strings match the cross-platform payload schema used by both iOS and Android dispatchers.
/// Unknown inputs return `nil` — unrecognized values are not forwarded to Firebase.
enum ConsentConverter {

    private static let typeByRaw: [String: ConsentType] = [
        "ad_storage": .adStorage,
        "analytics_storage": .analyticsStorage,
        "ad_user_data": .adUserData,
        "ad_personalization": .adPersonalization
    ]

    private static let statusByRaw: [String: ConsentStatus] = [
        "granted": .granted,
        "denied": .denied
    ]

    static func typeOrNil(_ raw: String) -> ConsentType? {
        typeByRaw[raw.lowercased()]
    }

    static func statusOrNil(_ raw: String) -> ConsentStatus? {
        statusByRaw[raw.lowercased()]
    }
}
