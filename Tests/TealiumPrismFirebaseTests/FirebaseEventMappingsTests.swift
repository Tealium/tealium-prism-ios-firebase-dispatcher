//
//  FirebaseEventMappingsTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

/// Tests for event-specific mappings (purchase, refund, level_up) and custom events
final class FirebaseEventMappingsTests: FirebaseMappingsTestBase {
    
    // MARK: - Standard Firebase Events Tests
    
    func test_purchase_event_with_standard_parameters() {
        let dispatch = Dispatch(name: "purchase", type: .event, data: [
            "order_total": 149.99,
            "order_currency": "USD",
            "order_id": "ORDER_12345",
            "product_tax": 10.50,
            "product_shipping": 5.00
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "purchase"),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "order_total", to: "value"),
            .mapFirebaseEventParameter(from: "order_currency", to: "currency"),
            .mapFirebaseEventParameter(from: "order_id", to: "transaction_id"),
            .mapFirebaseEventParameter(from: "product_tax", to: "tax"),
            .mapFirebaseEventParameter(from: "product_shipping", to: "shipping")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "purchase",
                "firebase_event_params": [
                    "value": 149.99,
                    "currency": "USD",
                    "transaction_id": "ORDER_12345",
                    "tax": 10.50,
                    "shipping": 5.00
                ] as DataObject
            ] as DataObject
        ])
    }
    
    func test_purchase_event_with_mix_of_standard_and_custom_parameters() {
        let dispatch = Dispatch(name: "purchase", type: .event, data: [
            "order_total": 99.99,
            "order_currency": "USD",
            "order_id": "ORD_456",
            // Custom parameters
            "customer_segment": "vip",
            "loyalty_points_earned": 500,
            "is_first_purchase": false
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            // Standard parameters
            .mapFirebaseEventParameter(from: "order_total", to: "value"),
            .mapFirebaseEventParameter(from: "order_currency", to: "currency"),
            .mapFirebaseEventParameter(from: "order_id", to: "transaction_id"),
            // Custom parameters
            .mapFirebaseEventParameter(from: "customer_segment", to: "customer_segment"),
            .mapFirebaseEventParameter(from: "loyalty_points_earned", to: "loyalty_points"),
            .mapFirebaseEventParameter(from: "is_first_purchase", to: "first_purchase")
        ])
        
        let logeventData = result.payload.getDataItem(key: "logevent")?.getDataDictionary()
        let eventParams = logeventData?.getDataItem(key: "firebase_event_params")?.getDataDictionary()
        
        XCTAssertEqual(result.payload.get(key: "command", as: String.self), "logevent")
        XCTAssertEqual(logeventData?.get(key: "firebase_event_name", as: String.self), "purchase")
        
        // Standard parameters
        XCTAssertEqual(eventParams?.get(key: "value", as: Double.self), 99.99)
        XCTAssertEqual(eventParams?.get(key: "currency", as: String.self), "USD")
        XCTAssertEqual(eventParams?.get(key: "transaction_id", as: String.self), "ORD_456")
        
        // Custom parameters
        XCTAssertEqual(eventParams?.get(key: "customer_segment", as: String.self), "vip")
        XCTAssertEqual(eventParams?.get(key: "loyalty_points", as: Int.self), 500)
        XCTAssertEqual(eventParams?.get(key: "first_purchase", as: Bool.self), false)
    }
    
    func test_purchase_event_with_items_array() {
        let dispatch = Dispatch(name: "purchase", type: .event, data: [
            "order_total": 199.98,
            "order_currency": "USD",
            "order_id": "ORDER_999",
            "products": [
                ["item_id": "SKU_A", "item_name": "Product A", "price": 99.99] as DataObject,
                ["item_id": "SKU_B", "item_name": "Product B", "price": 99.99] as DataObject
            ]
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "purchase"),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "order_total", to: "value"),
            .mapFirebaseEventParameter(from: "order_currency", to: "currency"),
            .mapFirebaseEventParameter(from: "order_id", to: "transaction_id"),
            .mapFirebaseLogEventItems(itemsKey: "products")
        ])
        
        // Verify the structure - items at logevent level, params in firebase_event_params
        XCTAssertEqual(result.payload.get(key: "command", as: String.self), "logevent")
        
        let logeventData = result.payload.getDataItem(key: "logevent")?.getDataDictionary()
        XCTAssertEqual(logeventData?.get(key: "firebase_event_name", as: String.self), "purchase")
        
        // Check event params
        let eventParams = logeventData?.getDataItem(key: "firebase_event_params")?.getDataDictionary()
        XCTAssertNotNil(eventParams)
        XCTAssertEqual(eventParams?.get(key: "value", as: Double.self), 199.98)
        XCTAssertEqual(eventParams?.get(key: "currency", as: String.self), "USD")
        XCTAssertEqual(eventParams?.get(key: "transaction_id", as: String.self), "ORDER_999")
        
        // Check items at logevent level (not in firebase_event_params)
        XCTAssertNotNil(logeventData?.getDataItem(key: "param_items"))
    }
    
    func test_refund_event_with_standard_parameters() {
        let dispatch = Dispatch(name: "refund", type: .event, data: [
            "refund_amount": 49.99,
            "refund_currency": "EUR",
            "refund_transaction_id": "REFUND_67890"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "refund"),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "refund_amount", to: "value"),
            .mapFirebaseEventParameter(from: "refund_currency", to: "currency"),
            .mapFirebaseEventParameter(from: "refund_transaction_id", to: "transaction_id")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "refund",
                "firebase_event_params": [
                    "value": 49.99,
                    "currency": "EUR",
                    "transaction_id": "REFUND_67890"
                ] as DataObject
            ] as DataObject
        ])
    }
    
    func test_level_up_event_with_standard_parameters() {
        let dispatch = Dispatch(name: "level_up", type: .event, data: [
            "player_level": 25,
            "player_character": "warrior"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "level_up"),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "player_level", to: "level"),
            .mapFirebaseEventParameter(from: "player_character", to: "character")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "level_up",
                "firebase_event_params": [
                    "level": 25,
                    "character": "warrior"
                ] as DataObject
            ] as DataObject
        ])
    }
    
    // MARK: - Custom Events Tests
    
    func test_custom_event_with_custom_parameters() {
        let dispatch = Dispatch(name: "user_engagement", type: .event, data: [
            "feature_name": "dark_mode",
            "engagement_score": 85,
            "is_premium_user": true
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "feature_name", to: "feature_name"),
            .mapFirebaseEventParameter(from: "engagement_score", to: "engagement_score"),
            .mapFirebaseEventParameter(from: "is_premium_user", to: "is_premium_user")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "user_engagement",
                "firebase_event_params": [
                    "feature_name": "dark_mode",
                    "engagement_score": 85,
                    "is_premium_user": true
                ] as DataObject
            ] as DataObject
        ])
    }
    
    func test_custom_event_with_conditional_mapping() {
        let dispatch = Dispatch(name: "app_interaction", type: .event, data: [
            "interaction_type": "swipe",
            "screen_name": "product_gallery"
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "app_interaction"),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "interaction_type", to: "interaction_type"),
            .mapFirebaseEventParameter(from: "screen_name", to: "screen_name")
        ])
        
        XCTAssertEqual(result.payload, [
            "command": "logevent",
            "logevent": [
                "firebase_event_name": "app_interaction",
                "firebase_event_params": [
                    "interaction_type": "swipe",
                    "screen_name": "product_gallery"
                ] as DataObject
            ] as DataObject
        ])
    }
    
    func test_multiple_custom_events_with_ifValueIn() {
        let mappings: [Mappings] = [
            // Custom Event 1: Feature Usage
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "feature_used"),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "feature_id", to: "feature_id"),
            .mapFirebaseEventParameter(from: "usage_duration", to: "duration_seconds"),
            
            // Custom Event 2: Content Interaction
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "content_interaction"),
            .mapFirebaseEventParameter(from: "content_id", to: "content_id"),
            .mapFirebaseEventParameter(from: "interaction_type", to: "interaction_type"),
            
            // Custom Event 3: Error Occurred
            .mapFirebaseLogEventCommand()
                .ifValueIn(TealiumDataKey.event, equals: "error_occurred"),
            .mapFirebaseEventParameter(from: "error_code", to: "error_code"),
            .mapFirebaseEventParameter(from: "error_message", to: "error_message")
        ]
        
        // Test Feature Usage
        let featureDispatch = Dispatch(name: "feature_used", type: .event, data: [
            "feature_id": "dark_mode",
            "usage_duration": 120
        ])
        
        let featureResult = map(dispatch: featureDispatch, mappings: mappings)
        XCTAssertEqual(featureResult.payload.get(key: "command", as: String.self), "logevent")
        XCTAssertEqual(
            featureResult.payload.getDataItem(key: "logevent")?
                .getDataDictionary()?.get(key: "firebase_event_name", as: String.self),
            "feature_used"
        )
        
        // Test Content Interaction
        let contentDispatch = Dispatch(name: "content_interaction", type: .event, data: [
            "content_id": "article_123",
            "interaction_type": "share"
        ])
        
        let contentResult = map(dispatch: contentDispatch, mappings: mappings)
        XCTAssertEqual(contentResult.payload.get(key: "command", as: String.self), "logevent")
        XCTAssertEqual(
            contentResult.payload.getDataItem(key: "logevent")?
                .getDataDictionary()?.get(key: "firebase_event_name", as: String.self),
            "content_interaction"
        )
        
        // Test Error Occurred
        let errorDispatch = Dispatch(name: "error_occurred", type: .event, data: [
            "error_code": "E404",
            "error_message": "Resource not found"
        ])
        
        let errorResult = map(dispatch: errorDispatch, mappings: mappings)
        XCTAssertEqual(errorResult.payload.get(key: "command", as: String.self), "logevent")
        XCTAssertEqual(
            errorResult.payload.getDataItem(key: "logevent")?
                .getDataDictionary()?.get(key: "firebase_event_name", as: String.self),
            "error_occurred"
        )
    }
    
    func test_custom_event_with_all_supported_parameter_types() {
        let dispatch = Dispatch(name: "data_type_test", type: .event, data: [
            "string_param": "test_string",
            "int_param": 42,
            "int64_param": Int64(9223372036854775807),
            "double_param": 3.14159,
            "float_param": Float(2.718),
            "bool_param": true,
            "nsnumber_param": NSNumber(value: 100)
        ])
        
        let result = map(dispatch: dispatch, mappings: [
            .mapFirebaseLogEventCommand(),
            .mapFirebaseLogEventName(),
            .mapFirebaseEventParameter(from: "string_param", to: "string_param"),
            .mapFirebaseEventParameter(from: "int_param", to: "int_param"),
            .mapFirebaseEventParameter(from: "int64_param", to: "int64_param"),
            .mapFirebaseEventParameter(from: "double_param", to: "double_param"),
            .mapFirebaseEventParameter(from: "float_param", to: "float_param"),
            .mapFirebaseEventParameter(from: "bool_param", to: "bool_param"),
            .mapFirebaseEventParameter(from: "nsnumber_param", to: "nsnumber_param")
        ])
        
        let eventParams = result.payload.getDataItem(key: "logevent")?
            .getDataDictionary()?.getDataItem(key: "firebase_event_params")?
            .getDataDictionary()
        
        XCTAssertEqual(eventParams?.get(key: "string_param", as: String.self), "test_string")
        XCTAssertEqual(eventParams?.get(key: "int_param", as: Int.self), 42)
        XCTAssertEqual(eventParams?.get(key: "int64_param", as: Int64.self), Int64(9223372036854775807))
        XCTAssertEqual(eventParams?.get(key: "double_param", as: Double.self), 3.14159)
        XCTAssertEqual(eventParams?.get(key: "float_param", as: Float.self), Float(2.718))
        XCTAssertEqual(eventParams?.get(key: "bool_param", as: Bool.self), true)
        XCTAssertNotNil(eventParams?.get(key: "nsnumber_param", as: NSNumber.self))
    }
}
