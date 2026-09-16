//
//  SetSessionTimeoutCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismCore
@testable import TealiumPrismFirebase
import XCTest

final class SetSessionTimeoutCommandTests: XCTestCase {

    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = SetSessionTimeoutCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests

    func test_execute_without_command_data_throws_missing_parameter() {
        let payload: DataObject = [:]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                case .missingParameter = commandError
            else {
                XCTFail("Expected missingParameter error but got \(error)")
                return
            }
        }
        XCTAssertEqual(mockFirebase.setSessionTimeoutCount, 0)
    }

    // MARK: - Double Value Tests

    func test_execute_sets_timeout_from_double() {
        let payload: DataObject = [
            "session_timeout_seconds": 1800.5
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setSessionTimeoutCount, 1)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }

    // MARK: - Int Value Tests

    func test_execute_sets_timeout_from_int() {
        let payload: DataObject = [
            "session_timeout_seconds": 3600
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setSessionTimeoutCount, 1)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600.0)
    }

    // MARK: - String Value Tests

    func test_execute_sets_timeout_from_string() {
        let payload: DataObject = [
            "session_timeout_seconds": "1800.5"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setSessionTimeoutCount, 1)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.5)
    }

    func test_execute_throws_invalid_parameter_type_for_invalid_string() {
        let payload: DataObject = [
            "session_timeout_seconds": "invalid"
        ]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                case .invalidParameterType = commandError
            else {
                XCTFail("Expected invalidParameterType error but got \(error)")
                return
            }
        }
        XCTAssertEqual(mockFirebase.setSessionTimeoutCount, 0)
    }

}
