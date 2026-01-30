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
    
    // MARK: - Set Property Tests
    
    func test_execute_sets_user_property() {
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
    
}
