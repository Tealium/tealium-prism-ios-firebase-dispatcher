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
    var command: SetSessionTimeoutCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = SetSessionTimeoutCommand(firebaseInstance: mockFirebase, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_command_data_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
    }
    
    // MARK: - Double Value Tests
    
    func test_execute_sets_timeout_from_double() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: 1800.5
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }
    
    // MARK: - Int Value Tests
    
    func test_execute_sets_timeout_from_int() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: 3600
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600.0)
    }
    
    // MARK: - String Value Tests
    
    func test_execute_sets_timeout_from_string() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: "1800.5"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }
    
    func test_execute_returns_false_for_invalid_string() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: "invalid"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
    }
    
}
