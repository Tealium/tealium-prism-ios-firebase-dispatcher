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
///     "command": "setconsent",
///     "ad_storage": "granted",
///     "analytics_storage": "granted",
///     "ad_user_data": "denied",
///     "ad_personalization": "denied"
/// ]
/// ```
///
/// **Supported consent types:** `ad_storage`, `analytics_storage`, `ad_user_data`, `ad_personalization`
///
/// **Supported values:** `granted`, `denied`
class SetConsentCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    let name = FirebaseConstants.SetConsent.name
    typealias Param = FirebaseConstants.SetConsent.Param
    
    func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetConsent command")
        
        var consentSettings: [ConsentType: ConsentStatus] = [:]
        
        // Check for known consent parameter keys
        let consentKeys = [Param.adStorage, Param.analyticsStorage, Param.adUserData, Param.adPersonalization]
        
        for key in consentKeys {
            guard let stringValue = payload.get(key: key, as: String.self) else {
                continue
            }
            
            guard let consentType = ConsentType.from(key) else {
                logger?.warn(category: LogCategory.firebase, 
                           "Invalid consent type '\(key)' - ignoring")
                continue
            }
        
            guard let status = ConsentStatus.from(stringValue) else {
                logger?.warn(category: LogCategory.firebase, 
                           "Invalid consent status '\(stringValue)' for '\(key)' - expected 'granted' or 'denied', ignoring")
                continue
            }
            
            consentSettings[consentType] = status
        }
        
        guard !consentSettings.isEmpty else {
            logger?.warn(category: LogCategory.firebase, 
                       "No valid consent settings provided - command skipped")
            return false
        }
        
        logger?.debug(category: LogCategory.firebase, "Setting consent: \(consentSettings.map { "\($0.key.rawValue)=\($0.value.rawValue)" }.joined(separator: ", "))")
        firebaseInstance.setConsent(consentSettings)
        return true
    }
}
