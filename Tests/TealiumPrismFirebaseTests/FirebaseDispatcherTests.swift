//
//  FirebaseDispatcherTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 15/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class FirebaseDispatcherTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var dispatcher: FirebaseDispatcher!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        dispatcher = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            validator: FirebaseValidator(logger: nil),
            logger: nil
        )
    }
    
    override func tearDown() {
        dispatcher = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_init_sets_default_id() {
        let defaultDispatcher = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            logger: nil
        )
        
        XCTAssertEqual(defaultDispatcher.id, FirebaseConstants.moduleType)
    }
    
    func test_init_sets_custom_id() {
        let customDispatcher = FirebaseDispatcher(
            id: "CustomFirebase",
            firebaseInstance: mockFirebase,
            logger: nil
        )
        
        XCTAssertEqual(customDispatcher.id, "CustomFirebase")
    }
    
    func test_init_sets_version() {
        XCTAssertEqual(dispatcher.version, FirebaseConstants.version)
    }
    
    // MARK: - Dispatch Tests - Single Command
    
    func test_dispatch_with_single_command_executes_command() {
        let dispatch = Dispatch(name: "test_event", data: [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.name: [
                FirebaseConstants.LogEvent.Param.eventName: "test_event"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { processedDispatches in
            XCTAssertEqual(processedDispatches.count, 1)
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.logEventCalled)
    }
    
    func test_dispatch_returns_disposed_disposable() {
        let dispatch = Dispatch(name: "test_event", data: [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.name: [
                FirebaseConstants.LogEvent.Param.eventName: "test_event"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        let disposable = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertNotNil(disposable)
    }
    
    // MARK: - Dispatch Tests - Multiple Commands
    
    func test_dispatch_with_command_array_executes_all_commands() {
        let dispatch = Dispatch(name: "multi_command", data: [
            FirebaseConstants.commandKey: [
                FirebaseConstants.LogEvent.name,
                FirebaseConstants.SetUserId.name
            ] as [String],
            FirebaseConstants.LogEvent.name: [
                FirebaseConstants.LogEvent.Param.eventName: "test_event"
            ] as DataObject,
            FirebaseConstants.SetUserId.name: [
                FirebaseConstants.SetUserId.Param.userId: "user123"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { processedDispatches in
            XCTAssertEqual(processedDispatches.count, 1)
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.logEventCalled)
        XCTAssertTrue(mockFirebase.setUserIdCalled)
    }
    
    func test_dispatch_with_multiple_dispatches_processes_all() {
        let dispatch1 = Dispatch(name: "event1", data: [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.name: [
                FirebaseConstants.LogEvent.Param.eventName: "event_one"
            ] as DataObject
        ])
        
        let dispatch2 = Dispatch(name: "event2", data: [
            FirebaseConstants.commandKey: FirebaseConstants.LogEvent.name,
            FirebaseConstants.LogEvent.name: [
                FirebaseConstants.LogEvent.Param.eventName: "event_two"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch1, dispatch2]) { processedDispatches in
            XCTAssertEqual(processedDispatches.count, 2)
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertEqual(mockFirebase.logEventCallCount, 2)
    }
    
    // MARK: - Dispatch Tests - Missing/Empty Command
    
    func test_dispatch_without_command_key_does_not_execute() {
        let dispatch = Dispatch(name: "no_command", data: [
            "some_key": "some_value"
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { processedDispatches in
            XCTAssertEqual(processedDispatches.count, 1)
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    func test_dispatch_with_empty_command_array_does_not_execute() {
        let dispatch = Dispatch(name: "empty_commands", data: [
            FirebaseConstants.commandKey: [] as [String]
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { processedDispatches in
            XCTAssertEqual(processedDispatches.count, 1)
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    func test_dispatch_with_unknown_command_does_not_execute() {
        let dispatch = Dispatch(name: "unknown", data: [
            FirebaseConstants.commandKey: "unknowncommand"
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    // MARK: - Command Execution Tests
    
    func test_dispatch_executes_initialize_command() {
        let dispatch = Dispatch(name: "init", data: [
            FirebaseConstants.commandKey: FirebaseConstants.Initialize.name,
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.sessionTimeout: 1800,
                FirebaseConstants.Initialize.Param.analyticsEnabled: true
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    // MARK: - Edge Cases
    
    func test_dispatch_with_mixed_valid_invalid_commands_executes_valid_only() {
        let dispatch = Dispatch(name: "mixed", data: [
            FirebaseConstants.commandKey: [
                "invalid_command",
                FirebaseConstants.LogEvent.name
            ] as [String],
            FirebaseConstants.LogEvent.name: [
                FirebaseConstants.LogEvent.Param.eventName: "test_event"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.logEventCalled)
    }
    
    func test_dispatch_with_command_as_number_does_not_crash() {
        let dispatch = Dispatch(name: "invalid_type", data: [
            FirebaseConstants.commandKey: 123  // Wrong type
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        // Should complete without crashing
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    // MARK: - Module Protocol Tests
    
    func test_updateConfiguration_returns_self() {
        let updated = dispatcher.updateConfiguration(["some": "config"])
        
        XCTAssertTrue(updated === dispatcher)
    }
    
    func test_shutdown_completes_without_error() {
        // Should not crash
        dispatcher.shutdown()
        
        // Verify dispatcher still exists and can handle calls after shutdown
        XCTAssertNotNil(dispatcher)
    }
}
