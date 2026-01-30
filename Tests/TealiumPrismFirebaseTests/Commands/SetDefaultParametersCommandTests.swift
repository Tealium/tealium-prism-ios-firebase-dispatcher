//
//  SetDefaultParametersCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class SetDefaultParametersCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var command: SetDefaultParametersCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = SetDefaultParametersCommand(firebaseInstance: mockFirebase)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_command_data_clears_parameters() {
        let payload: DataObject = [:]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertNil(mockFirebase.lastDefaultParameters)
    }
    
    func test_execute_with_empty_firebase_params_sets_empty_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [:] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        // Empty dictionary should set empty parameters, not nil (which would clear all)
        XCTAssertNotNil(mockFirebase.lastDefaultParameters)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?.count, 0)
    }
    
    // MARK: - String Parameter Tests
    
    func test_execute_sets_string_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [
                "version": "2.1.0",
                "language": "en"
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["version"] as? String, "2.1.0")
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["language"] as? String, "en")
    }
    
    // MARK: - Numeric Parameter Tests
    
    func test_execute_sets_int_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [
                "count": 42
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["count"] as? Int, 42)
    }
    
    func test_execute_sets_double_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [
                "price": 99.99
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["price"] as? Double, 99.99)
    }
    
    // MARK: - Nil vs Empty Dictionary Tests
    
    func test_nil_vs_empty_dictionary_behavior() {
        // Test 1: Missing key passes nil to Firebase (clears all parameters)
        let payloadWithoutKey: DataObject = [:]
        XCTAssertNoThrow(try command.execute(payload: payloadWithoutKey))
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertNil(mockFirebase.lastDefaultParameters, "Missing firebase_params key should pass nil to Firebase")
        
        // Reset mock
        mockFirebase.setDefaultEventParametersCalled = false
        mockFirebase.lastDefaultParameters = nil
        
        // Test 2: Empty dictionary passes empty dict to Firebase (does NOT clear)
        let payloadWithEmptyDict: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [:] as DataObject
        ]
        XCTAssertNoThrow(try command.execute(payload: payloadWithEmptyDict))
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertNotNil(mockFirebase.lastDefaultParameters, "Empty firebase_params dict should NOT pass nil to Firebase")
        XCTAssertEqual(mockFirebase.lastDefaultParameters?.count, 0, "Empty firebase_params dict should pass empty dict (not nil)")
    }
        
}
