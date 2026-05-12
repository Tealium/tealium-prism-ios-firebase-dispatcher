//
//  FirebaseDestinationTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 08/05/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
import FirebaseAnalytics
import XCTest

final class FirebaseDestinationTests: XCTestCase {

    func test_event_destinations_match_spec_paths() {
        XCTAssertEqual(FirebaseDestination.eventName.path.render(), "event_name")
        XCTAssertEqual(FirebaseDestination.eventParams.path.render(), "parameters")
        XCTAssertEqual(FirebaseDestination.eventParam(AnalyticsParameterValue).path.render(), "parameters.value")
        XCTAssertEqual(FirebaseDestination.itemParam(AnalyticsParameterItemID).path.render(), "parameters.items.item_id")
    }

    func test_user_destinations_match_spec_paths() {
        XCTAssertEqual(FirebaseDestination.userId.path.render(), "user_id")
        XCTAssertEqual(FirebaseDestination.userPropertyName.path.render(), "property_name")
        XCTAssertEqual(FirebaseDestination.userPropertyValue.path.render(), "property_value")
    }

    func test_default_params_destinations_match_spec_paths() {
        XCTAssertEqual(FirebaseDestination.defaultParams.path.render(), "parameters")
        XCTAssertEqual(FirebaseDestination.defaultParam("app_version").path.render(), "parameters.app_version")
    }

    func test_consent_destinations_use_string_raw_values() {
        XCTAssertEqual(FirebaseDestination.consentSettings.path.render(), "consent_settings")
        XCTAssertEqual(FirebaseDestination.consentSetting(.adStorage).path.render(), "consent_settings.ad_storage")
        XCTAssertEqual(FirebaseDestination.consentSetting(.analyticsStorage).path.render(), "consent_settings.analytics_storage")
        XCTAssertEqual(FirebaseDestination.consentSetting(.adUserData).path.render(), "consent_settings.ad_user_data")
        XCTAssertEqual(FirebaseDestination.consentSetting(.adPersonalization).path.render(), "consent_settings.ad_personalization")
    }

    func test_config_destinations_match_spec_paths() {
        XCTAssertEqual(FirebaseDestination.sessionTimeout.path.render(), "session_timeout_seconds")
        XCTAssertEqual(FirebaseDestination.analyticsEnabled.path.render(), "analytics_collection_enabled")
    }

    func test_conversion_destinations_match_spec_paths() {
        XCTAssertEqual(FirebaseDestination.conversionEmail.path.render(), "email_address")
        XCTAssertEqual(FirebaseDestination.conversionPhone.path.render(), "phone_number")
        XCTAssertEqual(FirebaseDestination.conversionHashedEmail.path.render(), "hashed_email_address")
        XCTAssertEqual(FirebaseDestination.conversionHashedPhone.path.render(), "hashed_phone_number")
    }
}
