//
//  FirebaseDispatcherConfigurationTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 30/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class FirebaseDispatcherConfigurationTests: XCTestCase {
    
    // MARK: - Keys Tests
    
    func test_keys_sessionTimeout() {
        XCTAssertEqual(FirebaseDispatcherConfiguration.Keys.sessionTimeout, "firebase_session_timeout_seconds")
    }
    
    func test_keys_analyticsEnabled() {
        XCTAssertEqual(FirebaseDispatcherConfiguration.Keys.analyticsEnabled, "firebase_analytics_collection_enabled")
    }
    
    func test_keys_logLevel() {
        XCTAssertEqual(FirebaseDispatcherConfiguration.Keys.logLevel, "firebase_log_level")
    }
    
    // MARK: - Initialization Tests
    
    func test_init_with_all_values() throws {
        let dataObject = try DataItem(serializing: [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 3600,
            FirebaseDispatcherConfiguration.Keys.analyticsEnabled: false,
            FirebaseDispatcherConfiguration.Keys.logLevel: "debug"
        ])
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertEqual(config.sessionTimeout, 3600)
        XCTAssertEqual(config.analyticsEnabled, false)
        XCTAssertEqual(config.logLevel, "debug")
    }
    
    func test_init_with_partial_values() throws {
        let dataObject = try DataItem(serializing: [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 1800
        ])
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertEqual(config.sessionTimeout, 1800)
        XCTAssertNil(config.analyticsEnabled)
        XCTAssertNil(config.logLevel)
    }
    
    func test_init_with_empty_configuration() {
        let dataObject = DataObject()
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertNil(config.sessionTimeout)
        XCTAssertNil(config.analyticsEnabled)
        XCTAssertNil(config.logLevel)
    }
    
    func test_init_sessionTimeout_numeric_conversion_from_int() throws {
        let dataObject = try DataItem(serializing: [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 1800
        ])
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertEqual(config.sessionTimeout, 1800.0)
    }
    
    func test_init_sessionTimeout_numeric_conversion_from_string() throws {
        let dataObject = try DataItem(serializing: [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: "2400"
        ])
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertEqual(config.sessionTimeout, 2400.0)
    }
    
    // MARK: - Defaults Tests
    
    func test_defaults_are_nil() {
        // Verify that defaults are nil to allow Firebase SDK defaults
        XCTAssertNil(FirebaseDispatcherConfiguration.Defaults.sessionTimeout)
        XCTAssertNil(FirebaseDispatcherConfiguration.Defaults.analyticsEnabled)
        XCTAssertNil(FirebaseDispatcherConfiguration.Defaults.logLevel)
    }
}
