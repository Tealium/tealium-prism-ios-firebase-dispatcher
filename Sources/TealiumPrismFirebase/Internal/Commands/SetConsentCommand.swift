//
//  SetConsentCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore
import FirebaseAnalytics

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
/// **Supported consent types:** `ad_storage`, `analytics_storage`, `ad_user_data`, `ad_personalization`
///
/// **Supported values:** `granted`, `denied`
class SetConsentCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseCommand.setConsent.rawValue

    func execute(payload: DataObject) throws(FirebaseCommandError) {
        guard let consentData = payload.getDataDictionary(key: FirebaseDestination.consentSettings.renderedPath) else {
            throw FirebaseCommandError.noValidConsentSettings
        }

        let consentSettings = Dictionary(uniqueKeysWithValues: ConsentType.all.compactMap { consentType -> (ConsentType, ConsentStatus)? in
            guard let dataItem = consentData[consentType.key],
                  let stringValue = dataItem.get(as: String.self),
                  let status = ConsentStatus.from(stringValue) else {
                return nil
            }
            return (consentType, status)
        })

        guard !consentSettings.isEmpty else {
            throw FirebaseCommandError.noValidConsentSettings
        }

        firebaseInstance.setConsent(consentSettings)
    }
}
