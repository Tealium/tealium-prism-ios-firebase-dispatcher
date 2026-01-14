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
    
    // MARK: - Initialize Command Tests
    
    func test_initialize_basic_mapping() {
        let dispatch = Dispatch(name: "init", type: .event)
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseInitializeCommand()
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "initialize"
        ])
    }
    
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
            "command": "initiateconversionmeasurement",
            "initiateconversionmeasurement": [
                "param_email_address": "user@example.com"
            ] as DataObject
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
            "command": "initiateconversionmeasurement",
            "initiateconversionmeasurement": [
                "param_phone_number": "+1234567890"
            ] as DataObject
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
            "command": "initiateconversionmeasurement",
            "initiateconversionmeasurement": [
                "param_hashed_email_address": "abc123hash"
            ] as DataObject
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
            "command": "initiateconversionmeasurement",
            "initiateconversionmeasurement": [
                "param_hashed_phone_number": "xyz789hash"
            ] as DataObject
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
            "command": "logevent",
            "logevent": ["firebase_event_name": "screen_view"] as DataObject
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
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "purchase",
                "firebase_event_params": [
                    "value": 99.99,
                    "currency": "USD"
                ] as DataObject
            ] as DataObject
        ])
    }
    
    func test_logEvent_with_items() {
        let dispatch = Dispatch(name: "view_item_list", type: .event, data: [
            "products": [
                ["item_id": "SKU001", "item_name": "Widget"] as DataObject,
                ["item_id": "SKU002", "item_name": "Gadget"] as DataObject
            ]
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseLogEventItems(itemsKey: "products")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "view_item_list",
                "param_items": [
                    ["item_id": "SKU001", "item_name": "Widget"] as DataObject,
                    ["item_id": "SKU002", "item_name": "Gadget"] as DataObject
                ]
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
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "custom_event",
                "firebase_event_params": [
                    "screen_name": "Home",
                    "user_type": "premium",
                    "session_count": 5
                ] as DataObject
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
            "command": "resetdata"
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
            "command": "setanalyticscollectionenabled",
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": true
            ] as DataObject
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
            "command": "setconsent",
            "setconsent": [
                "analytics_storage": "granted",
                "ad_storage": "denied",
                "ad_user_data": "granted",
                "ad_personalization": "denied"
            ] as DataObject
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
            "command": "setdefaultparameters",
            "setdefaultparameters": [
                "firebase_params": [
                    "app_version": "2.0",
                    "environment": "prod"
                ] as DataObject
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
            "command": "setdefaultparameters",
            "setdefaultparameters": [
                "firebase_params": [
                    "app_version": "2.0",
                    "environment": "production",
                    "feature_flag_enabled": true
                ] as DataObject
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
            "command": "setsessiontimeout",
            "setsessiontimeout": [
                "firebase_session_timeout_seconds": 3600
            ] as DataObject
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
            "command": "setuserid",
            "setuserid": ["firebase_user_id": "USER_123"] as DataObject
        ])
    }
    
    // MARK: - SetUserProperties Command Tests
    
    func test_setUserProperties_basic_mapping() {
        let dispatch = Dispatch(name: "bulk_props", type: .event, data: [
            "prop_names": ["tier", "level", "status"],
            "prop_values": ["premium", "expert", "active"]
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetUserPropertiesCommand(),
            .mapFirebaseUserPropertyNames(propertyNamesKey: "prop_names"),
            .mapFirebaseUserPropertyValues(propertyValuesKey: "prop_values")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "setuserproperties",
            "setuserproperties": [
                "firebase_property_names": ["tier", "level", "status"],
                "firebase_property_values": ["premium", "expert", "active"]
            ] as DataObject
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
            "command": "setuserproperty",
            "setuserproperty": [
                "firebase_property_name": "membership_tier",
                "firebase_property_value": "premium"
            ] as DataObject
        ])
    }
}
