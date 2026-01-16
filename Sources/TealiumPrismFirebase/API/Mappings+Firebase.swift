//
//  Mappings+Firebase.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

// MARK: - Firebase Mappings Extension

/// Extension providing Firebase-specific mapping helper methods.
///
/// Methods are grouped by Firebase command. Each group contains:
/// - Command mapping (required)
/// - Parameter mappings (as needed)
///
/// Use with `FirebaseSettingsBuilder.setMappings(_:)`.
public extension Mappings {
    
    // MARK: - LogEvent Command
    
    /// Log events to Firebase Analytics.
    ///
    /// **Simple event with parameters:**
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseLogEventCommand(),
    /// .mapFirebaseLogEventName(),
    /// .mapFirebaseLogEventParameters(parametersKey: "params")
    ///
    /// // Tracking:
    /// tealium.track("screen_view", data: ["params": ["screen_name": "Home"]])
    /// ```
    ///
    /// **E-commerce event with items (parallel arrays):**
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseLogEventCommand(),
    /// .mapFirebaseLogEventName(),
    /// .mapFirebaseEventParameter(from: "total", to: "value"),
    /// .mapFirebaseEventParameter(from: "currency", to: "currency"),
    /// .mapFirebaseItemParameter(from: "product_ids", to: "item_id"),
    /// .mapFirebaseItemParameter(from: "product_names", to: "item_name"),
    /// .mapFirebaseItemParameter(from: "prices", to: "price")
    ///
    /// // Tracking:
    /// tealium.track("purchase", data: [
    ///     "total": 99.99,
    ///     "currency": "USD",
    ///     "product_ids": ["SKU001", "SKU002"],
    ///     "product_names": ["Widget", "Gadget"],
    ///     "prices": [29.99, 70.00]
    /// ])
    /// ```
    
    /// Maps the "logevent" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseLogEventCommand() -> ConstantOptions {
        .constant(FirebaseConstants.LogEvent.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the Firebase event name parameter.
    ///
    /// Defaults to `tealium_event` which is automatically set by the SDK
    /// when you call `tealium.track("event_name")`.
    ///
    /// - Parameter eventKey: The source key containing the event name. Defaults to `tealium_event`.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseLogEventName(eventKey: String = TealiumDataKey.event) -> VariableOptions {
        .from(eventKey, to: FirebaseConstants.LogEvent.Path.eventName)
    }
    
