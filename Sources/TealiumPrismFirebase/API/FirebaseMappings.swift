//
//  FirebaseMappings.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/03/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import FirebaseAnalytics
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
    case eventParam(FirebaseEventParameter)

    /// A specific item parameter nested under `parameters.items.[name]`.
    case itemParam(FirebaseItemParameter)

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

    /// A specific consent setting nested under `consent_settings.[type.key]`.
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
            return ReferenceContainer(path: JSONPath["parameters"][param.value])
        case .itemParam(let param):
            return ReferenceContainer(path: JSONPath["parameters"][FirebaseEventParameter.items.value][param.value])

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
            return ReferenceContainer(path: JSONPath["consent_settings"][type.key])

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

// MARK: - Firebase Event Parameters

/// Predefined Firebase Analytics event parameter names.
///
/// Use with `FirebaseDestination.eventParam(_:)` for type-safe parameter mapping.
/// Values resolve to Firebase SDK constants (e.g., `.currency` -> `AnalyticsParameterCurrency`).
/// Use `.custom(_:)` for parameters not in the predefined list.
public enum FirebaseEventParameter {

    // MARK: Core

    case achievementId
    case adFormat
    case adNetworkClickId
    case adPlatform
    case adSource
    case adUnitName
    case affiliation
    case campaign
    case campaignId
    case character
    case content
    case contentType
    case coupon
    case cp1
    case creativeFormat
    case creativeName
    case creativeSlot
    case currency
    case destination
    case discount
    case endDate
    case extendSession
    case flightNumber
    case groupId
    case index
    case level
    case levelName
    case location
    case locationId
    case marketingTactic
    case medium
    case method
    case numberOfNights
    case numberOfPassengers
    case numberOfRooms
    case origin
    case paymentType
    case price
    case promotionId
    case promotionName
    case quantity
    case score
    case screenClass
    case screenName
    case searchTerm
    case shipping
    case shippingTier
    case source
    case sourcePlatform
    case startDate
    case success
    case tax
    case term
    case transactionId
    case travelClass
    case value
    case virtualCurrencyName

    // MARK: Item-scoped (also valid as event params)

    case itemBrand
    case itemCategory
    case itemCategory2
    case itemCategory3
    case itemCategory4
    case itemCategory5
    case itemId
    case itemListId
    case itemListName
    case itemName
    case itemVariant
    case items

    // MARK: User properties (also mappable as event params)

    case userAllowAdPersonalizationSignals
    case userSignupMethod

    // MARK: Custom

    /// A custom parameter name not in the predefined list.
    case custom(String)

    /// The Tealium-owned parameter key string.
    ///
    /// These strings are stable identifiers owned by Tealium (e.g., `"param_currency"`).
    /// The `FirebaseParameter` mapper translates them to Firebase SDK constants at dispatch time.
    var value: String {
        typealias K = FirebaseConstants.EventParamKey
        switch self {
        case .achievementId: return K.achievementId
        case .adFormat: return K.adFormat
        case .adNetworkClickId: return K.adNetworkClickId
        case .adPlatform: return K.adPlatform
        case .adSource: return K.adSource
        case .adUnitName: return K.adUnitName
        case .affiliation: return K.affiliation
        case .campaign: return K.campaign
        case .campaignId: return K.campaignId
        case .character: return K.character
        case .content: return K.content
        case .contentType: return K.contentType
        case .coupon: return K.coupon
        case .cp1: return K.cp1
        case .creativeFormat: return K.creativeFormat
        case .creativeName: return K.creativeName
        case .creativeSlot: return K.creativeSlot
        case .currency: return K.currency
        case .destination: return K.destination
        case .discount: return K.discount
        case .endDate: return K.endDate
        case .extendSession: return K.extendSession
        case .flightNumber: return K.flightNumber
        case .groupId: return K.groupId
        case .index: return K.index
        case .level: return K.level
        case .levelName: return K.levelName
        case .location: return K.location
        case .locationId: return K.locationId
        case .marketingTactic: return K.marketingTactic
        case .medium: return K.medium
        case .method: return K.method
        case .numberOfNights: return K.numberOfNights
        case .numberOfPassengers: return K.numberOfPassengers
        case .numberOfRooms: return K.numberOfRooms
        case .origin: return K.origin
        case .paymentType: return K.paymentType
        case .price: return K.price
        case .promotionId: return K.promotionId
        case .promotionName: return K.promotionName
        case .quantity: return K.quantity
        case .score: return K.score
        case .screenClass: return K.screenClass
        case .screenName: return K.screenName
        case .searchTerm: return K.searchTerm
        case .shipping: return K.shipping
        case .shippingTier: return K.shippingTier
        case .source: return K.source
        case .sourcePlatform: return K.sourcePlatform
        case .startDate: return K.startDate
        case .success: return K.success
        case .tax: return K.tax
        case .term: return K.term
        case .transactionId: return K.transactionId
        case .travelClass: return K.travelClass
        case .value: return K.value
        case .virtualCurrencyName: return K.virtualCurrencyName
        case .itemBrand: return K.itemBrand
        case .itemCategory: return K.itemCategory
        case .itemCategory2: return K.itemCategory2
        case .itemCategory3: return K.itemCategory3
        case .itemCategory4: return K.itemCategory4
        case .itemCategory5: return K.itemCategory5
        case .itemId: return K.itemId
        case .itemListId: return K.itemListId
        case .itemListName: return K.itemListName
        case .itemName: return K.itemName
        case .itemVariant: return K.itemVariant
        case .items: return K.items
        case .userAllowAdPersonalizationSignals: return K.userAllowAdPersonalizationSignals
        case .userSignupMethod: return K.userSignupMethod
        case .custom(let name): return name
        }
    }
}

