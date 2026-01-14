//
//  SetConsentCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import FirebaseAnalytics
import XCTest

final class SetConsentCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var mockLogger: MockLogger!
    var command: SetConsentCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        command = SetConsentCommand(firebaseInstance: mockFirebase, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_consent_data_returns_false() {
        let payload: DataObject = [:]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }
    
    func test_execute_with_empty_consent_data_returns_false() {
        let payload: DataObject = [
            "setconsent": [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setConsentCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "No valid consent settings"))
    }
    
    // MARK: - Single Consent Type Tests
    
    func test_execute_sets_ad_storage_granted() {
        let payload: DataObject = [
            "setconsent": [
                "ad_storage": "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setConsentCalled)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
    
    func test_execute_sets_ad_storage_denied() {
        let payload: DataObject = [
            "setconsent": [
                "ad_storage": "denied"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .denied)
    }
    
    func test_execute_sets_analytics_storage_granted() {
        let payload: DataObject = [
            "setconsent": [
                "analytics_storage": "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.analyticsStorage], .granted)
    }
    
    func test_execute_sets_ad_user_data_granted() {
        let payload: DataObject = [
            "setconsent": [
                "ad_user_data": "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adUserData], .granted)
    }
    
    func test_execute_sets_ad_personalization_granted() {
        let payload: DataObject = [
            "setconsent": [
                "ad_personalization": "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adPersonalization], .granted)
    }
    
    // MARK: - Multiple Consent Types Tests
    
    func test_execute_sets_multiple_consent_types() {
        let payload: DataObject = [
            "setconsent": [
                "ad_storage": "granted",
                "analytics_storage": "granted",
                "ad_user_data": "denied",
                "ad_personalization": "denied"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setConsentCalled)
        
        let consentSettings = mockFirebase.lastConsentSettings!
        XCTAssertEqual(consentSettings.count, 4)
        XCTAssertEqual(consentSettings[.adStorage], .granted)
        XCTAssertEqual(consentSettings[.analyticsStorage], .granted)
        XCTAssertEqual(consentSettings[.adUserData], .denied)
        XCTAssertEqual(consentSettings[.adPersonalization], .denied)
    }
    
    // MARK: - Invalid Values Tests
    
    func test_execute_ignores_invalid_consent_type() {
        let payload: DataObject = [
            "setconsent": [
                "ad_storage": "granted",
                "invalid_type": "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Invalid consent type 'invalid_type'"))
    }
    
    func test_execute_ignores_invalid_consent_status() {
        let payload: DataObject = [
            "setconsent": [
                "ad_storage": "granted",
                "analytics_storage": "invalid_status"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Invalid consent status 'invalid_status'"))
    }
    
    func test_execute_returns_false_when_all_values_are_invalid() {
        let payload: DataObject = [
            "setconsent": [
                "invalid_type": "granted",
                "another_invalid": "denied"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }
    
    func test_execute_ignores_non_string_value() {
        let payload: DataObject = [
            "setconsent": [
                "ad_storage": 123
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setConsentCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Unexpected data type"))
    }
    
    // MARK: - Case Sensitivity Tests
    
    func test_execute_handles_case_insensitive_consent_status() {
        let payload: DataObject = [
            "setconsent": [
                "ad_storage": "GRANTED"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
}
