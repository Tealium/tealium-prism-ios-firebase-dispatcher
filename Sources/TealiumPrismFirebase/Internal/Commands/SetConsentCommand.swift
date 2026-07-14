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
/// Unknown consent type/status strings cause the command to fail — unrecognized values
/// are rejected to surface configuration mistakes instead of silently discarding entries.
/// Known types: `ad_storage`, `analytics_storage`, `ad_user_data`, `ad_personalization`.
/// Known values: `granted`, `denied`.
class SetConsentCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.setConsent.commandName)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        let consentData = try payload.requireDataDictionary(.consentSettings)

        var consentSettings: [ConsentType: ConsentStatus] = [:]
        for (key, value) in consentData {
            guard let statusString = value.get(as: String.self) else {
                throw .invalidParameterType(
                    parameter: "\(FirebaseDestination.consentSettings.path.render()).\(key)",
                    expectedType: "string consent status"
                )
            }
            guard let type = ConsentConverter.typeOrNil(key) else {
                throw .invalidParameterType(
                    parameter: "\(FirebaseDestination.consentSettings.path.render()).\(key)",
                    expectedType:
                        "known consent type (ad_storage, analytics_storage, ad_user_data, ad_personalization)"
                )
            }
            guard let status = ConsentConverter.statusOrNil(statusString) else {
                throw .invalidParameterType(
                    parameter:
                        "\(FirebaseDestination.consentSettings.path.render()).\(key)=\(statusString)",
                    expectedType: "known consent status (granted, denied)"
                )
            }
            consentSettings[type] = status
        }

        guard !consentSettings.isEmpty else {
            throw .noValidParameters(expected: [.consentSettings])
        }

        firebaseInstance.setConsent(consentSettings)
    }
}
