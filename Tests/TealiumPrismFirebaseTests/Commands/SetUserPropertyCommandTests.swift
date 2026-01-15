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
    var validator: FirebaseValidator!
    var command: SetUserPropertyCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        validator = FirebaseValidator(logger: nil)
        command = SetUserPropertyCommand(firebaseInstance: mockFirebase, validator: validator, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        validator = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_property_data_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setUserPropertyCalled)
    }
    
    func test_execute_without_property_name_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Set Property Tests
    
    func test_execute_sets_user_property() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "tier",
                FirebaseConstants.SetUserProperty.Param.propertyValue: "premium"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "tier")
        XCTAssertEqual(mockFirebase.lastUserPropertyValue, "premium")
    }
    
    func test_execute_clears_property_without_value_or_empty_string() {
        // Empty string clears the property
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "tier",
                FirebaseConstants.SetUserProperty.Param.propertyValue: ""
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "tier")
        XCTAssertNil(mockFirebase.lastUserPropertyValue)
    }
    
    // MARK: - Validation Tests
    
    func test_execute_sanitizes_property_name() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "my-prop.name",
                FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "my_prop_name")
    }
    
    func test_execute_rejects_reserved_property_name() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "user_id",  // Reserved by Firebase
                FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setUserPropertyCalled)
    }
    
    func test_execute_truncates_long_property_value() {
        let longValue = String(repeating: "x", count: 50)
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "prop",
                FirebaseConstants.SetUserProperty.Param.propertyValue: longValue
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastUserPropertyValue?.count, 36)  // User property max length
    }
    
    func test_execute_truncates_long_property_name() {
        let longName = String(repeating: "a", count: 30)
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: longName,
                FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastUserPropertyName?.count, 24)  // User property name max length
    }
    
    func test_execute_removes_reserved_prefix_from_name() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "firebase_custom",
                FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "custom")
    }
    
    func test_execute_rejects_empty_property_name() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "",
                FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setUserPropertyCalled)
    }
    
    func test_execute_rejects_whitespace_only_property_name() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.name: [
                FirebaseConstants.SetUserProperty.Param.propertyName: "   ",
                FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setUserPropertyCalled)
    }
    
}
