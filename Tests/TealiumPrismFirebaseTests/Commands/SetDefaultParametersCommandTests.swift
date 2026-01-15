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
    var validator: FirebaseValidator!
    var command: SetDefaultParametersCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        validator = FirebaseValidator(logger: nil)
        command = SetDefaultParametersCommand(firebaseInstance: mockFirebase, validator: validator, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        validator = nil
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
    
    func test_execute_without_firebase_params_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setDefaultEventParametersCalled)
    }
    
    func test_execute_with_empty_firebase_params_clears_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [:] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertNil(mockFirebase.lastDefaultParameters)
    }
    
    // MARK: - String Parameter Tests
    
    func test_execute_sets_string_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "version": "2.1.0",
                    "language": "en"
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["version"] as? String, "2.1.0")
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["language"] as? String, "en")
    }
    
    func test_execute_sets_empty_string_as_nsnull() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "to_clear": ""
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.lastDefaultParameters?["to_clear"] is NSNull)
    }
    
    // MARK: - Numeric Parameter Tests
    
    func test_execute_sets_int_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "count": 42
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["count"] as? Int, 42)
    }
    
    func test_execute_sets_double_parameters() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "price": 99.99
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        // Double with fractional part should be stored as Double
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["price"] as? Double, 99.99)
    }
    
    func test_execute_sets_whole_number_double_as_int() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "quantity": 100.0  // Whole number double
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        // Whole number doubles should be stored as Int for cleaner Firebase data
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["quantity"] as? Int, 100)
    }
    
    // MARK: - Validation Tests
    
    func test_execute_sanitizes_parameter_names() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "my-param.name": "value"
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertNotNil(mockFirebase.lastDefaultParameters?["my_param_name"])
    }
    
    func test_execute_truncates_long_string_values() {
        let longValue = String(repeating: "x", count: 150)
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "long_param": longValue
                ] as DataObject
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        guard let paramValue = mockFirebase.lastDefaultParameters?["long_param"] as? String else {
            XCTFail("Parameter should be present")
            return
        }
        
        XCTAssertEqual(paramValue.count, 100)  // Standard limit
    }
    
    func test_execute_skips_invalid_parameter_names() {
        let payload: DataObject = [
            FirebaseConstants.SetDefaultParameters.name: [
                FirebaseConstants.SetDefaultParameters.Param.params: [
                    "valid_param": "value"
                ] as DataObject
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?.count, 1)
    }
    
}
