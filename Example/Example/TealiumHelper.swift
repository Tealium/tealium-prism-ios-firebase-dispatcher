//
//  TealiumHelper.swift
//  Example
//
//  Created by Sebastian Krajna on 16/01/2026.
//  Copyright © 2026 Tealium, Inc. All rights reserved.
//

import Foundation
import TealiumPrismCore
import TealiumPrismFirebase

class TealiumHelper {
    private(set) var teal: Tealium?
    static let shared = TealiumHelper()
    
    private init() {}
    
    func startTealium() {
        let config = TealiumConfig(
            account: "tealiummobile",
            profile: "firebase-test",
            environment: "dev",
            modules: [
                Modules.firebaseDispatcher(forcingSettings: { builder in
                    builder
                        .setSessionTimeout(1800)
                        .setAnalyticsEnabled(true)
                        .setGA360Mode(false)
                        .setInvalidCharacterStrategy("replace")
                        .setLogLevel("debug")
                        .setMappings([
                            // LogEvent Command
                            .mapFirebaseLogEventCommand(),
                            .mapFirebaseLogEventName(),
                            .mapFirebaseLogEventParameters(parametersKey: "firebase_params"),
                            .mapFirebaseEventParameter(from: "value", to: "value"),
                            .mapFirebaseEventParameter(from: "currency", to: "currency"),
                            .mapFirebaseEventParameter(from: "transaction_id", to: "transaction_id"),
                            .mapFirebaseItemParameter(from: "product_ids", to: "item_id"),
                            .mapFirebaseItemParameter(from: "product_names", to: "item_name"),
                            .mapFirebaseItemParameter(from: "prices", to: "price"),
                            .mapFirebaseItemParameter(from: "quantities", to: "quantity"),
                            
                            // SetUserId Command
                            .mapFirebaseSetUserIdCommand()
                                .ifValueIn("tealium_event", equals: "set_user_id"),
                            .mapFirebaseUserId(userIdKey: "user_id"),
                            
                            // SetUserProperty Command
                            .mapFirebaseSetUserPropertyCommand()
                                .ifValueIn("tealium_event", equals: "set_user_property"),
                            .mapFirebaseUserPropertyName(propertyNameKey: "property_name"),
                            .mapFirebaseUserPropertyValue(propertyValueKey: "property_value"),
                            
                            // SetUserProperties Command
                            .mapFirebaseSetUserPropertiesCommand()
                                .ifValueIn("tealium_event", equals: "set_user_properties"),
                            .mapFirebaseUserPropertyNames(propertyNamesKey: "property_names"),
                            .mapFirebaseUserPropertyValues(propertyValuesKey: "property_values"),
                            
                            // SetDefaultParameters Command
                            .mapFirebaseSetDefaultParametersCommand()
                                .ifValueIn("tealium_event", equals: "set_default_params"),
                            .mapFirebaseDefaultParameters(paramsKey: "default_params"),
                            
                            // SetConsent Command
                            .mapFirebaseSetConsentCommand()
                                .ifValueIn("tealium_event", equals: "update_consent"),
                            .mapFirebaseAnalyticsStorage(sourceKey: "analytics_storage"),
                            .mapFirebaseAdStorage(sourceKey: "ad_storage"),
                            .mapFirebaseAdUserData(sourceKey: "ad_user_data"),
                            .mapFirebaseAdPersonalization(sourceKey: "ad_personalization"),
                            
                            // ResetData Command
                            .mapFirebaseResetDataCommand()
                                .ifValueIn("tealium_event", equals: "reset_firebase_data"),
                            
                            // SetSessionTimeout Command
                            .mapFirebaseSetSessionTimeoutCommand()
                                .ifValueIn("tealium_event", equals: "update_session_timeout"),
                            .mapFirebaseSetSessionTimeoutValue(sourceKey: "session_timeout"),
                            
                            // SetAnalyticsCollectionEnabled Command
                            .mapFirebaseSetAnalyticsCollectionEnabledCommand()
                                .ifValueIn("tealium_event", equals: "toggle_analytics"),
                            .mapFirebaseSetAnalyticsCollectionEnabledValue(sourceKey: "analytics_enabled"),
                            
                            // InitiateConversionMeasurement Command
                            .mapFirebaseInitiateConversionMeasurementCommand()
                                .ifValueIn("tealium_event", equals: "conversion_measurement"),
                            .mapFirebaseConversionEmailAddress(sourceKey: "email"),
                            .mapFirebaseConversionPhoneNumber(sourceKey: "phone_number"),
                            .mapFirebaseConversionHashedEmailAddress(sourceKey: "hashed_email"),
                            .mapFirebaseConversionHashedPhoneNumber(sourceKey: "hashed_phone")
                        ])
                })
            ],
            forcingSettings: { builder in
                builder.setMinLogLevel(.trace)
            }
        )
        
    self.teal = Tealium.create(config: config)
    }
    
