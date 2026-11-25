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

    func test_execute_without_consent_data_throws_missing() {
        let payload: DataObject = [:]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .missing(key: "consent_settings"))
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    func test_execute_with_empty_consent_settings_throws_empty() {
        let payload: DataObject = [
            "consent_settings": [:] as DataObject
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "consent_settings"))
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    func test_execute_with_non_dictionary_consent_settings_throws_type_mismatch() {
        let payload: DataObject = [
            "consent_settings": "granted"
        ]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let extractionError = error as? ExtractionError,
                  case .typeMismatch(let key, _) = extractionError else {
                XCTFail("Expected typeMismatch error but got \(error)")
                return
            }
            XCTAssertEqual(key, "consent_settings")
        }
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    // MARK: - Single Consent Type Tests

    func test_execute_sets_ad_storage_granted() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setConsentCount, 1)
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
        XCTAssertEqual(mockFirebase.setConsentCount, 1)

        let consentSettings = try XCTUnwrap(mockFirebase.lastConsentSettings)
        XCTAssertEqual(consentSettings.count, 4)
        XCTAssertEqual(consentSettings[.adStorage], .granted)
        XCTAssertEqual(consentSettings[.analyticsStorage], .granted)
        XCTAssertEqual(consentSettings[.adUserData], .denied)
        XCTAssertEqual(consentSettings[.adPersonalization], .denied)
    }

    // MARK: - Invalid Values Tests

    func test_execute_throws_invalid_value_for_unknown_consent_type() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: "granted",
                "functional_storage": "granted"
            ] as DataObject
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .invalidValue(
                key: "consent_settings.functional_storage",
                reason: "unknown consent type, expected one of ad_personalization, ad_storage, ad_user_data, analytics_storage"
            )
        )
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    func test_execute_throws_invalid_value_for_unknown_consent_status() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: "granted",
                ConsentType.analyticsStorage.rawValue: "pending"
            ] as DataObject
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .invalidValue(key: "consent_settings.analytics_storage", reason: "expected one of denied, granted")
        )
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    func test_execute_throws_invalid_value_for_non_string_value() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: 123
            ] as DataObject
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .invalidValue(key: "consent_settings.ad_storage", reason: "expected one of denied, granted")
        )
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    func test_execute_throws_empty_for_blank_status() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: " "
            ] as DataObject
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "consent_settings.ad_storage"))
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    func test_execute_throws_missing_for_null_status() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: DataItem.null
            ] as DataObject
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .missing(key: "consent_settings.ad_storage"))
        XCTAssertEqual(mockFirebase.setConsentCount, 0)
    }

    func test_execute_trims_consent_status() {
        let payload: DataObject = [
            "consent_settings": [
                ConsentType.adStorage.rawValue: " granted\n"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
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

    func test_execute_handles_case_insensitive_consent_type() {
        let payload: DataObject = [
            "consent_settings": [
                "AD_STORAGE": "granted"
            ] as DataObject
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.setConsentCount, 1)
        XCTAssertEqual(mockFirebase.lastConsentSettings?[.adStorage], .granted)
    }
}
