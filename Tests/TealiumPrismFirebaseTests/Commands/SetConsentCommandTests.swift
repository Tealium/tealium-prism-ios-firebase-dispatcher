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
    
    let mockFirebase = MockFirebaseCommand()
    lazy var command = SetConsentCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests
    
    func test_execute_without_consent_data_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .noValidConsentSettings = commandError else {
                XCTFail("Expected noValidConsentSettings error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }
    
    // MARK: - Single Consent Type Tests
    
    func test_execute_sets_ad_storage_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adStorage: "granted"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setConsentCalled)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
    
    func test_execute_sets_ad_storage_denied() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adStorage: "denied"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .denied)
    }
    
    func test_execute_sets_analytics_storage_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.analyticsStorage: "granted"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.analyticsStorage], .granted)
    }
    
    func test_execute_sets_ad_user_data_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adUserData: "granted"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adUserData], .granted)
    }
    
    func test_execute_sets_ad_personalization_granted() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adPersonalization: "granted"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adPersonalization], .granted)
    }
    
    // MARK: - Multiple Consent Types Tests
    
    func test_execute_sets_multiple_consent_types() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adStorage: "granted",
            FirebaseConstants.SetConsent.Param.analyticsStorage: "granted",
            FirebaseConstants.SetConsent.Param.adUserData: "denied",
            FirebaseConstants.SetConsent.Param.adPersonalization: "denied"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
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
            FirebaseConstants.SetConsent.Param.adStorage: "granted",
            "invalid_type": "granted"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
    }
    
    func test_execute_ignores_invalid_consent_status() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adStorage: "granted",
            FirebaseConstants.SetConsent.Param.analyticsStorage: "invalid_status"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
    }
    
    func test_execute_throws_error_when_all_values_are_invalid() {
        let payload: DataObject = [
            "invalid_type": "granted",
            "another_invalid": "denied"
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .noValidConsentSettings = commandError else {
                XCTFail("Expected noValidConsentSettings error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }
    
    func test_execute_throws_error_for_non_string_value() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adStorage: 123
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is FirebaseCommandError)
        }
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }
    
    // MARK: - Case Sensitivity Tests
    
    func test_execute_handles_case_insensitive_consent_status() {
        let payload: DataObject = [
            FirebaseConstants.SetConsent.Param.adStorage: "GRANTED"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
}