    /// Maps a source JSONPath to the Firebase event name parameter.
    ///
    /// - Parameter eventPath: The source path containing the event name.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseLogEventName(eventPath: JSONObjectPath) -> VariableOptions {
        .from(eventPath, to: FirebaseConstants.LogEvent.Path.eventName)
    }
    
    /// Maps a source key to the Firebase event parameters.
    ///
    /// The parameters will be nested under the "logevent" container.
    ///
    /// - Parameter parametersKey: The source key containing event parameters dictionary.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseLogEventParameters(parametersKey: String) -> VariableOptions {
        .from(parametersKey, to: FirebaseConstants.LogEvent.Path.eventParams)
    }
    
    /// Maps a source JSONPath to the Firebase event parameters.
    ///
    /// - Parameter parametersPath: The source path containing event parameters dictionary.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseLogEventParameters(parametersPath: JSONObjectPath) -> VariableOptions {
        .from(parametersPath, to: FirebaseConstants.LogEvent.Path.eventParams)
    }
    
    /// Maps a source key to a specific event parameter.
    ///
    /// - Parameters:
    ///   - sourceKey: The source key to map from.
    ///   - parameterName: The name of the Firebase event parameter.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseEventParameter(from sourceKey: String, to parameterName: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.LogEvent.Path.eventParams[parameterName])
    }
    
    /// Maps a source key containing parallel arrays to a specific item parameter.
    ///
    /// Use this to map arrays of item properties directly into the items structure.
    ///
    /// - Parameters:
    ///   - sourceKey: The source key containing an array of values (e.g., ["SKU001", "SKU002"]).
    ///   - itemParameterName: The name of the Firebase item parameter (e.g., "item_id").
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseItemParameter(from sourceKey: String, to itemParameterName: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.LogEvent.Path.items[itemParameterName])
    }
    
    // MARK: - SetUserId Command
    
    /// Set or clear Firebase user ID.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseSetUserIdCommand()
    /// .mapFirebaseUserId(userIdKey: "customer_id")
    ///
    /// // Tracking:
    /// tealium.track("login", data: ["customer_id": "USER_123"])
    ///
    /// tealium.track("logout", data: ["customer_id": ""])  // Empty clears
    /// ```
    
    /// Maps the "setuserid" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseSetUserIdCommand() -> ConstantOptions {
        .constant(FirebaseConstants.SetUserId.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the Firebase user ID parameter.
    ///
    /// - Parameter userIdKey: The source key containing the user ID.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseUserId(userIdKey: String) -> VariableOptions {
        .from(userIdKey, to: FirebaseConstants.SetUserId.Path.userId)
    }
    
    /// Maps a source JSONPath to the Firebase user ID parameter.
    ///
    /// - Parameter userIdPath: The source path containing the user ID.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseUserId(userIdPath: JSONObjectPath) -> VariableOptions {
        .from(userIdPath, to: FirebaseConstants.SetUserId.Path.userId)
    }
    
    // MARK: - SetUserProperty Command
    
    /// Set a single Firebase user property.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseSetUserPropertyCommand()
    /// .mapFirebaseUserPropertyName(propertyNameKey: "prop_name"),
    /// .mapFirebaseUserPropertyValue(propertyValueKey: "prop_value")
    ///
    /// // Tracking:
    /// tealium.track("set_tier", data: ["prop_name": "tier", "prop_value": "premium"])
    /// ```
    
    /// Maps the "setuserproperty" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseSetUserPropertyCommand() -> ConstantOptions {
        .constant(FirebaseConstants.SetUserProperty.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the Firebase user property name.
    ///
    /// - Parameter propertyNameKey: The source key containing the property name.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseUserPropertyName(propertyNameKey: String) -> VariableOptions {
        .from(propertyNameKey, to: FirebaseConstants.SetUserProperty.Path.propertyName)
    }
    
    /// Maps a source key to the Firebase user property value.
    ///
    /// - Parameter propertyValueKey: The source key containing the property value.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseUserPropertyValue(propertyValueKey: String) -> VariableOptions {
        .from(propertyValueKey, to: FirebaseConstants.SetUserProperty.Path.propertyValue)
    }
    
    // MARK: - SetUserProperties Command
    
    /// Set multiple Firebase user properties using parallel arrays.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseSetUserPropertiesCommand()
    /// .mapFirebaseUserPropertyNames(propertyNamesKey: "names"),
    /// .mapFirebaseUserPropertyValues(propertyValuesKey: "values")
    ///
    /// // Tracking:
    /// tealium.track("bulk_props", data: [
    ///     "names": ["tier", "level"],
    ///     "values": ["premium", "expert"]
    /// ])
    /// ```
    
    /// Maps the "setuserproperties" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseSetUserPropertiesCommand() -> ConstantOptions {
        .constant(FirebaseConstants.SetUserProperties.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the Firebase user property names array.
    ///
    /// - Parameter propertyNamesKey: The source key containing the property names array.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseUserPropertyNames(propertyNamesKey: String) -> VariableOptions {
        .from(propertyNamesKey, to: FirebaseConstants.SetUserProperties.Path.propertyNames)
    }
    
    /// Maps a source key to the Firebase user property values array.
    ///
    /// - Parameter propertyValuesKey: The source key containing the property values array.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseUserPropertyValues(propertyValuesKey: String) -> VariableOptions {
        .from(propertyValuesKey, to: FirebaseConstants.SetUserProperties.Path.propertyValues)
    }
    
    // MARK: - SetDefaultParameters Command
    
    /// Set default event parameters (included with every event).
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseSetDefaultParametersCommand()
    /// .mapFirebaseDefaultParameters(paramsKey: "defaults")
    ///
    /// // Tracking:
    /// tealium.track("set_defaults", data: [
    ///     "defaults": ["app_version": "2.0", "env": "prod"]
    /// ])
    /// ```
    
    /// Maps the "setdefaultparameters" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseSetDefaultParametersCommand() -> ConstantOptions {
        .constant(FirebaseConstants.SetDefaultParameters.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the Firebase default parameters.
    ///
    /// - Parameter paramsKey: The source key containing the default parameters dictionary.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseDefaultParameters(paramsKey: String) -> VariableOptions {
        .from(paramsKey, to: FirebaseConstants.SetDefaultParameters.Path.params)
    }
    
    /// Maps a source key to a specific default parameter.
    ///
    /// - Parameters:
    ///   - sourceKey: The source key to map from.
    ///   - parameterName: The name of the default parameter.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseDefaultParameter(from sourceKey: String, to parameterName: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.SetDefaultParameters.Path.params[parameterName])
    }
    
    // MARK: - SetConsent Command
    
    /// Update Firebase consent settings.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseSetConsentCommand(),
    /// .mapFirebaseAnalyticsStorage(sourceKey: "analytics_consent"),
    /// .mapFirebaseAdStorage(sourceKey: "ad_consent")
    ///
    /// // Tracking:
    /// tealium.track("consent_update", data: [
    ///     "analytics_consent": "granted",
    ///     "ad_consent": "denied"
    /// ])
    /// ```
    ///
    /// Supported values: `"granted"`, `"denied"`
    
    /// Maps the "setconsent" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseSetConsentCommand() -> ConstantOptions {
        .constant(FirebaseConstants.SetConsent.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the Firebase ad_storage consent setting.
    ///
    /// - Parameter sourceKey: The source key containing the consent value.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseAdStorage(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.SetConsent.Path.adStorage)
    }
    
    /// Maps a source key to the Firebase analytics_storage consent setting.
    ///
    /// - Parameter sourceKey: The source key containing the consent value.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseAnalyticsStorage(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.SetConsent.Path.analyticsStorage)
    }
    
    /// Maps a source key to the Firebase ad_user_data consent setting.
    ///
    /// - Parameter sourceKey: The source key containing the consent value.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseAdUserData(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.SetConsent.Path.adUserData)
    }
    
    /// Maps a source key to the Firebase ad_personalization consent setting.
    ///
    /// - Parameter sourceKey: The source key containing the consent value.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseAdPersonalization(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.SetConsent.Path.adPersonalization)
    }
    
    // MARK: - ResetData Command
    
    /// Clear all Firebase Analytics data and reset app instance ID.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseResetDataCommand()
    ///     .ifValueIn(TealiumDataKey.event, equals: "delete_data")
    ///
    /// // Tracking:
    /// tealium.track("delete_data")
    /// ```
    
    /// Maps the "resetdata" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseResetDataCommand() -> ConstantOptions {
        .constant(FirebaseConstants.ResetData.name, to: FirebaseConstants.commandKey)
    }
    
    // MARK: - SetSessionTimeout Command
    
    /// Dynamically change session timeout at runtime.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseSetSessionTimeoutCommand()
    /// .mapFirebaseSetSessionTimeoutValue(sourceKey: "timeout")
    ///
    /// // Tracking:
    /// tealium.track("update_timeout", data: ["timeout": 3600])
    /// ```
    
    /// Maps the "setsessiontimeout" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseSetSessionTimeoutCommand() -> ConstantOptions {
        .constant(FirebaseConstants.SetSessionTimeout.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the session timeout parameter for the SetSessionTimeout command.
    ///
    /// - Parameter sourceKey: The source key containing the session timeout value.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseSetSessionTimeoutValue(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.SetSessionTimeout.Path.sessionTimeout)
    }
    
    // MARK: - SetAnalyticsCollectionEnabled Command
    
    /// Dynamically enable/disable analytics collection at runtime.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseSetAnalyticsCollectionEnabledCommand()
    /// .mapFirebaseSetAnalyticsCollectionEnabledValue(sourceKey: "enabled")
    ///
    /// // Tracking:
    /// tealium.track("toggle_analytics", data: ["enabled": false])
    /// ```
    
    /// Maps the "setanalyticscollectionenabled" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseSetAnalyticsCollectionEnabledCommand() -> ConstantOptions {
        .constant(FirebaseConstants.SetAnalyticsCollectionEnabled.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the analytics enabled parameter for the SetAnalyticsCollectionEnabled command.
    ///
    /// - Parameter sourceKey: The source key containing the enabled value.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseSetAnalyticsCollectionEnabledValue(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.SetAnalyticsCollectionEnabled.Path.analyticsEnabled)
    }
    
    // MARK: - InitiateConversionMeasurement Command
    
    /// Initiate on-device conversion measurement.
    ///
    /// ```swift
    /// // Mappings:
    /// .mapFirebaseInitiateConversionMeasurementCommand()
    /// .mapFirebaseConversionEmailAddress(sourceKey: "email")
    ///
    /// // Tracking:
    /// tealium.track("conversion", data: ["email": "user@example.com"])
    /// ```
    ///
    /// Priority: hashed_email > hashed_phone > email > phone
    
    /// Maps the "initiateconversionmeasurement" command constant to the command key.
    ///
    /// - Returns: A `ConstantOptions` mapping builder.
    static func mapFirebaseInitiateConversionMeasurementCommand() -> ConstantOptions {
        .constant(FirebaseConstants.InitiateConversionMeasurement.name, to: FirebaseConstants.commandKey)
    }
    
    /// Maps a source key to the email address parameter for conversion measurement.
    ///
    /// - Parameter sourceKey: The source key containing the email address.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseConversionEmailAddress(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.InitiateConversionMeasurement.Path.emailAddress)
    }
    
    /// Maps a source key to the phone number parameter for conversion measurement.
    ///
    /// - Parameter sourceKey: The source key containing the phone number.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseConversionPhoneNumber(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.InitiateConversionMeasurement.Path.phoneNumber)
    }
    
    /// Maps a source key to the hashed email address parameter for conversion measurement.
    ///
    /// - Parameter sourceKey: The source key containing the hashed email address.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseConversionHashedEmailAddress(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.InitiateConversionMeasurement.Path.hashedEmailAddress)
    }
    
    /// Maps a source key to the hashed phone number parameter for conversion measurement.
    ///
    /// - Parameter sourceKey: The source key containing the hashed phone number.
    /// - Returns: A `VariableOptions` mapping builder.
    static func mapFirebaseConversionHashedPhoneNumber(sourceKey: String) -> VariableOptions {
        .from(sourceKey, to: FirebaseConstants.InitiateConversionMeasurement.Path.hashedPhoneNumber)
    }
}
