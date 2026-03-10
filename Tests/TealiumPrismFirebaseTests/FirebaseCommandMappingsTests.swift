//
//  FirebaseCommandMappingsTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 13/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

/// Tests for all Firebase command mappings (LogEvent, SetUserId, SetUserProperty, etc.)
final class FirebaseCommandMappingsTests: FirebaseMappingsTestBase {

    // MARK: - InitiateConversionMeasurement Command Tests

    func test_initiateConversionMeasurement_with_email() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "email": "user@example.com"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.initiateConversionMeasurement)
            mappings.mapFrom("email", to: .conversionEmail)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.initiateConversionMeasurement.rawValue,
            FirebaseDestination.conversionEmail.renderedPath: "user@example.com"
        ])
    }

    func test_initiateConversionMeasurement_with_phone() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "phone": "+1234567890"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.initiateConversionMeasurement)
            mappings.mapFrom("phone", to: .conversionPhone)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.initiateConversionMeasurement.rawValue,
            FirebaseDestination.conversionPhone.renderedPath: "+1234567890"
        ])
    }

    func test_initiateConversionMeasurement_with_hashed_email() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "hashed_email": "abc123hash"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.initiateConversionMeasurement)
            mappings.mapFrom("hashed_email", to: .conversionHashedEmail)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.initiateConversionMeasurement.rawValue,
            FirebaseDestination.conversionHashedEmail.renderedPath: "abc123hash"
        ])
    }

    func test_initiateConversionMeasurement_with_hashed_phone() {
        let dispatch = Dispatch(name: "conversion", type: .event, data: [
            "hashed_phone": "xyz789hash"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.initiateConversionMeasurement)
            mappings.mapFrom("hashed_phone", to: .conversionHashedPhone)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.initiateConversionMeasurement.rawValue,
            FirebaseDestination.conversionHashedPhone.renderedPath: "xyz789hash"
        ])
    }

    // MARK: - LogEvent Command Tests

    func test_logEvent_basic_mapping() {
        let dispatch = Dispatch(name: "screen_view", type: .event)

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue,
            FirebaseDestination.eventName.renderedPath: "screen_view"
        ])
    }

    func test_logEvent_with_parameters() {
        let dispatch = Dispatch(name: "purchase", type: .event, data: [
            "total": 99.99,
            "currency": "USD"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
            mappings.mapFrom("total", to: .eventParam(.value))
            mappings.mapFrom("currency", to: .eventParam(.currency))
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue,
            FirebaseDestination.eventName.renderedPath: "purchase",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.value.value: 99.99,
                FirebaseEventParameter.currency.value: "USD"
            ] as DataObject
        ])
    }

    func test_logEvent_with_items() {
        let dispatch = Dispatch(name: "view_item_list", type: .event, data: [
            "item_id": ["SKU001", "SKU002"],
            "item_name": ["Widget", "Gadget"]
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
            mappings.mapFrom("item_id", to: .itemParam(.itemId))
            mappings.mapFrom("item_name", to: .itemParam(.itemName))
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue,
            FirebaseDestination.eventName.renderedPath: "view_item_list",
            FirebaseDestination.eventParams.renderedPath: [
                FirebaseEventParameter.items.value: [
                    FirebaseItemParameter.itemId.value: ["SKU001", "SKU002"],
                    FirebaseItemParameter.itemName.value: ["Widget", "Gadget"]
                ] as DataObject
            ] as DataObject
        ])
    }

    func test_logEvent_with_bulk_parameters_dictionary() {
        let dispatch = Dispatch(name: "custom_event", type: .event, data: [
            "event_params": [
                "screen_name": "Home",
                "user_type": "premium",
                "session_count": 5
            ] as DataObject
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.logEvent)
            mappings.mapFrom(TealiumDataKey.event, to: .eventName)
            mappings.mapFrom("event_params", to: .eventParams)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.logEvent.rawValue,
            FirebaseDestination.eventName.renderedPath: "custom_event",
            FirebaseDestination.eventParams.renderedPath: [
                "screen_name": "Home",
                "user_type": "premium",
                "session_count": 5
            ] as DataObject
        ])
    }

    // MARK: - ResetData Command Tests

    func test_resetData_basic_mapping() {
        let dispatch = Dispatch(name: "delete_data", type: .event)

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.resetData)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.resetData.rawValue
        ])
    }

    // MARK: - SetAnalyticsCollectionEnabled Command Tests

    func test_setAnalyticsCollectionEnabled_basic_mapping() {
        let dispatch = Dispatch(name: "toggle_analytics", type: .event, data: [
            "enabled": true
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setAnalyticsCollectionEnabled)
            mappings.mapFrom("enabled", to: .analyticsEnabled)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setAnalyticsCollectionEnabled.rawValue,
            FirebaseDestination.analyticsEnabled.renderedPath: true
        ])
    }

    // MARK: - SetConsent Command Tests

    func test_setConsent_all_consent_types() {
        let dispatch = Dispatch(name: "consent_update", type: .event, data: [
            "analytics": "granted",
            "ad": "denied",
            "ad_user": "granted",
            "ad_personalization": "denied"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setConsent)
            mappings.mapFrom("analytics", to: .consentSetting(.analyticsStorage))
            mappings.mapFrom("ad", to: .consentSetting(.adStorage))
            mappings.mapFrom("ad_user", to: .consentSetting(.adUserData))
            mappings.mapFrom("ad_personalization", to: .consentSetting(.adPersonalization))
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setConsent.rawValue,
            FirebaseDestination.consentSettings.renderedPath: [
                ConsentType.analyticsStorage.key: "granted",
                ConsentType.adStorage.key: "denied",
                ConsentType.adUserData.key: "granted",
                ConsentType.adPersonalization.key: "denied"
            ] as DataObject
        ])
    }

    // MARK: - SetDefaultParameters Command Tests

    func test_setDefaultParameters_basic_mapping() {
        let dispatch = Dispatch(name: "set_defaults", type: .event, data: [
            "version": "2.0",
            "env": "prod"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setDefaultParameters)
            mappings.mapFrom("version", to: .defaultParam("app_version"))
            mappings.mapFrom("env", to: .defaultParam("environment"))
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setDefaultParameters.rawValue,
            FirebaseDestination.defaultParams.renderedPath: [
                "app_version": "2.0",
                "environment": "prod"
            ] as DataObject
        ])
    }

    func test_setDefaultParameters_with_bulk_parameters_dictionary() {
        let dispatch = Dispatch(name: "set_defaults", type: .event, data: [
            "default_params": [
                "app_version": "2.0",
                "environment": "production",
                "feature_flag_enabled": true
            ] as DataObject
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setDefaultParameters)
            mappings.mapFrom("default_params", to: .defaultParams)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setDefaultParameters.rawValue,
            FirebaseDestination.defaultParams.renderedPath: [
                "app_version": "2.0",
                "environment": "production",
                "feature_flag_enabled": true
            ] as DataObject
        ])
    }

    // MARK: - SetSessionTimeout Command Tests

    func test_setSessionTimeout_basic_mapping() {
        let dispatch = Dispatch(name: "update_timeout", type: .event, data: [
            "timeout": 3600
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setSessionTimeout)
            mappings.mapFrom("timeout", to: .sessionTimeout)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setSessionTimeout.rawValue,
            FirebaseDestination.sessionTimeout.renderedPath: 3600
        ])
    }

    // MARK: - SetUserId Command Tests

    func test_setUserId_basic_mapping() {
        let dispatch = Dispatch(name: "login", type: .event, data: ["customer_id": "USER_123"])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setUserId)
            mappings.mapFrom("customer_id", to: .userId)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setUserId.rawValue,
            FirebaseDestination.userId.renderedPath: "USER_123"
        ])
    }

    // MARK: - SetUserProperty Command Tests (Multiple Properties)

    func test_setUserProperties_basic_mapping() {
        let dispatch = Dispatch(name: "bulk_props", type: .event, data: [
            "prop_names": ["tier", "level", "status"],
            "prop_values": ["premium", "expert", "active"]
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setUserProperty)
            mappings.mapFrom("prop_names", to: .userPropertyName)
            mappings.mapFrom("prop_values", to: .userPropertyValue)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setUserProperty.rawValue,
            FirebaseDestination.userPropertyName.renderedPath: ["tier", "level", "status"],
            FirebaseDestination.userPropertyValue.renderedPath: ["premium", "expert", "active"]
        ])
    }

    // MARK: - SetUserProperty Command Tests

    func test_setUserProperty_basic_mapping() {
        let dispatch = Dispatch(name: "set_tier", type: .event, data: [
            "prop_name": "membership_tier",
            "prop_value": "premium"
        ])

        let result = map(dispatch: dispatch) { mappings in
            mappings.mapCommand(.setUserProperty)
            mappings.mapFrom("prop_name", to: .userPropertyName)
            mappings.mapFrom("prop_value", to: .userPropertyValue)
        }

        XCTAssertEqual(result.payload, [
            FirebaseConstants.commandName: FirebaseCommand.setUserProperty.rawValue,
            FirebaseDestination.userPropertyName.renderedPath: "membership_tier",
            FirebaseDestination.userPropertyValue.renderedPath: "premium"
        ])
    }
}
