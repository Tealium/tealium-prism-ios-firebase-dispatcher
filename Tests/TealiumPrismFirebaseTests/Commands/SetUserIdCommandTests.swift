//
//  SetUserIdCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class SetUserIdCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var mockLogger: MockLogger!
    var command: SetUserIdCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        command = SetUserIdCommand(firebaseInstance: mockFirebase, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_user_id_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setUserIdCalled)
    }
    
    // MARK: - Set User ID Tests
    
    func test_execute_sets_user_id() {
        let payload: DataObject = [
            "setuserid": [
                "firebase_user_id": "user@example.com"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertEqual(mockFirebase.lastUserId, "user@example.com")
    }
    
    // MARK: - Clear User ID Tests
    
    func test_execute_clears_user_id_with_empty_string() {
        let payload: DataObject = [
            "setuserid": [
                "firebase_user_id": ""
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertNil(mockFirebase.lastUserId)
        XCTAssertTrue(mockLogger.hasLog(level: .debug, containing: "Clearing user ID"))
    }
    
    // MARK: - Validation Tests
    
    func test_execute_rejects_user_id_exceeding_256_characters() {
        let longUserId = String(repeating: "a", count: 300)
        let payload: DataObject = [
            "setuserid": [
                "firebase_user_id": longUserId
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setUserIdCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "exceeds 256 characters"))
    }
    
    func test_execute_accepts_user_id_at_256_characters() {
        let maxUserId = String(repeating: "a", count: 256)
        let payload: DataObject = [
            "setuserid": [
                "firebase_user_id": maxUserId
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertEqual(mockFirebase.lastUserId?.count, 256)
    }
    
}