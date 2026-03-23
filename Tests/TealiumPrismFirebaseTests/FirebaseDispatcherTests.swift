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
    
    let mockFirebase = MockFirebaseAnalytics()
    lazy var dispatcher = FirebaseDispatcher(
        firebaseInstance: mockFirebase,
        commandRegistry: CommandRegistry(commands: FirebaseDispatcher.makeCommands(firebaseInstance: mockFirebase)),
        configuration: FirebaseDispatcherConfiguration(configuration: [:]),
        logger: nil
    )

    // MARK: - Dispatch Tests - Single Command
    
    func test_dispatch_with_single_command_executes_command() {
        let dispatch = Dispatch(name: "test_event", data: [
            TealiumDataKey.commandName: FirebaseCommand.logEvent.rawValue,
            "event_name": "test_event"
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
            TealiumDataKey.commandName: FirebaseCommand.logEvent.rawValue,
            "event_name": "test_event"
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        let disposable = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(disposable.isDisposed)
    }
    
    // MARK: - Dispatch Tests - Multiple Commands
    
    func test_dispatch_with_command_array_executes_all_commands() {
        let dispatch = Dispatch(name: "multi_command", data: [
            TealiumDataKey.commandName: [
                FirebaseCommand.logEvent.rawValue,
                FirebaseCommand.setUserId.rawValue
            ],
            "event_name": "test_event",
            "user_id": "user123"
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
            TealiumDataKey.commandName: FirebaseCommand.logEvent.rawValue,
            "event_name": "event_one"
        ])
        
        let dispatch2 = Dispatch(name: "event2", data: [
            TealiumDataKey.commandName: FirebaseCommand.logEvent.rawValue,
            "event_name": "event_two"
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
            TealiumDataKey.commandName: [] as [String]
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
            TealiumDataKey.commandName: "unknowncommand"
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertFalse(mockFirebase.logEventCalled)
    }
    
    // MARK: - Edge Cases
    
    func test_dispatch_with_mixed_valid_invalid_commands_executes_valid_only() {
        let dispatch = Dispatch(name: "mixed", data: [
            TealiumDataKey.commandName: [
                "invalid_command",
                FirebaseCommand.logEvent.rawValue
            ],
            "event_name": "test_event"
        ])
        
        let completionCalled = expectation(description: "Completion called")
        
        _ = dispatcher.dispatch([dispatch]) { _ in
            completionCalled.fulfill()
        }
        
        waitForDefaultTimeout()
        XCTAssertTrue(mockFirebase.logEventCalled)
        XCTAssertEqual(mockFirebase.logEventCallCount, 1)
    }
    
    func test_dispatch_with_command_as_number_does_not_crash() {
        let dispatch = Dispatch(name: "invalid_type", data: [
            TealiumDataKey.commandName: 123  // Wrong type
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
    }
    
    // MARK: - Configuration Application Tests (Init)
    
    func test_init_applies_logLevel_from_configuration() {
        let mockFirebase = MockFirebaseAnalytics()
        let config: DataObject = [
            FirebaseDispatcherConfiguration.Keys.logLevel: "debug"
        ]
        
        _ = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            commandRegistry: CommandRegistry(commands: []),
            configuration: FirebaseDispatcherConfiguration(configuration: config),
            logger: nil
        )
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .debug)
    }
    
    func test_init_applies_sessionTimeout_from_configuration() {
        let mockFirebase = MockFirebaseAnalytics()
        let config: DataObject = [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 3600.0
        ]
        
        _ = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            commandRegistry: CommandRegistry(commands: []),
            configuration: FirebaseDispatcherConfiguration(configuration: config),
            logger: nil
        )
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600.0)
    }
    
    func test_init_applies_analyticsEnabled_from_configuration() {
        let mockFirebase = MockFirebaseAnalytics()
        let config: DataObject = [
            FirebaseDispatcherConfiguration.Keys.analyticsEnabled: false
        ]
        
        _ = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            commandRegistry: CommandRegistry(commands: []),
            configuration: FirebaseDispatcherConfiguration(configuration: config),
            logger: nil
        )
        
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_init_applies_all_configuration_settings() {
        let mockFirebase = MockFirebaseAnalytics()
        let config: DataObject = [
            FirebaseDispatcherConfiguration.Keys.logLevel: "warning",
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 1800.0,
            FirebaseDispatcherConfiguration.Keys.analyticsEnabled: true
        ]
        
        _ = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            commandRegistry: CommandRegistry(commands: []),
            configuration: FirebaseDispatcherConfiguration(configuration: config),
            logger: nil
        )
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .warning)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.0)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_init_with_empty_configuration_does_not_apply_settings() {
        let mockFirebase = MockFirebaseAnalytics()
        let config: DataObject = [:]
        
        _ = FirebaseDispatcher(
            firebaseInstance: mockFirebase,
            commandRegistry: CommandRegistry(commands: []),
            configuration: FirebaseDispatcherConfiguration(configuration: config),
            logger: nil
        )
        
        XCTAssertFalse(mockFirebase.setLoggerLevelCalled)
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertFalse(mockFirebase.setAnalyticsCollectionEnabledCalled)
    }
    
    // MARK: - Configuration Application Tests (Update)
    
    func test_updateConfiguration_applies_logLevel() {
        let newConfig: DataObject = [
            FirebaseDispatcherConfiguration.Keys.logLevel: "error"
        ]
        
        _ = dispatcher.updateConfiguration(newConfig)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .error)
    }
    
    func test_updateConfiguration_applies_sessionTimeout() {
        let newConfig: DataObject = [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 7200.0
        ]
        
        _ = dispatcher.updateConfiguration(newConfig)
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 7200.0)
    }
    
    func test_updateConfiguration_applies_analyticsEnabled() {
        let newConfig: DataObject = [
            FirebaseDispatcherConfiguration.Keys.analyticsEnabled: true
        ]
        
        _ = dispatcher.updateConfiguration(newConfig)
        
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_updateConfiguration_applies_all_settings() {
        let newConfig: DataObject = [
            FirebaseDispatcherConfiguration.Keys.logLevel: "info",
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 900.0,
            FirebaseDispatcherConfiguration.Keys.analyticsEnabled: false
        ]
        
        _ = dispatcher.updateConfiguration(newConfig)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .info)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 900.0)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
}
