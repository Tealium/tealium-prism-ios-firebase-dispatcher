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
        command = LogEventCommand(firebaseInstance: mockFirebase)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_event_name_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError else {
                XCTFail("Expected FirebaseCommandError")
                return
            }
            if case .missingParameter = commandError {
                // Success
            } else {
                XCTFail("Expected missingParameter error")
            }
        }
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    // MARK: - Simple Event Tests
    
    func test_execute_logs_simple_event() {
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "test_event"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.logEventCalled)
        XCTAssertEqual(mockFirebase.lastEventName, "test_event")
        XCTAssertNil(mockFirebase.lastEventParameters)
    }
    
    func test_execute_maps_event_name() {
        // "event_purchase" should map to Firebase's AnalyticsEventPurchase ("purchase")
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "event_purchase"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
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
        
        XCTAssertNoThrow(try command.execute(payload: payload))
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
        
        XCTAssertNoThrow(try command.execute(payload: payload))
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
        
        XCTAssertNoThrow(try command.execute(payload: payload))
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
        
        XCTAssertNoThrow(try command.execute(payload: payload))
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
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        
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
    
    func test_execute_throws_error_with_mismatched_item_array_lengths() {
        // Test that mismatched array lengths throw an error
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
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError else {
                XCTFail("Expected FirebaseCommandError")
                return
            }
            if case .arrayLengthMismatch(let array1, let count1, let array2, let count2) = commandError {
                // Verify we got the mismatch details
                XCTAssertTrue(count1 == 3 || count1 == 2)
                XCTAssertTrue(count2 == 3 || count2 == 2)
                XCTAssertNotEqual(count1, count2)
            } else {
                XCTFail("Expected arrayLengthMismatch error")
            }
        }
        
        // Event should not be logged
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    // MARK: - Array of Objects Format Tests
    
    func test_execute_logs_event_with_items_as_array_of_objects() {
        // Test new format: array of objects (Firebase-ready format)
        let itemsArray: [DataObject] = [
            [
                "item_id": "SKU001",
                "item_name": "Widget",
                "price": 29.99
            ],
            [
                "item_id": "SKU002",
                "item_name": "Gadget",
                "price": 70.00
            ]
        ]
        
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "purchase",
            FirebaseConstants.LogEvent.Param.eventParams: [
                "param_value": 99.99,
                "param_currency": "USD",
                FirebaseConstants.LogEvent.Param.items: itemsArray as [DataObject]
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        
        // Verify items were passed through correctly
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
    
    func test_execute_logs_event_with_items_array_of_objects_using_tealium_naming() {
        // Test array of objects with Tealium naming convention (param_items_*)
        let itemsArray: [DataObject] = [
            [
                "param_items_item_id": "SKU001",
                "param_items_item_name": "Widget",
                "param_items_price": 29.99
            ],
            [
                "param_items_item_id": "SKU002",
                "param_items_item_name": "Gadget",
                "param_items_price": 70.00
            ]
        ]
        
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "purchase",
            FirebaseConstants.LogEvent.Param.eventParams: [
                FirebaseConstants.LogEvent.Param.items: itemsArray as [DataObject]
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        
        guard let items = mockFirebase.lastEventParameters?["items"] as? [[String: Any]] else {
            XCTFail("Items should be present")
            return
        }
        
        XCTAssertEqual(items.count, 2)
        
        // Verify names were mapped to Firebase convention
        XCTAssertEqual(items[0]["item_id"] as? String, "SKU001")
        XCTAssertEqual(items[0]["item_name"] as? String, "Widget")
        XCTAssertEqual(items[0]["price"] as? Double, 29.99)
    }
    
    func test_execute_logs_event_with_items_array_of_objects_mixed_types() {
        // Test array of objects with various types
        let itemsArray: [DataObject] = [
            [
                "item_id": "SKU001",
                "quantity": 1,
                "price": 29.99,
                "in_stock": true
            ],
            [
                "item_id": "SKU002",
                "quantity": 3,
                "price": 70.00,
                "in_stock": false
            ]
        ]
        
        let payload: DataObject = [
            FirebaseConstants.LogEvent.Param.eventName: "view_cart",
            FirebaseConstants.LogEvent.Param.eventParams: [
                FirebaseConstants.LogEvent.Param.items: itemsArray as [DataObject]
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        
        guard let items = mockFirebase.lastEventParameters?["items"] as? [[String: Any]] else {
            XCTFail("Items should be present")
            return
        }
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0]["item_id"] as? String, "SKU001")
        XCTAssertEqual(items[0]["quantity"] as? Int, 1)
        XCTAssertEqual(items[0]["price"] as? Double, 29.99)
        XCTAssertEqual(items[0]["in_stock"] as? Bool, true)
        
        XCTAssertEqual(items[1]["in_stock"] as? Bool, false)
    }
    
    
}
