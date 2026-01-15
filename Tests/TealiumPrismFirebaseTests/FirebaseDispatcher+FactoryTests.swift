//
//  FirebaseDispatcher+FactoryTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 15/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class FirebaseDispatcherFactoryTests: XCTestCase {
    
    var factory: FirebaseDispatcher.Factory!
    
    override func setUp() {
        super.setUp()
        factory = FirebaseDispatcher.Factory()
    }
    
    override func tearDown() {
        factory = nil
        super.tearDown()
    }
    
    // MARK: - Factory Properties Tests
    
    func test_factory_static_moduleType_equals_constant() {
        XCTAssertEqual(FirebaseDispatcher.Factory.moduleType, FirebaseConstants.moduleType)
    }
    
    func test_factory_instance_moduleType_equals_constant() {
        XCTAssertEqual(factory.moduleType, FirebaseConstants.moduleType)
    }
    
    func test_factory_moduleType_is_FirebaseDispatcher() {
        XCTAssertEqual(factory.moduleType, "FirebaseDispatcher")
    }
    
    func test_factory_allowsMultipleInstances_is_false() {
        XCTAssertFalse(factory.allowsMultipleInstances)
    }
    
    // MARK: - Enforced Settings Tests
    
    func test_getEnforcedSettings_returns_empty_when_not_configured() {
        let settings = factory.getEnforcedSettings()
        
        XCTAssertTrue(settings.isEmpty)
    }
    
    func test_getEnforcedSettings_returns_settings_when_configured() {
        let enforcedSettings: DataObject = [
            "firebase_session_timeout_seconds": 1800,
            "firebase_analytics_collection_enabled": true
        ]
        let factoryWithSettings = FirebaseDispatcher.Factory(enforcedSettings: enforcedSettings)
        
        let settings = factoryWithSettings.getEnforcedSettings()
        
        XCTAssertEqual(settings.count, 1)
        XCTAssertEqual(settings.first, enforcedSettings)
    }
    
    func test_factory_init_with_nil_enforcedSettings() {
        let factoryWithNil = FirebaseDispatcher.Factory(enforcedSettings: nil)
        
        let settings = factoryWithNil.getEnforcedSettings()
        
        XCTAssertTrue(settings.isEmpty)
    }
    
    func test_getEnforcedSettings_returns_correct_settings_values() {
        let enforcedSettings: DataObject = [
            "custom_key": "custom_value",
            "number_key": 42
        ]
        let factoryWithSettings = FirebaseDispatcher.Factory(enforcedSettings: enforcedSettings)
        
        let settings = factoryWithSettings.getEnforcedSettings()
        
        XCTAssertEqual(settings.first?.get(key: "custom_key", as: String.self), "custom_value")
        XCTAssertEqual(settings.first?.get(key: "number_key", as: Int.self), 42)
    }
    
    // MARK: - Factory Initialization Tests
    
    func test_factory_default_init_has_no_enforced_settings() {
        let defaultFactory = FirebaseDispatcher.Factory()
        
        XCTAssertTrue(defaultFactory.getEnforcedSettings().isEmpty)
    }
    
    func test_factory_with_empty_enforcedSettings() {
        let emptySettings: DataObject = [:]
        let factoryWithEmpty = FirebaseDispatcher.Factory(enforcedSettings: emptySettings)
        
        let settings = factoryWithEmpty.getEnforcedSettings()
        
        XCTAssertEqual(settings.count, 1)
        XCTAssertEqual(settings.first, emptySettings)
    }
    
    func test_getEnforcedSettings_with_nested_configuration() {
        let enforcedSettings: DataObject = [
            "configuration": [
                "firebase_session_timeout_seconds": 3600,
                "firebase_log_level": "debug"
            ] as DataObject
        ]
        let factoryWithSettings = FirebaseDispatcher.Factory(enforcedSettings: enforcedSettings)
        
        let settings = factoryWithSettings.getEnforcedSettings()
        
        XCTAssertEqual(settings.count, 1)
        let configuration = settings.first?.getDataDictionary(key: "configuration")
        XCTAssertEqual(configuration?.get(key: "firebase_session_timeout_seconds", as: Int.self), 3600)
        XCTAssertEqual(configuration?.get(key: "firebase_log_level", as: String.self), "debug")
    }
    
    func test_changing_settings_after_factory_init_doesnt_affect_factory() {
        var enforcedSettings: DataObject = [
            "key": "original_value"
        ]
        let factoryWithSettings = FirebaseDispatcher.Factory(enforcedSettings: enforcedSettings)
        
        // Modify the settings after creating factory
        enforcedSettings = ["key": "modified_value"]
        
        let settings = factoryWithSettings.getEnforcedSettings()
        
        // Factory should still have original value (DataObject is value type)
        XCTAssertEqual(settings.first?.get(key: "key", as: String.self), "original_value")
    }
}
