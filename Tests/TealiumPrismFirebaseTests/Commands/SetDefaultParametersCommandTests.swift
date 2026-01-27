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
        command = SetDefaultParametersCommand(firebaseInstance: mockFirebase, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_command_data_clears_parameters() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertNil(mockFirebase.lastDefaultParameters)
    }
    
    func test_execute_with_empty_firebase_params_clears_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertNil(mockFirebase.lastDefaultParameters)
    }
    
    // MARK: - String Parameter Tests
    
    func test_execute_sets_string_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [
                "version": "2.1.0",
                "language": "en"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
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
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["count"] as? Int, 42)
    }
    
    func test_execute_sets_double_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.Param.params: [
                "price": 99.99
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["price"] as? Double, 99.99)
    }
        
}
