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
    
    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = SetDefaultParametersCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests
    
    func test_execute_without_command_data_clears_parameters() {
        // Set some parameters first so we can verify they get cleared
        let payloadWithParams: DataObject = [
            FirebaseDestination.defaultParams.renderedPath: [
                "version": "1.0"
            ] as DataObject
        ]
        XCTAssertNoThrow(try command.execute(payload: payloadWithParams))
        XCTAssertNotNil(mockFirebase.lastDefaultParameters, "Sanity: params should be set before clear test")

        // Now clear by executing with payload that has no parameters
        let payload: DataObject = [:]
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
        XCTAssertNil(mockFirebase.lastDefaultParameters, "Empty payload should clear default parameters")
    }
    
    func test_execute_with_empty_firebase_params_sets_empty_parameters() {
        let payload: DataObject = [
            FirebaseDestination.defaultParams.renderedPath: [:] as DataObject
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
            FirebaseDestination.defaultParams.renderedPath: [
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
            FirebaseDestination.defaultParams.renderedPath: [
                "count": 42
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["count"] as? Int, 42)
    }
    
    func test_execute_sets_double_parameters() {
        let payload: DataObject = [
            FirebaseDestination.defaultParams.renderedPath: [
                "price": 99.99
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["price"] as? Double, 99.99)
    }
    
    // MARK: - Bool Parameter Tests
    
    func test_execute_sets_bool_parameters() {
        let payload: DataObject = [
            FirebaseDestination.defaultParams.renderedPath: [
                "is_premium": true,
                "opted_out": false
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["is_premium"] as? Bool, true)
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["opted_out"] as? Bool, false)
    }
    
    // MARK: - Array Parameter Tests
    
    func test_execute_sets_array_parameters() {
        let payload: DataObject = [
            FirebaseDestination.defaultParams.renderedPath: [
                "tags": ["sale", "featured", "new"] as [String],
                "counts": [1, 2, 3] as [Int]
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["tags"] as? [String], ["sale", "featured", "new"])
        XCTAssertEqual(mockFirebase.lastDefaultParameters?["counts"] as? [Int], [1, 2, 3])
    }
    
    // MARK: - Dictionary Parameter Tests
    
    func test_execute_sets_dictionary_parameters() {
        let payload: DataObject = [
            FirebaseDestination.defaultParams.renderedPath: [
                "metadata": [
                    "source": "app",
                    "campaign_id": 42
                ] as DataObject
            ] as DataObject
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        let nested = mockFirebase.lastDefaultParameters?["metadata"] as? [String: Any]
        XCTAssertNotNil(nested)
        XCTAssertEqual(nested?["source"] as? String, "app")
        XCTAssertEqual(nested?["campaign_id"] as? Int, 42)
    }
}
