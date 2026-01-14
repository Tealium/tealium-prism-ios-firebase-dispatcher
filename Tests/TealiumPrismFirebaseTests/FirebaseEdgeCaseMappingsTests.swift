//
//  FirebaseEdgeCaseMappingsTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

/// Tests for edge cases: missing data, empty collections, and error scenarios
final class FirebaseEdgeCaseMappingsTests: FirebaseMappingsTestBase {
    
    // MARK: - Missing Data Tests
    
    func test_logEvent_with_missing_parameters_key() {
        let dispatch = Dispatch(name: "test_event", type: .event, data: [:])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "missing_key", to: "param_name")
        ])
        
        // Should still map command and event name, but not the missing parameter
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": ["firebase_event_name": "test_event"] as DataObject
        ])
    }
    
    func test_setUserId_with_empty_string_clears_user_id() {
        let dispatch = Dispatch(name: "logout", type: .event, data: [
            "customer_id": ""
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetUserIdCommand(),
            .mapFirebaseUserId(userIdKey: "customer_id")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "setuserid",
            "setuserid": ["firebase_user_id": ""] as DataObject
        ])
    }
    
    func test_logEvent_items_with_missing_key() {
        let dispatch = Dispatch(name: "purchase", type: .event, data: [:])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseLogEventItems(itemsKey: "products")
        ])
        
        // Should map command and name, but not items
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": ["firebase_event_name": "purchase"] as DataObject
        ])
    }
    
    func test_setConsent_with_partial_consent_values() {
        let dispatch = Dispatch(name: "consent_update", type: .event, data: [
            "analytics": "granted"
            // Missing ad_storage, ad_user_data, ad_personalization
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetConsentCommand(),
            .mapFirebaseAnalyticsStorage(sourceKey: "analytics"),
            .mapFirebaseAdStorage(sourceKey: "ad"),
            .mapFirebaseAdUserData(sourceKey: "ad_user"),
            .mapFirebaseAdPersonalization(sourceKey: "ad_personalization")
        ])
        
        // Should only map the available values
        XCTAssertEqual(result.payload, [
            "command": "setconsent",
            "setconsent": [
                "analytics_storage": "granted"
            ] as DataObject
        ])
    }
    
    // MARK: - Empty Collection Tests
    
    func test_logEvent_with_empty_parameters_dictionary() {
        let dispatch = Dispatch(name: "test_event", type: .event, data: [
            "event_params": DataObject()
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseLogEventParameters(parametersKey: "event_params")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "test_event",
                "firebase_event_params": DataObject()
            ] as DataObject
        ])
    }
    
    func test_logEvent_with_empty_items_array() {
        let dispatch = Dispatch(name: "view_item_list", type: .event, data: [
            "products": [DataObject]()
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
                "param_items": [DataObject]()
            ] as DataObject
        ])
    }
    
    func test_setUserProperties_with_empty_arrays() {
        let dispatch = Dispatch(name: "bulk_props", type: .event, data: [
            "prop_names": [String](),
            "prop_values": [String]()
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseSetUserPropertiesCommand(),
            .mapFirebaseUserPropertyNames(propertyNamesKey: "prop_names"),
            .mapFirebaseUserPropertyValues(propertyValuesKey: "prop_values")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "setuserproperties",
            "setuserproperties": [
                "firebase_property_names": [String](),
                "firebase_property_values": [String]()
            ] as DataObject
        ])
    }
}