    func stopTealium() {
        self.teal = nil
    }
    
    // MARK: - 1. LogEventCommand
    
    /// Simple event without parameters
    func logSimpleEvent() {
        teal?.track("screen_view", data: nil)
    }
    
    /// Event with parameters
    func logEventWithParameters() {
        teal?.track("login", data: [
            "firebase_params": [
                "method": "email"
            ] as DataObject
        ])
    }
    
    /// E-commerce event with items (parallel arrays)
    func logEcommerceEvent() {
        teal?.track("purchase", data: [
            "value": 149.99,
            "currency": "USD",
            "transaction_id": "TXN-2026-001",
            "product_ids": ["SKU-001", "SKU-002"],
            "product_names": ["Widget", "Gadget"],
            "prices": [79.99, 70.00],
            "quantities": [1, 2]
        ])
    }
    
    /// Test event name validation (invalid characters)
    func logEventWithInvalidChars() {
        teal?.track("test@event#with$invalid%chars", data: nil)
    }
    
    /// Test event name validation (reserved name)
    func logEventWithReservedName() {
        teal?.track("firebase_reserved_event", data: nil)
    }
    
    /// Test event name validation (exceeds 40 char limit)
    func logEventWithLongName() {
        teal?.track("this_is_a_very_long_event_name_that_exceeds_forty_chars", data: nil)
    }
    
    /// Test max parameters limit (100)
    func logEventWithMaxParams() {
        var params: [String: DataInputConvertible] = [:]
        for i in 0..<105 {
            params["param_\(i)"] = "value_\(i)"
        }
        teal?.track("max_params_test", data: [
            "firebase_params": DataObject(dictionary: params)
        ])
    }
    
    /// Test max items limit (100)
    func logEventWithMaxItems() {
        let productIds = (0..<105).map { "SKU\($0)" }
        let productNames = (0..<105).map { "Product\($0)" }
        let prices = (0..<105).map { Double($0) * 10.0 }
        let quantities = (0..<105).map { _ in 1 }
        
        teal?.track("max_items_test", data: [
            "value": 10500.0,
            "currency": "USD",
            "transaction_id": "TXN-MAX",
            "product_ids": productIds,
            "product_names": productNames,
            "prices": prices,
            "quantities": quantities
        ])
    }
    
    // MARK: - 2. SetUserIdCommand
    
    /// Set user ID
    func setUserId() {
        teal?.track("set_user_id", data: ["user_id": "user_12345"])
    }
    
    /// Clear user ID (empty string)
    func clearUserId() {
        teal?.track("set_user_id", data: ["user_id": ""])
    }
    
    /// Test user ID exceeding 256 chars limit
    func setUserIdTooLong() {
        let longUserId = String(repeating: "x", count: 300)
        teal?.track("set_user_id", data: ["user_id": longUserId])
    }
    
    // MARK: - 3. SetUserPropertyCommand
    
    /// Set single user property
    func setUserProperty() {
        teal?.track("set_user_property", data: [
            "property_name": "user_tier",
            "property_value": "premium"
        ])
    }
    
    /// Clear user property (empty value)
    func clearUserProperty() {
        teal?.track("set_user_property", data: [
            "property_name": "user_tier",
            "property_value": ""
        ])
    }
    
    // MARK: - 4. SetUserPropertiesCommand
    
    /// Set multiple user properties
    func setMultipleUserProperties() {
        teal?.track("set_user_properties", data: [
            "property_names": ["tier", "level", "status"],
            "property_values": ["premium", "expert", "active"]
        ])
    }
    
