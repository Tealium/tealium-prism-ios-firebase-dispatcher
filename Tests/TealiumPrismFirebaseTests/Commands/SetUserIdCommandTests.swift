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
            guard let commandError = error as? CommandError,
                  case .missingParameter = commandError else {
                XCTFail("Expected missingParameter error but got \(error)")
                return
            }
        }
        XCTAssertEqual(mockFirebase.setUserIdCount, 0)
    }

    // MARK: - Set User ID Tests

    func test_execute_sets_user_id() {
        let payload: DataObject = [
            "user_id": "user@example.com"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserIdCount, 1)
        XCTAssertEqual(mockFirebase.lastUserId, "user@example.com")
    }
    
    // MARK: - Clear User ID Tests

    func test_execute_clears_user_id_with_empty_string() {
        let payload: DataObject = [
            "user_id": ""
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserIdCount, 1)
        XCTAssertNil(mockFirebase.lastUserId)
    }

    // MARK: - Lenient Conversion Tests

    func test_execute_sets_integer_user_id_as_string() {
        let payload: DataObject = [
            "user_id": 12345
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserIdCount, 1)
        XCTAssertEqual(mockFirebase.lastUserId, "12345")
    }

    func test_execute_sets_double_user_id_as_string() {
        let payload: DataObject = [
            "user_id": 123.0
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setUserIdCount, 1)
        XCTAssertEqual(mockFirebase.lastUserId, "123")
    }

}
