//
//  LogEventCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import FirebaseAnalytics
import XCTest

final class LogEventCommandTests: XCTestCase {

    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = LogEventCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests

    func test_execute_without_event_name_throws_error() {
        let payload: DataObject = [:]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                  case .missingParameter = commandError else {
                XCTFail("Expected missingParameter error but got \(error)")
                return
            }
        }
        XCTAssertTrue(mockFirebase.loggedEvents.isEmpty)
    }

    // MARK: - Simple Event Tests

    func test_execute_logs_simple_event() {
        let payload: DataObject = [
            "event_name": "test_event"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.loggedEvents.isEmpty)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.name, "test_event")
        XCTAssertNil(mockFirebase.loggedEvents.last?.parameters)
    }

    // MARK: - Event with Parameters Tests

    func test_execute_logs_event_with_string_parameter() {
        let payload: DataObject = [
            "event_name": "test_event",
            "parameters": [
                AnalyticsParameterCurrency: "USD"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.loggedEvents.last?.parameters)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterCurrency] as? String, "USD")
    }

    func test_execute_logs_event_with_numeric_parameters() {
        let payload: DataObject = [
            "event_name": "purchase",
            "parameters": [
                AnalyticsParameterValue: 99.99,
                AnalyticsParameterQuantity: 2
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.loggedEvents.last?.parameters)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterValue] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterQuantity] as? Int, 2)
    }

    func test_execute_logs_event_with_boolean_parameter() {
        let payload: DataObject = [
            "event_name": "test_event",
            "parameters": [
                "custom_is_first_time": true
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.loggedEvents.last?.parameters)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?["custom_is_first_time"] as? Bool, true)
    }

    // MARK: - Items (E-commerce) Tests

    func test_execute_logs_event_with_items() {
        // Create items data as DataObject with parallel arrays.
        // Arrays need to be [DataInput] type for extractArrays() to work.
        let itemsObject: DataObject = [
            AnalyticsParameterItemID: ["SKU001", "SKU002"],
            AnalyticsParameterItemName: ["Widget", "Gadget"],
            AnalyticsParameterPrice: [29.99, 70.00]
        ]

        let payload: DataObject = [
            "event_name": "purchase",
            "parameters": [
                AnalyticsParameterValue: 99.99,
                AnalyticsParameterCurrency: "USD",
                AnalyticsParameterItems: itemsObject
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.loggedEvents.last?.parameters)

        guard let items = mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterItems] as? [[String: Any]] else {
            XCTFail("Items should be present in parameters under 'items' key")
            return
        }

        XCTAssertEqual(items.count, 2)

        // Verify first item
        XCTAssertEqual(items[0][AnalyticsParameterItemID] as? String, "SKU001")
        XCTAssertEqual(items[0][AnalyticsParameterItemName] as? String, "Widget")
        XCTAssertEqual(items[0][AnalyticsParameterPrice] as? Double, 29.99)

        // Verify second item
        XCTAssertEqual(items[1][AnalyticsParameterItemID] as? String, "SKU002")
        XCTAssertEqual(items[1][AnalyticsParameterItemName] as? String, "Gadget")
        XCTAssertEqual(items[1][AnalyticsParameterPrice] as? Double, 70.00)

        // Verify other parameters are also present
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterValue] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterCurrency] as? String, "USD")
    }

    func test_execute_logs_event_with_items_mixed_types() {
        // Test items with mixed value types (String, Int, Double)
        let itemsObject: DataObject = [
            AnalyticsParameterItemID: ["SKU001", "SKU002"],
            AnalyticsParameterQuantity: [1, 3],
            AnalyticsParameterPrice: [29.99, 70.00],
            AnalyticsParameterDiscount: [5.0, 0.0]
        ]

        let payload: DataObject = [
            "event_name": "add_to_cart",
            "parameters": [
                AnalyticsParameterItems: itemsObject
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))

        guard let items = mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterItems] as? [[String: Any]] else {
            XCTFail("Items should be present under 'items' key")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0][AnalyticsParameterItemID] as? String, "SKU001")
        XCTAssertEqual(items[0][AnalyticsParameterQuantity] as? Int, 1)
        XCTAssertEqual(items[0][AnalyticsParameterPrice] as? Double, 29.99)
        XCTAssertEqual(items[0][AnalyticsParameterDiscount] as? Double, 5.0)
    }

    func test_execute_throws_error_with_mismatched_item_array_lengths() {
        // Test that mismatched array lengths throw an error
        let itemsObject: DataObject = [
            AnalyticsParameterItemID: ["SKU001", "SKU002", "SKU003"],
            AnalyticsParameterItemName: ["Widget", "Gadget"]  // Shorter array
        ]

        let payload: DataObject = [
            "event_name": "purchase",
            "parameters": [
                AnalyticsParameterItems: itemsObject
            ] as DataObject
        ]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                  case .arrayLengthMismatch(_, let count1, _, let count2) = commandError else {
                XCTFail("Expected arrayLengthMismatch error but got \(error)")
                return
            }
            // Verify we got the mismatch details
            XCTAssertNotEqual(count1, count2)
        }

        // Event should not be logged
        XCTAssertTrue(mockFirebase.loggedEvents.isEmpty)
    }

    // MARK: - Array of Objects Format Tests

    func test_execute_logs_event_with_items_as_array_of_objects() {
        // Test new format: array of objects (Firebase-ready format)
        let itemsArray: [DataObject] = [
            [
                AnalyticsParameterItemID: "SKU001",
                AnalyticsParameterItemName: "Widget",
                AnalyticsParameterPrice: 29.99
            ],
            [
                AnalyticsParameterItemID: "SKU002",
                AnalyticsParameterItemName: "Gadget",
                AnalyticsParameterPrice: 70.00
            ]
        ]

        let payload: DataObject = [
            "event_name": "purchase",
            "parameters": [
                AnalyticsParameterValue: 99.99,
                AnalyticsParameterCurrency: "USD",
                AnalyticsParameterItems: itemsArray as [DataObject]
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.loggedEvents.last?.parameters)

        guard let items = mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterItems] as? [[String: Any]] else {
            XCTFail("Items should be present in parameters under 'items' key")
            return
        }

        XCTAssertEqual(items.count, 2)

        // Verify first item
        XCTAssertEqual(items[0][AnalyticsParameterItemID] as? String, "SKU001")
        XCTAssertEqual(items[0][AnalyticsParameterItemName] as? String, "Widget")
        XCTAssertEqual(items[0][AnalyticsParameterPrice] as? Double, 29.99)

        // Verify second item
        XCTAssertEqual(items[1][AnalyticsParameterItemID] as? String, "SKU002")
        XCTAssertEqual(items[1][AnalyticsParameterItemName] as? String, "Gadget")
        XCTAssertEqual(items[1][AnalyticsParameterPrice] as? Double, 70.00)

        // Verify other parameters are also present
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterValue] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterCurrency] as? String, "USD")
    }

    // MARK: - Lenient Conversion Tests

    func test_execute_logs_event_with_numeric_event_name() {
        let payload: DataObject = [
            "event_name": 42
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.loggedEvents.isEmpty)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.name, "42")
    }

    func test_execute_logs_event_with_double_event_name() {
        let payload: DataObject = [
            "event_name": 3.14
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.loggedEvents.isEmpty)
        XCTAssertEqual(mockFirebase.loggedEvents.last?.name, "3.14")
    }

    func test_execute_logs_event_with_items_array_of_objects_mixed_types() {
        // Test array of objects with various types
        let itemsArray: [DataObject] = [
            [
                AnalyticsParameterItemID: "SKU001",
                AnalyticsParameterQuantity: 1,
                AnalyticsParameterPrice: 29.99,
                "custom_in_stock": true
            ],
            [
                AnalyticsParameterItemID: "SKU002",
                AnalyticsParameterQuantity: 3,
                AnalyticsParameterPrice: 70.00,
                "custom_in_stock": false
            ]
        ]

        let payload: DataObject = [
            "event_name": "view_cart",
            "parameters": [
                AnalyticsParameterItems: itemsArray as [DataObject]
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))

        guard let items = mockFirebase.loggedEvents.last?.parameters?[AnalyticsParameterItems] as? [[String: Any]] else {
            XCTFail("Items should be present")
            return
        }

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0][AnalyticsParameterItemID] as? String, "SKU001")
        XCTAssertEqual(items[0][AnalyticsParameterQuantity] as? Int, 1)
        XCTAssertEqual(items[0][AnalyticsParameterPrice] as? Double, 29.99)
        XCTAssertEqual(items[0]["custom_in_stock"] as? Bool, true)

        XCTAssertEqual(items[1]["custom_in_stock"] as? Bool, false)
    }


}
