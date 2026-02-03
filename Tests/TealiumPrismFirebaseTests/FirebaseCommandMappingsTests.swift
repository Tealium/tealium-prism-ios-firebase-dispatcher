//
//  FirebaseCommandMappingsTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

/// Tests for all Firebase command mappings (LogEvent, SetUserId, SetUserProperty, etc.)
final class FirebaseCommandMappingsTests: FirebaseMappingsTestBase {
    
    // MARK: - InitiateConversionMeasurement Command Tests
    
    func test_initiateConversionMeasurement_with_email() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "email": "user@example.com"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseInitiateConversionMeasurementCommand(),
            .mapFirebaseConversionEmailAddress(sourceKey: "email")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.InitiateConversionMeasurement.name,
            FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress: "user@example.com"
        ])
    }
    
    func test_initiateConversionMeasurement_with_phone() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "phone": "+1234567890"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseInitiateConversionMeasurementCommand(),
            .mapFirebaseConversionPhoneNumber(sourceKey: "phone")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.InitiateConversionMeasurement.name,
            FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber: "+1234567890"
        ])
    }
    
    func test_initiateConversionMeasurement_with_hashed_email() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "hashed_email": "abc123hash"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseInitiateConversionMeasurementCommand(),
            .mapFirebaseConversionHashedEmailAddress(sourceKey: "hashed_email")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.InitiateConversionMeasurement.name,
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress: "abc123hash"
        ])
    }
    
    func test_initiateConversionMeasurement_with_hashed_phone() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "hashed_phone": "xyz789hash"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseInitiateConversionMeasurementCommand(),
            .mapFirebaseConversionHashedPhoneNumber(sourceKey: "hashed_phone")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.InitiateConversionMeasurement.name,
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber: "xyz789hash"
        ])
    }
    
    // MARK: - LogEvent Command Tests
    
    func test_logEvent_basic_mapping() {
        let dispatch = Dispatch(name: "screen_view", type: .event)
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName()
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.Param.eventName: "screen_view"
        ])
    }
    
    func test_logEvent_with_parameters() {
        let dispatch = Dispatch(name: "purchase", type: .event, data: [
            "total": 99.99,
            "currency": "USD"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "total", to: "value"),
            .mapFirebaseEventParameter(from: "currency", to: "currency")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.Param.eventName: "purchase",
            FirebaseConstants.LogEvent.Param.eventParams: [
                "value": 99.99,
                "currency": "USD"
            ] as DataObject
        ])
    }
    
    func test_logEvent_with_items() { 
        let dispatch = Dispatch(name: "view_item_list", type: .event, data: [
            "item_id": ["SKU001", "SKU002"] as [String],
            "item_name": ["Widget", "Gadget"] as [String]
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseItemParameter(from: "item_id", to: "item_id"),
            .mapFirebaseItemParameter(from: "item_name", to: "item_name")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.Param.eventName: "view_item_list",
            FirebaseConstants.LogEvent.Param.items: [
                "item_id": ["SKU001", "SKU002"] as [String],
                "item_name": ["Widget", "Gadget"] as [String]
            ] as DataObject
        ])
    }
    
    func test_logEvent_with_bulk_parameters_dictionary() {
        let dispatch = Dispatch(name: "custom_event", type: .event, data: [
            "event_params": [
                "screen_name": "Home",
                "user_type": "premium",
                "session_count": 5
            ] as DataObject
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseLogEventParameters(parametersKey: "event_params")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.Param.eventName: "custom_event",
            FirebaseConstants.LogEvent.Param.eventParams: [
                "screen_name": "Home",
                "user_type": "premium",
                "session_count": 5
            ] as DataObject
        ])
    }
    
    // MARK: - ResetData Command Tests
    
    func test_resetData_basic_mapping() {
        let dispatch = Dispatch(name: "delete_data", type: .event)
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseResetDataCommand()
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.ResetData.name
        ])
    }
    
    // MARK: - SetAnalyticsCollectionEnabled Command Tests
    
    func test_setAnalyticsCollectionEnabled_basic_mapping() {
        let dispatch = Dispatch(name: "toggle_analytics", type: .event, data: [
            "enabled": true
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetAnalyticsCollectionEnabledCommand(),
            .mapFirebaseSetAnalyticsCollectionEnabledValue(sourceKey: "enabled")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetAnalyticsCollectionEnabled.name,
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: true
        ])
    }
    
    // MARK: - SetConsent Command Tests
    
    func test_setConsent_all_consent_types() {
        let dispatch = Dispatch(name: "consent_update", type: .event, data: [
            "analytics": "granted",
            "ad": "denied",
            "ad_user": "granted",
            "ad_personalization": "denied"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetConsentCommand(),
            .mapFirebaseAnalyticsStorage(sourceKey: "analytics"),
            .mapFirebaseAdStorage(sourceKey: "ad"),
            .mapFirebaseAdUserData(sourceKey: "ad_user"),
            .mapFirebaseAdPersonalization(sourceKey: "ad_personalization")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetConsent.name,
            FirebaseConstants.SetConsent.Param.analyticsStorage: "granted",
            FirebaseConstants.SetConsent.Param.adStorage: "denied",
            FirebaseConstants.SetConsent.Param.adUserData: "granted",
            FirebaseConstants.SetConsent.Param.adPersonalization: "denied"
        ])
    }
    
    // MARK: - SetDefaultParameters Command Tests
    
    func test_setDefaultParameters_basic_mapping() {
        let dispatch = Dispatch(name: "set_defaults", type: .event, data: [
            "version": "2.0",
            "env": "prod"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetDefaultParametersCommand(),
            .mapFirebaseDefaultParameter(from: "version", to: "app_version"),
            .mapFirebaseDefaultParameter(from: "env", to: "environment")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetDefaultParameters.name,
            FirebaseConstants.SetDefaultParameters.Param.params: [
                "app_version": "2.0",
                "environment": "prod"
            ] as DataObject
        ])
    }
    
    func test_setDefaultParameters_with_bulk_parameters_dictionary() {
        let dispatch = Dispatch(name: "set_defaults", type: .event, data: [
            "default_params": [
                "app_version": "2.0",
                "environment": "production",
                "feature_flag_enabled": true
            ] as DataObject
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetDefaultParametersCommand(),
            .mapFirebaseDefaultParameters(paramsKey: "default_params")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetDefaultParameters.name,
            FirebaseConstants.SetDefaultParameters.Param.params: [
                "app_version": "2.0",
                "environment": "production",
                "feature_flag_enabled": true
            ] as DataObject
        ])
    }
    
    // MARK: - SetSessionTimeout Command Tests
    
    func test_setSessionTimeout_basic_mapping() {
        let dispatch = Dispatch(name: "update_timeout", type: .event, data: [
            "timeout": 3600
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetSessionTimeoutCommand(),
            .mapFirebaseSetSessionTimeoutValue(sourceKey: "timeout")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetSessionTimeout.name,
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: 3600
        ])
    }
    
    // MARK: - SetUserId Command Tests
    
    func test_setUserId_basic_mapping() {
        let dispatch = Dispatch(name: "login", type: .event, data: ["customer_id": "USER_123"])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetUserIdCommand(),
            .mapFirebaseUserId(userIdKey: "customer_id")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetUserId.name,
            FirebaseConstants.SetUserId.Param.userId: "USER_123"
        ])
    }
    
    // MARK: - SetUserProperty Command Tests (Multiple Properties)
    
    func test_setUserProperties_basic_mapping() {
        let dispatch = Dispatch(name: "bulk_props", type: .event, data: [
            "prop_names": ["tier", "level", "status"],
            "prop_values": ["premium", "expert", "active"]
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetUserPropertyCommand(),
            .mapFirebaseUserPropertyName(propertyNameKey: "prop_names"),
            .mapFirebaseUserPropertyValue(propertyValueKey: "prop_values")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetUserProperty.name,
            FirebaseConstants.SetUserProperty.Param.propertyName: ["tier", "level", "status"],
            FirebaseConstants.SetUserProperty.Param.propertyValue: ["premium", "expert", "active"]
        ])
    }
    
    // MARK: - SetUserProperty Command Tests
    
    func test_setUserProperty_basic_mapping() {
        let dispatch = Dispatch(name: "set_tier", type: .event, data: [
            "prop_name": "membership_tier",
            "prop_value": "premium"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetUserPropertyCommand(),
            .mapFirebaseUserPropertyName(propertyNameKey: "prop_name"),
            .mapFirebaseUserPropertyValue(propertyValueKey: "prop_value")
        ])
        
        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseConstants.SetUserProperty.name,
            FirebaseConstants.SetUserProperty.Param.propertyName: "membership_tier",
            FirebaseConstants.SetUserProperty.Param.propertyValue: "premium"
        ])
    }
}
