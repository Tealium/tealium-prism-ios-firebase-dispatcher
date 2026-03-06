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
    
    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = SetUserIdCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests
    
    func test_execute_without_user_id_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .missingParameter = commandError else {
                XCTFail("Expected missingParameter error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.setUserIdCalled)
    }
    
    // MARK: - Set User ID Tests
    
    func test_execute_sets_user_id() {
        let payload: DataObject = [
            FirebaseDestination.userId.renderedPath: "user@example.com"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertEqual(mockFirebase.lastUserId, "user@example.com")
    }
    
    // MARK: - Clear User ID Tests
    
    func test_execute_clears_user_id_with_empty_string() {
        let payload: DataObject = [
            FirebaseDestination.userId.renderedPath: ""
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertNil(mockFirebase.lastUserId)
    }
    
}
