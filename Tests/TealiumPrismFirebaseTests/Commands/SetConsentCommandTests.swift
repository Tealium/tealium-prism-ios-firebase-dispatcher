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

    let mockFirebase = MockFirebaseAnalytics()
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
            FirebaseDestination.consentSettings.path: [
                ConsentType.adStorage.key: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setConsentCalled)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }

    func test_execute_sets_ad_storage_denied() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                ConsentType.adStorage.key: "denied"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .denied)
    }

    func test_execute_sets_analytics_storage_granted() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                ConsentType.analyticsStorage.key: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.analyticsStorage], .granted)
    }

    func test_execute_sets_ad_user_data_granted() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                ConsentType.adUserData.key: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adUserData], .granted)
    }

    func test_execute_sets_ad_personalization_granted() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                ConsentType.adPersonalization.key: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adPersonalization], .granted)
    }

    // MARK: - Multiple Consent Types Tests

    func test_execute_sets_multiple_consent_types() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                ConsentType.adStorage.key: "granted",
                ConsentType.analyticsStorage.key: "granted",
                ConsentType.adUserData.key: "denied",
                ConsentType.adPersonalization.key: "denied"
            ] as DataObject
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
            FirebaseDestination.consentSettings.path: [
                ConsentType.adStorage.key: "granted",
                "invalid_type": "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
    }

    func test_execute_ignores_invalid_consent_status() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                ConsentType.adStorage.key: "granted",
                ConsentType.analyticsStorage.key: "invalid_status"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 1)
    }

    func test_execute_throws_error_when_all_values_are_invalid() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                "invalid_type": "granted",
                "another_invalid": "denied"
            ] as DataObject
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
            FirebaseDestination.consentSettings.path: [
                ConsentType.adStorage.key: 123
            ] as DataObject
        ]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is FirebaseCommandError)
        }
        XCTAssertFalse(mockFirebase.setConsentCalled)
    }

    // MARK: - Case Sensitivity Tests

    func test_execute_handles_case_insensitive_consent_status() {
        let payload: DataObject = [
            FirebaseDestination.consentSettings.path: [
                ConsentType.adStorage.key: "GRANTED"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
}
