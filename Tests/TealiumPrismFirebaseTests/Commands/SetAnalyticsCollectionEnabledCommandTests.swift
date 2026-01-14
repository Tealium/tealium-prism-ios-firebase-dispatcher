//
//  SetAnalyticsCollectionEnabledCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class SetAnalyticsCollectionEnabledCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var mockLogger: MockLogger!
    var command: SetAnalyticsCollectionEnabledCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        command = SetAnalyticsCollectionEnabledCommand(firebaseInstance: mockFirebase, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_command_data_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing command data"))
    }
    
    func test_execute_without_enabled_parameter_returns_false() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing or invalid"))
    }
    
    // MARK: - Boolean Value Tests
    
    func test_execute_enables_analytics_collection_with_true() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": true
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_false() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": false
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    // MARK: - String Value Tests
    
    func test_execute_enables_analytics_collection_with_string_true() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": "true"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_string_false() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": "false"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_execute_enables_analytics_collection_with_string_1() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": "1"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_string_0() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": "0"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_execute_handles_string_true_case_insensitive() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": "TRUE"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    // MARK: - Integer Value Tests
    
    func test_execute_enables_analytics_collection_with_int_1() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": 1
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_int_0() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": 0
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_execute_enables_analytics_collection_with_non_zero_int() {
        let payload: DataObject = [
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": 42
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
}
