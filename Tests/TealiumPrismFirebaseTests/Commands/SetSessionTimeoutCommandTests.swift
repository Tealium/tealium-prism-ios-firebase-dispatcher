//
//  SetSessionTimeoutCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class SetSessionTimeoutCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var mockLogger: MockLogger!
    var command: SetSessionTimeoutCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        command = SetSessionTimeoutCommand(firebaseInstance: mockFirebase, logger: mockLogger)
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
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing command data"))
    }
    
    func test_execute_without_timeout_parameter_returns_false() {
        let payload: DataObject = [
            "setsessiontimeout": [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing or invalid"))
    }
    
    // MARK: - Double Value Tests
    
    func test_execute_sets_timeout_from_double() {
        let payload: DataObject = [
            "setsessiontimeout": [
                "firebase_session_timeout_seconds": 1800.5
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }
    
    // MARK: - Int Value Tests
    
    func test_execute_sets_timeout_from_int() {
        let payload: DataObject = [
            "setsessiontimeout": [
                "firebase_session_timeout_seconds": 3600
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600.0)
    }
    
    // MARK: - String Value Tests
    
    func test_execute_sets_timeout_from_string() {
        let payload: DataObject = [
            "setsessiontimeout": [
                "firebase_session_timeout_seconds": "1800.5"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }
    
    func test_execute_returns_false_for_invalid_string() {
        let payload: DataObject = [
            "setsessiontimeout": [
                "firebase_session_timeout_seconds": "invalid"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
    }
    
}
