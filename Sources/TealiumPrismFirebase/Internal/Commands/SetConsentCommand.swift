//
//  SetConsentCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import FirebaseAnalytics
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
/// Unknown consent type/status strings cause the command to fail — unrecognized values
/// are rejected to surface configuration mistakes instead of silently discarding entries.
/// Known types: `ad_storage`, `analytics_storage`, `ad_user_data`, `ad_personalization`.
/// Known values: `granted`, `denied`. Both are matched ignoring case, and values are trimmed.
class SetConsentCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.setConsent.commandName)
    }

    override func execute(payload: DataObject) throws {
        firebaseInstance.setConsent(try consentSettings(in: payload))
    }

    // MARK: - Private Helpers

    private func consentSettings(in payload: DataObject) throws(ExtractionError) -> [ConsentType: ConsentStatus] {
        let path = FirebaseDestination.consentSettings.path
        let consentData = try payload.requireDataDictionary(path)
        guard !consentData.isEmpty else {
            throw .empty(key: path.render())
        }

        var consentSettings: [ConsentType: ConsentStatus] = [:]
        for key in consentData.keys {
            let settingPath = path[key]
            guard let type = ConsentConverter.typeOrNil(key) else {
                throw .invalidValue(
                    key: settingPath.render(),
                    reason: "unknown consent type, expected one of \(ConsentConverter.typeNames)"
                )
            }
            consentSettings[type] = try payload.requireOneOf(settingPath, values: ConsentConverter.statuses)
        }
        return consentSettings
    }
}
