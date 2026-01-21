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
    var command: SetUserPropertiesCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = SetUserPropertiesCommand(firebaseInstance: mockFirebase, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
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
            FirebaseConstants.SetUserProperties.name: [
                FirebaseConstants.SetUserProperties.Param.propertyValues: ["value1", "value2"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
    }
    
    func test_execute_without_property_values_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperties.name: [
                FirebaseConstants.SetUserProperties.Param.propertyNames: ["prop1", "prop2"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
    }
    
    func test_execute_with_empty_names_array_returns_false() {
        let emptyNamesArray: [String] = []
        let emptyValuesArray: [String] = []
        let payload: DataObject = [
            FirebaseConstants.SetUserProperties.name: [
                FirebaseConstants.SetUserProperties.Param.propertyNames: emptyNamesArray,
                FirebaseConstants.SetUserProperties.Param.propertyValues: emptyValuesArray
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
    }
    
    func test_execute_with_mismatched_array_lengths_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperties.name: [
                FirebaseConstants.SetUserProperties.Param.propertyNames: ["prop1", "prop2", "prop3"],
                FirebaseConstants.SetUserProperties.Param.propertyValues: ["value1", "value2"]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Single Property Tests
    
    func test_execute_sets_single_property() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperties.name: [
                FirebaseConstants.SetUserProperties.Param.propertyNames: ["subscription_tier"],
                FirebaseConstants.SetUserProperties.Param.propertyValues: ["premium"]
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
            FirebaseConstants.SetUserProperties.name: [
                FirebaseConstants.SetUserProperties.Param.propertyNames: ["subscription_tier", "user_level", "account_type"],
                FirebaseConstants.SetUserProperties.Param.propertyValues: ["premium", "expert", "business"]
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
            FirebaseConstants.SetUserProperties.name: [
                FirebaseConstants.SetUserProperties.Param.propertyNames: ["to_clear"],
                FirebaseConstants.SetUserProperties.Param.propertyValues: [""]
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls[0].value, nil)
    }
    
    
}
