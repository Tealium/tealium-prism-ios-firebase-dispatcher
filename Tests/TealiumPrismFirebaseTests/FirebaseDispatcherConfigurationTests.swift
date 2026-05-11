//
//  FirebaseDispatcherConfigurationTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 30/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import FirebaseCore
import XCTest

final class FirebaseDispatcherConfigurationTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_init_with_all_values() throws {
        let dataObject: DataObject = [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 3600,
            FirebaseDispatcherConfiguration.Keys.analyticsEnabled: false,
            FirebaseDispatcherConfiguration.Keys.logLevel: "debug"
        ]
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertEqual(config.sessionTimeoutSeconds, 3600)
        XCTAssertEqual(config.analyticsCollectionEnabled, false)
        XCTAssertEqual(config.logLevel, .debug)
    }
    
    func test_init_with_invalid_logLevel_returns_nil() throws {
        let dataObject: DataObject = [
            FirebaseDispatcherConfiguration.Keys.logLevel: "invalid_level"
        ]
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertNil(config.logLevel)
    }
    
    func test_init_with_partial_values() throws {
        let dataObject: DataObject = [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 1800
        ]
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertEqual(config.sessionTimeoutSeconds, 1800)
        XCTAssertNil(config.analyticsCollectionEnabled)
        XCTAssertNil(config.logLevel)
    }
    
    func test_init_with_empty_configuration() {
        let dataObject = DataObject()
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertNil(config.sessionTimeoutSeconds)
        XCTAssertNil(config.analyticsCollectionEnabled)
        XCTAssertNil(config.logLevel)
    }
    
    func test_init_sessionTimeout_numeric_conversion_from_int() throws {
        let dataObject: DataObject = [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: 1800
        ]
        
        let config = FirebaseDispatcherConfiguration(configuration: dataObject)
        
        XCTAssertEqual(config.sessionTimeoutSeconds, 1800.0)
    }
    
    func test_init_sessionTimeout_numeric_conversion_from_string() throws {
        let dataObject: DataObject = [
            FirebaseDispatcherConfiguration.Keys.sessionTimeout: "2400"
        ]

        let config = FirebaseDispatcherConfiguration(configuration: dataObject)

        XCTAssertEqual(config.sessionTimeoutSeconds, 2400.0)
    }

    func test_init_logLevel_is_case_insensitive() {
        let dataObject: DataObject = [
            FirebaseDispatcherConfiguration.Keys.logLevel: "WARNING"
        ]

        let config = FirebaseDispatcherConfiguration(configuration: dataObject)

        XCTAssertEqual(config.logLevel, .warning)
    }
}
