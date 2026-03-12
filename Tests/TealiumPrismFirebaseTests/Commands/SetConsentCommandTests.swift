//
//  SetConsentCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseAnalytics
@testable import TealiumPrismCore
@testable import TealiumPrismFirebase
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
            "consent_settings": [
                ConsentType.adStorage.rawValue: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setConsentCalled)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }

    func test_execute_sets_ad_storage_denied() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: "denied"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .denied)
    }

    func test_execute_sets_analytics_storage_granted() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.analyticsStorage.rawValue: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.analyticsStorage], .granted)
    }

    func test_execute_sets_ad_user_data_granted() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adUserData.rawValue: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adUserData], .granted)
    }

    func test_execute_sets_ad_personalization_granted() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adPersonalization.rawValue: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adPersonalization], .granted)
    }

    // MARK: - Multiple Consent Types Tests

    func test_execute_sets_multiple_consent_types() throws {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: "granted",
                ConsentType.analyticsStorage.rawValue: "granted",
                ConsentType.adUserData.rawValue: "denied",
                ConsentType.adPersonalization.rawValue: "denied"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setConsentCalled)

        let consentSettings = try XCTUnwrap(mockFirebase.lastConsentSettings)
        XCTAssertEqual(consentSettings.count, 4)
        XCTAssertEqual(consentSettings[.adStorage], .granted)
        XCTAssertEqual(consentSettings[.analyticsStorage], .granted)
        XCTAssertEqual(consentSettings[.adUserData], .denied)
        XCTAssertEqual(consentSettings[.adPersonalization], .denied)
    }

    // MARK: - Invalid Values Tests

    func test_execute_forwards_unknown_consent_type() {
        // ConsentType is RawRepresentable — unknown keys should be forwarded to Firebase
        // rather than silently dropped, so future Firebase types work without SDK updates.
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: "granted",
                "functional_storage": "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 2)
    }

    func test_execute_forwards_unknown_consent_status() {
        // ConsentStatus is RawRepresentable — unknown status strings should be forwarded
        // to Firebase rather than silently dropped, so future statuses work without SDK updates.
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: "granted",
                ConsentType.analyticsStorage.rawValue: "pending"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?.count, 2)
    }

    func test_execute_throws_error_for_non_string_value() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: 123
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
            "consent_settings": [
                ConsentType.adStorage.rawValue: "GRANTED"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
}
