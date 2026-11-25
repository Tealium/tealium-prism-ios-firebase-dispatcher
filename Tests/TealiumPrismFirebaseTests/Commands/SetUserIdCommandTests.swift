//
//  SetUserIdCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest

@testable import TealiumPrismCore
@testable import TealiumPrismFirebase

final class SetUserIdCommandTests: XCTestCase {

    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = SetUserIdCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests

    func test_execute_without_user_id_throws_missing() {
        let payload: DataObject = [:]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .missing(key: "user_id"))
        XCTAssertEqual(mockFirebase.setUserIdCount, 0)
    }

    func test_execute_with_null_user_id_throws_missing() {
        let payload: DataObject = [
            "user_id": DataItem.null
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .missing(key: "user_id"))
        XCTAssertEqual(mockFirebase.setUserIdCount, 0)
    }

    func test_execute_with_non_string_value_throws_type_mismatch() {
        let payload: DataObject = [
            "user_id": ["nested": "value"]
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .typeMismatch(key: "user_id", expectedType: "String")
        )
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
            "user_id": 12_345
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
