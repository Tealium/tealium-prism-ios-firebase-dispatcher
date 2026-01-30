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
        command = SetUserIdCommand(firebaseInstance: mockFirebase)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_user_id_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError else {
                XCTFail("Expected FirebaseCommandError")
                return
            }
            if case .missingParameter = commandError {
                // Success
            } else {
                XCTFail("Expected missingParameter error")
            }
        }
        XCTAssertFalse(mockFirebase.setUserIdCalled)
    }
    
    // MARK: - Set User ID Tests
    
    func test_execute_sets_user_id() {
        let payload: DataObject = [
            FirebaseConstants.SetUserId.Param.userId: "user@example.com"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertEqual(mockFirebase.lastUserId, "user@example.com")
    }
    
    // MARK: - Clear User ID Tests
    
    func test_execute_clears_user_id_with_empty_string() {
        let payload: DataObject = [
            FirebaseConstants.SetUserId.Param.userId: ""
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertNil(mockFirebase.lastUserId)
    }
    
}
