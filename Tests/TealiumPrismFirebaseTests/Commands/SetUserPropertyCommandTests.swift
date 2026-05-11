//
//  SetUserPropertyCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class SetUserPropertyCommandTests: XCTestCase {
    
    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = SetUserPropertyCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests
    
    func test_execute_without_property_data_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is CommandError)
        }
        XCTAssertTrue(mockFirebase.userProperties.isEmpty)
    }
    
    func test_execute_without_property_name_throws_error() {
        let payload: DataObject = [
            "property_value": "value"
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is CommandError)
        }
    }
    
    // MARK: - Single Property Tests
    
    func test_execute_sets_single_property() {
        let payload: DataObject = [
            "property_name": "tier",
            "property_value": "premium"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.userProperties.isEmpty)
        XCTAssertEqual(mockFirebase.userProperties.last?.name, "tier")
        XCTAssertEqual(mockFirebase.userProperties.last?.value, "premium")
    }
    
    func test_execute_clears_property_without_value_or_empty_string() {
        // Empty string clears the property
        let payload: DataObject = [
            "property_name": "tier",
            "property_value": ""
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.userProperties.isEmpty)
        XCTAssertEqual(mockFirebase.userProperties.last?.name, "tier")
        XCTAssertNil(mockFirebase.userProperties.last?.value)
    }
    
    // MARK: - Multiple Properties Tests (Array Format)
    
    func test_execute_with_empty_names_array_throws_error() {
        let emptyNamesArray: [String] = []
        let emptyValuesArray: [String] = []
        let payload: DataObject = [
            "property_name": emptyNamesArray,
            "property_value": emptyValuesArray
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                  case .emptyArray = commandError else {
                XCTFail("Expected emptyArray error but got \(error)")
                return
            }
        }
    }
    
    func test_execute_with_mismatched_array_lengths_throws_error() {
        let payload: DataObject = [
            "property_name": ["prop1", "prop2", "prop3"],
            "property_value": ["value1", "value2"]
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                  case .arrayLengthMismatch = commandError else {
                XCTFail("Expected arrayLengthMismatch error but got \(error)")
                return
            }
        }
    }
    
    func test_execute_sets_single_property_with_array_format() {
        let payload: DataObject = [
            "property_name": ["subscription_tier"],
            "property_value": ["premium"]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.userProperties.isEmpty)
        XCTAssertEqual(mockFirebase.userProperties.count, 1)
        XCTAssertEqual(mockFirebase.userProperties[0].name, "subscription_tier")
        XCTAssertEqual(mockFirebase.userProperties[0].value, "premium")
    }
    
    func test_execute_sets_multiple_properties() {
        let payload: DataObject = [
            "property_name": ["subscription_tier", "user_level", "account_type"],
            "property_value": ["premium", "expert", "business"]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.userProperties.count, 3)
        
        // Note: Order may vary, so we check by name
        let propDict = Dictionary(uniqueKeysWithValues: mockFirebase.userProperties.map { ($0.name, $0.value) })
        XCTAssertEqual(propDict["subscription_tier"], "premium")
        XCTAssertEqual(propDict["user_level"], "expert")
        XCTAssertEqual(propDict["account_type"], "business")
    }
    
    func test_execute_clears_property_with_empty_value_in_array_format() {
        let payload: DataObject = [
            "property_name": ["to_clear"],
            "property_value": [""]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.userProperties[0].value, nil)
    }

    // MARK: - Nil in Arrays Tests

    func test_execute_with_nil_in_names_array_skips_that_pair() {
        let payload: DataObject = [
            "property_name": ["prop_a", nil, "prop_c"] as [String?],
            "property_value": ["value_a", "value_b", "value_c"]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.userProperties.count, 2)
        let propDict = Dictionary(uniqueKeysWithValues: mockFirebase.userProperties.map { ($0.name, $0.value) })
        XCTAssertEqual(propDict["prop_a"], "value_a")
        XCTAssertEqual(propDict["prop_c"], "value_c")
    }

    func test_execute_with_nil_in_values_array_clears_that_property() {
        let payload: DataObject = [
            "property_name": ["prop_a", "prop_b", "prop_c"],
            "property_value": ["value_a", nil, "value_c"] as [String?]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.userProperties.count, 3)
        
        // Verify each call individually
        XCTAssertEqual(mockFirebase.userProperties[0].name, "prop_a")
        XCTAssertEqual(mockFirebase.userProperties[0].value, "value_a")
        
        XCTAssertEqual(mockFirebase.userProperties[1].name, "prop_b")
        XCTAssertNil(mockFirebase.userProperties[1].value)
        
        XCTAssertEqual(mockFirebase.userProperties[2].name, "prop_c")
        XCTAssertEqual(mockFirebase.userProperties[2].value, "value_c")
    }

    func test_execute_with_nil_in_both_arrays_at_same_index_skips_pair() {
        let payload: DataObject = [
            "property_name": ["prop_a", nil, "prop_c"] as [String?],
            "property_value": ["value_a", nil, "value_c"] as [String?]
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.userProperties.count, 2)
        let propDict = Dictionary(uniqueKeysWithValues: mockFirebase.userProperties.map { ($0.name, $0.value) })
        XCTAssertEqual(propDict["prop_a"], "value_a")
        XCTAssertEqual(propDict["prop_c"], "value_c")
    }

    func test_execute_with_all_nil_names_throws_emptyArray() {
        let payload: DataObject = [
            "property_name": [nil, nil] as [String?],
            "property_value": ["value_a", "value_b"]
        ]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                  case .emptyArray = commandError else {
                XCTFail("Expected emptyArray error but got \(error)")
                return
            }
        }
        XCTAssertTrue(mockFirebase.userProperties.isEmpty)
    }

    // MARK: - Lenient Conversion Tests

    func test_execute_sets_property_with_numeric_name_and_value() {
        let payload: DataObject = [
            "property_name": 42,
            "property_value": 99
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.userProperties.isEmpty)
        XCTAssertEqual(mockFirebase.userProperties.last?.name, "42")
        XCTAssertEqual(mockFirebase.userProperties.last?.value, "99")
    }

    func test_execute_sets_property_with_double_value() {
        let payload: DataObject = [
            "property_name": "score",
            "property_value": 9.5
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(!mockFirebase.userProperties.isEmpty)
        XCTAssertEqual(mockFirebase.userProperties.last?.name, "score")
        XCTAssertEqual(mockFirebase.userProperties.last?.value, "9.5")
    }
}
