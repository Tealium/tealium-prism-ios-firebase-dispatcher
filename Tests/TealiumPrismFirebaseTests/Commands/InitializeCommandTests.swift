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
    
    func test_execute_with_empty_payload_returns_true_and_does_not_call_firebase() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        // Empty payload should not trigger any Firebase calls
        XCTAssertFalse(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertFalse(mockFirebase.setAnalyticsCollectionEnabledCalled)
    }
    
    // MARK: - Log Level Tests
    
    func test_execute_sets_log_level_min() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.logLevel: "min"
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .min)
    }
    
    func test_execute_sets_log_level_max() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.logLevel: "max"
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .max)
    }
    
    func test_execute_sets_log_level_debug() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.logLevel: "debug"
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .debug)
    }
    
    func test_execute_with_invalid_log_level_defaults_to_notice() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.logLevel: "invalid"
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setLoggerLevelCalled)
        XCTAssertEqual(mockFirebase.lastLoggerLevel, .notice)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Unknown log level"))
    }
    
    // MARK: - Session Timeout Tests
    
    func test_execute_sets_session_timeout_from_double() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.sessionTimeout: 1800.0
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 1800.0)
    }
    
    func test_execute_sets_session_timeout_from_int() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.sessionTimeout: 3600
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 3600.0)
    }
    
    func test_execute_sets_session_timeout_from_string() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.sessionTimeout: "7200"
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setSessionTimeoutIntervalCalled)
        XCTAssertEqual(mockFirebase.lastSessionTimeout, 7200.0)
    }
    
    // MARK: - Analytics Collection Tests
    
    func test_execute_enables_analytics_collection() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.analyticsEnabled: true
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.analyticsEnabled: false
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    // MARK: - Validator Configuration Tests
    
    func test_execute_sets_ga360_mode() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.ga360Mode: true
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertTrue(validator.isGA360ModeEnabled())
    }
    
    func test_execute_disables_ga360_mode() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.ga360Mode: false
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertFalse(validator.isGA360ModeEnabled())
    }
    
    func test_execute_sets_invalid_char_strategy_replace() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.invalidCharStrategy: "replace"
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertEqual(validator.getInvalidCharStrategy(), "replace")
    }
    
    func test_execute_sets_invalid_char_strategy_remove() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.invalidCharStrategy: "remove"
        ]
        
        _ = command.execute(payload: payload)
        
        XCTAssertEqual(validator.getInvalidCharStrategy(), "remove")
    }
    
    // MARK: - Full Configuration Tests
    
    func test_execute_configures_all_settings() {
        let payload: DataObject = [
            FirebaseConstants.Initialize.Param.logLevel: "debug",
            FirebaseConstants.Initialize.Param.sessionTimeout: 1800,
            FirebaseConstants.Initialize.Param.analyticsEnabled: true,
            FirebaseConstants.Initialize.Param.ga360Mode: true,
            FirebaseConstants.Initialize.Param.invalidCharStrategy: "remove"
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
