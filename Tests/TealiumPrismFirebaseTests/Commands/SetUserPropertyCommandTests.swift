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
    
    var mockFirebase: MockFirebaseCommand!
    var command: SetUserPropertyCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = SetUserPropertyCommand(firebaseInstance: mockFirebase)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_property_data_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is FirebaseCommandError)
        }
        XCTAssertFalse(mockFirebase.setUserPropertyCalled)
    }
    
    func test_execute_without_property_name_throws_error() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is FirebaseCommandError)
        }
    }
    
    // MARK: - Single Property Tests
    
    func test_execute_sets_single_property() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: "tier",
            FirebaseConstants.SetUserProperty.Param.propertyValue: "premium"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "tier")
        XCTAssertEqual(mockFirebase.lastUserPropertyValue, "premium")
    }
    
    func test_execute_clears_property_without_value_or_empty_string() {
        // Empty string clears the property
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: "tier",
            FirebaseConstants.SetUserProperty.Param.propertyValue: ""
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "tier")
        XCTAssertNil(mockFirebase.lastUserPropertyValue)
    }
    
    // MARK: - Multiple Properties Tests (Array Format)
    
    func test_execute_with_empty_names_array_throws_error() {
        let emptyNamesArray: [String] = []
        let emptyValuesArray: [String] = []
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: emptyNamesArray,
            FirebaseConstants.SetUserProperty.Param.propertyValue: emptyValuesArray
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError else {
                XCTFail("Expected FirebaseCommandError")
                return
            }
            if case .emptyArray = commandError {
                // Success
            } else {
                XCTFail("Expected emptyArray error")
            }
        }
    }
    
    func test_execute_with_mismatched_array_lengths_throws_error() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: ["prop1", "prop2", "prop3"],
            FirebaseConstants.SetUserProperty.Param.propertyValue: ["value1", "value2"]
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError else {
                XCTFail("Expected FirebaseCommandError")
                return
            }
            if case .arrayLengthMismatch = commandError {
                // Success
            } else {
                XCTFail("Expected arrayLengthMismatch error")
            }
        }
    }
    
    func test_execute_sets_single_property_with_array_format() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: ["subscription_tier"],
            FirebaseConstants.SetUserProperty.Param.propertyValue: ["premium"]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 1)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].name, "subscription_tier")
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].value, "premium")
    }
    
    func test_execute_sets_multiple_properties() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: ["subscription_tier", "user_level", "account_type"],
            FirebaseConstants.SetUserProperty.Param.propertyValue: ["premium", "expert", "business"]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 3)
        
        // Note: Order may vary, so we check by name
        let propDict = Dictionary(uniqueKeysWithValues: mockFirebase.setUserPropertyCalls.map { ($0.name, $0.value) })
        XCTAssertEqual(propDict["subscription_tier"], "premium")
        XCTAssertEqual(propDict["user_level"], "expert")
        XCTAssertEqual(propDict["account_type"], "business")
    }
    
    func test_execute_clears_property_with_empty_value_in_array_format() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: ["to_clear"],
            FirebaseConstants.SetUserProperty.Param.propertyValue: [""]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].value, nil)
    }

    // MARK: - Nil in Arrays Tests

    func test_execute_with_nil_in_names_array_skips_that_pair() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: ["prop_a", nil, "prop_c"] as [String?],
            FirebaseConstants.SetUserProperty.Param.propertyValue: ["value_a", "value_b", "value_c"]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 2)
        let propDict = Dictionary(uniqueKeysWithValues: mockFirebase.setUserPropertyCalls.map { ($0.name, $0.value) })
        XCTAssertEqual(propDict["prop_a"], "value_a")
        XCTAssertEqual(propDict["prop_c"], "value_c")
    }

    func test_execute_with_nil_in_values_array_clears_that_property() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: ["prop_a", "prop_b", "prop_c"],
            FirebaseConstants.SetUserProperty.Param.propertyValue: ["value_a", nil, "value_c"] as [String?]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 3)
        
        // Verify each call individually
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].name, "prop_a")
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].value, "value_a")
        
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[1].name, "prop_b")
        XCTAssertNil(mockFirebase.setUserPropertyCalls[1].value)
        
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[2].name, "prop_c")
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[2].value, "value_c")
    }

    func test_execute_with_nil_in_both_arrays_at_same_index_skips_pair() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: ["prop_a", nil, "prop_c"] as [String?],
            FirebaseConstants.SetUserProperty.Param.propertyValue: ["value_a", nil, "value_c"] as [String?]
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 2)
        let propDict = Dictionary(uniqueKeysWithValues: mockFirebase.setUserPropertyCalls.map { ($0.name, $0.value) })
        XCTAssertEqual(propDict["prop_a"], "value_a")
        XCTAssertEqual(propDict["prop_c"], "value_c")
    }
}
