//
//  LogEventCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class LogEventCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var command: LogEventCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = LogEventCommand(firebaseInstance: mockFirebase, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_event_name_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    // MARK: - Simple Event Tests
    
    func test_execute_logs_simple_event() {
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "test_event"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.logEventCalled)
        XCTAssertEqual(mockFirebase.lastEventName, "test_event")
        XCTAssertNil(mockFirebase.lastEventParameters)
    }
    
    func test_execute_maps_event_name() {
        // "event_purchase" should map to Firebase's AnalyticsEventPurchase ("purchase")
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "event_purchase"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastEventName, "purchase")
    }
    
    // MARK: - Event with Parameters Tests
    
    func test_execute_logs_event_with_string_parameter() {
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "test_event",
            FirebaseConstants.LogEvent.Param.eventParams: [
                "param_currency": "USD"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertEqual(mockFirebase.lastEventParameters?["currency"] as? String, "USD")
    }
    
    func test_execute_logs_event_with_numeric_parameters() {
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "purchase",
            FirebaseConstants.LogEvent.Param.eventParams: [
                "param_value": 99.99,
                "param_quantity": 2
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertEqual(mockFirebase.lastEventParameters?["value"] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.lastEventParameters?["quantity"] as? Int, 2)
    }
    
    func test_execute_logs_event_with_boolean_parameter() {
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "test_event",
            FirebaseConstants.LogEvent.Param.eventParams: [
                "is_first_time": true
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertEqual(mockFirebase.lastEventParameters?["is_first_time"] as? Bool, true)
    }
    
    // MARK: - Items (E-commerce) Tests
    
    func test_execute_logs_event_with_items() {
        // Create items data as DataObject with parallel arrays
        // Arrays need to be [DataInput] type for extractArrays() to work
        let itemsObject: DataObject = [
            "param_items_item_id": ["SKU001", "SKU002"] as [String],
            "param_items_item_name": ["Widget", "Gadget"] as [String],
            "param_items_price": [29.99, 70.00] as [Double]
        ]
        
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "purchase",
            FirebaseConstants.LogEvent.Param.eventParams: [
                "param_value": 99.99,
                "param_currency": "USD",
                FirebaseConstants.LogEvent.Param.items: itemsObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        
        // Verify items were converted from parallel arrays to array of dictionaries
        // Note: items are under "items" key (AnalyticsParameterItems)
        guard let items = mockFirebase.lastEventParameters?["items"] as? [[String: Any]] else {
            XCTFail("Items should be present in parameters under 'items' key")
            return
        }
        
        XCTAssertEqual(items.count, 2)
        
        // Verify first item
        XCTAssertEqual(items[0]["item_id"] as? String, "SKU001")
        XCTAssertEqual(items[0]["item_name"] as? String, "Widget")
        XCTAssertEqual(items[0]["price"] as? Double, 29.99)
        
        // Verify second item
        XCTAssertEqual(items[1]["item_id"] as? String, "SKU002")
        XCTAssertEqual(items[1]["item_name"] as? String, "Gadget")
        XCTAssertEqual(items[1]["price"] as? Double, 70.00)
        
        // Verify other parameters are also present
        XCTAssertEqual(mockFirebase.lastEventParameters?["value"] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.lastEventParameters?["currency"] as? String, "USD")
    }
    
    func test_execute_logs_event_with_items_mixed_types() {
        // Test items with mixed value types (String, Int, Double)
        let itemsObject: DataObject = [
            "param_items_item_id": ["SKU001", "SKU002"] as [String],
            "param_items_quantity": [1, 3] as [Int],
            "param_items_price": [29.99, 70.00] as [Double],
            "param_items_discount": [5.0, 0.0] as [Double]
        ]
        
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "add_to_cart",
            FirebaseConstants.LogEvent.Param.eventParams: [
                FirebaseConstants.LogEvent.Param.items: itemsObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        
        guard let items = mockFirebase.lastEventParameters?["items"] as? [[String: Any]] else {
            XCTFail("Items should be present under 'items' key")
            return
        }
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0]["item_id"] as? String, "SKU001")
        XCTAssertEqual(items[0]["quantity"] as? Int, 1)
        XCTAssertEqual(items[0]["price"] as? Double, 29.99)
        XCTAssertEqual(items[0]["discount"] as? Double, 5.0)
    }
    
    func test_execute_logs_event_with_mismatched_item_array_lengths() {
        // Test handling of mismatched array lengths
        let itemsObject: DataObject = [
            "param_items_item_id": ["SKU001", "SKU002", "SKU003"] as [String],
            "param_items_item_name": ["Widget", "Gadget"] as [String]  // Shorter array
        ]
        
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "purchase",
            FirebaseConstants.LogEvent.Param.eventParams: [
                FirebaseConstants.LogEvent.Param.items: itemsObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        
        guard let items = mockFirebase.lastEventParameters?["items"] as? [[String: Any]] else {
            XCTFail("Items should be present under 'items' key")
            return
        }
        
        // Should create 3 items (max array length)
        XCTAssertEqual(items.count, 3)
        
        // First two items have both properties
        XCTAssertEqual(items[0]["item_id"] as? String, "SKU001")
        XCTAssertEqual(items[0]["item_name"] as? String, "Widget")
        
        // Third item only has item_id (item_name array was shorter)
        XCTAssertEqual(items[2]["item_id"] as? String, "SKU003")
        XCTAssertNil(items[2]["item_name"])
    }
    
    
}
