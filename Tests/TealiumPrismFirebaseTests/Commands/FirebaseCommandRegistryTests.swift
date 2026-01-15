//
//  FirebaseCommandRegistryTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class FirebaseCommandRegistryTests: XCTestCase {
    
    var registry: FirebaseCommandRegistry!
    
    override func setUp() {
        super.setUp()
        registry = FirebaseCommandRegistry()
    }
    
    override func tearDown() {
        registry = nil
        super.tearDown()
    }
    
    // MARK: - Registration Tests
    
    func test_register_single_command() {
        let command = MockCommand(name: "test")
        registry.register(command)
        
        let payload: DataObject = [:]
        let result = registry.execute(commandName: "test", payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(command.executeCalled)
    }
    
    func test_register_multiple_commands() {
        let command1 = MockCommand(name: "command1")
        let command2 = MockCommand(name: "command2")
        let command3 = MockCommand(name: "command3")
        
        registry.registerAll([command1, command2, command3])
        
        let payload: DataObject = [:]
        
        XCTAssertTrue(registry.execute(commandName: "command1", payload: payload))
        XCTAssertTrue(registry.execute(commandName: "command2", payload: payload))
        XCTAssertTrue(registry.execute(commandName: "command3", payload: payload))
        
        XCTAssertTrue(command1.executeCalled)
        XCTAssertTrue(command2.executeCalled)
        XCTAssertTrue(command3.executeCalled)
    }
    
    func test_register_overwrites_existing_command() {
        let originalCommand = MockCommand(name: "test")
        let newCommand = MockCommand(name: "test")
        
        registry.register(originalCommand)
        registry.register(newCommand)
        
        let payload: DataObject = [:]
        _ = registry.execute(commandName: "test", payload: payload)
        
        XCTAssertFalse(originalCommand.executeCalled)
        XCTAssertTrue(newCommand.executeCalled)
    }
    
    // MARK: - Execution Tests
    
    func test_execute_unknown_command_returns_false() {
        let payload: DataObject = [:]
        let result = registry.execute(commandName: "unknown", payload: payload)
        XCTAssertFalse(result)
    }
    
    func test_execute_normalizes_command_name_to_lowercase() {
        let command = MockCommand(name: "test")
        registry.register(command)
        
        let payload: DataObject = [:]
        
        XCTAssertTrue(registry.execute(commandName: "TEST", payload: payload))
        XCTAssertTrue(registry.execute(commandName: "Test", payload: payload))
        XCTAssertTrue(registry.execute(commandName: "TeSt", payload: payload))
    }
    
    func test_execute_trims_whitespace_from_command_name() {
        let command = MockCommand(name: "test")
        registry.register(command)
        
        let payload: DataObject = [:]
        
        XCTAssertTrue(registry.execute(commandName: "  test  ", payload: payload))
        XCTAssertTrue(registry.execute(commandName: "\ttest\t", payload: payload))
    }
    
    func test_execute_passes_payload_to_command() {
        let command = MockCommand(name: "test")
        registry.register(command)
        
        let payload: DataObject = ["key": "value", "number": 42]
        
        _ = registry.execute(commandName: "test", payload: payload)
        
        XCTAssertEqual(command.lastPayload, payload)
    }
    
    func test_execute_returns_command_result() {
        let successCommand = MockCommand(name: "success", returnValue: true)
        let failureCommand = MockCommand(name: "failure", returnValue: false)
        
        registry.register(successCommand)
        registry.register(failureCommand)
        
        let payload: DataObject = [:]
        
        XCTAssertTrue(registry.execute(commandName: "success", payload: payload))
        XCTAssertFalse(registry.execute(commandName: "failure", payload: payload))
    }
    
    func test_execute_empty_command_name_returns_false() {
        let command = MockCommand(name: "test")
        registry.register(command)
        
        let payload: DataObject = [:]
        
        XCTAssertFalse(registry.execute(commandName: "", payload: payload))
        XCTAssertFalse(registry.execute(commandName: "   ", payload: payload))
    }
}

