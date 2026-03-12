//
//  SetConsentCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import FirebaseAnalytics
import Foundation
import TealiumPrismCore

/// Command for configuring Firebase Analytics consent settings.
///
/// Sets end user consent state for device identifiers.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(Consent)#setconsent_:
///
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command_name": "setconsent",
///     "consent_settings": [
///         "ad_storage": "granted",
///         "analytics_storage": "granted",
///         "ad_user_data": "denied",
///         "ad_personalization": "denied"
///     ]
/// ]
/// ```
///
/// Accepts any consent type and status strings — unknown values are forwarded to Firebase
/// directly, allowing future Firebase additions to work without SDK updates.
/// Known types: `ad_storage`, `analytics_storage`, `ad_user_data`, `ad_personalization`.
/// Known values: `granted`, `denied`.
class SetConsentCommand: FirebaseCommandProtocol {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
    }

    let name = FirebaseCommand.setConsent.rawValue

    func execute(payload: DataObject) throws(FirebaseCommandError) {
        guard let consentData = payload.extractDataDictionary(path: FirebaseDestination.consentSettings.path) else {
            throw FirebaseCommandError.noValidConsentSettings
        }

        let consentSettings = Dictionary(uniqueKeysWithValues: consentData.compactMap { key, value -> (ConsentType, ConsentStatus)? in
            guard let statusString = value.get(as: String.self) else {
                return nil
            }
            let consentType = ConsentType(rawValue: key)
            let consentStatus = ConsentStatus(rawValue: statusString.lowercased())
            return (consentType, consentStatus)
        })

        guard !consentSettings.isEmpty else {
            throw FirebaseCommandError.noValidConsentSettings
        }

        firebaseInstance.setConsent(consentSettings)
    }
}
