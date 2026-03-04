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
import CryptoKit

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
    
    /// Initiate conversion measurement with plaintext email (Firebase handles normalization/hashing)
    func conversionWithEmail() {
        teal?.track("conversion_measurement", data: [
            "email": "user@example.com"
        ])
    }
    
    /// Initiate conversion measurement with plaintext phone in E.164 format (Firebase handles hashing)
    func conversionWithPhone() {
        teal?.track("conversion_measurement", data: [
            "phone_number": "+1234567890"
        ])
    }
    
    /// Initiate conversion measurement with hashed email
    /// Flow: normalize email → SHA256 hash → Base64 encode → send via Tealium
    func conversionWithHashedEmail() {
        let rawEmail = "An.Email.User0125@googlemail.com"
        let normalizedEmail = normalizeEmail(rawEmail)
        let hash = SHA256.hash(data: Data(normalizedEmail.utf8))
        let base64String = Data(hash).base64EncodedString()
        
        teal?.track("conversion_measurement", data: [
            "hashed_email": base64String
        ])
        
        print("📧 Hashed Email Conversion")
        print("   Raw: \(rawEmail)")
        print("   Normalized: \(normalizedEmail)")
        print("   Base64: \(base64String)")
    }
    
    /// Initiate conversion measurement with hashed phone
    /// Flow: E.164 format → SHA256 hash → Base64 encode → send via Tealium
    func conversionWithHashedPhone() {
        let phoneNumber = "+15555551234"
        let hash = SHA256.hash(data: Data(phoneNumber.utf8))
        let base64String = Data(hash).base64EncodedString()
        
        teal?.track("conversion_measurement", data: [
            "hashed_phone": base64String
        ])
        
        print("📱 Hashed Phone Conversion")
        print("   Phone: \(phoneNumber)")
        print("   Base64: \(base64String)")
    }
    
    // MARK: - Email Normalization Helper
    
    /// Normalizes email according to Firebase documentation
    /// https://firebase.google.com/docs/tutorials/ads-ios-on-device-measurement/step-3
    ///
    /// Rules: lowercase, @googlemail.com → @gmail.com, Gmail substitutions (I/i/1→l, 0→o, 2→z, 5→s)
    private func normalizeEmail(_ email: String) -> String {
        var normalized = email.lowercased()
        normalized = normalized.replacingOccurrences(of: "@googlemail.com", with: "@gmail.com")
        
        if normalized.hasSuffix("@gmail.com") {
            let components = normalized.split(separator: "@")
            guard components.count == 2 else { return normalized }
            
            var username = String(components[0])
            let domain = String(components[1])
            
            username = username.replacingOccurrences(of: ".", with: "")
            username = username
                .replacingOccurrences(of: "i", with: "l")
                .replacingOccurrences(of: "1", with: "l")
                .replacingOccurrences(of: "0", with: "o")
                .replacingOccurrences(of: "2", with: "z")
                .replacingOccurrences(of: "5", with: "s")
            
            normalized = "\(username)@\(domain)"
        }
        
        return normalized
    }
}
