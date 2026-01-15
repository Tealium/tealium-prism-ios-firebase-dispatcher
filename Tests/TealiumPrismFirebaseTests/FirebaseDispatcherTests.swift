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
    var mockLogger: MockLogger!
    var dispatcher: FirebaseDispatcher!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        dispatcher = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            validator: FirebaseValidator(logger: mockLogger),
            logger: mockLogger
        )
    }
    
    override func tearDown() {
        dispatcher = nil
        mockFirebase = nil
        mockLogger = nil
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
    
    func test_init_with_moduleId_convenience() {
        let convenienceDispatcher = FirebaseDispatcher(moduleId: "TestModule", logger: mockLogger)
        
        XCTAssertEqual(convenienceDispatcher.id, "TestModule")
    }
    
    // MARK: - Dispatch Tests - Single Command
    
    func test_dispatch_with_single_command_executes_command() {
        let dispatch = Dispatch(name: "test_event", data: [
            FirebaseConstants.commandKey: "logevent",
            "logevent": [
                "firebase_event_name": "test_event"
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
            FirebaseConstants.commandKey: "logevent",
            "logevent": [
                "firebase_event_name": "test_event"
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
            FirebaseConstants.commandKey: ["logevent", "setuserid"] as [String],
            "logevent": [
                "firebase_event_name": "test_event"
            ] as DataObject,
            "setuserid": [
                "firebase_user_id": "user123"
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
            FirebaseConstants.commandKey: "logevent",
            "logevent": [
                "firebase_event_name": "event_one"
            ] as DataObject
        ])
        
        let dispatch2 = Dispatch(name: "event2", data: [
            FirebaseConstants.commandKey: "logevent",
            "logevent": [
                "firebase_event_name": "event_two"
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
    
    func test_dispatch_without_command_key_logs_debug() {
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
        XCTAssertTrue(mockLogger.hasLog(level: .debug, containing: "No command"))
    }
    
    func test_dispatch_with_empty_command_array_logs_debug() {
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
        XCTAssertTrue(mockLogger.hasLog(level: .debug, containing: "Empty command array"))
    }
    
    func test_dispatch_with_unknown_command_logs_warning() {
        let dispatch = Dispatch(name: "unknown", data: [
            FirebaseConstants.commandKey: "unknowncommand"
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "unknowncommand"))
    }
    
    // MARK: - Dispatch Tests - Empty Dispatches
    
    func test_dispatch_with_empty_array_calls_completion_with_empty() {
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([]) { processedDispatches in
            XCTAssertTrue(processedDispatches.isEmpty)
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
    }
    
    // MARK: - Command Execution Tests
    
    func test_dispatch_executes_initialize_command() {
        let dispatch = Dispatch(name: "init", data: [
            FirebaseConstants.commandKey: "initialize",
            "initialize": [
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
    
    func test_dispatch_executes_setsessiontimeout_command() {
        let dispatch = Dispatch(name: "timeout", data: [
            FirebaseConstants.commandKey: "setsessiontimeout",
            "setsessiontimeout": [
                "firebase_session_timeout_seconds": 3600
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600)
    }
    
    func test_dispatch_executes_setanalyticscollectionenabled_command() {
        let dispatch = Dispatch(name: "analytics", data: [
            FirebaseConstants.commandKey: "setanalyticscollectionenabled",
            "setanalyticscollectionenabled": [
                "firebase_analytics_collection_enabled": false
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_dispatch_executes_setuserid_command() {
        let dispatch = Dispatch(name: "userid", data: [
            FirebaseConstants.commandKey: "setuserid",
            "setuserid": [
                "firebase_user_id": "user_12345"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.setUserIdCalled)
        XCTAssertEqual(mockFirebase.lastUserId, "user_12345")
    }
    
    func test_dispatch_executes_setuserproperty_command() {
        let dispatch = Dispatch(name: "property", data: [
            FirebaseConstants.commandKey: "setuserproperty",
            "setuserproperty": [
                "firebase_property_name": "membership",
                "firebase_property_value": "premium"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.lastUserPropertyName, "membership")
        XCTAssertEqual(mockFirebase.lastUserPropertyValue, "premium")
    }
    
    func test_dispatch_executes_setuserproperties_command() {
        let dispatch = Dispatch(name: "properties", data: [
            FirebaseConstants.commandKey: "setuserproperties",
            "setuserproperties": [
                "firebase_property_names": ["tier", "region"] as [String],
                "firebase_property_values": ["gold", "us-west"] as [String]
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.setUserPropertyCalled)
        XCTAssertEqual(mockFirebase.setUserPropertyCalls.count, 2)
    }
    
    func test_dispatch_executes_resetdata_command() {
        let dispatch = Dispatch(name: "reset", data: [
            FirebaseConstants.commandKey: "resetdata"
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.resetAnalyticsDataCalled)
    }
    
    func test_dispatch_executes_setdefaultparameters_command() {
        let dispatch = Dispatch(name: "defaults", data: [
            FirebaseConstants.commandKey: "setdefaultparameters",
            "setdefaultparameters": [
                "firebase_params": [
                    "app_version": "1.0.0",
                    "environment": "production"
                ] as DataObject
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.setDefaultEventParametersCalled)
    }
    
    // MARK: - Module Protocol Tests
    
    func test_updateConfiguration_returns_self() {
        let updated = dispatcher.updateConfiguration(["some": "config"])
        
        XCTAssertTrue(updated === dispatcher)
    }
    
    func test_shutdown_logs_debug_message() {
        dispatcher.shutdown()
        
        XCTAssertTrue(mockLogger.hasLog(level: .debug, containing: "shutdown"))
    }
    
    // MARK: - Logging Tests
    
    func test_dispatch_logs_processing_info() {
        let dispatch = Dispatch(name: "test", data: [
            FirebaseConstants.commandKey: "logevent",
            "logevent": [
                "firebase_event_name": "test"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockLogger.hasLog(level: .debug, containing: "Processing dispatch"))
    }
    
    func test_dispatch_logs_successful_command() {
        let dispatch = Dispatch(name: "test", data: [
            FirebaseConstants.commandKey: "logevent",
            "logevent": [
                "firebase_event_name": "test"
            ] as DataObject
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockLogger.hasLog(level: .debug, containing: "executed successfully"))
    }
}
