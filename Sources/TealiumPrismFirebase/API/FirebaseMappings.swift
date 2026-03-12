//
//  FirebaseMappings.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/03/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseAnalytics
import Foundation
import TealiumPrismCore

// MARK: - Firebase Commands

/// Type-safe Firebase Analytics commands for use with `FirebaseMappings.mapCommand(_:)`.
public enum FirebaseCommand: String {
    case logEvent = "logevent"
    case setUserId = "setuserid"
    case setUserProperty = "setuserproperty"
    case resetData = "resetdata"
    case setDefaultParameters = "setdefaultparameters"
    case setConsent = "setconsent"
    case setSessionTimeout = "setsessiontimeout"
    case setAnalyticsCollectionEnabled = "setanalyticscollectionenabled"
    case initiateConversionMeasurement = "initiateconversionmeasurement"
}

// MARK: - Firebase Destinations

/// Type-safe Firebase Analytics mapping destinations.
///
/// Each case maps to a specific key or path in the Firebase command payload.
/// Use with `mapFrom(_:to:)`, `mapConstant(_:to:)`, and `keep(_:)`.
public enum FirebaseDestination: ReferenceContainerConvertible {

    // MARK: LogEvent

    /// The event name parameter (`"event_name"`).
    case eventName

    /// The event parameters dictionary (`"parameters"`).
    case eventParams

    /// A specific event parameter nested under `parameters.[name]`.
    ///
    /// Pass a Firebase Analytics parameter constant (e.g. `AnalyticsParameterCurrency`)
    /// or any custom string for non-predefined parameters.
    case eventParam(String)

    /// A specific item parameter nested under `parameters.items.[name]`.
    ///
    /// Pass a Firebase Analytics item parameter constant (e.g. `AnalyticsParameterItemID`)
    /// or any custom string for non-predefined parameters.
    case itemParam(String)

    // MARK: SetUserId

    /// The user ID parameter (`"user_id"`).
    case userId

    // MARK: SetUserProperty

    /// The user property name(s) parameter (`"property_name"`).
    case userPropertyName

    /// The user property value(s) parameter (`"property_value"`).
    case userPropertyValue

    // MARK: SetDefaultParameters

    /// The default parameters dictionary (`"parameters"`).
    case defaultParams

    /// A specific default parameter nested under `parameters.[name]`.
    case defaultParam(String)

    // MARK: SetConsent

    /// The consent settings dictionary (`"consent_settings"`).
    case consentSettings

    /// A specific consent setting nested under `consent_settings.[type.rawValue]`.
    case consentSetting(ConsentType)

    // MARK: SetSessionTimeout

    /// The session timeout parameter (`"session_timeout_seconds"`).
    case sessionTimeout

    // MARK: SetAnalyticsCollectionEnabled

    /// The analytics enabled parameter (`"analytics_collection_enabled"`).
    case analyticsEnabled

    // MARK: InitiateConversionMeasurement

    /// The email address for conversion measurement.
    case conversionEmail

    /// The phone number for conversion measurement.
    case conversionPhone

    /// The hashed email address for conversion measurement.
    case conversionHashedEmail

    /// The hashed phone number for conversion measurement.
    case conversionHashedPhone

    public func asReferenceContainer() -> ReferenceContainer {
        switch self {
        // LogEvent
        case .eventName:
            return ReferenceContainer(key: "event_name")
        case .eventParams:
            return ReferenceContainer(key: "parameters")
        case .eventParam(let param):
            return ReferenceContainer(path: JSONPath["parameters"][param])
        case .itemParam(let param):
            return ReferenceContainer(path: JSONPath["parameters"][AnalyticsParameterItems][param])

        // SetUserId
        case .userId:
            return ReferenceContainer(key: "user_id")

        // SetUserProperty
        case .userPropertyName:
            return ReferenceContainer(key: "property_name")
        case .userPropertyValue:
            return ReferenceContainer(key: "property_value")

        // SetDefaultParameters
        case .defaultParams:
            return ReferenceContainer(key: "parameters")
        case .defaultParam(let name):
            return ReferenceContainer(path: JSONPath["parameters"][name])

        // SetConsent
        case .consentSettings:
            return ReferenceContainer(key: "consent_settings")
        case .consentSetting(let type):
            return ReferenceContainer(path: JSONPath["consent_settings"][type.rawValue])

        // SetSessionTimeout
        case .sessionTimeout:
            return ReferenceContainer(key: "session_timeout_seconds")

        // SetAnalyticsCollectionEnabled
        case .analyticsEnabled:
            return ReferenceContainer(key: "analytics_collection_enabled")

        // InitiateConversionMeasurement
        case .conversionEmail:
            return ReferenceContainer(key: "email_address")
        case .conversionPhone:
            return ReferenceContainer(key: "phone_number")
        case .conversionHashedEmail:
            return ReferenceContainer(key: "hashed_email_address")
        case .conversionHashedPhone:
            return ReferenceContainer(key: "hashed_phone_number")
        }
    }
}

// MARK: - Firebase Mappings

/// Concrete Firebase mappings builder combining `FirebaseCommand` and `FirebaseDestination`.
///
/// Used with `FirebaseSettingsBuilder.setMappings(_:)` to configure Firebase-specific
/// data mappings with type-safe enums.
///
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder.setMappings { mappings in
///         mappings.mapCommand(.logEvent)
///         mappings.mapFrom("tealium_event", to: .eventName)
///         mappings.mapFrom("total", to: .eventParam(AnalyticsParameterValue))
///         mappings.mapFrom("product_ids", to: .itemParam(AnalyticsParameterItemID))
///     }
/// })
/// ```
public class FirebaseMappings: RemoteCommandMappingsBuilder<FirebaseCommand, FirebaseDestination> {
    required public init() { super.init() }
}
