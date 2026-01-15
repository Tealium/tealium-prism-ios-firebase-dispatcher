//
//  InitializeCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import FirebaseCore
import XCTest

final class InitializeCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var validator: FirebaseValidator!
    var mockLogger: MockLogger!
    var command: InitializeCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        validator = FirebaseValidator(logger: mockLogger)
        command = InitializeCommand(firebaseInstance: mockFirebase, validator: validator, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        validator = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_with_empty_payload_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing command data"))
    }
    
    func test_execute_with_missing_initialize_container_returns_false() {
        let payload: DataObject = [
            "some_other_key": "value"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing command data"))
    }
    
    func test_execute_with_empty_initialize_container_returns_true() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        // Empty container should not trigger any Firebase calls
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertFalse(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertFalse(mockFirebase.setLoggerLevelCalled)
    }
    
    // MARK: - Log Level Tests
    
    func test_execute_sets_log_level_min() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.logLevel: "min"
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .min)
    }
    
    func test_execute_sets_log_level_max() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.logLevel: "max"
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .max)
    }
    
    func test_execute_sets_log_level_debug() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.logLevel: "debug"
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .debug)
    }
    
    func test_execute_with_invalid_log_level_defaults_to_notice() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.logLevel: "invalid"
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .notice)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Unknown log level"))
    }
    
    // MARK: - Session Timeout Tests
    
    func test_execute_sets_session_timeout_from_double() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.sessionTimeout: 1800.0
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.0)
    }
    
    func test_execute_sets_session_timeout_from_int() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.sessionTimeout: 3600
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600.0)
    }
    
    func test_execute_sets_session_timeout_from_string() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.sessionTimeout: "7200"
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 7200.0)
    }
    
    // MARK: - Analytics Collection Tests
    
    func test_execute_enables_analytics_collection() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.analyticsEnabled: true
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.analyticsEnabled: false
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    // MARK: - Validator Configuration Tests
    
    func test_execute_sets_ga360_mode() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.ga360Mode: true
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(validator.isGA360ModeEnabled())
    }
    
    func test_execute_disables_ga360_mode() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.ga360Mode: false
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertFalse(validator.isGA360ModeEnabled())
    }
    
    func test_execute_sets_invalid_char_strategy_replace() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.invalidCharStrategy: "replace"
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertEqual(validator.getInvalidCharStrategy(), "replace")
    }
    
    func test_execute_sets_invalid_char_strategy_remove() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.invalidCharStrategy: "remove"
            ] as DataObject
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertEqual(validator.getInvalidCharStrategy(), "remove")
    }
    
    // MARK: - Full Configuration Tests
    
    func test_execute_configures_all_settings() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.name: [
                FirebaseConstants.Initialize.Param.logLevel: "debug",
                FirebaseConstants.Initialize.Param.sessionTimeout: 1800,
                FirebaseConstants.Initialize.Param.analyticsEnabled: true,
                FirebaseConstants.Initialize.Param.ga360Mode: true,
                FirebaseConstants.Initialize.Param.invalidCharStrategy: "remove"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        // Check Firebase SDK calls
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .debug)
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.0)
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
        // Check validator configuration
        XCTAssertTrue(validator.isGA360ModeEnabled())
        XCTAssertEqual(validator.getInvalidCharStrategy(), "remove")
    }
}
