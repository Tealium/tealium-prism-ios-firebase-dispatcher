//
//  SetUserPropertiesCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class SetUserPropertiesCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var validator: FirebaseValidator!
    var mockLogger: MockLogger!
    var command: SetUserPropertiesCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        validator = FirebaseValidator(logger: mockLogger)
        command = SetUserPropertiesCommand(firebaseInstance: mockFirebase, validator: validator, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        validator = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_property_data_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setUserPropertyCalled)
    }
    
    func test_execute_without_property_names_returns_false() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_values": ["value1", "value2"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing or invalid property names"))
    }
    
    func test_execute_without_property_values_returns_false() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["prop1", "prop2"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing or invalid property values"))
    }
    
    func test_execute_with_empty_names_array_returns_false() {
        let emptyNamesArray: [String] = []
        let emptyValuesArray: [String] = []
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": emptyNamesArray,
                "firebase_property_values": emptyValuesArray
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Empty property names"))
    }
    
    func test_execute_with_mismatched_array_lengths_returns_false() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["prop1", "prop2", "prop3"],
                "firebase_property_values": ["value1", "value2"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "matching length"))
    }
    
    // MARK: - Single Property Tests
    
    func test_execute_sets_single_property() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["subscription_tier"],
                "firebase_property_values": ["premium"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 1)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].name, "subscription_tier")
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].value, "premium")
    }
    
    // MARK: - Multiple Properties Tests
    
    func test_execute_sets_multiple_properties() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["subscription_tier", "user_level", "account_type"],
                "firebase_property_values": ["premium", "expert", "business"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 3)
        
        // Note: Order may vary, so we check by name
        let propDict = Dictionary(uniqueKeysWithValues: mockFirebase.setUserPropertyCalls.map { ($0.name, $0.value) })
        XCTAssertEqual(propDict["subscription_tier"], "premium")
        XCTAssertEqual(propDict["user_level"], "expert")
        XCTAssertEqual(propDict["account_type"], "business")
    }
    
    // MARK: - Clear Property Tests
    
    func test_execute_clears_property_with_empty_value() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["to_clear"],
                "firebase_property_values": [""]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].value, nil)
        XCTAssertTrue(mockLogger.hasLog(level: .debug, containing: "Removing user property"))
    }
    
    // MARK: - Validation Tests
    
    func test_execute_sanitizes_property_names() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["my-prop.name"],
                "firebase_property_values": ["value"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].name, "my_prop_name")
    }
    
    func test_execute_truncates_long_property_values() {
        let longValue = String(repeating: "x", count: 50)
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["prop"],
                "firebase_property_values": [longValue]
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].value?.count, 36)  // User property max length
    }
    
    func test_execute_skips_invalid_property_names() {
        let payload: DataObject = [
            "setuserproperties": [
                "firebase_property_names": ["valid_prop", "user_id"],  // user_id is reserved
                "firebase_property_values": ["value1", "value2"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        
        // Only the valid property should be set
        let validCalls = mockFirebase.setUserPropertyCalls.filter { $0.name == "valid_prop" }
        XCTAssertEqual(validCalls.count, 1)
        
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Invalid user property name 'user_id'"))
    }
    
}