    /// Test mismatched arrays (should fail)
    func setUserPropertiesMismatchedArrays() {
        teal?.track("set_user_properties", data: [
            "property_names": ["tier", "level", "status"],
            "property_values": ["premium", "expert"] // Missing one value
        ])
    }
    
    /// Test empty arrays (should fail)
    func setUserPropertiesEmpty() {
        teal?.track("set_user_properties", data: [
            "property_names": [] as [String],
            "property_values": [] as [String]
        ])
    }
    
    // MARK: - 5. SetDefaultParametersCommand
    
    /// Set default parameters
    func setDefaultParameters() {
        teal?.track("set_default_params", data: [
            "default_params": [
                "app_version": "1.0.0",
                "environment": "production",
                "platform": "iOS"
            ] as DataObject
        ])
    }
    
    /// Clear default parameters (empty dict)
    func clearDefaultParameters() {
        teal?.track("set_default_params", data: [
            "default_params": [:] as DataObject
        ])
    }
    
    // MARK: - 6. SetConsentCommand
    
    /// Grant all consent
    func grantAllConsent() {
        teal?.track("update_consent", data: [
            "analytics_storage": "granted",
            "ad_storage": "granted",
            "ad_user_data": "granted",
            "ad_personalization": "granted"
        ])
    }
    
    /// Deny all consent
    func denyAllConsent() {
        teal?.track("update_consent", data: [
            "analytics_storage": "denied",
            "ad_storage": "denied",
            "ad_user_data": "denied",
            "ad_personalization": "denied"
        ])
    }
    
    /// Mixed consent
    func mixedConsent() {
        teal?.track("update_consent", data: [
            "analytics_storage": "granted",
            "ad_storage": "denied",
            "ad_user_data": "denied",
            "ad_personalization": "denied"
        ])
    }
    
    /// Test invalid consent value (should warn)
    func invalidConsentValue() {
        teal?.track("update_consent", data: [
            "analytics_storage": "maybe" // Invalid value
        ])
    }
    
    // MARK: - 7. ResetDataCommand
    
    /// Reset Firebase data
    func resetFirebaseData() {
        teal?.track("reset_firebase_data", data: nil)
    }
    
    // MARK: - 8. SetSessionTimeoutCommand
    
    /// Update session timeout
    func updateSessionTimeout() {
        teal?.track("update_session_timeout", data: ["session_timeout": 3600])
    }
    
    /// Test session timeout as string (should convert)
    func updateSessionTimeoutString() {
        teal?.track("update_session_timeout", data: ["session_timeout": "1800"])
    }
    
    // MARK: - 9. SetAnalyticsCollectionEnabledCommand
    
    /// Enable analytics
    func enableAnalytics() {
        teal?.track("toggle_analytics", data: ["analytics_enabled": true])
    }
    
    /// Disable analytics
    func disableAnalytics() {
        teal?.track("toggle_analytics", data: ["analytics_enabled": false])
    }
    
    /// Test as string "true" (should convert)
    func enableAnalyticsString() {
        teal?.track("toggle_analytics", data: ["analytics_enabled": "true"])
    }
    
    /// Test as int 1 (should convert to true)
    func enableAnalyticsInt() {
        teal?.track("toggle_analytics", data: ["analytics_enabled": 1])
    }
    
    // MARK: - 10. InitiateConversionMeasurementCommand
    
    /// With email address
    func conversionWithEmail() {
        teal?.track("conversion_measurement", data: [
            "email": "user@example.com"
        ])
    }
    
    /// With phone number
    func conversionWithPhone() {
        teal?.track("conversion_measurement", data: [
            "phone_number": "+1234567890"
        ])
    }
    
    /// With hashed email
    func conversionWithHashedEmail() {
        teal?.track("conversion_measurement", data: [
            "hashed_email": "hashed_email_data_here"
        ])
    }
    
    /// With hashed phone
    func conversionWithHashedPhone() {
        teal?.track("conversion_measurement", data: [
            "hashed_phone": "hashed_phone_data_here"
        ])
    }
    
    /// No parameters (should fail)
    func conversionWithoutParams() {
        teal?.track("conversion_measurement", data: [:])
    }
    
    /// Empty email (should fail)
    func conversionWithEmptyEmail() {
        teal?.track("conversion_measurement", data: [
            "email": ""
        ])
    }
}
