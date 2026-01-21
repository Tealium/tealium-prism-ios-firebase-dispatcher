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
    var command: SetUserIdCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = SetUserIdCommand(firebaseInstance: mockFirebase, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
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
            FirebaseConstants.SetUserId.name: [
                FirebaseConstants.SetUserId.Param.userId: "user@example.com"
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
            FirebaseConstants.SetUserId.name: [
                FirebaseConstants.SetUserId.Param.userId: ""
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertNil(mockFirebase.lastUserId)
    }
    
}