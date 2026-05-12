//
//  CommandRegistryTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest

@testable import TealiumPrismCore
@testable import TealiumPrismFirebase

final class CommandRegistryTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_with_single_command() {
        let command = MockCommand(name: "test")
        let registry = CommandRegistry(commands: [command])

        let payload: DataObject = [:]

        var error: CommandError?
        _ = registry.execute(commandName: "test", payload: payload) { error = $0 }

        XCTAssertNil(error)
        XCTAssertTrue(command.executeCalled)
    }

    func test_init_with_multiple_commands() {
        let command1 = MockCommand(name: "command1")
        let command2 = MockCommand(name: "command2")
        let command3 = MockCommand(name: "command3")
        let registry = CommandRegistry(commands: [command1, command2, command3])

        let payload: DataObject = [:]

        var errors: [CommandError?] = []
        _ = registry.execute(commandName: "command1", payload: payload) { errors.append($0) }
        _ = registry.execute(commandName: "command2", payload: payload) { errors.append($0) }
        _ = registry.execute(commandName: "command3", payload: payload) { errors.append($0) }

        XCTAssertTrue(errors.allSatisfy { $0 == nil })
        XCTAssertTrue(command1.executeCalled)
        XCTAssertTrue(command2.executeCalled)
        XCTAssertTrue(command3.executeCalled)
    }

    func test_init_last_command_wins_on_duplicate_name() {
        let originalCommand = MockCommand(name: "test")
        let newCommand = MockCommand(name: "test")
        let registry = CommandRegistry(commands: [originalCommand, newCommand])

        let payload: DataObject = [:]
        var error: CommandError?
        _ = registry.execute(commandName: "test", payload: payload) { error = $0 }

        XCTAssertNil(error)
        XCTAssertFalse(originalCommand.executeCalled)
        XCTAssertTrue(newCommand.executeCalled)
    }

    // MARK: - Execution Tests

    func test_execute_unknown_command_calls_completion_with_error() {
        let registry = CommandRegistry(commands: [])
        let payload: DataObject = [:]

        var receivedError: CommandError?
        _ = registry.execute(commandName: "unknown", payload: payload) { receivedError = $0 }

        guard case .commandNotFound(let name) = receivedError else {
            XCTFail("Expected commandNotFound but got \(String(describing: receivedError))")
            return
        }
        XCTAssertEqual(name, "unknown")
    }

    func test_execute_normalizes_command_name_to_lowercase() {
        let command = MockCommand(name: "test")
        let registry = CommandRegistry(commands: [command])

        let payload: DataObject = [:]

        var errors: [CommandError?] = []
        _ = registry.execute(commandName: "TEST", payload: payload) { errors.append($0) }
        _ = registry.execute(commandName: "Test", payload: payload) { errors.append($0) }
        _ = registry.execute(commandName: "TeSt", payload: payload) { errors.append($0) }

        XCTAssertTrue(errors.allSatisfy { $0 == nil })
    }

    func test_execute_trims_whitespace_from_command_name() {
        let command = MockCommand(name: "test")
        let registry = CommandRegistry(commands: [command])

        let payload: DataObject = [:]

        var errors: [CommandError?] = []
        _ = registry.execute(commandName: "  test  ", payload: payload) { errors.append($0) }
        _ = registry.execute(commandName: "\ttest\t", payload: payload) { errors.append($0) }

        XCTAssertTrue(errors.allSatisfy { $0 == nil })
    }

    func test_execute_passes_payload_to_command() {
        let command = MockCommand(name: "test")
        let registry = CommandRegistry(commands: [command])

        let payload: DataObject = ["key": "value", "number": 42]

        var error: CommandError?
        _ = registry.execute(commandName: "test", payload: payload) { error = $0 }

        XCTAssertNil(error)
        XCTAssertEqual(command.lastPayload, payload)
    }

    func test_execute_propagates_command_error() {
        let failureCommand = MockCommand(
            name: "failure", errorToThrow: .missingParameter("test_param"))
        let registry = CommandRegistry(commands: [failureCommand])

        let payload: DataObject = [:]

        var receivedError: CommandError?
        _ = registry.execute(commandName: "failure", payload: payload) { receivedError = $0 }

        XCTAssertNotNil(receivedError)
    }
}