// MARK: - Firebase Item Parameters

/// Predefined Firebase Analytics item parameter names.
///
/// Use with `FirebaseDestination.itemParam(_:)` for type-safe item parameter mapping.
/// Values resolve to Firebase SDK constants (e.g., `.itemId` -> `AnalyticsParameterItemID`).
/// Use `.custom(_:)` for parameters not in the predefined list.
public enum FirebaseItemParameter {

    // MARK: Core

    case itemId
    case itemName
    case itemBrand
    case itemCategory
    case itemCategory2
    case itemCategory3
    case itemCategory4
    case itemCategory5
    case itemVariant

    // MARK: Lists

    case itemListId
    case itemListName
    case index

    // MARK: Pricing

    case price
    case quantity
    case discount

    // MARK: E-commerce

    case affiliation
    case coupon
    case locationId

    // MARK: Promotions

    case promotionId
    case promotionName
    case creativeName
    case creativeSlot

    // MARK: Custom

    /// A custom item parameter name not in the predefined list.
    case custom(String)

    /// The Tealium-owned item parameter key string.
    ///
    /// These strings are stable identifiers owned by Tealium (e.g., `"param_items_item_id"`).
    /// The `FirebaseItemParameterMapper` translates them to Firebase SDK constants at dispatch time.
    var value: String {
        typealias K = FirebaseConstants.ItemParamKey
        switch self {
        case .itemId: return K.itemId
        case .itemName: return K.itemName
        case .itemBrand: return K.itemBrand
        case .itemCategory: return K.itemCategory
        case .itemCategory2: return K.itemCategory2
        case .itemCategory3: return K.itemCategory3
        case .itemCategory4: return K.itemCategory4
        case .itemCategory5: return K.itemCategory5
        case .itemVariant: return K.itemVariant
        case .itemListId: return K.itemListId
        case .itemListName: return K.itemListName
        case .index: return K.index
        case .price: return K.price
        case .quantity: return K.quantity
        case .discount: return K.discount
        case .affiliation: return K.affiliation
        case .coupon: return K.coupon
        case .locationId: return K.locationId
        case .promotionId: return K.promotionId
        case .promotionName: return K.promotionName
        case .creativeName: return K.creativeName
        case .creativeSlot: return K.creativeSlot
        case .custom(let name): return name
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
///         mappings.mapFrom("total", to: .eventParam(.value))
///         mappings.mapFrom("product_ids", to: .itemParam(.itemId))
///     }
/// })
/// ```
public class FirebaseMappings: RemoteCommandMappingsBuilder<FirebaseCommand, FirebaseDestination> {
    required public init() { super.init() }
}
