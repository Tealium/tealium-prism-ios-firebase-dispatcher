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
    var validator: FirebaseValidator!
    var mockLogger: MockLogger!
    var command: LogEventCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        validator = FirebaseValidator(logger: mockLogger)
        command = LogEventCommand(firebaseInstance: mockFirebase, validator: validator, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        validator = nil
        mockLogger = nil
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
            "logevent": [
                "firebase_event_name": "test_event"
            ] as DataObject
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
            "logevent": [
                "firebase_event_name": "event_purchase"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastEventName, "purchase")
    }
    
    // MARK: - Event with Parameters Tests
    
    func test_execute_logs_event_with_string_parameter() {
        let payload: DataObject = [
            "logevent": [
                "firebase_event_name": "test_event",
                "firebase_event_params": [
                    "param_currency": "USD"
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertEqual(mockFirebase.lastEventParameters?["currency"] as? String, "USD")
    }
    
    func test_execute_logs_event_with_numeric_parameters() {
        let payload: DataObject = [
            "logevent": [
                "firebase_event_name": "purchase",
                "firebase_event_params": [
                    "param_value": 99.99,
                    "param_quantity": 2
                ] as DataObject
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
            "logevent": [
                "firebase_event_name": "test_event",
                "firebase_event_params": [
                    "is_first_time": true
                ] as DataObject
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
            "logevent": [
                "firebase_event_name": "purchase",
                "firebase_event_params": [
                    "param_value": 99.99,
                    "param_currency": "USD",
                    "param_items": itemsObject
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        
        // Verify items were converted from parallel arrays to array of dictionaries
        // Note: items are under "param_items" key, not "items"
        guard let items = mockFirebase.lastEventParameters?["param_items"] as? [[String: Any]] else {
            XCTFail("Items should be present in parameters under 'param_items' key")
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
            "logevent": [
                "firebase_event_name": "add_to_cart",
                "firebase_event_params": [
                    "param_items": itemsObject
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        
        guard let items = mockFirebase.lastEventParameters?["param_items"] as? [[String: Any]] else {
            XCTFail("Items should be present under 'param_items' key")
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
            "logevent": [
                "firebase_event_name": "purchase",
                "firebase_event_params": [
                    "param_items": itemsObject
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        
        guard let items = mockFirebase.lastEventParameters?["param_items"] as? [[String: Any]] else {
            XCTFail("Items should be present under 'param_items' key")
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
        
        // Should log a warning about mismatched lengths
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "mismatched lengths"))
    }
    
    // MARK: - Validation Tests
    
    func test_execute_with_reserved_event_name_returns_false() {
        let payload: DataObject = [
            "logevent": [
                "firebase_event_name": "session_start"  // Reserved by Firebase
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    func test_execute_sanitizes_event_name() {
        let payload: DataObject = [
            "logevent": [
                "firebase_event_name": "my-event.name"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastEventName, "my_event_name")
    }
    
    func test_execute_truncates_long_parameter_value() {
        let longValue = String(repeating: "x", count: 150)
        let payload: DataObject = [
            "logevent": [
                "firebase_event_name": "test_event",
                "firebase_event_params": [
                    "long_param": longValue
                ] as DataObject
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        guard let paramValue = mockFirebase.lastEventParameters?["long_param"] as? String else {
            XCTFail("Parameter should be present")
            return
        }
        
        XCTAssertEqual(paramValue.count, 100)  // Standard limit
    }
    
    // MARK: - Parameter Limit Tests
    
    func test_execute_enforces_parameter_limit() {
        // Build params dictionary with 30 parameters
        var paramsDict: [String: DataInputConvertible] = [:]
        for i in 1...30 {
            paramsDict["param_\(i)"] = "value_\(i)"
        }
        
        let payload: DataObject = [
            "logevent": [
                "firebase_event_name": "test_event",
                "firebase_event_params": DataObject(dictionary: paramsDict)
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertLessThanOrEqual(mockFirebase.lastEventParameters?.count ?? 0, 25)
    }
}
