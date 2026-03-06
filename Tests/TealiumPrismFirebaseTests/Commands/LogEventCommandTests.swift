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
            guard let commandError = error as? FirebaseCommandError,
                  case .missingParameter = commandError else {
                XCTFail("Expected missingParameter error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.logEventCalled)
    }

    // MARK: - Simple Event Tests

    func test_execute_logs_simple_event() {
        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "test_event"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.logEventCalled)
        XCTAssertEqual(mockFirebase.lastEventName, "test_event")
        XCTAssertNil(mockFirebase.lastEventParameters)
    }

    func test_execute_maps_event_name() {
        // "event_purchase" should map to Firebase's AnalyticsEventPurchase ("purchase")
        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "event_purchase"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastEventName, "purchase")
    }

    // MARK: - Event with Parameters Tests

    func test_execute_logs_event_with_string_parameter() {
        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "test_event",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.currency.value: "USD"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertEqual(mockFirebase.lastEventParameters?[AnalyticsParameterCurrency] as? String, "USD")
    }

    func test_execute_logs_event_with_numeric_parameters() {
        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "purchase",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.value.value: 99.99,
                FirebaseEventParameter.quantity.value: 2
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertEqual(mockFirebase.lastEventParameters?[AnalyticsParameterValue] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.lastEventParameters?[AnalyticsParameterQuantity] as? Int, 2)
    }

    func test_execute_logs_event_with_boolean_parameter() {
        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "test_event",
            FirebaseDestination.eventParams.renderedPath: [
                "custom_is_first_time": true
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.lastEventParameters)
        XCTAssertEqual(mockFirebase.lastEventParameters?["custom_is_first_time"] as? Bool, true)
    }

    // MARK: - Items (E-commerce) Tests

    func test_execute_logs_event_with_items() {
        // Create items data as DataObject with parallel arrays.
        // Arrays need to be [DataInput] type for extractArrays() to work.
        let itemsObject: DataObject = [
            FirebaseItemParameter.itemId.value: ["SKU001", "SKU002"],
            FirebaseItemParameter.itemName.value: ["Widget", "Gadget"],
            FirebaseItemParameter.price.value: [29.99, 70.00]
        ]

        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "purchase",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.value.value: 99.99,
                FirebaseEventParameter.currency.value: "USD",
                FirebaseEventParameter.items.value: itemsObject
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.lastEventParameters)

        guard let items = mockFirebase.lastEventParameters?[AnalyticsParameterItems] as? [[String: Any]] else {
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
        XCTAssertEqual(mockFirebase.lastEventParameters?[AnalyticsParameterValue] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.lastEventParameters?[AnalyticsParameterCurrency] as? String, "USD")
    }

    func test_execute_logs_event_with_items_mixed_types() {
        // Test items with mixed value types (String, Int, Double)
        let itemsObject: DataObject = [
            FirebaseItemParameter.itemId.value: ["SKU001", "SKU002"],
            FirebaseItemParameter.quantity.value: [1, 3],
            FirebaseItemParameter.price.value: [29.99, 70.00],
            FirebaseItemParameter.discount.value: [5.0, 0.0]
        ]

        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "add_to_cart",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.items.value: itemsObject
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))

        guard let items = mockFirebase.lastEventParameters?[AnalyticsParameterItems] as? [[String: Any]] else {
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
            FirebaseItemParameter.itemId.value: ["SKU001", "SKU002", "SKU003"],
            FirebaseItemParameter.itemName.value: ["Widget", "Gadget"]  // Shorter array
        ]

        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "purchase",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.items.value: itemsObject
            ] as DataObject
        ]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .arrayLengthMismatch(_, let count1, _, let count2) = commandError else {
                XCTFail("Expected arrayLengthMismatch error but got \(error)")
                return
            }
            // Verify we got the mismatch details
            XCTAssertNotEqual(count1, count2)
        }

        // Event should not be logged
        XCTAssertFalse(mockFirebase.logEventCalled)
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
            FirebaseDestination.eventName.renderedPath: "purchase",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.value.value: 99.99,
                FirebaseEventParameter.currency.value: "USD",
                FirebaseEventParameter.items.value: itemsArray as [DataObject]
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertNotNil(mockFirebase.lastEventParameters)

        guard let items = mockFirebase.lastEventParameters?[AnalyticsParameterItems] as? [[String: Any]] else {
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
        XCTAssertEqual(mockFirebase.lastEventParameters?[AnalyticsParameterValue] as? Double, 99.99)
        XCTAssertEqual(mockFirebase.lastEventParameters?[AnalyticsParameterCurrency] as? String, "USD")
    }

    func test_execute_logs_event_with_items_array_of_objects_using_tealium_naming() {
        // Test array of objects with Tealium naming convention (param_items_*)
        let itemsArray: [DataObject] = [
            [
                FirebaseItemParameter.itemId.value: "SKU001",
                FirebaseItemParameter.itemName.value: "Widget",
                FirebaseItemParameter.price.value: 29.99
            ],
            [
                FirebaseItemParameter.itemId.value: "SKU002",
                FirebaseItemParameter.itemName.value: "Gadget",
                FirebaseItemParameter.price.value: 70.00
            ]
        ]

        let payload: DataObject = [
            FirebaseDestination.eventName.renderedPath: "purchase",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.items.value: itemsArray as [DataObject]
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))

        guard let items = mockFirebase.lastEventParameters?[AnalyticsParameterItems] as? [[String: Any]] else {
            XCTFail("Items should be present")
            return
        }

        XCTAssertEqual(items.count, 2)

        // Verify names were mapped to Firebase convention
        XCTAssertEqual(items[0][AnalyticsParameterItemID] as? String, "SKU001")
        XCTAssertEqual(items[0][AnalyticsParameterItemName] as? String, "Widget")
        XCTAssertEqual(items[0][AnalyticsParameterPrice] as? Double, 29.99)
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
            FirebaseDestination.eventName.renderedPath: "view_cart",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.items.value: itemsArray as [DataObject]
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))

        guard let items = mockFirebase.lastEventParameters?[AnalyticsParameterItems] as? [[String: Any]] else {
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
