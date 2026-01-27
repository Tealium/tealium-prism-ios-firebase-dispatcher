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
        command = SetUserPropertyCommand(firebaseInstance: mockFirebase, logger: nil)
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
    
    func test_execute_without_property_name_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyValue: "value"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Set Property Tests
    
    func test_execute_sets_user_property() {
        let payload: DataObject = [
            FirebaseConstants.SetUserProperty.Param.propertyName: "tier",
            FirebaseConstants.SetUserProperty.Param.propertyValue: "premium"
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
            FirebaseConstants.SetUserProperty.Param.propertyName: "tier",
            FirebaseConstants.SetUserProperty.Param.propertyValue: ""
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "tier")
        XCTAssertNil(mockFirebase.lastUserPropertyValue)
    }
    
}
