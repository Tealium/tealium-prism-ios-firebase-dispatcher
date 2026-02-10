//
//  TealiumHelper.swift
//  Example
//
//  Created by Sebastian Krajna on 16/01/2026.
//  Copyright © 2026 Tealium, Inc. All rights reserved.
//

import Foundation
import FirebaseCore
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
                Modules.firebaseDispatcher()
            ],
            settingsFile: "TealiumSettings",
            forcingSettings: { builder in
                builder.setMinLogLevel(.trace)
            }
        )

        self.teal = Tealium.create(config: config)
    }
    
    func stopTealium() {
        self.teal = nil
    }
    
    // MARK: - LogEventCommand
    
    /// Comprehensive purchase event demonstrating all features:
    /// - All predefined event parameters (value, currency, transaction_id, shipping, tax, affiliation, coupon)
    /// - Custom event parameters
    /// - Items with all predefined item parameters (item_id, item_name, item_brand, item_category, price, quantity, discount, etc.)
    /// - Custom item parameters
    func logComprehensivePurchaseEvent() {
        teal?.track("purchase", data: [
            // Predefined event parameters
            "value": 249.97,
            "currency": "USD",
            "transaction_id": "TXN-2026-001",
            "shipping": 9.99,
            "tax": 20.00,
            "affiliation": "Online Store",
            "coupon": "SUMMER2026",
            
            // Custom event parameters
            "custom_event_param_1": "custom_value_1",
            "custom_event_param_2": 12345,
            "custom_event_param_3": true,
            
            // Items (parallel arrays format)
            // Predefined item parameters
            "product_ids": ["SKU-001", "SKU-002", "SKU-003"],
            "product_names": ["Premium Widget", "Gadget Pro", "Super Tool"],
            "product_brands": ["BrandA", "BrandB", "BrandA"],
            "product_categories": ["Electronics", "Tools", "Electronics"],
            "product_category2": ["Widgets", "Hand Tools", "Widgets"],
            "product_category3": ["Premium", "Professional", "Premium"],
            "prices": [99.99, 79.99, 69.99],
            "quantities": [1, 2, 1],
            "discounts": [10.00, 5.00, 0.00],
            "item_variants": ["Blue", "Red", "Black"],
            "item_list_ids": ["list_001", "list_002", "list_001"],
            "item_list_names": ["Featured", "Recommended", "Featured"],
            "indices": [0, 1, 2],
            
            // Custom item parameters (parallel arrays format)
            "custom_item_color": ["Blue", "Red", "Black"],
            "custom_item_size": ["Large", "Medium", "Small"],
            "custom_item_material": ["Metal", "Plastic", "Metal"]
        ])
    }
    
    // MARK: - SetUserIdCommand
    
    /// Set user ID
    func setUserId() {
        teal?.track("set_user_id", data: ["user_id": "user_12345"])
    }
    
    /// Clear user ID (empty string clears the ID)
    func clearUserId() {
        teal?.track("set_user_id", data: ["user_id": ""])
    }
    
    // MARK: - SetUserPropertyCommand
    
    /// Set single user property
    func setUserProperty() {
        teal?.track("set_user_property", data: [
            "property_name": "user_tier",
            "property_value": "premium"
        ])
    }
    
    /// Clear user property (empty value clears the property)
    func clearUserProperty() {
        teal?.track("set_user_property", data: [
            "property_name": "user_tier",
            "property_value": ""
        ])
    }
    
    // MARK: - SetUserPropertiesCommand
    
    /// Set multiple user properties at once
    func setMultipleUserProperties() {
        teal?.track("set_user_properties", data: [
            "property_names": ["tier", "level", "status", "region", "membership_start"],
            "property_values": ["premium", "expert", "active", "NA", "2026-01-01"]
        ])
    }
    
    /// Clear multiple user properties at once (empty strings clear the properties)
    func clearMultipleUserProperties() {
        teal?.track("set_user_properties", data: [
            "property_names": ["tier", "level", "status", "region", "membership_start"],
            "property_values": ["", "", "", "", ""]  // Empty strings clear properties
        ])
    }
    
    // MARK: - SetDefaultParametersCommand
    
    /// Set default parameters that will be included with every event
    func setDefaultParameters() {
        teal?.track("set_default_params", data: [
            "default_params": [
                "app_version": "1.0.0",
                "environment": "production",
                "platform": "iOS",
                "device_type": "iPhone",
                "build_number": "42"
            ] as DataObject
        ])
    }
    
    /// Clear default parameters (omitting firebase_params passes nil to Firebase)
    func clearDefaultParameters() {
        teal?.track("set_default_params", data: [:])
    }
    
    // MARK: - SetConsentCommand
    
    /// Grant all consent types
    func grantAllConsent() {
        teal?.track("update_consent", data: [
            "analytics_storage": "granted",
            "ad_storage": "granted",
            "ad_user_data": "granted",
            "ad_personalization": "granted"
        ])
    }
    
    /// Deny all consent types
    func denyAllConsent() {
        teal?.track("update_consent", data: [
            "analytics_storage": "denied",
            "ad_storage": "denied",
            "ad_user_data": "denied",
            "ad_personalization": "denied"
        ])
    }
    
    // MARK: - ResetDataCommand
    
    /// Reset all Firebase Analytics data (clears user ID, properties, and app instance ID)
    func resetFirebaseData() {
        teal?.track("reset_firebase_data", data: nil)
    }
    
    // MARK: - SetSessionTimeoutCommand
    
    /// Update session timeout duration to 1 hour
    func updateSessionTimeout() {
        teal?.track("update_session_timeout", data: ["session_timeout": 3600])  // 1 hour (3600 seconds)
    }
    
    /// Reset session timeout to Firebase default (30 minutes)
    func resetSessionTimeout() {
        teal?.track("update_session_timeout", data: ["session_timeout": 1800])  // 30 minutes (1800 seconds) - Firebase default
    }
    
    // MARK: - SetAnalyticsCollectionEnabledCommand
    
    /// Enable Firebase Analytics data collection
    func enableAnalytics() {
        teal?.track("toggle_analytics", data: ["analytics_enabled": true])
    }
    
    /// Disable Firebase Analytics data collection
    func disableAnalytics() {
        teal?.track("toggle_analytics", data: ["analytics_enabled": false])
    }
    
    // MARK: - InitiateConversionMeasurementCommand
    
    /// Initiate conversion measurement with email address
    func conversionWithEmail() {
        teal?.track("conversion_measurement", data: [
            "email": "user@example.com"
        ])
    }
    
    /// Initiate conversion measurement with phone number
    func conversionWithPhone() {
        teal?.track("conversion_measurement", data: [
            "phone_number": "+1234567890"
        ])
    }
    
    /// Initiate conversion measurement with hashed email address
    func conversionWithHashedEmail() {
        teal?.track("conversion_measurement", data: [
            "hashed_email": "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"  // SHA256 of "password"
        ])
    }
    
    /// Initiate conversion measurement with hashed phone number
    func conversionWithHashedPhone() {
        teal?.track("conversion_measurement", data: [
            "hashed_phone": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"  // SHA256 of empty string
        ])
    }
}
