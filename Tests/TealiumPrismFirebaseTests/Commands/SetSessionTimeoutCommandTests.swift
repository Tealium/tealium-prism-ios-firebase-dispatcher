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
    
    let mockFirebase = MockFirebaseCommand()
    lazy var command = SetSessionTimeoutCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests
    
    func test_execute_without_command_data_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is FirebaseCommandError)
        }
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
    }
    
    // MARK: - Double Value Tests
    
    func test_execute_sets_timeout_from_double() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: 1800.5
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }
    
    // MARK: - Int Value Tests
    
    func test_execute_sets_timeout_from_int() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: 3600
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600.0)
    }
    
    // MARK: - String Value Tests
    
    func test_execute_sets_timeout_from_string() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: "1800.5"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }
    
    func test_execute_throws_error_for_invalid_string() {
        let payload: DataObject = [
            FirebaseConstants.SetSessionTimeout.Param.sessionTimeout: "invalid"
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is FirebaseCommandError)
        }
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
    }
    
}
