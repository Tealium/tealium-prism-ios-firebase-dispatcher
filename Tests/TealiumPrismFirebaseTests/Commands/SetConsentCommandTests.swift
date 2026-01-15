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
    var command: SetConsentCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = SetConsentCommand(firebaseInstance: mockFirebase, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
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
            FirebaseConstants.SetConsent.name: [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }
    
    // MARK: - Single Consent Type Tests
    
    func test_execute_sets_ad_storage_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adStorage: "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.setConsentCalled)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
    
    func test_execute_sets_ad_storage_denied() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adStorage: "denied"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .denied)
    }
    
    func test_execute_sets_analytics_storage_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.analyticsStorage: "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.analyticsStorage], .granted)
    }
    
    func test_execute_sets_ad_user_data_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adUserData: "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adUserData], .granted)
    }
    
    func test_execute_sets_ad_personalization_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adPersonalization: "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adPersonalization], .granted)
    }
    
    // MARK: - Multiple Consent Types Tests
    
    func test_execute_sets_multiple_consent_types() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adStorage: "granted",
                FirebaseConstants.SetConsent.Param.analyticsStorage: "granted",
                FirebaseConstants.SetConsent.Param.adUserData: "denied",
                FirebaseConstants.SetConsent.Param.adPersonalization: "denied"
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
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adStorage: "granted",
                "invalid_type": "granted"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
    }
    
    func test_execute_ignores_invalid_consent_status() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adStorage: "granted",
                FirebaseConstants.SetConsent.Param.analyticsStorage: "invalid_status"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
    }
    
    func test_execute_returns_false_when_all_values_are_invalid() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
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
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adStorage: 123
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }
    
    // MARK: - Case Sensitivity Tests
    
    func test_execute_handles_case_insensitive_consent_status() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.name: [
                FirebaseConstants.SetConsent.Param.adStorage: "GRANTED"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
}
