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
/// // Full consent update
/// tealium.track("consent_update", data: [
///     "consent_ad_storage": "granted",
///     "consent_analytics_storage": "granted",
///     "consent_ad_user_data": "denied",
///     "consent_ad_personalization": "denied"
/// ])
///
/// // Partial consent update (only specified types are updated)
/// tealium.track("consent_update", data: [
///     "consent_ad_personalization": "denied"
/// ])
/// ```
///
/// ### 3. After Mappings (What This Command Receives)
/// ```
/// payload = [
///     "setconsent": [
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
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    public let name = FirebaseConstants.SetConsent.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing SetConsent command")
        
        guard let consentData = payload.getDataItem(key: FirebaseConstants.SetConsent.name)?
            .getDataDictionary() else {
            return false
        }
        
        var consentSettings: [ConsentType: ConsentStatus] = [:]
        
        for key in consentData.keys {
            guard let consentType = ConsentType.from(key) else {
                logger?.warn(category: LogCategory.firebase, 
                           "Invalid consent type '\(key)' - ignoring")
                continue
            }
            
            guard let stringValue = consentData.get(key: key, as: String.self) else {
                logger?.warn(category: LogCategory.firebase, 
                           "Unexpected data type for consent '\(key)' - expected String, ignoring")
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
